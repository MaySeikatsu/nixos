{...}:{

  services = {
    tailscale = {
      enable = true;
      extraDaemonFlags = ["--no-logs-no-support"];
    };
  };
  networking = {
    # Enable Firewall and NetworkManager
    networkmanager.enable = true; # Enable networking
    firewall = {
      enable = true;
      # Tell the firewall to implicitly trust packets routed over Tailscale:
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
