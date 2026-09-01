{
  description = "Nixos config flake";

  # Trusts chaotic-nyx's binary cache so cachyos kernel builds (see the
  # `chaotic` input below) are fetched pre-built instead of compiled locally.
  # `nixos-rebuild --flake` prompts to accept this on first use.
  nixConfig = {
    extra-substituters = ["https://chaotic-nyx.cachix.org/"];
    extra-trusted-public-keys = ["chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="];
  };

  inputs = {
    # Nixpkgs source and home-manager
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system76-scheduler-niri = {
      # url = "github:kirottu/system76-scheduler-niri";
      url = "github:mayseikatsu/system76-scheduler-niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake Inputs:
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    textfox = {
      url = "github:adriankarlen/textfox";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spotatui = {
      url = "github:mayseikatsu/spotatui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.home-manager.follows = "home-manager"; # stylix does not expose this input
    };
    niri = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tagstudio = {
      url = "github:TagStudioDev/TagStudio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fsel = {
      url = "github:mjoyufull/fsel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # noctalia = {
    #   url = "github:noctalia-dev/noctalia";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    monado-rift-wayland = {
      url = "github:MaySeikatsu/monado-rift-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelix-hm = {
      url = "github:luccahuguet/yazelix";
      # NOTE: deliberately *not* following our nixpkgs.
      # yazelix vendors yazi config files and hard-asserts the yazi version it
      # was built against (flake.nix: `assert pkgs.yazi-unwrapped.version == "26.5.6"`).
      # Our nixpkgs is already on yazi 26.8.15, so following it fails eval.
      # An overlay can't fix this: the assert reads yazelix's own `pkgs`, not ours.
      # Cost: a second nixpkgs instance for yazelix's stack, and yazelix's internal
      # yazi stays 26.5.6 while the system yazi is 26.8.15.
      # Pinned to yazelix's own locked nixpkgs (the one it asserts against);
      # leaving the input unpinned just re-resolves nixos-unstable to HEAD, which
      # is where the too-new yazi comes from in the first place.
      # Re-add `inputs.nixpkgs.follows = "nixpkgs";` (and drop this pin) once upstream
      # yazelix bumps the assertion to match nixpkgs' yazi -- check on every flake update.
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";
      # TEMPORARILY DISABLED -- re-enable after updating the fork.
      # Swap yazelix's embedded Helix build for our own fork instead of the
      # per-machine helix_external option, which the Nova rewrite removed.
      # Upstream yazelix now needs `packages.<system>.yazelix_helix_steel`, which
      # our fork (last synced 2026-07-10) doesn't expose -> eval fails. Until the
      # fork is updated we fall back to upstream Yazelix/nova-helix, which means
      # *no evil-helix vim keybindings* in the yazelix Helix.
      # To fix the fork: port `yazelix/steel/{bridge,bridge-actions}.scm` plus the
      # `yazelix_helix_steel` runCommand output from Yazelix/nova-helix's flake.nix,
      # then uncomment the line below.
      # inputs.yazelixHelix.follows = "evil-yazelix-helix";
    };
    evil-yazelix-helix = {
      url = "github:MaySeikatsu/evil-yazelix-helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noren = {
      url = "github:MaySeikatsu/noren";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # forest-hx = {
    #   url = "github:Ra77a3l3-jar/forest.hx";
    #   flake = false;
    # };
    # notify-hx = {
    #   url = "github:chuwy/notify.hx";
    #   flake = false;
    # };
    # glyph-hx = {
    #   url = "github:Ra77a3l3-jar/glyph.hx";
    #   flake = false;
    # };
    iris = {
      url = "github:versenilvis/iris";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-session-restore = {
      # Local fork under active development; switch to
      # "github:MaySeikatsu/niri-session-restore" once it's pushed there.
      url = "path:/home/maike/Projects/forks/niri-session-restore";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic = {
      # CachyOS kernel packages (linuxPackages_cachyos*) for NixOS.
      # Deliberately NOT following our nixpkgs: chaotic-nyx pins to the
      # nixpkgs revision its cachyos kernel builds were actually built
      # against, which is what makes the chaotic-nyx.cachix.org binary
      # cache hit. Following our nixpkgs would make Nix rebuild the kernel
      # from source instead of fetching the prebuilt one.
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    zen-browser,
    spicetify-nix,
    nixcord,
    stylix,
    textfox,
    niri,
    sysc-greet,
    system76-scheduler-niri,
    sops-nix,
    monado-rift-wayland,
    # shellseikatsu,
    yazelix-hm,
    chaotic,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    system2 = "aarch64-linux";
    host = "nixos-maike-pc";
    host2 = "nixos-legion";
    host3 = "nixos-pi3";
    username = "maike";

    commonOverlays = [
      (final: prev: {
        inherit
          (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })
      # commitizen's test suite expects Python <3.14's unquoted argparse
      # "invalid choice" error format; Python 3.14 quotes each choice now,
      # so one snapshot test fails. Not a real bug in the package itself.
      (final: prev: {
        commitizen = prev.commitizen.overridePythonAttrs (old: {
          doCheck = false;
        });
      })
    ];

    mkHomeManagerConfig = homePath: {
      home-manager = {
        users.${username} = import homePath;
        useGlobalPkgs = true;
        useUserPackages = true;
        # backupFileExtension = "bck";
        backupCommand = "mv \"$1\" \"$1.bck.$(date +%Y%m%d%H%M%S)\"";
        extraSpecialArgs = {inherit inputs;};
        sharedModules = [
          inputs.nixcord.homeModules.nixcord
          textfox.homeManagerModules.default
          inputs.sops-nix.homeManagerModules.sops
          monado-rift-wayland.homeManagerModules.default
          # shellseikatsu.homeManagerModules.default
          yazelix-hm.homeManagerModules.default
        ];
      };
    };

    commonDesktopModules = [
      inputs.spicetify-nix.nixosModules.default
      inputs.stylix.nixosModules.stylix
      # Exposes pkgs.linuxPackages_cachyos* + trusts the chaotic-nyx cache;
      # doesn't change the running kernel by itself (see the cachyos
      # specialisation in hosts/nixos-maike-pc/configuration.nix).
      chaotic.nixosModules.default
      # Oculus Rift CV1: udev rules + patched Monado package
      monado-rift-wayland.nixosModules.default
      {hardware.oculus-rift-cv1.enable = true;}
      sysc-greet.nixosModules.default
      {nixpkgs.overlays = commonOverlays;}
      home-manager.nixosModules.home-manager
    ];
  in {
    nixosConfigurations = {
      "${host}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs system;
          host = host;
        };
        modules =
          commonDesktopModules
          ++ [
            ./hosts/nixos-maike-pc/configuration.nix
            (mkHomeManagerConfig ./hosts/nixos-maike-pc/home.nix)
          ];
      };

      "${host2}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs system;
          host = host2;
        };
        modules =
          commonDesktopModules
          ++ [
            ./hosts/nixos-legion/configuration.nix
            (mkHomeManagerConfig ./hosts/nixos-legion/home.nix)
          ];
      };

      # "${host3}" = nixpkgs.lib.nixosSystem {
      #   specialArgs = {
      #     inherit inputs;
      #     system = system2;
      #     host = host3;
      #   };
      #   modules = [
      #     ./hosts/nixos-pi3/configuration.nix
      #   ];
      # };
    };
  };
}
