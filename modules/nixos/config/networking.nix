{
  config,
  lib,
  ...
}: let
  serve = config.my.tailscaleServe;
in {
  # Local-only services (bound to 127.0.0.1) published on the tailnet via
  # `tailscale serve`, so they never sit on a LAN-facing socket. Each entry is
  # the argument list for one `tailscale serve --bg ...` call. The unit resets
  # the serve config first, so this list is the whole truth.
  #   inspect: tailscale serve status
  options.my.tailscaleServe = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    example = ["--https=7443 http://127.0.0.1:7000"];
    description = "Arguments for `tailscale serve --bg`, one entry per call.";
  };

  config = {
    services = {
      cloudflared = {
        enable = false;

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

    # wayvnc (home-manager) binds 127.0.0.1; reach it over the tailnet
    my.tailscaleServe = lib.mkIf (lib.any (u: u.services.wayvnc.enable or false)
      (lib.attrValues (config.home-manager.users or {})))
    ["--tcp=5900 tcp://127.0.0.1:5900"];

    systemd.services.tailscale-serve-local = lib.mkIf (serve != []) {
      description = "Publish local-only services on the tailnet (tailscale serve)";
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      path = [config.services.tailscale.package];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        tailscale wait
        tailscale serve reset
        ${lib.concatMapStrings (args: "tailscale serve --bg ${args}\n") serve}
      '';
    };

    networking = {
      # Enable Firewall and NetworkManager
      networkmanager.enable = true; # Enable networking
      firewall = {
        enable = true;
        # Tell the firewall to implicitly trust packets routed over Tailscale.
        # Services meant for the tailnet bind 127.0.0.1 and are published via
        # my.tailscaleServe (above), so nothing listens on the LAN by accident.
        # To allow non-tailscale LAN devices, scope per-interface with
        # firewall.interfaces.<iface>.allowedTCPPorts.
        trustedInterfaces = ["tailscale0"];
      };
    };
  };
}
