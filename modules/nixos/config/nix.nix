{ pkgs, config, ...}:{
# Use LIX instead of official NIX Package Manager
  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings.experimental-features = ["nix-command" "flakes"]; # Enable flake support

    # Local builds (CUDA packages, Blender, kernels) used to run up to
    # 12 jobs x all cores at once: heavy C++ (OpenUSD, Blender) needs 1-2.5 GB
    # per compiler, so the PC ran out of RAM and thrashed swap, which is slower
    # than building with fewer jobs. 2 jobs x 4 cores caps it at 8 compilers.
    # Downloads from the cache are unaffected (separate max-substitution-jobs).
    settings.max-jobs = 2;
    settings.cores = 4;
    # Builds only get CPU/disk time nothing else wants: the desktop stays
    # responsive during a rebuild, which simply takes longer while you work.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
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
