# Interactive Arch installer and linked dotfiles — design

Date: 2026-10-22. Status: approved in conversation, pending written review.

## Goal

One script, launched from the Arch ISO, that turns a blank (or dual-boot) machine into this
exact desktop: Hyprland + Quickshell, fish, kitty, the dev tooling, drivers for whatever CPU
and GPU it finds. It asks every question up front, shows one summary, takes one typed
confirmation, and then runs hands-off to a reboot that lands on a working session.

Alongside it, the dotfiles stop being a copy: `~/.config/<app>` becomes a symlink into the
repo, so editing the live config edits the repo and publishing is `git add`, `commit`, `push`.

## Work order

1. **Linked dotfiles on this machine** (small, verifiable, everything else builds on it).
2. **The installer**, which reproduces that linked layout on a new machine.

---

## Part 1 — linked dotfiles

### Repo location

The repo moves from `~/Downloads/dotfile_hyperland` to `~/.dotfiles`. The GitHub remote
(`git@github.com:bboysidou/dotfile_hyperland.git`) is unchanged.

### nvim as a submodule

`~/.config/nvim` is its own git repo (branch `master`, **no remote today**) and is currently
mirrored by hand into `dotfiles/nvim` with `rsync --exclude=.git`.

- A GitHub repo for nvim is created (name to confirm; this is a public action and needs an
  explicit OK before it happens), `~/.config/nvim` gets it as `origin` and is pushed.
- `dotfiles/nvim` (the mirrored copy) is removed from the dotfiles index and re-added as a
  submodule pointing at that remote.
- The nvim repo has uncommitted changes today (`.luarc.json` modified, a spec file deleted);
  they are resolved by the user before the switch, never discarded by the script.

### Link map — `install/links.list`

One line per link, `repo-relative-source  target`, `~` expanded at run time:

```
fontconfig        ~/.config/fontconfig
hypr              ~/.config/hypr
quickshell        ~/.config/quickshell
systemd/user/quickshell.service    ~/.config/systemd/user/quickshell.service
systemd/user/quickshell.service.d  ~/.config/systemd/user/quickshell.service.d
nvim              ~/.config/nvim
kitty             ~/.config/kitty
tmux              ~/.config/tmux
fish              ~/.config/fish
custom_scripts    ~/.config/custom_scripts
fastfetch         ~/.config/fastfetch
mpv               ~/.config/mpv
yazi              ~/.config/yazi
mimeapps.list     ~/.config/mimeapps.list
gtk/gtk-3.0/settings.ini  ~/.config/gtk-3.0/settings.ini
gtk/gtk-3.0/bookmarks     ~/.config/gtk-3.0/bookmarks
gtk/gtk-4.0/settings.ini  ~/.config/gtk-4.0/settings.ini
gtk/.gtkrc-2.0    ~/.gtkrc-2.0
gtk/.Xresources   ~/.Xresources
dbus/org.freedesktop.FileManager1.service  ~/.local/share/dbus-1/services/org.freedesktop.FileManager1.service
icons/kora        ~/.local/share/icons/kora
icons/kora-robot  ~/.local/share/icons/kora-robot
fonts             ~/.local/share/fonts/dotfiles
Wallpaper         ~/Pictures/wallpaper
```

`gtk-3.0`, `gtk-4.0` and `systemd/user` are linked per file, not per directory: the
Graphite theme puts `gtk.css`/`assets` links into `~/.config/gtk-4.0`, and
`systemctl --user enable` writes `.wants/` links into `~/.config/systemd/user`; neither belongs
in the repo. Every other entry is a directory linked whole, because apps that save a symlinked *file* often
replace it with a regular file (`nwg-look` with gtk `settings.ini`, `xdg-mime` with
`mimeapps.list`). Because the repo is the target, a broken link shows up immediately as a
diverged file; `link.sh --check` reports any target that is no longer a link to the repo.

System files are **copied**, never linked, because root-owned config must not resolve into a
user-writable home: `/etc/fonts/local.conf`, udev rules, `power-events.service`.

Runtime files the apps write inside linked directories are already gitignored
(`fish_variables`, `fish_history`, `fishd.tmp*`, `hypr/config/env-gpu.lua`,
`custom_scripts/saved_sessions.txt`, `tmux_sessions.txt`). Any new one found during migration
is added to `.gitignore` in the same change. One is known already: the GPU step writes the
machine-specific `systemd/user/quickshell.service.d/gpu.conf`, which gets an ignore entry.

### `install/link.sh`

Standalone, also used by the installer.

- `link.sh` — for every entry: if the target already links to the source, skip. If the
  target exists as a real file or directory, print `diff -r target source`, ask, move it to
  `~/.config-backup/<timestamp>/<target path>`, then `ln -sfn source target`.
- `link.sh --check` — read-only; lists targets that are missing or not links into the repo.
- `link.sh --dry-run` — prints the actions, changes nothing.
- `link.sh --yes` — no per-entry prompt (the installer, on a fresh home, has nothing to back up).

### Migration on this machine

1. Commit or stash anything pending in both repos.
2. `mv ~/Downloads/dotfile_hyperland ~/.dotfiles`.
3. nvim remote + submodule switch (above).
4. `~/.dotfiles/install/link.sh` — review every diff before it moves anything.
5. Reload Hyprland and Quickshell, check bar, launcher, lock, wallpaper, fish prompt, nvim.
6. Delete `~/.config-backup/<timestamp>` only after the user confirms everything works.

Rollback per entry: remove the link, move the backup back.

### Hyprland autostart on tty1

New `fish/conf.d/hyprland_autostart.fish`: on a login shell, on `/dev/tty1`, with no
`WAYLAND_DISPLAY`, run `exec start-hyprland`. `uwsm` leaves the package list (unused, and
Hyprland no longer recommends it).

---

## Part 2 — the installer

### Entry and bootstrap

`install.sh` at the repo root. On the ISO:

```
curl -fsSL https://raw.githubusercontent.com/bboysidou/dotfile_hyperland/main/install.sh -o install.sh
bash install.sh            # or: bash install.sh --dry-run
```

The script downloads the repo tarball with curl into the live environment (no git on the
ISO needed), installs `gum` into the live environment with `pacman -Sy --noconfirm gum`, and
sources `install/lib/*.sh`. If gum cannot be installed, `ui.sh` falls back to plain `read`
prompts with the same flow.

### Layout

```
install.sh                  entry: parse flags, bootstrap, run stages
install/lib/ui.sh           gum wrappers: header, spin, confirm, input, choose, table, error box
install/lib/state.sh        answers file, stage markers, resume, traps, logging, retry
install/lib/detect.sh       cpu, gpu (+ nvidia generation), disks, other OSes, laptop, vm, wifi
install/lib/disk.sh         disk discovery, wipe plan, alongside plan, partition, format, mount
install/lib/base.sh         mirrors, pacstrap, fstab, chroot system config, gpu config
install/lib/boot.sh         systemd-boot or grub
install/lib/user.sh         yay, AUR, dotfiles clone + link, fish, tmux, theme, wallpapers
install/lib/gpu.sh          gpu detection, packages, system + user gpu files (ported install/gpu.sh)
install/lib/bundles.sh      bundle parsing, selection, per-bundle system/user hooks
install/lib/questions.sh    stage 1: questions, summary, change menu, destructive confirmation
install/bundles/NN-name.list  `#: title|description|default=` header, one package per line, `aur:` prefix for AUR
install/links.list          link map (part 1)
install/link.sh             linker (part 1)
install/browsers.sh         kept; called by the browsers bundle
install/android_dev.sh      kept; called by the android bundle
```

Removed once their logic has moved: `install/arch_install.sh`, `install/post_arch_install.sh`,
`install/core/`, `install/gpu.sh`, `install/manual_stuff.sh`.

### Stages

| # | Stage | Runs as | What |
|---|---|---|---|
| 0 | preflight | ISO root | UEFI check, network (offers `iwctl` if down), `timedatectl set-ntp true`, keyring, gum |
| 1 | questions | ISO root | everything below, then summary + typed confirmation |
| 2 | disk | ISO root | partition, format, btrfs subvolumes, mount |
| 3 | base | ISO root | reflector mirrors, `pacstrap -K`, `genfstab -U` |
| 4 | system | chroot root | locale, time, hosts, zram, sudo, pacman/makepkg tweaks, multilib, drivers, mkinitcpio, bootloader, services, security files |
| 5 | user | chroot, `runuser -u <user>` | yay-bin, AUR packages, clone `~/.dotfiles` with submodules, `link.sh --yes`, fisher + tide, tpm, Graphite theme, `browsers.sh`, chsh fish |
| 6 | finish | ISO root | remove temp sudoers, copy log to `/mnt/var/log/installer.log`, summary, offer reboot |

After the confirmation in stage 1, nothing prompts again unless a step fails.

### Stage 1 questions

hostname · username · user password (hidden, twice) · root password (hidden, twice) ·
timezone (fuzzy list from `/usr/share/zoneinfo`) · locale · console keymap · target disk ·
install mode (wipe / alongside) · bootloader (systemd-boot default / GRUB) · bundles (with
per-package drill-down) · detected-hardware overrides.

Defaults match today's machine: user `sidouxp3`, timezone `Africa/Algiers`, locale
`en_US.UTF-8`, keymap `us`.

Passwords are only ever piped to `chpasswd` on stdin: never written to disk, never on a
command line, never in the answers file or the log.

### Disk

**Discovery.** `lsblk -dnpo NAME,SIZE,MODEL,TRAN,TYPE`, keeping `TYPE=disk` and dropping the
device backing `/run/archiso/bootmnt`, loop, zram and optical devices.

**Partition paths are never built from a suffix.** After every partitioning command:
`partprobe`, `udevadm settle`, then resolve partition *N* with `lsblk -lnpo NAME,PARTN
<disk>`. One rule covers `nvme0n1p2`, `sda2`, `mmcblk0p2`, `vda2`.

**Other OS detection.** Every ESP on every disk is mounted read-only and its `/EFI/*` listed
(`Microsoft` → Windows, `ubuntu`, `fedora`, … → that distro); `os-prober` (installed into the
live environment) catches other Linux installs. Results are shown as tags on each disk row.

**Free space.** `parted -m <disk> unit MiB print free`, largest free region. Minimum 40 GiB.
The installer **never shrinks a partition**; if space is short it says to shrink in the
other OS first and returns to disk selection.

**Modes.**

- *Wipe*: new GPT, ESP 2 GiB FAT32 (`ef00`) mounted at `/boot`, rest btrfs.
- *Alongside*: btrfs in the largest free region. The existing ESP is reused at `/boot` if it
  has at least 500 MiB free; otherwise a 1 GiB FAT32 XBOOTLDR partition (`ea00`) is created
  in the free region and mounted at `/boot`, with the ESP at `/efi`.

`/boot` is FAT in every case, never btrfs, so GRUB can always write `grubenv`.

**btrfs.** Subvolumes `@`, `@home`, `@var`, `@tmp`; mount options
`noatime,compress=zstd:3,space_cache=v2,discard=async`.

**Guards.**

- Wipe requires typing the disk name; if that disk carries an OS, a red warning names it.
- Alongside shows a before/after partition table and asks yes/no.
- Secure Boot enabled (`SecureBoot` efivar) blocks with "disable Secure Boot in firmware".
- A BitLocker partition present: warning to have the recovery key at hand.
- Dual-boot finish note: Windows keeps the RTC in local time; the summary prints the
  `RealTimeIsUniversal` registry fix.

### Hardware detection

All results appear on the summary screen and can be overridden there.

- **CPU**: `/proc/cpuinfo` vendor → `amd-ucode` / `intel-ucode`. Microcode is packed into the
  main initramfs by mkinitcpio, so no separate `initrd` line is written.
- **GPU**: the existing `gpu.sh` logic (hybrid detection via `boot_vga`, stable
  `/dev/dri/igpu` / `/dev/dri/dgpu` udev symlinks, `AQ_DRM_DEVICES`, generated
  `hypr/config/env-gpu.lua`, Quickshell pinned to the iGPU, `/etc/environment` VA-API vars,
  old-Intel `i965` fallback) moves into `detect.sh` + `base.sh` unchanged, plus:
  - NVIDIA generation from the `lspci` codename: `TU`/`GA`/`AD`/`GB` → `nvidia-open-dkms`;
    `GM`/`GP`/`GV` → `nvidia-580xx-dkms` (AUR); older → nouveau with a warning.
  - `nvidia-utils`, `lib32-nvidia-utils`, `egl-wayland`, `libva-nvidia-driver`, matching
    kernel headers; `nvidia-prime` on hybrids.
  - `/etc/modprobe.d/nvidia.conf` with `options nvidia_drm modeset=1` (default in current
    `nvidia-utils`, kept because the Hyprland wiki lists it).
  - `nvidia nvidia_modeset nvidia_uvm nvidia_drm` in `MODULES` (with `i915` / `amdgpu` first
    on hybrids), `kms` removed from `HOOKS`, `mkinitcpio -P`.
  - `nvidia-suspend`, `nvidia-hibernate`, `nvidia-resume` enabled.
  - Hyprland env: `LIBVA_DRIVER_NAME=nvidia`, `__GLX_VENDOR_LIBRARY_NAME=nvidia` (when NVIDIA
    renders), `NVD_BACKEND=direct`, `ELECTRON_OZONE_PLATFORM_HINT=auto`,
    `AQ_FORCE_LINEAR_BLIT=0` on hybrids.
- **Laptop**: any `/sys/class/power_supply/BAT*` → laptop bundle pre-ticked.
- **VM**: `systemd-detect-virt` → guest tools (`qemu-guest-agent`, `spice-vdagent`), no GPU
  vendor packages.

### Bootloader

Shared kernel command line: `root=UUID=<root> rootflags=subvol=@ rw loglevel=7
systemd.show_status=1`, plus `lsm=landlock,lockdown,yama,integrity,apparmor,bpf` when the
security bundle is selected. The fallback entry omits the logging parameters.

**systemd-boot** (default)

- Installed with `arch-chroot -S /mnt bootctl --esp-path=<esp> --boot-path=/boot install`
  (`-S` is required: plain `arch-chroot` runs in a pid namespace where `bootctl` refuses to
  write EFI variables).
- `loader.conf`: `default @saved`, `timeout 3`, `console-mode max`, `editor no`.
- Entries `arch.conf` and `arch-fallback.conf`; no microcode `initrd` line.
- Windows on the same ESP: automatic `auto-windows` entry, nothing to write.
- Windows on another disk: systemd-boot cannot start it directly, and the UEFI-shell chainload
  needs an FS alias that only the shell knows at run time. The bootloader question therefore
  defaults to GRUB when Windows is found on another disk. If systemd-boot is chosen anyway,
  `edk2-shell` is copied to `<esp>/shellx64.efi` and the finish screen gives the `map` →
  `windows.conf` recipe; the firmware boot menu also works.
- Updates: automatic (`systemd-boot-update.service`, systemd ≥ 261.2); no hook needed.

**GRUB**

- Packages `grub efibootmgr os-prober fuse3 ntfs-3g`.
- `grub-install --target=x86_64-efi --efi-directory=<esp> --bootloader-id=GRUB`, run inside
  the chroot. In wipe mode it is also installed with `--removable` (firmware that ignores
  NVRAM entries, e.g. MSI boards); skipped in alongside mode because Windows owns that path.
- `/etc/default/grub`: `GRUB_DEFAULT=saved`, `GRUB_SAVEDEFAULT=true`, `GRUB_TIMEOUT=5`,
  `GRUB_DISABLE_OS_PROBER=false`, `GRUB_GFXMODE=auto`, `GRUB_GFXPAYLOAD_LINUX=keep`,
  `GRUB_DISABLE_SUBMENU=y`.
- `GRUB_CMDLINE_LINUX_DEFAULT` carries only the extras (`lsm=`, logging): `grub-mkconfig`
  writes `root=UUID=` and `rootflags=subvol=@` itself.
- `grub-mkconfig -o /boot/grub/grub.cfg` with every other ESP mounted so os-prober sees them.
  os-prober can miss systems inside a chroot; the finish screen then says to re-run
  `sudo grub-mkconfig -o /boot/grub/grub.cfg` after first boot.
- `/etc/pacman.d/hooks/95-grub.hook`: on a `grub` upgrade, re-run `grub-install` (same
  arguments) and `grub-mkconfig`, because a new config syntax with an old binary can leave
  the machine unbootable.

### System configuration (stage 4)

Carried over from `arch_install.sh` / `post_arch_install.sh`: timezone + `hwclock --systohc`,
locale, vconsole, hostname + hosts, zram-generator (`zram-size = ram`, zstd), user in
`wheel,users,storage,power,audio,video,input`, `%wheel` sudo, pacman `Color`, `CheckSpace`,
`VerbosePkgLists`, `ParallelDownloads = 12`, `MAKEFLAGS=-j$(nproc)`, multilib,
`NetworkManager`, `fstrim.timer`, `bluetooth`, `cronie`, `docker` (docker bundle),
`paccache.timer`, solaar udev rule (peripherals bundle), font `local.conf`.

Security bundle without a running system: `ufw` is configured by file (`ENABLED=yes` in
`/etc/ufw/ufw.conf`, default deny incoming / allow outgoing) and its service enabled, because
`ufw enable` needs a live netfilter; `fail2ban` `jail.local` as today; `apparmor` enabled.

AUR builds need a non-root user and sudo without a terminal: a temporary
`/etc/sudoers.d/99-installer` (`<user> ALL=(ALL) NOPASSWD: ALL`, mode 0440, validated with
`visudo -c`) exists only during stage 5 and is removed by the `EXIT` trap whatever happens.

### Bundles

`install/bundles/<name>.list` replaces the arrays in `install/core/packages.sh`.

| Bundle | Default | Contents |
|---|---|---|
| core | always | base tools, hyprland, `xdg-desktop-portal-hyprland` + `-gtk`, quickshell and its deps (**cliphist** added), fish, kitty, pipewire stack, fonts, polkit, networkmanager, Graphite theme, cursor + icon themes |
| dev | on | gcc, clang, cmake, ninja, meson, node/npm, jdk17 + jdk21, github-cli, opencode, tree-sitter-cli |
| docker | on | docker, docker-compose, group membership, service |
| android | off | android-tools, android-udev, scrcpy, then `android_dev.sh` |
| browsers | on | firefox, chromium, brave-bin, zen-browser-bin, then `browsers.sh` |
| office | on | onlyoffice-bin, evince, bruno-bin |
| media | on | obs-studio, kdenlive, vlc, mpv, codecs, discord |
| ocr | on | `tesseract-data-fra`, `-ara` (tesseract + `-eng` are in core: screenshot OCR needs them) |
| peripherals | on | solaar + udev rule, openrgb |
| security | on | ufw, fail2ban, apparmor (+ `lsm=`), arch-audit |
| laptop | auto | power-profiles-daemon (the power udev rules stay with todo 11: they need real hardware) |

Dropped: `zsh`, `uwsm`, `zscroll-git`, `papirus-icon-theme` (unused; kora-robot inherits
breeze), `gnome-shell-extensions` (pulled in all of gnome-shell). Added: `cliphist`,
`breeze-icons`, `hwinfo`, `pciutils`, `libpulse`, `polkit`, `xdg-desktop-portal-gtk`,
`antigravity` (AUR). `nwg-look` / `nwg-displays` moved from the AUR to the official repos.
`qs-hwinfo` (Quickshell root helper) is installed and enabled as a system service.

The bundle screen is a multi-select; choosing to edit a bundle opens a pre-ticked
multi-select of its packages.

### Reliability

- `set -Eeuo pipefail`; an `ERR` trap shows stage, failed command and the last 20 log lines
  in an error box, then offers retry / skip (only for steps marked non-critical: fisher,
  tide, Graphite theme, wallpapers, `browsers.sh`) / abort.
- `EXIT` trap: always removes the temp sudoers file.
- Full command output goes to `/tmp/install.log`; the screen shows headers and spinners.
- Answers (no passwords) in `/tmp/install.answers`; a marker per finished stage in
  `/tmp/install.state`. A re-run offers to resume from the first unfinished stage. Stages 0–2
  re-run only on explicit request.
- Network commands (pacstrap, pacman, yay, git, curl) retry three times with backoff.
- `--dry-run` prints every command that would run and ends with the full plan; it changes
  nothing.

### Verification

Testing is paused, so verification is gates and a real run:

- `bash -n` and `shellcheck -x` clean on every script.
- `--dry-run` completes and its plan matches the chosen answers.
- QEMU + OVMF with the current archiso and a blank qcow2: wipe + systemd-boot, then
  wipe + GRUB. Pass = reboot reaches tty1, login starts Hyprland with Quickshell.
- Alongside mode: in a VM whose disk already holds a second ESP and partition standing in
  for another OS. The real Windows disk is never used for testing.
- Part 1: `link.sh --check` reports every target linked; Hyprland and Quickshell reload
  without errors; `git -C ~/.dotfiles status` stays clean after a normal session.

## Out of scope

LUKS, hibernation, snapper/snapshots (todo item 2), Secure Boot signing, BIOS/legacy boot,
partition shrinking.
