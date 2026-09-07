# Runtime dependencies

The shell shells out to these binaries. They are not bundled — a missing one
makes the feature that uses it fail silently, so install them before running.

```sh
sudo pacman -S --needed \
    networkmanager iw brightnessctl \
    grim slurp tesseract tesseract-data-eng wl-clipboard libnotify \
    pacman-contrib btop htop kitty

# AUR
yay -S solaar
```

| Binary | Package | Used by |
| --- | --- | --- |
| `nmcli` | `networkmanager` | `Net` — connection details (MAC, IPv4, gateway, DNS) |
| `iw` | `iw` | `Net` — per-network RSSI in dBm from `scan dump` |
| `rfkill` | `util-linux` | `Bt` — unblocks the adapter before powering it on |
| `nm-connection-editor` | `nm-connection-editor` | enterprise Wi-Fi hand-off |
| `brightnessctl` | `brightnessctl` | `Brightness` |
| `grim`, `slurp` | `grim`, `slurp` | screenshot module |
| `tesseract` | `tesseract` + a language pack | screenshot OCR |
| `wl-copy` | `wl-clipboard` | screenshot OCR |
| `notify-send` | `libnotify` | screenshot notifications |
| `checkupdates` | `pacman-contrib` | `Updates` — repo updates |
| `yay` | `yay` (AUR) | `Updates` — AUR updates |
| `btop`, `htop` | `btop`, `htop` | dashboard monitor launchers |
| `kitty` | `kitty` | terminal launcher for the above |
| `solaar` | `solaar` (AUR) | mouse battery settings launcher |
| `zen-browser` | `zen-browser-bin` (AUR) | calendar launcher |

Everything else the shell calls (`cat`, `ls`, `uname`, `timeout`, `systemctl`,
`pacman`, `rfkill`) ships with a base Arch install.

## Degradation

`iw` is the only optional one. Without it `Net.signals` stays empty and the
network cards fall back to NetworkManager's signal percentage instead of dBm —
no error, just less precision. Every other binary above is required by the
feature that calls it.
