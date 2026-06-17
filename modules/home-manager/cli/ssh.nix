{config,...}:{
  # Manage SSH Keys for github
  programs.ssh = {
    enable = true;

    # Pulls in ~/.ssh/config.d/work (rendered by sops) without naming employer.
    includes = [ "${config.home.homeDirectory}/.ssh/config.d/*" ];

    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      identitiesOnly = true;
    };
  };
}
