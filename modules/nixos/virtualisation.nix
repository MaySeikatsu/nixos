{ ... }: {

  virtualisation.docker.enable = true;

  #Enable VMware virtualisation straight out of nixos
  # virtualisation.vmware.host.enable = true; #needs to be added manually to nix store
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "maike" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Settings for build to VM / Virtualisation
  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = { };
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      resolution = {
        x = 1920;
        y = 1080;
      };
      memorySize = 8192; # Use 2048MiB memory.
      cores = 8;
    };
  };
}
