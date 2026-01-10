{
  description = "Nixos config flake";

  # TODO find solution to avoid repetition of inputs.nixpkgs.follows = "nixpkgs"
  inputs = {
    # Nixpkgs source and home-manager
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    # Flake Inputs:
    zen-browser.url =
      "github:0xc000022070/zen-browser-flake"; # or emmi version: zen-browser.url = "./packages/home-manager/zen-browser";
    nixcord.url = "github:kaylorben/nixcord";
    textfox.url = "github:adriankarlen/textfox";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.home-manager.follows = "home-manager";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # sddm-astronaut-theme = {
    #   url = "path:./ressources/sddm-astronaut-theme";
    #   # url = "github:MaySeikatsu/sddm-astronaut-theme";
    # };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Optional, by default this flake follows nixpkgs-unstable.
    };
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mistral-vibe = {
      url = "github:mistralai/mistral-vibe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:InioX/Matugen";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    qs-caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qs-caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qs-illogical-flake = {
      url = "github:soymou/illogical-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nuls = {
      url = "github:MaySeikatsu/nuls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-desktop = {
    #   url = "github:k3d3/claude-desktop-linux-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # swww.url = "github:LGFae/swww";
    # nvix.url = "github:niksingh710/nvix";
    # hyprpanel = {
    #   url = "github:Jas-SinghFSU/HyprPanel";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # millennium = {
    #   url = "git+https://github.com/SteamClientHomebrew/Millennium";
    # };

    # quickshell = {
    #   url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # qs-dankmaterial= {
    #   url = "github:AvengeMedia/danklinux";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # qs-noctalia = {
    #   url = "github:noctalia-dev/noctalia-shell";
    #   # url =
    #   #   "github:MaySeikatsu/noctalia-shell-wallust?ref=orig_settings_adjust";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # qs-retroism = {
    #   url = "github:diinki/linux-retroism?dir=configs/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # winboat = {
    #   url = "github:TibixDev/winboat";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # winapps = {
    #   url = "github:winapps-org/winapps";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # CURRENTLY UNUSED FLAKE IMPORTS
    # hyprddm.url = "github:maotseantonio/hyprddm";
    # nixCats-nvim.url = "github:BirdeeHub/nixCats-nvim";
    # hyprscroller = {
    #     url = "github:maotseantonio/hyprscroller-flake";
    #     inputs.hyprland.follows = "hyprland";
    # };
    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # legionrgb = {
    #   url = "github:/4JX/L5P-Keyboard-RGB";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # ironbar = {
    #   url = "github:JakeStanger/ironbar";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, zen-browser, home-manager, flake-utils
    , spicetify-nix, nixcord, matugen, stylix, textfox, niri
    , sddm-sugar-candy-nix, astal, qs-caelestia-shell, qs-caelestia-cli
    , qs-illogical-flake, mistral-vibe, nuls,
    # nvix,
    # qs-noctalia,
    # winboat
    # claude-desktop,
    # winapps
    # millennium
    # qs-retroism
    # ironbar
    # hyprpanel,
    # hyprddm,
    # nixCats-nvim,
    # sddm-astronaut-theme,
    # hyprscroller,
    # hyprland-plugins,
    # legionrgb
    ... }@inputs:
    let
      system = "x86_64-linux";
      system2 = "aarch64-linux";
      host = "nixos-maike-pc";
      host2 = "nixos-legion";
      host3 = "nixos-pi3";
      username = "maike";

    in {

      nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit host;
          inherit system;
        };
        modules = [
          ./hosts/nixos-maike-pc/configuration.nix

          # Nix Modules
          inputs.spicetify-nix.nixosModules.default
          inputs.stylix.nixosModules.stylix
          matugen.nixosModules.default
          sddm-sugar-candy-nix.nixosModules.default
          # nixCats-nvim.nixosModules.default

          {
            nixpkgs.overlays = [
              (final: prev: {
                inherit (prev.lixPackageSets.stable)
                  nixpkgs-review nix-eval-jobs nix-fast-build colmena;
              })

              # inputs.hyprpanel.overlay
              sddm-sugar-candy-nix.overlays.default
              # inputs.millennium.overlays.default
              # inputs.millennium.overlays.millennium
            ];
          }

          # Home Manager as a NIXOS Module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.maike = import ./hosts/nixos-maike-pc/home.nix;
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bck";
              # Home-Manager Modules
              extraSpecialArgs = {
                inherit inputs; # apperently needed for textfox?
              };
              sharedModules = [
                inputs.nixcord.homeModules.nixcord
                textfox.homeManagerModules.default
                # inputs.ironbar.homeManagerModules.default
                # inputs.nixCats-nvim.homeModule
                # inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
                # inputs.stylix.homeModules.stylix
                qs-illogical-flake.homeManagerModules.default
                { programs.illogical-impulse.enable = true; }

              ];
            };
          }

        ];
      };
      nixosConfigurations."${host2}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit host2;
          inherit system;
        };
        modules = [
          ./hosts/nixos-legion/configuration.nix

          # Nix Modules
          inputs.spicetify-nix.nixosModules.default
          inputs.stylix.nixosModules.stylix
          matugen.nixosModules.default
          sddm-sugar-candy-nix.nixosModules.default
          # nixCats-nvim.nixosModules.default

          #Overlays (?)
          {
            nixpkgs.overlays = [
              (final: prev: {
                inherit (prev.lixPackageSets.stable)
                  nixpkgs-review nix-eval-jobs nix-fast-build colmena;
              })

              # inputs.hyprpanel.overlay
              sddm-sugar-candy-nix.overlays.default
              # inputs.millennium.overlays.default
              # inputs.millennium.overlays.millennium
            ];
          }

          # Home Manager as a NIXOS Module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.maike = import ./hosts/nixos-legion/home.nix;
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bck";
              # Home-Manager Modules
              extraSpecialArgs = {
                inherit inputs; # apperently needed for textfox?
              };
              sharedModules = [
                inputs.nixcord.homeModules.nixcord
                textfox.homeManagerModules.default
                # inputs.ironbar.homeManagerModules.default
                # inputs.nixCats-nvim.homeModule
                # inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
                # inputs.stylix.homeModules.stylix

                qs-illogical-flake.homeManagerModules.default
                { programs.illogical-impulse.enable = true; }
              ];
            };
          }

        ];
      };
      nixosConfigurations."${host3}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit host3;
          inherit system2;
        };
        modules = [
          ./hosts/nixos-pi3/configuration.nix

          # Home Manager as a NIXOS Module
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager = {
          #     users.maike = import ./hosts/nixos-pi3/home.nix;
          #     useGlobalPkgs = true;
          #     useUserPackages = true;
          #     backupFileExtension = "bck";
          #   };
          # }
          #
        ];
      };
    };
}
