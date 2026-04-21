{ pkgs, config, ...}:{
# Use LIX instead of official NIX Package Manager
  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings.experimental-features = ["nix-command" "flakes"]; # Enable flake support
  };

  nixpkgs.config = {
    allowUnfree = true; # Allow unfree packages
    allowUnsupportedSystem = true; # Allow unsupported SystemPackages
# Call packages from a stable nix release in pkgs with stable.packageName
    # packageOverrides = pkgs: {
    #   stable = import <nixos-25.11>{
    #       config = config.nixpkgs.config;
    #     };
    # };
  };

# Garbage Collection and Store Optimisations:
  # Nixos Helper for cleanup and commands
  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 7";
      flake = "/home/maike/.config/nixos"; # might need adjustment to different hosts
    };
  };
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 15d";
  # };

  # Storage Optimisations between different nix stores:
  nix.optimise = {
    automatic = true;
    dates = ["03:45"];
  };
  # nix.settings.auto-optimise-store = true; # This would execute the optimisations on rebuild, does slow them down significantly though

# Added to avoid rebuild issues after flake update:
  # nix.settings.download-buffer-size = 524288000; # 500MB
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = 1048576;
  # Increase system-wide file descriptor limit
  boot.kernel.sysctl = {"fs.file-max" = 524288;};

  # Increase limits for all users (including systemd services)
  # security.pam.loginLimits = [
  #   { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
  #   { domain = "*"; type = "hard"; item = "nofile"; value = "524288"; }
  # ];
}
