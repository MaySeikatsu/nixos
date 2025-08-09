# 🍁My NixOS Config with Dynamic Theming🍁

Hey, glad you found my config. Please be aware that this repo contains my personal NixOS configuration which is actively developing day by day. Therefore it's not adviced to directly copy this configuration to use it as a foundation for your system, as there might be a lot of stuff that's not necessary for you. I published it to offer a reference for people who are working on their own config and might want to figure out how to set up specific features that I integrated into my system. 

With that said, now to the actual content of this repo - I hope you enjoy it

---

## ✨ Screenshots
### Autumn Themed Desktop with Stylix & Hyprpanel

![Autumn Theme with Stylix](https://github.com/user-attachments/assets/fe25b266-b54e-421a-aa6a-4b1cfb4c22c8)

## 🖥️ Current Setup - what’s in the config?

### Features
  - home-manager and flakes
  - multiple device support
    -> incremental device management via *shared* and *standalone* config files
  - multiple supported desktops and VMs
    -> [hyprland](https://github.com/hyprwm/Hyprlandf) (fully configured, used as main WM)
    -> [niri](https://github.com/YaLTeR/niri) (wip, working on migration towards it)
    -> kde-plasma (as fallback)
    -> gnome (also as fallback)
    -> [wayfire](https://github.com/WayfireWM/wayfire) (for funny effects)
  - full integration of [kanata](https://github.com/jtroo/kanata) managed by nix
    -> homerow mods enabled by default
    -> replaced Capslock with ESC(tap) and Layerswitch(hold)
    -> HJKL in layer for VIM movements everywhere
    -> quick *home* and *end* buttons for faster navigation
  - Modular Theming with [Stylix](https://github.com/danth/stylix) on rebuild (currently mostly inactive)
  - Modular Theming with [Wallust](https://codeberg.org/explosion-mental/wallust) on wallpaper change (a faster and more advanced version of pywal)
  - [tmux](https://github.com/tmux/tmux/wiki) / [zellij](https://github.com/zellij-org/zellij) configurations
  - [nushell](https://github.com/nushell/nushell) with [carapace](https://github.com/carapace-sh/carapace) completions
  - [hyprpanel](https://github.com/Jas-SinghFSU/HyprPanel) config via home-manager
  - custom scripts to match room/device rgb to apps to wallpaper with openrgb and wallust
  - sherlock-launcher for app launching
  - sddm-astronaut-theme

### 🗂️ Base Repo Structure
```
├── flake.lock
├── flake.nix
├── hosts
│   ├── common
│   ├── configuration-shared.nix
│   ├── home-shared.nix
│   ├── nixos-legion
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   ├── nixos-maike-pc
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
├── modules
│   ├── home-manager
│   └── nixos
├── readme.md
├── ressources
│   ├── sddm-astronaut-theme
│   │   ├── default.nix
│   │   └── flake.nix
│   ├── theming
│   │   ├── hellwal
│   │   ├── matugen
│   │   └── wallust
│   │       ├── templates
│   └── wallpapers
└── scripts
├── flake.lock
├── flake.nix
├── hosts
│   ├── common
│   ├── configuration-shared.nix
│   ├── home-shared.nix
│   ├── nixos-legion
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
│   ├── nixos-maike-pc
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── home.nix
├── modules
│   ├── home-manager
│   └── nixos
├── readme.md
├── ressources
│   ├── sddm-astronaut-theme
│   │   ├── default.nix
│   │   └── flake.nix
│   ├── theming
│   │   ├── hellwal
│   │   ├── matugen
│   │   └── wallust
│   │       ├── templates
│   └── wallpapers
└── scripts
```

## 📝 Roadmap / Wishlist
- [ ] full niri setup and rice
- [ ] alternative styles and rice themes for WM 
  -> osu!lazer based rice (OSyoU)
  -> retro futurism rice (thinking of win 95 with some dystopian aspects to it)
- [ ] writing own quickshell config to integrate with niri and hyprland
- [ ] refactor config for better modularization and providing a barebones core config
- [ ] cleanup unused tools
- [ ] focus on using mainly rust based applications
- [ ] improved scripts for multiple syncing purposes
- [x] Automatic wallpaper and theme switching (matugen/pywal style, but fully declarative)
- [ ] Improved documentation and onboarding for others

---

## 🚀 Getting Started

> **Note:** This config is tailored to my hardware and preferences.  
> If you want to use it, review and adapt the configuration to fit your needs.

1. **Clone the repo**

2. **Pick or create your host config** in `hosts/`.

3. **Build and switch:**
`sudo nixos-rebuild switch --flake .#your-hostname`

4. **Enjoy!** (And tweak as needed.)


---

## 💬 Why NixOS

I go crazy when I don't know  what exactly is configured on my system. Especially when I am troubleshooting and set multiple options of which I forget about later and therfore can't clean them up properly. I have been using archlinux for a while and really enjoyed it but as I am using multiple devices and love to have feature parity on all of them once I change a thing, I decided to use NixOS and I am really happy with it so far.

---

## 🤝 Contributing / Feedback

If you have suggestions, questions, or want to share your feedback, feel free to contact me! 
I know this config is far from perfect and in parts very cluttered. I’m still relatively new to nix, but I hope it gives you some inspiration or helped you to solve an issue you're working on.

---

Happy ricing y'all!  |^.^/ 
**MaySeikatsu**
