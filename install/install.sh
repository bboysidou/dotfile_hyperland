#!/usr/bin/env bash
set -Eeuo pipefail

REPO_SLUG="bboysidou/dotfile_hyperland"
BOOTSTRAP_DIR="/tmp/dotfiles-src"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIVE_TOOLS=(gum os-prober)
NETWORK_PROBE_HOST="archlinux.org"

DRY_RUN=0
PRESEED=0
ANSWERS_INPUT=""
export DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

_usage() {
  cat <<EOF
Usage: install.sh [--dry-run] [--answers FILE] [--branch NAME]

Installs Arch Linux with this Hyprland + Quickshell desktop. Run it as root from the Arch ISO.
  --dry-run       print every command instead of running it; nothing on disk changes
  --answers FILE  preload answers (lines like A_HOSTNAME=box); those questions are skipped
  --branch NAME   dotfiles branch to install (default: main)
EOF
}

_parseArgs() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --answers)
        ANSWERS_INPUT="$(realpath "$2")"
        PRESEED=1
        shift
        ;;
      --branch)
        DOTFILES_BRANCH="$2"
        shift
        ;;
      -h | --help)
        _usage
        exit 0
        ;;
      *)
        _usage >&2
        exit 2
        ;;
    esac
    shift
  done
}

_bootstrap() {
  local url="https://codeload.github.com/${REPO_SLUG}/tar.gz/refs/heads/${DOTFILES_BRANCH}"
  echo "Downloading the installer (${DOTFILES_BRANCH})..."
  rm -rf "$BOOTSTRAP_DIR"
  mkdir -p "$BOOTSTRAP_DIR"
  curl -fsSL --retry 3 "$url" | tar -xz --strip-components=1 -C "$BOOTSTRAP_DIR"
  exec bash "${BOOTSTRAP_DIR}/install/install.sh" "$@"
}

_parseArgs "$@"
if [[ ! -f "${SELF_DIR}/lib/state.sh" ]]; then
  _bootstrap "$@"
fi

INSTALLER_DIR="$(cd "${SELF_DIR}/.." && pwd)"
LIB_DIR="${SELF_DIR}/lib"
# shellcheck source=lib/state.sh
source "${LIB_DIR}/state.sh"
# shellcheck source=lib/ui.sh
source "${LIB_DIR}/ui.sh"
# shellcheck source=lib/detect.sh
source "${LIB_DIR}/detect.sh"
# shellcheck source=lib/gpu.sh
source "${LIB_DIR}/gpu.sh"
# shellcheck source=lib/disk.sh
source "${LIB_DIR}/disk.sh"
# shellcheck source=lib/bundles.sh
source "${LIB_DIR}/bundles.sh"
# shellcheck source=lib/boot.sh
source "${LIB_DIR}/boot.sh"
# shellcheck source=lib/base.sh
source "${LIB_DIR}/base.sh"
# shellcheck source=lib/user.sh
source "${LIB_DIR}/user.sh"
# shellcheck source=lib/questions.sh
source "${LIB_DIR}/questions.sh"

_onExit() {
  if ((!DRY_RUN)); then
    removeTempSudoers
  fi
}

_onError() {
  echo "Unexpected failure at line $1: $2" >&2
  echo "Log: ${LOG_FILE}" >&2
}

trap _onExit EXIT
trap '_onError "$LINENO" "$BASH_COMMAND"' ERR

_requireLive() {
  if ((DRY_RUN)); then
    if ((EUID != 0)); then uiWarn "Not root: disk and OS probing is limited in this dry run."; fi
    if [[ ! -d /run/archiso ]]; then uiWarn "Not running from the Arch ISO (fine for a dry run)."; fi
    return 0
  fi
  if ((EUID != 0)); then
    uiError "Run this as root from the Arch ISO."
    exit 1
  fi
  if [[ ! -d /run/archiso ]]; then
    uiError "This is not the Arch ISO. Refusing to partition a running system."
    exit 1
  fi
}

_requireFirmware() {
  if ((!D_UEFI)); then
    uiError "The machine booted in BIOS/legacy mode. Reboot the ISO in UEFI mode."
    ((DRY_RUN)) || exit 1
  fi
  if ((D_SECURE_BOOT)); then
    uiError "Secure Boot is on. Disable it in the firmware settings, then run this again."
    ((DRY_RUN)) || exit 1
  fi
  return 0
}

_requireNetwork() {
  while ! ping -c 1 -W 3 "$NETWORK_PROBE_HOST" >/dev/null 2>&1; do
    if ((DRY_RUN)); then
      uiWarn "No network (ignored in a dry run)."
      return 0
    fi
    uiWarn "No internet connection."
    if uiConfirm "Open iwctl to connect to Wi-Fi? (station wlan0 connect <SSID>, then exit)" yes; then
      iwctl || true
    else
      exit 1
    fi
  done
  uiOk "Network is up"
}

_liveTools() {
  run timedatectl set-ntp true
  retry run pacman -Sy --noconfirm --needed "${LIVE_TOOLS[@]}"
}

stagePreflight() {
  uiHeader "0 · Preflight"
  _requireLive
  detectAll
  _requireFirmware
  _requireNetwork
  if ((!DRY_RUN)) && ! command -v gum >/dev/null 2>&1; then
    uiStep --verbose "Install installer tools (gum, os-prober)" _liveTools
    uiInit
  fi
}

_offerResume() {
  if [[ -s "$DONE_FILE" && -s "$ANSWERS_FILE" ]] && ((!PRESEED)); then
    uiInfo "A previous run finished: $(paste -sd' ' "$DONE_FILE")"
    if uiConfirm "Resume it with the same answers?" yes; then
      loadVars "$ANSWERS_FILE"
      loadVars "$LAYOUT_FILE"
      PRESEED=1
      return 0
    fi
    resetStages
  fi
  return 1
}

stageQuestions() {
  uiHeader "1 · Questions"
  if _offerResume; then
    askHardware
    askBoot
    if ! stageDone system; then
      askPasswords
    fi
    return 0
  fi
  if [[ -n "$ANSWERS_INPUT" ]]; then
    loadVars "$ANSWERS_INPUT"
  fi
  askEverything
  saveAnswers
  saveLayout
  markStage questions
}

stageDisk() {
  uiHeader "2 · Disk"
  if ! stageDone disk; then
    if [[ "$A_MODE" == alongside ]]; then
      uiStep "Create partitions in the free space of ${A_DISK}" diskApplyAlongside
    else
      uiStep "Wipe and partition ${A_DISK}" diskApplyWipe
    fi
    loadVars "$LAYOUT_FILE"
    uiStep "Create btrfs subvolumes" diskCreateSubvolumes
    markStage disk
  fi
  loadVars "$LAYOUT_FILE"
  uiStep "Mount the new system on ${MNT}" diskMount
}

stageBase() {
  uiHeader "3 · Base system"
  if stageDone base; then return 0; fi
  uiStep "Prepare pacman on the ISO" baseLivePacman
  uiStep --optional "Rank the fastest mirrors" baseMirrors
  uiStep --verbose "Install packages (pacstrap, this takes a while)" basePacstrap
  uiStep "Write fstab" baseFstab
  markStage base
}

stageSystem() {
  uiHeader "4 · System"
  if stageDone system; then return 0; fi
  uiStep "Configure locale, users, drivers and services" systemConfigure
  uiStep "Install the ${A_BOOT} bootloader" bootInstall
  markStage system
}

stageUser() {
  uiHeader "5 · Your desktop"
  if stageDone user; then return 0; fi
  uiStep "Allow AUR builds for ${A_USER} (temporary)" userSudoersOn
  uiStep --verbose "Build yay" userYay
  uiStep --verbose "Install AUR packages" userAur
  uiStep "Clone and link the dotfiles" userDotfiles
  uiStep --optional "Create home folders" userDirs
  uiStep --optional "Fish plugins and tide prompt" userFish
  uiStep --optional "tmux plugin manager" userTmux
  uiStep --optional "Graphite GTK theme" userTheme
  bundleUserHooks
  uiStep "Rebuild the initramfs" systemInitramfs
  uiStep "Remove the temporary sudo rule" userSudoersOff
  markStage user
}

stageFinish() {
  local notes
  uiHeader "6 · Done"
  if ((!DRY_RUN)); then
    install -Dm600 "$LOG_FILE" "${MNT}/var/log/installer.log"
  fi
  notes="$(bootNotes; bundleNotes)"
  if [[ -n "$notes" ]]; then
    uiBox "$UI_WARN" <<<"$notes"
  fi
  uiOk "Installed. Log in on tty1 as ${A_USER}; Hyprland starts by itself."
  if ((DRY_RUN)); then return 0; fi
  if uiConfirm "Unmount and reboot now?" yes; then
    umount -R "$MNT"
    reboot
  fi
}

main() {
  local subtitle="interactive installer"
  if ((DRY_RUN)); then subtitle+=" · dry run"; fi
  stateInit
  uiInit
  uiBanner "Arch · Hyprland · Quickshell" "$subtitle"
  stagePreflight
  stageQuestions
  stageDisk
  stageBase
  stageSystem
  stageUser
  stageFinish
}

main
