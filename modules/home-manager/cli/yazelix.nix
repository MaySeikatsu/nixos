# See for documentation: https://github.com/luccahuguet/yazelix/blob/main/home_manager/README.md
{pkgs, inputs, ...}:
let
  evilYazelixHelix = inputs.evil-yazelix-helix.packages.${pkgs.system}.default;
in {
  programs.yazelix = {
    enable = true;
    # terminal = "foot";
    manage_config = true;

    helix_external = {
      binary = "${evilYazelixHelix}/bin/hx";
      runtime_path = "${evilYazelixHelix.runtimeDir}";
    };

    skip_welcome_screen = true;
    # screen_saver_enabled = true;
    # show_macchina_on_welcome = false;
    # components = {
    #   cursors = false;
    #   screen = false;
    # };

    custom_popups = [
      {
        id = "btop";
        command = [ "btop" ];
        keybindings = [ "Alt Shift Y" ];
        keep_alive = true;
      }
      # {
      #   id = "zenith";
      #   command = [ "zenith" ];
      #   keybindings = [ "Alt Shift I" ];
      #   keep_alive = true;
      # }
    ];
    # runtime_tool_sources = {
    # Use "host" to use the binary already installed on the host instead the yazelix one
    #   lazygit = "host";
    #   zenith = "host";
    #   helix = "host";
    #   steel = "host";
    #   yazi = "host";
    #   ripgrep = "host";
    #   fd = "host";
    # Use if you want to disable the tools to safe space / since they're not being used
      # macchina = "off";
      # steel = "off";
      # p7zip = "off";
      # poppler = "off";
      # resvg = "off";
    # };
  };
}
