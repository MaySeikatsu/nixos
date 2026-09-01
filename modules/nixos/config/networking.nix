{...}: {
  services = {
    cloudflared = {
      enable = true;

      tunnels."2b9aee76-6085-4819-9792-68258ec239bc" = {
        credentialsFile = "/var/lib/cloudflared/photo-share.json";
        default = "http_status:404";
        ingress."sailwithus.mayseikatsu.com" = "http://localhost:3923";
      };
    };

    tailscale = {
      enable = true;
      extraDaemonFlags = ["--no-logs-no-support"];
      extraSetFlags = ["--ssh"];
    };
  };
  networking = {
    # Enable Firewall and NetworkManager
    networkmanager.enable = true; # Enable networking
    firewall = {
      enable = true;
      # Tell the firewall to implicitly trust packets routed over Tailscale:
      # Note: wayvnc binds 0.0.0.0 but no port is opened here, so it is reachable
      # only via loopback + tailscale0 (trusted above). To also allow non-tailscale
      # devices on the LAN, add e.g. allowedTCPPorts = [ 5900 ] (exposes it on all
      # interfaces) or scope per-interface with firewall.interfaces.<iface>.
      trustedInterfaces = ["tailscale0"];
    };
  };
}
