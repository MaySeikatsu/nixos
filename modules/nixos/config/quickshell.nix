{pkgs, ...}:{
  environment.systemPackages = with pkgs; [
    kdePackages.qtsvg # support for SVG image loading (bundled with most packages)
    kdePackages.qtimageformats # support for WEBP images as well as some less common ones
    kdePackages.qtmultimedia # support for playing videos, audio, etc
    kdePackages.qt5compat # extra visual effects, notably gaussian blur. MultiEffect is usually preferable
    kdePackages.qtdeclarative
  ];
}
