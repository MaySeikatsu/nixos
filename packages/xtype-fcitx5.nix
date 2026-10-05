# XType: Cotypist-style inline AI autocomplete for any text field, as a
# Fcitx5 input method. A local model (via Ollama) continues what you type as
# grey ghost text; Tab accepts the next word, Shift+Tab the whole suggestion,
# Esc dismisses. Not in nixpkgs; young single-developer project (2026).
# Update: bump rev + hash (nix-prefetch-url --unpack <archive url>).
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  kdePackages,
  fcitx5,
  curl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xtype-fcitx5";
  version = "0.1.0-unstable-2026-08-08";

  src = fetchFromGitHub {
    owner = "KS0Code";
    repo = "XType";
    rev = "c54f5c7c95386750a50abee87ddacf3759f45a42";
    hash = "sha256-5yjbvquVNSk3ClsKWv1czUePPmJfM3z5mSnAO7xgT4E=";
  };

  sourceRoot = "${finalAttrs.src.name}/fcitx5-engine";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
  ];
  buildInputs = [
    fcitx5
    curl
  ];

  meta = {
    description = "Inline AI autocomplete (ghost text) for every text field, as a Fcitx5 input method";
    homepage = "https://github.com/KS0Code/XType";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
