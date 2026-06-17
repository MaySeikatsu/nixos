{ config, pkgs, ... }:
# let
  # Host can override this in its home.nix (see step 5b).
  # workDir = config.my.git.workDir;
# in
{

  # Personal identity = the default.
  # NOTE: email comes from the sops template via includes below, not here.
  programs.git = {
    enable = true;
    lfs.enable = true;

    signing = {
      format = "ssh";
      signByDefault = true;
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rebase.autosquash = true;
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";

      "gpg \"ssh\"".allowedSignersFile =
        "${config.xdg.configHome}/git/allowed_signers";
    };

    includes = [
      # Always pull personal info(mail/name) from sops.
      { path = config.sops.templates."git-personal.inc".path; }
      # In the work folder, override identity + signing key + default branch.
      { path = config.sops.templates."git-includes.inc".path; }
    ];
  };

  # allowed_signers file so `git log --show-signature` works locally too.
  # Public keys are not secret, so this is a plain HM-managed file.
  # (If you'd rather encrypt the emails here too, turn this into another sops template.)
  xdg.configFile."git/allowed_signers".text = ''
    # personal
    * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdhLo5AoX6hY822//+I76GSDd6WXAxZfH81TyfHWfvQ
    # work
    * ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDjpunpiDglMm0Fqd/wc3pxEG4bHA3ZFAEnYLBW/C/xq
  '';

  # A tiny script that prints the active identity $PWD.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "git-whoami";
      runtimeInputs = [ pkgs.git ];
      text = ''
        # Print identity that would be used for a commit in $PWD.
        name="$(git config user.name  || echo '?')"
        email="$(git config user.email || echo '?')"
        signer="$(git config user.signingkey || echo 'unsigned')"
        printf '%s <%s>\n  signing: %s\n' "$name" "$email" "$signer"
      '';
    })
  ];

  # Setup precommit hook to .git dir
    home.activation.gitHookSymlink =
       config.lib.dag.entryAfter [ "writeBoundary" ] ''
         repo="${config.home.homeDirectory}/.config/nixos"

         src="$repo/scripts/git-hooks/basic_pre-commit-hook"
         dst="$repo/.git/hooks/pre-commit"

         if [ -d "$repo/.git" ] && [ -f "$src" ]; then
           run mkdir -p "$repo/.git/hooks"
           run ln -sf "../../scripts/git-hooks/pre-commit" "$dst"
         fi
       '';
}
