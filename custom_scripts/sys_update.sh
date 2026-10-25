#!/usr/bin/env bash
set -uo pipefail

MIN_FREE_GIB=10
CACHE_KEEP_VERSIONS=2
SUDO_REFRESH_SECONDS=60
SNAPPER_CONFIG="root"
SNAPSHOT_DESCRIPTION="sys-update"
INHIBIT_WHAT="sleep:idle"
INHIBIT_WHO="sys-update"
INHIBIT_WHY="System update in progress"
HYPRLAND_PROCESS="Hyprland"

sudoPid=""
inhibitPid=""

say() {
  printf '\n\033[1m:: %s\033[0m\n' "$1"
}

warn() {
  printf '\033[33mwarning:\033[0m %s\n' "$1"
}

die() {
  printf '\033[31merror:\033[0m %s\n' "$1" >&2
  exit 1
}

confirm() {
  local reply
  read -rp "$1 [y/N] " reply
  [[ "$reply" == [yY]* ]]
}

stopBackground() {
  if [[ -n "$inhibitPid" ]]; then
    kill "$inhibitPid" 2>/dev/null
    inhibitPid=""
  fi
  if [[ -n "$sudoPid" ]]; then
    kill "$sudoPid" 2>/dev/null
    sudoPid=""
  fi
}

requireFreeSpace() {
  local freeGib
  freeGib=$(($(df --output=avail -B1G / | tail -1)))
  if ((freeGib < MIN_FREE_GIB)); then
    die "only ${freeGib} GiB free on /, need ${MIN_FREE_GIB} GiB"
  fi
}

keepSudoAlive() {
  sudo -v || die "sudo authentication failed"
  while sleep "$SUDO_REFRESH_SECONDS"; do
    sudo -n true 2>/dev/null || exit
  done &
  sudoPid=$!
}

holdInhibitor() {
  systemd-inhibit --what="$INHIBIT_WHAT" --mode=block --who="$INHIBIT_WHO" --why="$INHIBIT_WHY" sleep infinity &
  inhibitPid=$!
}

pruneCache() {
  say "Pruning the package cache"
  sudo paccache -rk"$CACHE_KEEP_VERSIONS" || warn "paccache failed"
  sudo paccache -ruk0 || warn "paccache failed for uninstalled packages"
}

takeSnapshot() {
  if ! command -v snapper >/dev/null || ! sudo snapper list-configs 2>/dev/null | grep -qw "$SNAPPER_CONFIG"; then
    say "No snapper config '${SNAPPER_CONFIG}', skipping the snapshot"
    return 0
  fi
  say "Creating a snapshot"
  if sudo snapper -c "$SNAPPER_CONFIG" create -c number -d "$SNAPSHOT_DESCRIPTION"; then
    sudo snapper -c "$SNAPPER_CONFIG" cleanup number || warn "snapshot cleanup failed"
  else
    warn "snapshot failed, continuing without one"
  fi
}

upgradeSystem() {
  say "Updating archlinux-keyring"
  sudo pacman -Sy --needed --noconfirm archlinux-keyring || die "keyring update failed"
  say "Upgrading the system"
  sudo pacman -Su || die "system upgrade failed"
}

reviewOrphans() {
  local orphans list
  orphans="$(pacman -Qtdq)"
  if [[ -z "$orphans" ]]; then
    return 0
  fi
  say "Orphan packages"
  printf '%s\n' "$orphans"
  if confirm "Remove them?"; then
    mapfile -t list <<<"$orphans"
    sudo pacman -Rns "${list[@]}" || warn "orphan removal failed"
  fi
}

upgradeAur() {
  if ! command -v yay >/dev/null; then
    return 0
  fi
  say "Upgrading AUR packages"
  yay -Sua || warn "AUR upgrade failed"
}

rebootReason() {
  local pid
  if [[ ! -d "/usr/lib/modules/$(uname -r)" ]]; then
    echo "the running kernel was replaced"
    return 0
  fi
  pid="$(pgrep -x "$HYPRLAND_PROCESS" | head -1)"
  if [[ -n "$pid" && "$(readlink "/proc/${pid}/exe")" == *"(deleted)"* ]]; then
    echo "Hyprland was upgraded"
  fi
}

offerReboot() {
  local reason
  reason="$(rebootReason)"
  if [[ -z "$reason" ]]; then
    say "Done, no reboot needed"
    return 0
  fi
  say "Reboot recommended: ${reason}"
  if confirm "Reboot now?"; then
    systemctl reboot
  fi
}

main() {
  trap stopBackground EXIT
  requireFreeSpace
  keepSudoAlive
  holdInhibitor
  pruneCache
  takeSnapshot
  upgradeSystem
  reviewOrphans
  upgradeAur
  stopBackground
  offerReboot
}

main "$@"
