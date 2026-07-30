{
  config,
  pkgs,
  lib,
  ...
}: let
  keyDir = "${config.xdg.configHome}/wayvnc";
  rsaKey = "${keyDir}/rsa_key.pem";
in {
  # VNC server, using home-manager's services.wayvnc module. This owns the
  # package, the ~/.config/wayvnc/config file, and the systemd user service.
  # niri runs a real systemd session (graphical-session.target is active with
  # WAYLAND_DISPLAY exported), so autoStart launches it reliably.
  #
  #   address 0.0.0.0 -> bound on all interfaces, BUT the firewall opens no port
  #                      (see modules/nixos/config/networking.nix), so in practice
  #                      it is reachable only via loopback + tailscale0 (trusted).
  #                      Nothing is exposed to the LAN or internet.
  #   enable_pam      -> authenticate with your system login (user `maike` +
  #                      password). Needs security.pam.services.wayvnc, which lives
  #                      in hosts/configuration-shared.nix (PAM is system-scoped).
  #   rsa_private_key -> nixpkgs' wayvnc uses the nettle crypto backend, so auth
  #                      is RSA-AES (not TLS/VeNCrypt). The key MUST be PKCS#1
  #                      ("BEGIN RSA PRIVATE KEY"); a PKCS#8 key makes wayvnc
  #                      segfault on startup. See the keygen below.
  #
  # Connect over tailscale (works even on the same wifi) with an RSA-AES-capable
  # client — TigerVNC viewer is the safe choice:
  #   vncviewer <this-host-tailscale-ip-or-MagicDNS-name>:5900
  # then log in as `maike` with your system password.
  services.wayvnc = {
    enable = true;
    autoStart = true;
    settings = {
      address = "0.0.0.0";
      port = 5900;
      enable_auth = true;
      enable_pam = true;
      rsa_private_key_file = rsaKey;
    };
  };

  # Restart if it crashes (the module only sets ExecStart).
  systemd.user.services.wayvnc.Service = {
    Restart = "on-failure";
    RestartSec = 3;
  };

  # Generate the RSA-AES key once, in PKCS#1 form (`openssl genrsa` on recent
  # openssl defaults to PKCS#8, which crashes wayvnc — so force -traditional).
  # Self-healing: regenerates if the file is missing OR not PKCS#1. Runs before
  # sd-switch (re)starts the wayvnc unit, so the key is in place first.
  home.activation.wayvncKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
    keydir="${keyDir}"
    run mkdir -p "$keydir"
    run chmod 700 "$keydir"
    if ! ${pkgs.gnugrep}/bin/grep -q "BEGIN RSA PRIVATE KEY" "${rsaKey}" 2>/dev/null; then
      run ${pkgs.openssl}/bin/openssl genrsa -traditional -out "${rsaKey}" 2048
    fi
    run chmod 600 "${rsaKey}"
  '';
}
