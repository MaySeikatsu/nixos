{config, ...}: {
  # Shared aliases for all shells. home.shellAliases covers zsh/fish/bash;
  # nushell's HM module doesn't inherit it, so it's mapped explicitly below.
  home.shellAliases = {
    n = "nvim";
    v = "nvim";
    zlja = "zellij attach";
    zlj = "zellij";
    zide = "zellij action new-tab --layout ide"; # tree + console tab
    zideg = "zellij action new-tab --layout ide-git"; # + lazygit right
    zidel = "zellij action new-tab --layout ide-llm"; # + claude right
    zidef = "zellij action new-tab --layout ide-filetree"; # tree only
    zidec = "zellij action new-tab --layout ide-console"; # console only
    zidey = "zellij action new-tab --layout ide-yazi"; # yazi tree + console
    pass = "gopass";

    # Git
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gf = "git fetch";
    gp = "git pull";
    gP = "git push";
    gb = "git branch";
    gC = "git checkout";
    gm = "git merge";
    gr = "git rebase";
    gl = "git log";

    davinci-resolve = "nvidia-offload davinci-resolve";
  };

  programs.nushell.shellAliases = config.home.shellAliases;
}
