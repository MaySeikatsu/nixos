{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.tagstudio.packages.${pkgs.stdenv.hostPlatform.system}.tagstudio
  ];
}
