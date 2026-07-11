{pkgs, lib,config,...}:
let
  # Tiny self-contained script. Has its own PATH via runtimeInputs, so it
  # works identically under bash / zsh / nu / fish.
  gitIdentity = pkgs.writeShellApplication {
    name = "starship-git-identity";
    runtimeInputs = [ pkgs.git pkgs.coreutils ];
    text = ''
      # Read the *effective* user.email for $PWD. Works inside a repo
      # (resolves includeIf overrides) AND outside (returns the global value).
      email=$(git config user.email 2>/dev/null || true)

      # Compare against the sops-rendered work email file (tmpfs, mode 0400).
      # Path is fixed at build time so no env-var dependency.
      work=$(cat ${config.sops.secrets."git/work/email".path} 2>/dev/null || true)

      if   [ -z "$email" ];        then printf '⚠ no-identity'
      elif [ "$email" = "$work" ]; then printf '🏢 work'
      else                              printf '🏠 personal'
      fi
    '';
  };
in{
  programs = {
    starship = {
      enable = true;
      settings = {
        add_newline = true;
         
        # Built-in modules that leak cloud/cluster account names into the prompt.
        gcloud = {
            disabled = true;
            format = "on [☁ $project]($style) ";   # shows project only, never account
          };
        azure.disabled      = true;
        aws.disabled        = true;
        openstack.disabled  = true;
        kubernetes.disabled = true;   # if you ever set up kubectl contexts

         # --- Show current account in use per dir ---
         format = lib.concatStrings [
           "$all"
           "$custom"
           "$character"
         ];

        custom.git_identity_via_sops = {
           description = "Active git identity for $PWD";
           command = lib.getExe gitIdentity;
           # Without this, starship runs `when` via its lightweight
           # non-shell executor, which doesn't understand `||`, `>`, or
           # `case` - the when condition below silently always failed and
           # this module never once rendered, in any shell.
           shell = "${pkgs.bash}/bin/bash";
           # Show only when we're somewhere git-relevant (in a repo OR in a
           # typical project parent dir). Suppresses badge in /tmp, /, etc.
           when = ''
             git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
               || [ -d "$PWD/.git" ] \
               || case "$PWD" in
                    "$HOME"/Projects*|"$HOME"/Documents/*) true ;;
                    *) false ;;
                  esac
           '';
           format = "[\\[$output\\]]($style) ";
           style  = "bold yellow";
         };      
      };
    };
  };
}
