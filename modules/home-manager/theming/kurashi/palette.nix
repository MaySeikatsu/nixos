# Rosé Pine Moon (dark): the Nix palette of the theming design (modules/home-manager/theming/kurashi.nix).
#
# Keys are kurashi's token names where kurashi has one: a token kurashi sends replaces the value here. The "rp.*" keys
# are Nix-only values (the 16 highlight and tint colours of the Rosé Pine themes) that kurashi has no token for, so the
# bridge always renders them from this file. The moon palette kurashi gets must use these same values, or switching the
# theming on changes the look.
{
  "color.surface" = "#232136"; # base
  "color.surface_container_low" = "#2a273f"; # surface
  "color.surface_container" = "#393552"; # overlay
  "color.surface_container_high" = "#44415a"; # highlight med
  "color.surface_container_highest" = "#56526e"; # highlight high
  "color.outline" = "#6e6a86"; # muted
  "color.on_surface_variant" = "#908caa"; # subtle
  "color.on_surface" = "#e0def4"; # text
  "color.error" = "#eb6f92"; # love
  "color.warning" = "#f6c177"; # gold
  "color.tertiary" = "#ea9a97"; # rose
  "color.success" = "#3e8fb0"; # pine
  "color.secondary" = "#9ccfd8"; # foam
  "color.accent" = "#c4a7e7"; # iris

  "rp.highlight_low" = "#2a283e";
  "rp.love_10" = "#3a2841";
  "rp.gold_10" = "#39313e";
  "rp.rose_10" = "#392d41";
  "rp.pine_10" = "#252c44";
  "rp.foam_10" = "#2e3248";
  "rp.iris_10" = "#342e4a";
}
