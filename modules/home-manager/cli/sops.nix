{config,...}:{
  # Use sops -d ./secrets/secrets.yaml to decrypt and ditch -d to edit
  sops = {
       # ciphertext blob.
    defaultSopsFile =  ../../../secrets/secrets.yaml;
    validateSopsFiles = false; # files live outside HM's store; HM can't read them at eval

    age = {
      # Derive the age private key from the existing SSH ed25519 key.
      # sops-nix calls ssh-to-age internally; no extra files to manage.
      sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      # Where the derived age key is cached. Fine to leave at default.
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = true;
    };
    
    secrets = {
     "git/personal/name" = { };
     "git/personal/email" = { };

     "git/work/name"      = { };
     "git/work/email"     = { };
     "git/work/keyfile"   = { };
     "git/work/host_alias" = { };
     "git/work/org"       = { };

     "git/paths/work_dir_pc"  = { };
     "git/paths/work_dir_legion" = { };
    };

    # --- git ---------------------------------------------------------------
    # Templates render small files with `${config.sops.placeholder."key"}` substituted
    # at activation. The rendered file is what we point git's `include.path` at,
    # so the email value never lands in the nix store.

    # The personal identity (default, applies everywhere).
    templates."git-personal.inc".content = ''
      [user]
        name = ${config.sops.placeholder."git/personal/name"}
        email = ${config.sops.placeholder."git/personal/email"}
    '';
    # The work identity override (only included by gitdir match below).
    templates."git-work.inc".content = ''
      [user]
        name = ${config.sops.placeholder."git/work/name"}
        email = ${config.sops.placeholder."git/work/email"}
        signingkey = ${config.home.homeDirectory}/.ssh/${config.sops.placeholder."git/work/keyfile"}.pub
      [init]
        defaultBranch = master
      [url "git@${config.sops.placeholder."git/work/host_alias"}:${config.sops.placeholder."git/work/org"}/"]
        insteadOf = git@github.com:${config.sops.placeholder."git/work/org"}/
        insteadOf = https://github.com/${config.sops.placeholder."git/work/org"}/
    '';
    # The router file: tells git WHEN to pull in git-work.inc
    templates."git-includes.inc".content = ''
      [includeIf "gitdir:${config.sops.placeholder."git/paths/work_dir_pc"}/"]
        path = ${config.sops.templates."git-work.inc".path}
      [includeIf "gitdir:${config.sops.placeholder."git/paths/work_dir_legion"}/"]
        path = ${config.sops.templates."git-work.inc".path}
    '';
    # --- ssh ---------------------------------------------------------------

    templates."ssh-work.conf" = {
      content = ''
        Host ${config.sops.placeholder."git/work/host_alias"}
          Hostname github.com
          User git
          IdentityFile ${config.home.homeDirectory}/.ssh/${config.sops.placeholder."git/work/keyfile"}
          IdentitiesOnly yes
      '';
      path = "${config.home.homeDirectory}/.ssh/config.d/work";
    };
  };

  # Keep the env var so the `sops` CLI works.
  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
