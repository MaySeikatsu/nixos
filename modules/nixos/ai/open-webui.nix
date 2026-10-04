# Open WebUI: ChatGPT-style web UI for the local stack.
#
#   http://127.0.0.1:3000   (the first account you create becomes admin)
#
# Wired to what's already running: Ollama for chat, ComfyUI for image
# generation (start ComfyUI first: `systemctl --user start comfyui`). Tools,
# MCP servers (via mcpo), RAG over documents and web search can be added in
# its admin settings. Native NixOS service (DynamicUser, state in
# /var/lib/open-webui); the frontend is compiled locally on first build.
{
  config,
  lib,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.openWebui;
in {
  options.my.ai.openWebui = {
    enable = lib.mkEnableOption "Open WebUI" // {default = ai.enable;};
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000; # 8080 (the module default) is Odysseus' SearXNG
    };
  };

  config = lib.mkIf cfg.enable {
    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      inherit (cfg) port;
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        ENABLE_OPENAI_API = "False"; # enable in settings if you add a cloud key
        # image generation through the local ComfyUI
        ENABLE_IMAGE_GENERATION = "True";
        IMAGE_GENERATION_ENGINE = "comfyui";
        COMFYUI_BASE_URL = "http://127.0.0.1:${toString ai.comfyui.port}";
        # no phoning home
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };
    };
  };
}
