{
  description = "Nixos config flake";

  inputs = {
    # Essentials (nixpkgs-channel and home-manager)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake imports:
    zen-browser.url =
      "github:0xc000022070/zen-browser-flake"; # or emmi version: zen-browser.url = "./packages/home-manager/zen-browser";
    nixcord.url =
      "github:kaylorben/nixcord?rev=c1a2a14393dba951994442199b9adfe14bb78a99"; # the rev value can be removed in the future, currently there is a but and the old rev must be used
    textfox.url = "github:adriankarlen/textfox";
    swww.url = "github:LGFae/swww";
    nvix.url = "github:niksingh710/nvix";
    ashell.url = "github:MalpenZibo/ashell";
    eww.url = "github:elkowar/eww";
    # hyprpanel = {
    #   url = "github:Jas-SinghFSU/HyprPanel";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:InioX/Matugen";
      # inputs.nixpkgs.follows = "nixpkgs";
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
    sddm-astronaut-theme = {
      url = "./ressources/sddm-astronaut-theme";
      # url = "github:MaySeikatsu/sddm-astronaut-theme";
    };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Optional, by default this flake follows nixpkgs-unstable.
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium = {
      url = "git+https://github.com/SteamClientHomebrew/Millennium";
    };

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
    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zen-browser, home-manager, swww, spicetify-nix
    , nixcord, matugen, stylix, textfox, niri, ashell, eww, nvix, ironbar
    , sddm-sugar-candy-nix, astal, claude-desktop, millennium,
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
      host = "nixos-maike-pc";
      host2 = "nixos-legion";
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

          #Overlays (?)
          {
            nixpkgs.overlays = [
              # inputs.hyprpanel.overlay
              sddm-sugar-candy-nix.overlays.default
              inputs.millennium.overlays.default
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
              backupFileExtension = "backup";
              # Home-Manager Modules 
              extraSpecialArgs = {
                inherit inputs; # apperently needed for textfox?
              };
              sharedModules = [
                inputs.nixcord.homeManagerModules.nixcord
                textfox.homeManagerModules.default
                # inputs.nixCats-nvim.homeModule
                # inputs.matugen.packages.${system}.default
                # inputs.stylix.homeModules.stylix
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
              # inputs.hyprpanel.overlay
              sddm-sugar-candy-nix.overlays.default
              inputs.millennium.overlays.default
            ];
          }

          # Home Manager as a NIXOS Module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.maike = import ./hosts/nixos-legion/home.nix;
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              # Home-Manager Modules 
              extraSpecialArgs = {
                inherit inputs; # apperently needed for textfox?
              };
              sharedModules = [
                inputs.nixcord.homeManagerModules.nixcord
                textfox.homeManagerModules.default
                # inputs.nixCats-nvim.homeModule
                # inputs.matugen.packages.${system}.default
                # inputs.stylix.homeModules.stylix
              ];
            };
          }

        ];
      };
    };
}

