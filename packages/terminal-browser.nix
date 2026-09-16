{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "terminal-browser";
  version = "0.8.1";

  src = pkgs.fetchurl {
    url = "https://terminal-browser.sh/install/dl/stable/v${version}/terminal-browser-linux-x64.tar.gz";
    hash = "sha256-NeeAidEIncT0krvX0qA9V+1VQ7Q5S0/d875Xx1t3dH4=";
  };

  nativeBuildInputs = with pkgs; [autoPatchelfHook makeWrapper];
  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    stdenv.cc.cc.lib
  ];

  sourceRoot = "terminal-browser";
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/terminal-browser $out/bin
    cp -R . $out/lib/terminal-browser/
    ln -s $out/lib/terminal-browser/bin/terminal-browser $out/bin/terminal-browser
    runHook postInstall
  '';

  meta = {
    description = "A real browser that runs inside your terminal";
    homepage = "https://github.com/zenbu-labs/terminal-browser";
    license = pkgs.lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "terminal-browser";
  };
}
