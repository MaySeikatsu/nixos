{
  #run with nix develop ~/.config/nixos/nix-envs/rice/
  description = "osu! development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            #fun cli tools:
            fastfetch
            # macchina # neofetch alt rust
            cava
            cbonsai
            pipes-rs
            cmatrix
            rsclock
            lolcat
            # steam-tui
            discordo # discord cli client
            spotify-player
            reddix
            # ytui-music
            manga-tui
            ani-cli
            taskwarrior-tui
            bluetui

            # gui tools
            cavalier
            cool-retro-term
            # add packages here
          ];
        };
      };
    };
}
