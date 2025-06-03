{ config, pkgs, hellwal, ... }: # hellwal is now available through extraSpecialArgs
let
  # Define your wallpaper path
  # This path should be accessible by hellwal when it runs.
  # For syncing, it's good to keep it within your git repo.
  # The source path for home.file below is relative to your flake root,
  # but hellwal itself needs the path on the target system after deployment.
  wallpaperPath = "${config.home.homeDirectory}/.config/wallpapers/my-wallpaper.jpg";

  # Generate the hellwal colors into a temporary derivation
  hellwalColors = pkgs.runCommand "kitty-hellwal-colors" {
    nativeBuildInputs = [ hellwal.packages.${pkgs.system}.default ]; # Access the hellwal package
  } ''
    mkdir -p $out
    hellwal -i ${wallpaperPath} --template $out/kitty-theme.conf \
      --template-str "background='%%background%%'\n" \
      --template-str "foreground='%%foreground%%'\n" \
      --template-str "cursor='%%cursor%%'\n" \
      --template-str "color0='%%color0.hex%%'\n" \
      --template-str "color1='%%color1.hex%%'\n" \
      --template-str "color2='%%color2.hex%%'\n" \
      --template-str "color3='%%color3.hex%%'\n" \
      --template-str "color4='%%color4.hex%%'\n" \
      --template-str "color5='%%color5.hex%%'\n" \
      --template-str "color6='%%color6.hex%%'\n" \
      --template-str "color7='%%color7.hex%%'\n" \
      --template-str "color8='%%color8.hex%%'\n" \
      --template-str "color9='%%color9.hex%%'\n" \
      --template-str "color10='%%color10.hex%%'\n" \
      --template-str "color11='%%color11.hex%%'\n" \
      --template-str "color12='%%color12.hex%%'\n" \
      --template-str "color13='%%color13.hex%%'\n" \
      --template-str "color14='%%color14.hex%%'\n" \
      --template-str "color15='%%color15.hex%%'\n"
  '';
in
{
  # Make the generated kitty colors file path available via config.custom
  config.custom.hellwal.kittyColorsFile = "${hellwalColors}/kitty-theme.conf";

  # Ensure the wallpaper file is copied from your repo to the user's home directory.
  # The `source` path is relative to your flake root.
  home.file.".config/wallpapers/my-wallpaper.jpg".source = ./../../wallpapers/my-wallpaper.jpg;

  # Configure Kitty to use the generated theme
  programs.kitty = {
    enable = true; # Enable kitty if it's not enabled elsewhere
    # ... any other general kitty settings you want to share ...

    # Include the generated theme file
    extraConfig = ''
      include ${config.custom.hellwal.kittyColorsFile}
    '';
  };

  # You can add other applications here that use hellwal output,
  # or create separate modules for them and import them into a main shared module
  # (e.g., home/default.nix if it serves as your primary shared module).
}
