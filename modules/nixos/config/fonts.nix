{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = true;

    fontconfig = {
      enable = true;
      antialias = true;
      subpixel.rgba = "rgb";
      subpixel.lcdfilter = "default";
      defaultFonts = {
        monospace = [
          "DejaVu Sans Mono"
          "IPAGothic"
        ];
        sansSerif = [
          "DejaVu Sans"
          "IPAPGothic"
        ];
        serif = [
          "DejaVu Serif"
          "IPAPMincho"
        ];
      };
    };

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      roboto
      source-sans
      font-awesome
      source-sans
      font-awesome_6
      openmoji-color
      dejavu_fonts

      #Japanese
      mplus-outline-fonts.osdnRelease
      ipafont
      kochi-substitute
      source-code-pro
      ttf_bitstream_vera

      #enabled for end-4-dots
      # rubik
      # nerd-fonts.ubuntu
    ];

    # fontDir.enable = true;
  };
}
