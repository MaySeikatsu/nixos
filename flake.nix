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
    zen-browser.url = "github:0xc000022070/zen-browser-flake";     # or emmi version: zen-browser.url = "./packages/home-manager/zen-browser";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    swww.url = "github:LGFae/swww";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen = {
      url = "github:/InioX/Matugen";
      # If you need a specific version:
      # ref = "refs/tags/matugen-v0.10.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # legionrgb = {
    #   url = "github:/4JX/L5P-Keyboard-RGB";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };


    nixcord.url = "github:kaylorben/nixcord?rev=c1a2a14393dba951994442199b9adfe14bb78a99"; #the rev value can be removed in the future, currently there is a but and the old rev must be used
    # stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    zen-browser,
    home-manager,
    hyprpanel,
    swww,
    spicetify-nix,
    nixcord,
    matugen,
    # stylix,
    # legionrgb
    ...
    }@ inputs: let
      system = "x86_64-linux";
      host = "default";
      host2 = "nixos-legion";
      username = "maike";
    in {
    nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
      specialArgs = {
          inherit inputs;
          inherit host;
        };
      modules = [
        ./hosts/default/configuration.nix

        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
        inputs.spicetify-nix.nixosModules.default
        # inputs.nixcord.homeManagerModules.nixcord
        # inputs.matugen.packages.${system}.default
        # inputs.stylix.nixosModules.stylix
        # stylix.homeManagerModules.stylix

        #nixcord config
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.maike = import ./hosts/default/home.nix;

          home-manager.sharedModules = [
            inputs.nixcord.homeManagerModules.nixcord
            # inputs.matugen.packages.${system}.default
          ];
        }
        
      ];
    };
    nixosConfigurations."${host2}" = nixpkgs.lib.nixosSystem {
      specialArgs = {
          inherit inputs;
          inherit host2;
        };
      modules = [
        ./hosts/nixos-legion/configuration.nix

        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
        inputs.spicetify-nix.nixosModules.default
        # inputs.nixcord.homeManagerModules.nixcord
          # inputs.matugen.packages.${system}.default
        # inputs.stylix.nixosModules.stylix
        # stylix.homeManagerModules.stylix

        #nixcord config
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.maike = import ./hosts/nixos-legion/home.nix;

          home-manager.sharedModules = [
            inputs.nixcord.homeManagerModules.nixcord
            # inputs.matugen.packages.${system}.default
          ];
        }

      ];
    };
    # homeConfigurations."username@host" = home-manager.lib.homeMangerConfiguration {
    #   pkgs = import nixpkgs {
    #     inherit system;
    #     overlays = [
    #       inputs.hyprpanel.overlay
    #       ];
    #     };
    #     extraSpecialArgs = {
    #     };
    # };
  };
}

