{config, ...}: let
  on = config.my.virtualisation.enable; # toggle: modules/nixos/profiles.nix
in {
  # Enable VMware virtualisation straight out of nixos
  # virtualisation.vmware.host.enable = true; #needs to be added manually to nix store
  programs.virt-manager.enable = on;

  users = {
    groups = {
      libvirtd.members = ["maike"];
      nixosvmtest = {};
    };
    # Settings for build to VM / Virtualisation
    users = {
      nixosvmtest = {
        isSystemUser = true;
        initialPassword = "test";
        group = "nixosvmtest";
      };
    };
  };

  virtualisation = {
    docker.enable = on;
    podman.enable = on;
    libvirtd.enable = on;
    spiceUSBRedirection.enable = on;
    vmVariant = {
      # following configuration is added only when building VM with build-vm
      virtualisation = {
        cores = 8;
        memorySize = 8192; # Use 2048MiB memory.
        resolution = {
          x = 1920;
          y = 1080;
        };
      };
    };
  };
}
