This directory contains the configuration for my GNOME setup that mimicks my Regolith setup.

It only requires GNOME and its extensions, you don't have to install additional tiling managers.

It's suitable if you cannot run a tiling manager, but doesn't fully capture the experience of Regolith
for example.

Make sure these GNOME extensions are installed on your machine:
- `paperwm@paperwm.github.com`
- `tiling-assistant@leleat-on-github`
- `dash-to-dock@micxgx.gmail.com`

To install and manage GNOME extensions, install these:

```
sudo apt install gnome-shell-extension-manager
```

Load the configuration:

```
dconf load /org/gnome/shell/extensions/ < gnome-extensions-settings.ini
```

Then you need to log out and log back in.

This configuration is tested on Ubuntu 26.04
