# Instead you could also use crane:
# Start with a comprehensive suite of tests
# nix flake init -t github:ipetkov/crane#quick-start
{
  #run with nix develop ~/.config/nixos/nix-envs/dev/#rust (or any other possible variation)
  description = "osu! development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system} = {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # add packages here
        ];
      };
      # general rust dev-env
      rust = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          rustfmt
          clippy
          cargo
          openssl
          openssl.dev
        ];
        # Set up environment variables
        shellHook = ''
          export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
        '';
      };
      # general hestia dev-env
      hestia = pkgs.mkShell {
        packages = with pkgs; [
          sea-orm-cli
          rustc
          rustfmt
          clippy
          cargo
          openssl
          xorg.libX11
          atk
          webkitgtk_4_1
          nodejs
          deno
          bun
          unixtools.netstat
          lsb-release
          xdg-utils
          sqlite
          sqlite.dev
          openssl.dev
          pkg-config
        ];

        # Set up environment variables
        shellHook = ''
          export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
        '';
      };
      # for osu dev:
      dotnet = pkgs.mkShell {
        packages = with pkgs; [
          # .NET SDK
          dotnetCorePackages.sdk_8_0

          # Build tools
          git

          # Runtime libraries
          SDL2
          ffmpeg
          alsa-lib
          libglvnd
          xorg.libXi
          lttng-ust
          numactl
          udev

          # Wayland support
          wayland
          wayland-protocols
          libxkbcommon
        ];

        # Set up environment variables
        shellHook = ''
          export DOTNET_ROOT="${pkgs.dotnetCorePackages.sdk_8_0}";
          export DOTNET_CLI_TELEMETRY_OPTOUT=1
          export DOTNET_NOLOGO=1

          # Help SDL find Wayland
          export SDL_VIDEODRIVER=wayland

          # Library path for runtime dependencies
          export LD_LIBRARY_PATH="${
            pkgs.lib.makeLibraryPath [
              pkgs.SDL2
              pkgs.alsa-lib
              pkgs.libglvnd
              pkgs.udev
              pkgs.wayland
              pkgs.libxkbcommon
            ]
          }:$LD_LIBRARY_PATH"
        '';
      };
      terraform = pkgs.mkShell {
        buildInputs = with pkgs; [
          google-cloud-sdk
          # azure-cli
          terraform
          terraformer
          terraform-ls
          terraform-docs
          hclfmt
          # terraform-landscape
          # terraform-inventory
          # terraform-mcp-server
          # tfmigrate
          opentofu
          tofu-ls
          gemini-cli
        ];
      };
    };
  };
}
