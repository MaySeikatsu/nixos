{inputs, ...}: {
  imports = [inputs.walker.homeManagerModules.default];
  programs.walker = {
    enable = false;
    runAsService = true;
    config = {
      # theme = "rose-pine-moon"
    };
  };
}
