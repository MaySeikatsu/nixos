{config,...}:{
  # Manage SSH Keys for github
  programs.ssh = {
    enable = true;

    # Pulls in ~/.ssh/config.d/work (rendered by sops) without naming employer.
    includes = [ "${config.home.homeDirectory}/.ssh/config.d/*" ];

    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };

      # HM's implicit defaults (being removed upstream), kept as they were
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
    enableDefaultConfig = false;
  };
}
