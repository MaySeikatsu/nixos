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
    # stylix.url = "github:danth/stylix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixcord.url = "github:kaylorben/nixcord";
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
    # stylix,
    ...
    }@ inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
        inputs.spicetify-nix.nixosModules.default
        # inputs.stylix.nixosModules.stylix
        # stylix.homeManagerModules.stylix
        # inputs.nixcord.homeManagerModules.nixcord

        # home-manager.nixosModules.home-manager {
        #     home-manager.useGlobalPkgs = true;
        #     home-manager.useUserPackages = true;
        #     home-manager.users.maike = import ./home.nix;
        #
        #     home-manager.sharedModules = [
        #       inputs.nixcored.homeManagerModules.nixcord
        #     ];
        #   }
        
        ./hosts/default/configuration.nix
      ];
    };
  };
}

