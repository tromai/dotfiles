# Hyprland Setup (Ubuntu 26.04)

This folder holds a minimal Hyprland config that mirrors my regolith3 (i3) setup.

- `hyprland.conf` — the Hyprland configuration
- `SHORTCUTS.md` — human-readable list of keybindings

## 1. Install Hyprland

> Note: Hyprland is bleeding-edge and the project officially supports Arch/NixOS.
> On Ubuntu, prefer the distro package; fall back to building from source if the
> packaged version is too old or missing.

### Option A — apt (try this first)

Ubuntu ships Hyprland in the `universe` repository on recent releases, so on
26.04 this should work:

```bash
sudo apt update
sudo apt install hyprland
```

Recommended companion tools used by this config (install what you want):

```bash
sudo apt install kitty wofi hyprlock waybar \
                 xdg-desktop-portal-hyprland \
                 polkitd pipewire wireplumber
```

Check the installed version (this config targets reasonably recent Hyprland):

```bash
hyprland --version
```

### Option B — build from source (if apt's version is too old)

```bash
# Build dependencies (C++26 capable toolchain, gcc>=15)
sudo apt update
sudo apt install -y build-essential cmake-extras meson ninja-build \
  git gcc-15 g++-15 \
  libwayland-dev wayland-protocols libdrm-dev libxkbcommon-dev \
  libpixman-1-dev libcairo2-dev libpango1.0-dev libinput-dev \
  libgbm-dev libgles2-mesa-dev libegl1-mesa-dev libdisplay-info-dev \
  libtomlplusplus-dev libzip-dev librsvg2-dev

# Build + install (pulls hypr* deps via submodules)
git clone --recursive https://github.com/hyprwm/Hyprland
cd Hyprland
make all
sudo make install
```

If you hit `.so` mismatch errors, the apt route is safer — building manually can
pull in incompatible versions of the `hypr*` dependencies. See the official wiki:
https://wiki.hypr.land/Getting-Started/Installation/

## 2. Install this configuration

Hyprland reads its config from `~/.config/hypr/hyprland.conf`.

```bash
mkdir -p ~/.config/hypr
ln -sf "$(pwd)/hyprland.conf" ~/.config/hypr/hyprland.conf
```

(Run the above from inside this `hyprland/` folder. Using a symlink keeps the
config tracked in this dotfiles repo. Use `cp` instead of `ln -sf` if you prefer
a plain copy.)

## 3. Log in to Hyprland

1. Log out of your current session.
2. At the GDM/login screen, click the gear/session icon.
3. Select **Hyprland** from the session list.
4. Log in.

If Hyprland doesn't appear as a session, make sure the desktop entry exists:

```bash
ls /usr/share/wayland-sessions/hyprland.desktop
```

(The apt package installs this automatically; a source build does too via
`make install`.)

## 4. Reload / iterate

While inside Hyprland you can reload the config without logging out:

```
Super + Shift + c
```

(or run `hyprctl reload`).

## Notes

- Adjust the placeholder apps in `hyprland.conf` to taste: terminal `kitty`,
  launcher `wofi`, lock `hyprlock`. Swap for your preferred Wayland tools.
- **Look & feel** is intentionally basic: small gaps, 2px blue active border,
  light rounding (6px), a subtle shadow, and short fade/slide animations. Blur is
  off to stay lightweight. A `waybar` status bar is started automatically — make
  sure it's installed (`sudo apt install waybar`) or comment out the
  `exec-once = waybar` line. For a wallpaper, install `hyprpaper` and uncomment
  the `exec-once = hyprpaper` line.
- NVIDIA GPUs need extra setup — see https://wiki.hypr.land/Nvidia/
- See `SHORTCUTS.md` for the full keybinding list.
