# Odysseus (github.com/odysseus-dev/odysseus, AGPL-3.0): self-hosted AI
# workspace - chat, agents with tools/MCP, deep research, documents, email,
# notes, tasks/calendar, model "Cookbook". Uses the local Ollama; OpenAI /
# Anthropic keys can be added in its settings.
#
#   http://127.0.0.1:7000   first admin password: `sudo docker logs odysseus`
#   tailnet: https://<host>.<tailnetDomain>:7443 or http://<host>:7000
#            (tailscale serve, see my.tailscaleServe)
#
# Upstream ships it as a docker-compose stack and never merged its Nix PRs,
# so this mirrors the upstream compose (main branch, image 1.0.3) as
# declarative containers: the app, ChromaDB (vector store) and ntfy (push
# notifications). Web search uses the standalone SearXNG service
# (modules/nixos/config/searxng.nix) instead of upstream's SearXNG container.
# The app uses host networking to reach Ollama, which listens on 127.0.0.1
# only; the helpers publish their ports on 127.0.0.1. Everything stays local.
#
# LLMs run in the host Ollama (on the GPU), never inside the container. The
# container itself also gets the NVIDIA GPU, for the Cookbook features that
# run in-process (diffusers, SAM masks, rembg, Real-ESRGAN, whisper); their
# Python packages are installed declaratively (pythonPackages below).
#
# Image generation: Odysseus only speaks the OpenAI images API
# (/v1/images/generations), which ComfyUI and A1111 don't offer, so they
# can't be its generator (A1111 only serves as an img2img fallback for
# edits). Local generation = Cookbook -> Image -> serve a Diffusers model:
# runs scripts/diffusion_server.py in the container on the GPU, port 8100.
#
# Update: bump the image tags/digest below (tags: ghcr.io/odysseus-dev/odysseus).
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.odysseus;
  dir = "${ai.dataDir}/odysseus";
  gpu = config.hardware.nvidia-container-toolkit.enable;

  # Optional Python packages, installed by `odysseus-python-deps` (below) the
  # way the Cookbook's Install buttons do it: `pip install --user` into
  # /app/.local, which is persisted in the data dir.
  pipSpec = builtins.toJSON {
    torch = ai.torchIndexUrl;
    inherit (cfg) pythonPackages;
  };
  pipStamp = "${dir}/data/local/.nixos-python-deps";
in {
  options.my.ai.odysseus = {
    enable = lib.mkEnableOption "Odysseus AI workspace" // {default = ai.enable;};
    tailnetDomain = lib.mkOption {
      type = lib.types.str;
      default = "tail8d63ed.ts.net";
      description = "Tailscale MagicDNS suffix (tailscale status --json | jq .MagicDNSSuffix).";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the stack at boot (needed for reminders, scheduled agent tasks
        and email polling). Costs ~1-1.5 GB RAM while running; otherwise start
        it with `sudo systemctl start docker-odysseus`.
      '';
    };
    pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # Cookbook -> Dependencies (Linux/NVIDIA entries) + upstream's
      # requirements-optional.txt. kokoro TTS is left out: no Python 3.14
      # support yet (the image runs 3.14). Each string is one pip call.
      default = [
        "diffusers[torch] accelerate scipy python-multipart transformers pillow" # local image gen/editing, SAM masks
        "rembg[gpu]" # background removal
        "realesrgan" # denoise + upscale (basicsr/gfpgan ship in the image)
        "playwright" # browser automation for web tools
        "faster-whisper" # speech to text
        "ddgs" # DuckDuckGo search fallback
        "PyMuPDF" # PDF reading
        "markitdown[docx,pptx,xlsx,xls]==0.1.6" # Office documents -> text
      ];
      description = ''
        pip requirement groups installed into the container's persisted user
        site. torch + torchvision come first, from my.ai.torchIndexUrl (CUDA
        build matching the GPU; PyPI's torch has no Pascal kernels).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "my.ai.odysseus runs on Docker: keep my.virtualisation enabled or disable my.ai.odysseus.";
      }
    ];

    # tailnet access (the app itself listens on 127.0.0.1 only)
    my.tailscaleServe = [
      "--https=7443 http://127.0.0.1:7000"
      "--http=7000 http://127.0.0.1:7000"
    ];

    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      odysseus = {
        image = "ghcr.io/odysseus-dev/odysseus:1.0.3@sha256:4aa6e607d2108bd7b5f37ee1a0841dc56e6bbac36e9ccd5e1705aff7ea36fb04";
        inherit (cfg) autoStart;
        dependsOn = ["odysseus-chromadb"];
        # upstream binds 0.0.0.0; with host networking that is every host
        # interface. Loopback only; the tailnet goes through tailscale serve.
        cmd = ["uvicorn" "app:app" "--host" "127.0.0.1" "--port" "7000"];
        volumes = [
          "${dir}/data:/app/data"
          "${dir}/logs:/app/logs"
          "${dir}/data/ssh:/app/.ssh"
          "${dir}/data/huggingface:/app/.cache/huggingface"
          "${dir}/data/local:/app/.local"
        ];
        environment = {
          OLLAMA_BASE_URL = "http://127.0.0.1:11434";
          LLM_HOST = "localhost";
          # the standalone SearXNG service (modules/nixos/config/searxng.nix)
          SEARXNG_INSTANCE = lib.optionalString config.my.searxng.enable "http://127.0.0.1:8080";
          CHROMADB_HOST = "127.0.0.1";
          # not 8100: with host networking that is where the Cookbook serves
          # diffusers image models by default
          CHROMADB_PORT = "8110";
          DATABASE_URL = "sqlite:///./data/app.db";
          AUTH_ENABLED = "true";
          # must stay false: tailnet requests arrive via tailscale serve,
          # i.e. from 127.0.0.1
          LOCALHOST_BYPASS = "false";
          # browser origins allowed to talk to the API: local, plus the tailnet
          # (direct http on :7000, and https via `tailscale serve` on :7443)
          ALLOWED_ORIGINS = lib.concatStringsSep "," [
            "http://localhost:7000"
            "http://127.0.0.1:7000"
            "http://${config.networking.hostName}:7000"
            "http://${config.networking.hostName}.${cfg.tailnetDomain}:7000"
            "https://${config.networking.hostName}.${cfg.tailnetDomain}:7443"
          ];
          FASTEMBED_MODEL = "sentence-transformers/all-MiniLM-L6-v2";
          # files in the data dir stay owned by the desktop user
          PUID = toString (
            if config.users.users.${ai.user}.uid != null
            then config.users.users.${ai.user}.uid
            else 1000 # first normal user; uid isn't pinned in this config
          );
          PGID = toString config.users.groups.users.gid;
        };
        extraOptions =
          ["--network=host"]
          # local diffusers, SAM, rembg, Real-ESRGAN, whisper run on the GPU
          ++ lib.optional gpu "--device=nvidia.com/gpu=all";
      };

      odysseus-chromadb = {
        image = "docker.io/chromadb/chroma:1.5.9";
        inherit (cfg) autoStart;
        ports = ["127.0.0.1:8110:8000"];
        volumes = ["${dir}/chromadb:/chroma/chroma"];
        environment.ANONYMIZED_TELEMETRY = "FALSE";
      };

      odysseus-ntfy = {
        image = "docker.io/binwiederhier/ntfy:v2.28.0";
        inherit (cfg) autoStart;
        cmd = ["serve"];
        ports = ["127.0.0.1:8091:80"];
        volumes = ["${dir}/ntfy:/var/cache/ntfy"];
        environment.NTFY_BASE_URL = "http://localhost:8091";
      };
    };

    # Runs whenever the container starts, but only calls pip when the package
    # list or torch index changed (stamp file). First run downloads several
    # GB (torch + CUDA libraries) and takes a while; Odysseus works meanwhile
    # and is restarted once at the end so it picks the packages up.
    # Progress: journalctl -fu odysseus-python-deps
    systemd.services.odysseus-python-deps = lib.mkIf (cfg.pythonPackages != []) {
      description = "Install Odysseus' optional Python packages";
      wantedBy = ["docker-odysseus.service"];
      after = ["docker-odysseus.service"];
      path = [config.virtualisation.docker.package];
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "2h";
      };
      script = ''
        spec=${lib.escapeShellArg pipSpec}
        if [ "$(cat ${pipStamp} 2>/dev/null)" = "$spec" ]; then exit 0; fi
        for _ in $(seq 60); do
          docker exec odysseus true 2>/dev/null && break
          sleep 2
        done
        install() {
          docker exec -u odysseus -e HOME=/app odysseus \
            python3 -m pip install --user --no-cache-dir --disable-pip-version-check "$@"
        }
        install --index-url ${lib.escapeShellArg ai.torchIndexUrl} torch torchvision
        failed=0
        ${lib.concatMapStrings (group: ''
            install ${lib.escapeShellArgs (lib.splitString " " group)} \
              || { echo "pip failed: ${lib.escapeShellArg group}" >&2; failed=1; }
          '')
          cfg.pythonPackages}
        if [ "$failed" = 1 ]; then exit 1; fi
        printf '%s' "$spec" > ${pipStamp}
        systemctl --no-block restart docker-odysseus.service
      '';
    };

    # bind-mount sources must exist before docker starts the containers
    systemd.tmpfiles.settings."10-odysseus" = lib.genAttrs [
      dir
      "${dir}/data"
      "${dir}/logs"
      "${dir}/chromadb"
      "${dir}/ntfy"
    ] (_: {d.user = ai.user;});
  };
}
