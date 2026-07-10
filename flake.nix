{
  description = "Nixos config flake";

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
    nixcord= {
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
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    monado-rift-wayland = {
      url = "github:MaySeikatsu/monado-rift-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelix-hm = {
      url = "github:luccahuguet/yazelix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    evil-yazelix-helix = {
      url = "github:MaySeikatsu/evil-yazelix-helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # shellseikatsu = {
    #   url = "git+file:///home/maike/Documents/projects/quickshell/shellseikatsu/";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
      monado-rift-wayland.nixosModules.default{
          # udev rules + monado-service/monado-cli in systemPackages
          hardware.oculus-rift-cv1.enable = true;
        }
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
