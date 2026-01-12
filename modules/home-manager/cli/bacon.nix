{...}: {
  programs = {
    bacon = {
      enable = true;
      settings = {
        jobs = {
          default = {
            command = [
              "cargo"
              "build"
              "--all-features"
              "--color"
              "always"
            ];
            need_stdout = true;
          };
        };
      };
    };
  };
}
