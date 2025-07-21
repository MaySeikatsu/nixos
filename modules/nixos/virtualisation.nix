{...}:{
  
  #Enable VMware virtualisation straight out of nixos
  # virtualisation.vmware.host.enable = true; #needs to be added manually to nix store
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["maike"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

}
