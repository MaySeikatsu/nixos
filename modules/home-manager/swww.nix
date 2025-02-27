{pkgs, inputs, ...}:
  let
    system = "x86_64-linux";
  in
{
  home.packages = [
    inputs.swww.packages.${pkgs.system}.swww
  ];
}
