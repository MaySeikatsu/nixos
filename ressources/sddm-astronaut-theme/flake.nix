{
  outputs = { self, nixpkgs }: {
    packages = nixpkgs.legacyPackages.x86_64-linux.callPackage ./default.nix {};
  };
}
