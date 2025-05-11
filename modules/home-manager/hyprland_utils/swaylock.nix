
{pkgs, ...}:
{
  programs.swaylock =  {
    enable  =  true;
    package = pkgs.swaylock-effects;
    settings  =  {
      screenshots = true ;
      effect-blur = "4x6" ;
      scaling = "fill" ;
      indicator-x-position = "0" ;
      indicator-y-position = "0" ;
      indicator-radius = "200" ;
      indicator-thickness = "30" ;
      bs-hl-color = "ffa066" ;
      caps-lock-bs-hl-color = "ffa066" ;
      caps-lock-key-hl-color = "957fbb" ;
      inside-color = "1f1f28" ;
      inside-clear-color = "1f1f28" ;
      inside-caps-lock-color = "1f1f28" ;
      inside-ver-color = "1f1f28" ;
      inside-wrong-color = "1f1f28" ;
      key-hl-color = "7fb4ca" ;
      layout-bg-color = "1f1f28" ;
      layout-border-color = "1f1f28" ;
      layout-text-color = "dcd7ba" ;
      line-color = "1f1f28" ;
      line-clear-color = "1f1f28" ;
      line-caps-lock-color = "1f1f28" ;
      line-ver-color = "1f1f28" ;
      line-wrong-color = "1f1f28" ;
      ring-color = "1f1f28" ;
      ring-clear-color = "ffa066" ;
      ring-caps-lock-color = "1f1f28" ;
      ring-ver-color = "98bb6c" ;
      ring-wrong-color = "1f1f28" ;
      separator-color = "00000000" ;
      text-color = "dcd7ba" ;
      text-clear-color = "ffa066" ;
      text-caps-lock-color = "957fbb" ;
      text-ver-color = "dcd7ba" ;
      text-wrong-color = "f7768etrue" ;
    };
  };
}
