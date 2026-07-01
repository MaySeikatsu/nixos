{pkgs, ...}:{
  programs.gh = {
    enable = true;
    extensions = [pkgs.gh-dash pkgs.gh-poi /*pkgs.gh-copilot*/]; # Run gh poi to clean up dead/merged local branches
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "ssh";
      #optional
      prompt = "enabled";
      editor = "nvim";
    };
  };
}
