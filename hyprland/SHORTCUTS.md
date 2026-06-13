# Hyprland Shortcuts (mirrors regolith3)

`$mod` = **SUPER** (⊞ Win), matching the i3 `$mod` used in regolith3.

Bindings below reproduce the **Regolith 3 defaults** for the basic actions,
plus the three **custom** bindings you had in `regolith3/i3/config.d/move_display.conf`.
Any default not listed here was intentionally left out to keep this minimal.

## Launchers
| Shortcut | Action |
|----------|--------|
| `Super` + `Enter` | Open terminal |
| `Super` + `Shift` + `Enter` | Open browser (firefox) |
| `Super` + `Space` | Application launcher |
| `Super` + `Shift` + `Space` | Run command |

## Window Management
| Shortcut | Action |
|----------|--------|
| `Super` + `f` | Toggle fullscreen |
| `Super` + `Shift` + `f` | Toggle floating |
| `Super` + `Shift` + `q` | Close window |
| `Super` + `t` | Toggle split orientation |
| `Super` + `h/j/k/l` or arrows | Move focus left/down/up/right |
| `Super` + `Shift` + `h/j/k/l` or arrows | Move window left/down/up/right |
| `Super` (hold) + mouse drag | Move / resize floating window |

## Workspaces
| Shortcut | Action |
|----------|--------|
| `Super` + `0..9` | Switch to workspace 1–10 |
| `Super` + `Shift` + `0..9` | Move window to workspace 1–10 |
| `Super` + `Tab` | Next workspace |
| `Super` + `Shift` + `Tab` | Previous workspace |
| `Super` + `Alt` + `→` | Next workspace |
| `Super` + `Alt` + `←` | Previous workspace |

## Session
| Shortcut | Action |
|----------|--------|
| `Super` + `Escape` | Lock screen |
| `Super` + `Shift` + `c` | Reload config |
| `Super` + `Shift` + `e` | Logout / exit Hyprland |

## Custom (carried over from regolith3 move_display.conf)
| Shortcut | Action |
|----------|--------|
| `Super` + `Ctrl` + `.` (greater) | Move workspace to next monitor |
| `Super` + `Ctrl` + `,` (less) | Move workspace to previous monitor |
| `Super` + `Alt` + `w` | Switch to previously focused workspace |

## App → Workspace assignments (from apps.conf)
| App | Workspace |
|-----|-----------|
| Slack | 1 |
| VS Code | 2 |
| Firefox (aurora) | 3 |
| Cisco AnyConnect / Gnome Control Center | 4 |

## Autostart
- Slack
- Firefox
- Cisco AnyConnect (`/opt/cisco/anyconnect/bin/vpnui`)

---
### Notes / things to review
- **Terminal & launcher commands** are placeholders: `kitty` (terminal) and
  `wofi` (launcher). Regolith uses `gnome-terminal`/`ilia`; change these to your
  preferred Wayland tools.
- **Lock** uses `hyprlock` — install it or swap for your locker.
- Regolith defaults I left out for minimalism (add if you want them):
  file browser, file search, notification viewer, scratchpad, resize mode,
  bluetooth/wifi/display settings, save/load layout, workspaces 11–19,
  reboot/poweroff/sleep, restart i3 equivalent.
