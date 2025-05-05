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
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

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
    # stylix,
    ...
    }@ inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
        inputs.spicetify-nix.nixosModules.default
        # inputs.nixcord.homeManagerModules.nixcord

        # inputs.stylix.nixosModules.stylix
        # stylix.homeManagerModules.stylix

        #nixcord config
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.maike = import ./hosts/default/home.nix;

          home-manager.sharedModules = [
            inputs.nixcord.homeManagerModules.nixcord
          ];
        }
        
        #./hosts/default/configuration.nix
	./hosts/default/configuration.nix
      ];
    };
    nixosConfigurations.nixos-legion = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
        inputs.spicetify-nix.nixosModules.default
        # inputs.nixcord.homeManagerModules.nixcord

        # inputs.stylix.nixosModules.stylix
        # stylix.homeManagerModules.stylix

        #nixcord config
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.maike = import ./hosts/nixos-legion/home.nix;

          home-manager.sharedModules = [
            inputs.nixcord.homeManagerModules.nixcord
          ];
        }
        
        #./hosts/default/configuration.nix
	./hosts/nixos-legion/configuration.nix
      ];
    };
  };
}

