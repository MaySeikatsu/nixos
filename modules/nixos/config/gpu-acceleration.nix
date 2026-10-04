# VA-API video decoding (browsers, mpv, ...) on desktops whose only GPU is
# NVIDIA, via nvidia-vaapi-driver (installed by hardware.nvidia's
# videoAcceleration). PRIME laptops keep decoding on the iGPU: cheaper on
# battery, and the iGPU drives the display anyway. Zen's side of this is in
# modules/home-manager/ui/browsers.nix. (Blender's CUDA build lives in
# graphics.nix.)
{
  config,
  lib,
  pkgs,
  ...
}: let
  nvidia = config.hardware.nvidia;
  nvidiaOnly =
    lib.elem "nvidia" config.services.xserver.videoDrivers
    && !nvidia.prime.offload.enable
    && !nvidia.prime.sync.enable;
in {
  environment.systemPackages = [
    pkgs.libva-utils # `vainfo`: lists what the GPU can decode
  ];

  environment.sessionVariables = lib.mkIf nvidiaOnly {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct"; # the EGL backend is broken on current drivers
    # Firefox-based browsers decode in the RDD process, whose sandbox blocks
    # the NVIDIA driver's device files. Caveat: loosens that one sandbox.
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };
}
