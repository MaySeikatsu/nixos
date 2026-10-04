# Speech-to-text with whisper.cpp (CUDA build, native Nix package).
#
#   whisper-cpp-download-ggml-model large-v3-turbo   # into the current dir
#   whisper-cli -m ggml-large-v3-turbo.bin -l auto -f audio.wav
#   whisper-server -m ggml-large-v3-turbo.bin        # OpenAI-style HTTP API
#
# large-v3-turbo (~1.6 GB) is the sweet spot for both GPUs; small/medium if
# VRAM is taken by something else.
{
  config,
  lib,
  pkgs,
  ...
}: let
  ai = config.my.ai;
  cfg = ai.stt;
in {
  options.my.ai.stt = {
    enable = lib.mkEnableOption "whisper.cpp speech-to-text" // {default = ai.enable;};

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.whisper-cpp.override {
        cudaSupport = true;
        inherit (pkgs) cudaPackages;
      };
      defaultText = lib.literalExpression "pkgs.whisper-cpp.override { cudaSupport = true; }";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
  };
}
