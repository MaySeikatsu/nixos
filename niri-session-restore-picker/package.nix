# Standalone package for niri-session-restore-picker. Kept independent of
# the surrounding nixos config so this whole directory can be lifted into
# its own repo later without untangling anything — see README.md.
{
  writeShellApplication,
  jq,
  fzf,
  libnotify,
  coreutils,
  findutils,
  gawk,
}:
writeShellApplication {
  name = "niri-session-restore-picker";
  runtimeInputs = [
    jq
    fzf
    libnotify
    coreutils
    findutils
    gawk
  ];
  text = builtins.readFile ./niri-session-restore-picker.sh;
  meta = {
    description = "Interactively pick which workspaces to restore from a niri-session-restore snapshot";
    mainProgram = "niri-session-restore-picker";
  };
}
