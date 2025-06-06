#!/usr/bin/env sh
# Source: https://gitlab.com/fazzi/dotfiles

# staticwall="$HOME/Pictures/1359465.png"
staticwall="$HOME/.current-wallpaper"

if [ -z "$1" ]; then
  echo "add wallpaper as arg"
  exit 1
fi

wallust run "$1" &

ln -sf "$1" "$staticwall"
# hyprctl hyprpaper reload ,"$1"
swww-daemon &
# swww img $1
swww img $1 --transition-fps 240 --transition-step 170 --transition-duration 1 --transition-type any --transition-bezier .54,0,.34,.99 --transition-wave 200,200

# while wallust is still running, wait
while pgrep -x wallust >/dev/null; do
  sleep 0.2
done

# Restart dunst and update pywalfox
# pkill dunst &
# pywalfox --browser librewolf update
