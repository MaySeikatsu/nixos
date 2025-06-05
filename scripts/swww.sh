#!/usr/bin/env sh

staticwall="$HOME/Pictures/wallpaper.png"

if [ -z "$1" ]; then
  echo "add wallpaper as arg"
  exit 1
fi

wallust run "$1" &

# hyprctl hyprpaper reload ,"$1"
ln -sf "$1" "$staticwall" #creates a symlinks thebetween static wall and 1, sf forces overwrite
# swww-daemon &
swww img $1 --transition-fps 240 --transition-step 170 --transition-duration 1 --transition-type any --transition-bezier .54,0,.34,.99 --transition-wave 200,200

# while wallust is still running, wait
while pgrep -x wallust >/dev/null; do
  sleep 0.1
done
