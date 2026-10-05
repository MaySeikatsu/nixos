# Odysseus (github.com/odysseus-dev/odysseus, AGPL-3.0): self-hosted AI
# workspace - chat, agents with tools/MCP, deep research, documents, email,
# notes, tasks/calendar, model "Cookbook". Uses the local Ollama; OpenAI /
# Anthropic keys can be added in its settings.
#
#   http://127.0.0.1:7000   first admin password: `sudo docker logs odysseus`
#
# Upstream ships it as a docker-compose stack and never merged its Nix PRs,
# so this mirrors the upstream compose (main branch, image 1.0.3) as
# declarative containers: the app, ChromaDB (vector store) and ntfy (push
# notifications). Web search uses the standalone SearXNG service
# (modules/nixos/config/searxng.nix) instead of upstream's SearXNG container.
# The app uses host networking to reach Ollama, which listens on 127.0.0.1
# only; the helpers publish their ports on 127.0.0.1. Everything stays local.
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
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "my.ai.odysseus runs on Docker: keep my.virtualisation enabled or disable my.ai.odysseus.";
      }
    ];

    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers = {
      odysseus = {
        image = "ghcr.io/odysseus-dev/odysseus:1.0.3@sha256:4aa6e607d2108bd7b5f37ee1a0841dc56e6bbac36e9ccd5e1705aff7ea36fb04";
        inherit (cfg) autoStart;
        dependsOn = ["odysseus-chromadb"];
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
          CHROMADB_PORT = "8100";
          DATABASE_URL = "sqlite:///./data/app.db";
          AUTH_ENABLED = "true";
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
        extraOptions = ["--network=host"];
      };

      odysseus-chromadb = {
        image = "docker.io/chromadb/chroma:1.5.9";
        inherit (cfg) autoStart;
        ports = ["127.0.0.1:8100:8000"];
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
