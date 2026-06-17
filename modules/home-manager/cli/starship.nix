{lib,config,...}: {
  programs = {
    starship = {
      enable = true;
      settings = {
        add_newline = true;

         # --- Show current account in use per dir ---
         # Drop into the prompt format string somewhere sensible, e.g. right after
         # `$git_branch`. Default format is fine if you just want it appended.
         format = lib.concatStrings [
           "$all"           # everything starship would normally show
           "$custom"        # our custom modules
           "$character"
         ];

         custom.git_identity = {
           description = "Active git identity (personal vs work)";
           # Only run inside a git repo.
           when = "git rev-parse --is-inside-work-tree";
           # `command` runs in a shell; print a short tag based on the email domain.
           command = ''
             email=$(git config user.email 2>/dev/null || true)
             case "$email" in
               *@admin*)        print '🏢 work' ;;
               "")            print '⚠ no-identity' ;;
               *)             print '🏠 personal' ;;
             esac
           '';
           format = "[\\[$output\\]]($style) ";
            style = "bold yellow";
            # Re-evaluate per directory; cheap enough.
          };
        # custom.git_identity_via_sops = {
        #     description = "Active git identity (personal vs work)";
        #     when = "git rev-parse --is-inside-work-tree";
        #     command = ''
        #       email=$(git config user.email 2>/dev/null || true)
        #       work=$(cat ${config.sops.secrets."git/work/email".path} 2>/dev/null || true)
        #       if [ -z "$email" ]; then
        #         printf '⚠ no-identity'
        #       elif [ "$email" = "$work" ]; then
        #         printf '🏢 work'
        #       else
        #         printf '🏠 personal'
        #       fi
        #     '';
        #     format = "[\\[$output\\]]($style) ";
        #     style = "bold yellow";
        # };
      };
      # Or import a toml settings file if prefered non nixified
      # settings = pkgs.lib.importTOML ../starship.toml;
    };
  };
}
