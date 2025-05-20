# 🍁 Bloated NixOS Config with Hyprland and Stylix 🍁

Welcome!  
This repo contains my personal NixOS system configuration, focused on a fully riced Hyprland desktop with dynamic theming and a modular, flake-based structure. It’s a living setup—always evolving as I learn more about NixOS and the world of ricing.

---

## ✨ Screenshots
### Autumn Themed Desktop with Stylix & Hyprpanel

![Autumn Theme with Stylix](https://github.com/user-attachments/assets/fe25b266-b54e-421a-aa6a-4b1cfb4c22c8)

Here’s my autumn-inspired rice! The wallpaper and system colors are managed by [Stylix](https://github.com/danth/stylix), and the panel is powered by [Hyprpanel](https://github.com/hyprwm/hyprpanel). The goal: everything matches the current wallpaper, for a cozy, unified look.

---

## 🗂️ Repo Structure

- **hosts/**  
  Per-machine configurations. Each host (laptop, desktop, etc.) has its own entrypoint, making it easy to manage multiple systems with shared and unique settings.

- **modules/**  
  Custom NixOS modules for things like Hyprland, theming, and extra services. This is where most of my desktop and ricing logic lives.

- **pkgs/**  
  Custom or overridden Nix packages. If I need to patch or tweak something from nixpkgs, it goes here.

- **ressources/**  
  Wallpapers, icons, and other static assets that make the rice shine.

- **scripts-unused/**  
  Scripts I’m not currently using but might revisit later.

- **flake.nix / flake.lock**  
  The main entry point for the configuration, using Nix flakes for reproducibility and modularity.

---

## 🖥️ What’s in the Config?

- **Hyprland** as the main Wayland compositor, with custom settings for window management, keybinds, and effects.
- **Stylix** for dynamic theming—automatically updates GTK, Qt, terminal, and other app colors to match the wallpaper.
- **Hyprpanel** as the status bar, themed to match the system.
- **Anime & Nature Wallpapers** with a focus on seasonal vibes.
- **Declarative Home Manager** config for user-level dotfiles and app settings.
- **Modular NixOS Setup**—split into reusable modules for easy tweaking and expansion.
- **Custom scripts** (planned) for future features like automatic wallpaper and theme switching (think pywal/matugen, but “the Nix way”).

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

## 📝 Roadmap / Wishlist

- [ ] Automatic wallpaper and theme switching (matugen/pywal style, but fully declarative)
- [ ] More modularization and cleanup of configs
- [ ] Improved documentation and onboarding for others

---

## 💬 Why NixOS & Hyprland?

I chose NixOS for its reproducibility and modularity—no more “it worked on my machine” headaches.  
Hyprland gives me a fast, modern Wayland environment with great ricing potential.  
Stylix and Home Manager tie it all together for a seamless, auto-themed desktop.

---

## 🤝 Contributing / Feedback

If you have suggestions, questions, or want to share your own rice, feel free to contact me!  
I’m always learning and happy to chat about NixOS, Hyprland, and ricing.

---

**MaySeikatsu**
