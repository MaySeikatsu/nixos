{
  config,
  pkgs,
  lib,
  ...
}: let
  keyDir = "${config.xdg.configHome}/wayvnc";
in {
  # VNC server, using home-manager's services.wayvnc module. This owns the
  # package, the ~/.config/wayvnc/config file, and the systemd user service.
  # niri runs a real systemd session (graphical-session.target is active with
  # WAYLAND_DISPLAY exported), so autoStart launches it reliably — no niri
  # spawn-at-startup needed.
  #
  #   address 0.0.0.0 -> bound on all interfaces, BUT the firewall only lets
  #                      loopback + tailscale0 through (no allowedTCPPorts), so
  #                      in practice it is reachable only locally and over the
  #                      tailnet. Nothing is exposed to the LAN or internet.
  #   enable_pam      -> authenticate with your system login (user `maike` +
  #                      password). Needs security.pam.services.wayvnc, which
  #                      lives in hosts/configuration-shared.nix (system-scoped;
  #                      home-manager cannot configure PAM).
  #   *_file          -> encryption keys, generated once below, kept out of the
  #                      world-readable nix store.
  #
  # Connect over tailscale (works even on the same wifi) with a VeNCrypt/RSA-AES
  # client (TigerVNC, remmina): <this-host-tailscale-ip-or-name>:5900
  services.wayvnc = {
    enable = true;
    autoStart = true;
    settings = {
      address = "0.0.0.0";
      port = 5900;
      enable_auth = true;
      enable_pam = true;
      private_key_file = "${keyDir}/tls_key.pem";
      certificate_file = "${keyDir}/tls_cert.pem";
      rsa_private_key_file = "${keyDir}/rsa_key.pem";
    };
  };

  # Restart if it crashes (the module only sets ExecStart).
  systemd.user.services.wayvnc.Service = {
    Restart = "on-failure";
    RestartSec = 3;
  };

  # wayvnc refuses to start with enable_auth unless the key files exist, so
  # generate them once on activation (idempotent: skipped when already present).
  # Runs before sd-switch (re)starts the wayvnc unit, so the keys are in place.
  home.activation.wayvncKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
    keydir="${keyDir}"
    run mkdir -p "$keydir"
    run chmod 700 "$keydir"
    if [ ! -f "$keydir/tls_key.pem" ]; then
      run ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout "$keydir/tls_key.pem" -out "$keydir/tls_cert.pem" \
        -days 3650 -subj "/CN=wayvnc"
    fi
    if [ ! -f "$keydir/rsa_key.pem" ]; then
      run ${pkgs.openssl}/bin/openssl genrsa -out "$keydir/rsa_key.pem" 2048
    fi
    run chmod 600 "$keydir"/tls_key.pem "$keydir"/tls_cert.pem "$keydir"/rsa_key.pem
  '';
}
