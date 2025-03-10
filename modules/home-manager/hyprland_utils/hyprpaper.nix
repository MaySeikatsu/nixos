{pkgs, ...}:
{
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = "false";
        splash_offset = 2.0;

          #Defining Variables
          "$image1" = "~/Pictures/wallpaper/1343335.png" ;
          "$image2" = "~/Pictures/wallpaper/1313942.png";
          "$image3" = "~/Pictures/wallpaper/1317094.png";

          "$monitor1" = "DP-2";
          "$monitor2" = "HDMI-A-2";
          "$monitor3" = "DVI-D-1";

#Preloading Images
        preload = [
          "$image1"
          "$image2"
          "$image3"
        ];

        wallpaper = [
         "$monitor1, $image1"
         "$monitor2, $image2"
         "$monitor3, $image3"
  # unload unused
        ];
      };
    };
}
#preload = /path/to/next_image.png #not needed as it loads image into ram and can slow down enviroment. Just needed if an image needs to be loaded instantly, like for example on startup or within a theme change. unload is also possible


#enable splash text rendering over the wallpaper
  # "splash"        = "false" 
  # "splash_offset" = "2.0"
  # "splash_color"  = "55ffffff"

#fully disable ipc - for wallpaper switch I guess?
  # ipc = on
  #
  # $wp1 = hyprctl hyprpaper wallpaper "$monitor1, $image1"
  # $wp2 = hyprctl hyprpaper wallpaper "$monitor1, $image2"

  # bind=SUPER,1,exec $wp1
  # bind=SUPER,2,exec $wp2

