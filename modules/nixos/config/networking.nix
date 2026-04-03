{...}:{

  # Tell the firewall to implicitly trust packets routed over Tailscale:
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Enable Firewal and NetworkManager
  networking.networkmanager.enable = true; # Enable networking
  networking.firewall.enable = true;

}
