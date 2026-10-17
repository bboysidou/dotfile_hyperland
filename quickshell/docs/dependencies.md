# Runtime dependencies

The shell shells out to these binaries. They are not bundled — a missing one
makes the feature that uses it fail silently, so install them before running.

```sh
sudo pacman -S --needed \
    networkmanager iw brightnessctl \
    grim slurp tesseract tesseract-data-eng wl-clipboard libnotify \
    pacman-contrib btop htop kitty \
    curl cava libpulse

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
| `slurp`, `xdg-desktop-portal-hyprland` | `slurp`, `xdg-desktop-portal-hyprland` | share picker — region pick, and the portal that launches it |
| `tesseract` | `tesseract` + a language pack | screenshot OCR |
| `wl-copy` | `wl-clipboard` | screenshot OCR |
| `notify-send` | `libnotify` | screenshot notifications |
| `checkupdates` | `pacman-contrib` | `Updates` — repo updates |
| `yay` | `yay` (AUR) | `Updates` — AUR updates |
| `btop`, `htop` | `btop`, `htop` | dashboard monitor launchers |
| `kitty` | `kitty` | terminal launcher for the above |
| `solaar` | `solaar` (AUR) | mouse battery settings launcher |
| `zen-browser` | `zen-browser-bin` (AUR) | calendar launcher |
| `curl` | `curl` | `Geo` — IP location and place search; `Notif` — browser favicons |
| `cava` | `cava` | `Cava` — media visualiser bars |
| `paplay` | `libpulse` | `NotifSound` — notification sound |
| `nvtop` | `nvtop` | hardware sheet — GPU monitor launcher |
| `lspci` | `pciutils` | `GpuStats` — GPU model name |
| `top`, `find`, `xargs`, `awk` | `procps-ng`, `findutils`, `gawk` | `CpuStats` / `GpuStats` — top processes |
| `dmidecode` | `dmidecode` | `qs-hwinfo` helper — DIMM details (runs as root) |

Everything else the shell calls (`cat`, `ls`, `uname`, `timeout`, `systemctl`,
`pacman`, `rfkill`) ships with a base Arch install.

## Share picker

`system/qs-share-picker` replaces `hyprland-share-picker` for every screen share
that goes through the portal (Zen, Firefox, Chromium, Electron). xdph runs it,
it opens the `share` module over IPC and relays the pick back through a FIFO.
If the shell is not running it falls back to the stock picker.

```
# ~/.config/hypr/xdph.conf
screencopy {
    custom_picker_binary = /home/sidouxp3/.config/quickshell/system/qs-share-picker
}
```

Then `systemctl --user restart xdg-desktop-portal-hyprland`.

## Root helper

`system/qs-hwinfo` + `system/qs-hwinfo.service` publish two root-only readings to
`/run/qs-hw/`: `dimms.tsv` (`dmidecode -t memory`, once at boot) and `cpu_power`
(RAPL package energy, rounded to whole watts every 2 s — never the raw
`energy_uj` counter, which is root-only because of CVE-2020-8694). Install:

```
sudo install -Dm755 system/qs-hwinfo /usr/local/bin/qs-hwinfo
sudo install -Dm644 system/qs-hwinfo.service /etc/systemd/system/qs-hwinfo.service
sudo systemctl daemon-reload && sudo systemctl enable --now qs-hwinfo
```

Without it the CPU power row shows a dash and the memory sheet lists no modules.

## Degradation

`iw` is the only optional one. Without it `Net.signals` stays empty and the
network cards fall back to NetworkManager's signal percentage instead of dBm —
no error, just less precision. Every other binary above is required by the
feature that calls it.
