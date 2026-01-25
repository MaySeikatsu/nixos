{
  #run with nix develop ~/.config/nixos/nix-envs/rice/
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
          fastfetch
          # macchina # neofetch alt rust
          cava
          cavalier
          cbonsai
          pipes-rs
          cmatrix
          rsclock
          lolcat
          # steam-tui
          discordo # discord cli client
          bluetui
          spotify-player
          reddix
          youtube-tui
          mpv
          yt-dlp
          # ytui-music
          manga-tui
          ani-cli
          taskwarrior-tui
          # cool-retro-term
          gitlogue
          netscanner
          impala
        ];
      };
    };
  };
}
