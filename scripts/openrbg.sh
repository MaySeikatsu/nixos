#!/usr/bin/env sh

# Adjusts openrgb devices to the current color of the wallpaper, crrently just set to device 0, add other devices if needed
openrgb -d 0 -c $(grep '^let color0' ~/.cache/wallust/colors_neopywal.vim | sed -E 's/.*= "#([0-9A-Fa-f]+)"/\1/')
