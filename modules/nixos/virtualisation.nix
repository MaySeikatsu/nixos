{...}: {
  # Enable VMware virtualisation straight out of nixos
  # virtualisation.vmware.host.enable = true; #needs to be added manually to nix store
  programs.virt-manager.enable = true;

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
    docker.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
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
