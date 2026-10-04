# bevy_brp_mcp: MCP server for the Bevy Remote Protocol (inspect/modify a
# running Bevy app's entities, resources, components; launch examples).
# Version must match the Bevy version: 0.22.x <-> Bevy 0.19.
# The game needs `bevy_brp_extras` (or `RemotePlugin` + `RemoteHttpPlugin`).
{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bevy_brp_mcp";
  version = "0.22.8";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-X9We8y+VVfQB3HgDLMvZF+0Ismpf8qpvyGRfjpwt1uk=";
  };

  cargoHash = "sha256-M2xccmCc3eypqzTFQMAqRXpgk3NYYtQEN1ay+jeY020=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];
  doCheck = false;

  meta = {
    description = "MCP server for the Bevy Remote Protocol";
    homepage = "https://github.com/natepiano/bevy_brp";
    license = with lib.licenses; [mit asl20];
    mainProgram = "bevy_brp_mcp";
  };
})
