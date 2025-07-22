#!/bin/sh

#this would work for arch but not nixos, therefore we need to symlink a file as shown below
#WP1=$(grep '/home/' /home/maike/.cache/swww/eDP-2)
#export WP1
# echo "$WP1"

# Currently just configured to work with hardcoded device

# WP_PATH=$(grep '/home/' /home/maike/.cache/swww/eDP-2)
# ln -sf "$WP_PATH" ~/.current-wallpaper-eDP2
#
# export WP_PATH
# echo $WP_PATH
mkdir "~/.config/hypr/colors-hyprland.conf"

# Get all connected monitor names using hyprctl's JSON output
for monitor in $(hyprctl -j monitors | jq -r '.[].name'); do
	# Construct the path to the wallpaper file for this monitor
	WP_PATH=$(grep '/home/' "/home/maike/.cache/swww/$monitor")

	# Do something with $WP_PATH, e.g., update symlink for each monitor
	if [ -n "$WP_PATH" ]; then
		ln -sf "$WP_PATH" "/home/maike/.current-wallpaper"
		echo "Set wallpaper for $monitor: $WP_PATH"
	fi
done

wallust run ~/.current-wallpaper

# SCRIPTS MIGHT NEED: sudo chmod +x ./swww-find-wallpaper.sh     to run the scripts

#Sync RGB Color to Wallpaper
~/.config/nixos/scripts/openrbg.sh
