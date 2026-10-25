#!/usr/bin/env bash

DEFAULT_HOSTNAME="archlinux"
DEFAULT_USERNAME="sidouxp3"
DEFAULT_TZ="Africa/Algiers"
DEFAULT_LOCALE="en_US.UTF-8"
DEFAULT_KEYMAP="us"
HOSTNAME_PATTERN='^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$'
USERNAME_PATTERN='^[a-z_][a-z0-9_-]{0,31}$'
MIB_PER_GIB=1024
PRESEED="${PRESEED:-0}"

P_USER=""
P_ROOT=""

_preseeded() {
  ((PRESEED)) && [[ -n "${!1-}" ]]
}

_preseededAny() {
  ((PRESEED)) && [[ -v "$1" ]]
}

askIdentity() {
  if ! _preseeded A_HOSTNAME; then
    while true; do
      uiInput A_HOSTNAME "Hostname" "${A_HOSTNAME:-$DEFAULT_HOSTNAME}"
      [[ "$A_HOSTNAME" =~ $HOSTNAME_PATTERN ]] && break
      uiWarn "Lowercase letters, digits and dashes only."
    done
  fi
  if ! _preseeded A_USER; then
    while true; do
      uiInput A_USER "Username" "${A_USER:-$DEFAULT_USERNAME}"
      [[ "$A_USER" =~ $USERNAME_PATTERN ]] && break
      uiWarn "Start with a letter; lowercase letters, digits, - and _ only."
    done
  fi
  return 0
}

askLocale() {
  if ! _preseeded A_TZ; then
    uiFilter A_TZ "Timezone (type to search)" "${A_TZ:-$DEFAULT_TZ}" < <(timedatectl list-timezones 2>/dev/null)
  fi
  if ! _preseeded A_LOCALE; then
    uiFilter A_LOCALE "Locale" "${A_LOCALE:-$DEFAULT_LOCALE}" \
      < <(sed -nE 's/^#?([A-Za-z_@.-]+\.UTF-8) UTF-8.*/\1/p' /etc/locale.gen)
  fi
  if ! _preseeded A_KEYMAP; then
    uiFilter A_KEYMAP "Console keymap" "${A_KEYMAP:-$DEFAULT_KEYMAP}" < <(localectl list-keymaps 2>/dev/null)
  fi
  return 0
}

askPasswords() {
  if ((DRY_RUN)); then
    P_USER="dry-run"
    P_ROOT="dry-run"
    return 0
  fi
  uiPassword P_USER "Password for ${A_USER}"
  uiPassword P_ROOT "Password for root"
}

_diskRow() {
  local dev="$1" tags free
  tags="$(diskOsTags "$dev")"
  free="$(diskLargestFree "$dev" | awk '{print $3}')"
  printf '%s  %s' "$dev" "$(diskDescribe "$dev")"
  if [[ -n "$tags" ]]; then printf '  [%s]' "$tags"; fi
  if [[ -n "$free" ]]; then printf '  free %d GiB' $((free / MIB_PER_GIB)); fi
  printf '|%s\n' "$dev"
}

askDisk() {
  local rows=() dev
  _preseeded A_DISK && return 0
  diskProbeOs
  while read -r dev; do
    rows+=("$(_diskRow "$dev")")
  done < <(diskList)
  if ((${#rows[@]} == 0)); then
    uiError "No installable disk found."
    exit 1
  fi
  uiChoose A_DISK "Install on which disk?" "${rows[@]}"
}

askMode() {
  local tags free options=()
  tags="$(diskOsTags "$A_DISK")"
  free="$(diskLargestFree "$A_DISK" | awk '{print $3}')"
  free="${free:-0}"
  if ! _preseeded A_MODE; then
    options+=("Wipe ${A_DISK} completely${tags:+ (destroys ${tags})}|wipe")
    if ((free >= MIN_ROOT_MIB)); then
      options+=("Install alongside, in the $((free / MIB_PER_GIB)) GiB of free space|alongside")
    else
      uiInfo "Alongside needs ${MIN_ROOT_MIB} MiB free; the largest free region is ${free} MiB. Shrink the other OS first to get that option."
    fi
    uiChoose A_MODE "How should Arch use ${A_DISK}?" "${options[@]}"
  fi
  if [[ "$A_MODE" == alongside ]]; then
    diskPlanAlongside "$A_DISK"
  else
    diskPlanWipe "$A_DISK"
  fi
}

_askSnapper() {
  if [[ -n "$L_XBOOT" ]]; then
    A_SNAPPER=no
    uiInfo "Snapshot boot entries need the kernels on the same partition as limine.conf; this layout keeps them on a separate /boot, so snapper with limine-snapper-sync is not offered."
    return 0
  fi
  uiInfo "Snapper takes a btrfs snapshot before each sys_update.sh run (5 kept), and limine-snapper-sync adds them to the Limine menu. limine-snapper-sync is built from the AUR with GraalVM: a large download and a slow compile."
  if uiConfirm "Add snapper with snapshot boot entries?" no; then
    A_SNAPPER=yes
  else
    A_SNAPPER=no
  fi
}

_askLimineScan() {
  if [[ "$A_BOOT" != limine ]]; then
    A_LIMINE_SCAN=no
    A_SNAPPER=no
    return 0
  fi
  ((PRESEED)) && return 0
  _askSnapper
  uiInfo "limine-scan adds other EFI boot entries to the Limine menu after install. It is built from the AUR with GraalVM: a large download and a slow compile."
  if uiConfirm "Build limine-scan?" no; then
    A_LIMINE_SCAN=yes
  else
    A_LIMINE_SCAN=no
  fi
}

askBoot() {
  W_OTHER_ESPS="$(otherWindowsEsps | paste -sd' ')"
  A_LIMINE_SCAN="${A_LIMINE_SCAN:-no}"
  A_SNAPPER="${A_SNAPPER:-no}"
  if ! _preseeded A_BOOT; then
    if [[ -n "$W_OTHER_ESPS" ]]; then
      uiInfo "Windows was found on another disk: GRUB and Limine can add it to the menu, systemd-boot cannot."
      uiChoose A_BOOT "Bootloader" "GRUB (recommended here)|grub" "Limine|limine" "systemd-boot|systemd-boot"
    else
      uiChoose A_BOOT "Bootloader" "systemd-boot (recommended)|systemd-boot" "GRUB|grub" "Limine|limine"
    fi
  fi
  _askLimineScan
}

_bundleLabel() {
  printf '%s: %s' "$1" "$(bundleMeta "$1" description)"
}

_fineTuneBundle() {
  local name="$1" entries=() excluded=() ticked=() kept entry
  mapfile -t entries < <(bundleEntries "$name" | sed "s/^${AUR_PREFIX}//")
  for entry in "${entries[@]}"; do
    packageExcluded "$entry" || ticked+=("$entry")
  done
  uiMulti kept "Untick what you do not want from ${name}" "$(IFS=,; echo "${ticked[*]}")" "${entries[@]}"
  read -ra excluded <<<"$A_EXCLUDE"
  for entry in "${entries[@]}"; do
    mapfile -t excluded < <(printf '%s\n' "${excluded[@]}" | grep -vxF "$entry" || true)
    if [[ " ${kept} " != *" ${entry} "* ]]; then
      excluded+=("$entry")
    fi
  done
  A_EXCLUDE="$(printf '%s\n' "${excluded[@]}" | awk 'NF' | paste -sd' ')"
}

askBundles() {
  local labels=() selected=() bundles=() chosen name pick
  A_EXCLUDE="${A_EXCLUDE-}"
  _preseeded A_BUNDLES && return 0
  A_BUNDLES="${A_BUNDLES:-$(bundleDefaults)}"
  while read -r name; do
    [[ "$name" == core ]] && continue
    labels+=("$(_bundleLabel "$name")")
    if bundleSelected "$name"; then
      selected+=("$(_bundleLabel "$name")")
    fi
  done < <(bundleNames)
  uiInfo "Core is always installed: $(bundleMeta core description)."
  uiMulti chosen "Extra bundles (space toggles, enter confirms)" "$(IFS=,; echo "${selected[*]}")" "${labels[@]}"
  A_BUNDLES="$(grep -oE '(^| )[a-z0-9-]+:' <<<" ${chosen}" | tr -d ': ' | paste -sd' ' || true)"
  read -ra bundles <<<"core ${A_BUNDLES}"
  while uiConfirm "Fine-tune the packages inside a bundle?" no; do
    uiChoose pick "Which bundle?" "${bundles[@]}"
    _fineTuneBundle "$pick"
  done
}

_loginShellOptions() {
  local candidates=() shell
  read -ra candidates <<<"${A_LOGIN_SHELL} ${DEFAULT_LOGIN_SHELL} ${A_SHELLS} ${BASE_SHELL}"
  for shell in "${candidates[@]}"; do
    shellSelected "$shell" && echo "$shell"
  done | awk '!seen[$0]++'
}

_defaultTerminalOptions() {
  local candidates=() terminal
  read -ra candidates <<<"${A_DEFAULT_TERMINAL} ${BASE_TERMINAL} ${A_TERMINALS}"
  for terminal in "${candidates[@]}"; do
    terminalSelected "$terminal" && echo "$terminal"
  done | awk '!seen[$0]++'
}

askShells() {
  local options=()
  shellDefaults
  if ! _preseededAny A_SHELLS; then
    uiMulti A_SHELLS "Shells besides ${BASE_SHELL} (space toggles, enter confirms)" "${A_SHELLS// /,}" "${EXTRA_SHELLS[@]}"
  fi
  mapfile -t options < <(_loginShellOptions)
  if ((${#options[@]} == 1)); then
    A_LOGIN_SHELL="${options[0]}"
  elif ! _preseeded A_LOGIN_SHELL || [[ "${options[0]}" != "$A_LOGIN_SHELL" ]]; then
    uiChoose A_LOGIN_SHELL "Login shell" "${options[@]}"
  fi
  if ! _preseededAny A_TERMINALS; then
    uiMulti A_TERMINALS "Terminals besides ${BASE_TERMINAL} (space toggles, enter confirms)" "${A_TERMINALS// /,}" "${EXTRA_TERMINALS[@]}"
  fi
  mapfile -t options < <(_defaultTerminalOptions)
  if ((${#options[@]} == 1)); then
    A_DEFAULT_TERMINAL="${options[0]}"
  elif ! _preseeded A_DEFAULT_TERMINAL || [[ "${options[0]}" != "$A_DEFAULT_TERMINAL" ]]; then
    uiChoose A_DEFAULT_TERMINAL "Terminal for the Hyprland keybind" "${options[@]}"
  fi
  return 0
}

askHardware() {
  A_CPU="${A_CPU:-$D_CPU}"
  A_NVIDIA="${A_NVIDIA:-$D_NVIDIA}"
}

_changeHardware() {
  uiChoose A_CPU "CPU microcode" "AMD (amd-ucode)|amd" "Intel (intel-ucode)|intel" "None|none"
  if ((G_NVIDIA)); then
    uiChoose A_NVIDIA "NVIDIA driver" \
      "nvidia-open-dkms (Turing / RTX 20 and newer)|open" \
      "nvidia-580xx-dkms from AUR (Maxwell, Pascal, Volta)|580xx" \
      "nouveau (Kepler and older)|nouveau"
  fi
}

_summaryRows() {
  local plan="wipe the whole disk"
  if [[ "$A_MODE" == alongside ]]; then
    plan="alongside · ESP ${L_ESP} at ${L_ESP_MOUNT}"
    if [[ -n "$L_XBOOT" ]]; then plan+=" · new 1 GiB XBOOTLDR at /boot"; fi
  fi
  uiSummary \
    "Hostname=${A_HOSTNAME}" "User=${A_USER}" "Timezone=${A_TZ}" "Locale=${A_LOCALE}" \
    "Keymap=${A_KEYMAP}" "Disk=${A_DISK} ($(diskDescribe "$A_DISK"))" "Layout=${plan}" \
    "Bootloader=${A_BOOT}$([[ "$A_LIMINE_SCAN" == yes ]] && echo " + limine-scan")$([[ "$A_SNAPPER" == yes ]] && echo " + snapper")" "CPU=${A_CPU}" "GPU=$(gpuDescribe)" "Virtual=${D_VIRT}" \
    "Bundles=core ${A_BUNDLES}" "Excluded=${A_EXCLUDE:-none}" \
    "Shells=${BASE_SHELL} ${A_SHELLS} · login ${A_LOGIN_SHELL}" "Terminals=${BASE_TERMINAL} ${A_TERMINALS} · keybind ${A_DEFAULT_TERMINAL}"
}

_changeMenu() {
  local section
  uiChoose section "Change what?" "Hostname and user|identity" "Timezone, locale, keymap|locale" \
    "Disk and layout|disk" "Bootloader|boot" "Bundles|bundles" \
    "Shells and terminals|shells" "CPU / GPU drivers|hardware"
  PRESEED=0
  case "$section" in
    identity) askIdentity ;;
    locale) askLocale ;;
    disk)
      askDisk
      askMode
      askBoot
      ;;
    boot) askBoot ;;
    bundles) askBundles ;;
    shells) askShells ;;
    hardware) _changeHardware ;;
  esac
}

_confirmDestructive() {
  local tags
  tags="$(diskOsTags "$A_DISK")"
  if [[ "$A_MODE" == wipe ]]; then
    if [[ -n "$tags" ]]; then uiError "${A_DISK} holds ${tags}. All of it will be erased."; fi
    uiWarn "Every partition on ${A_DISK} will be destroyed."
    uiTypedConfirm "$A_DISK" "Type ${A_DISK} to confirm"
    return
  fi
  uiInfo "Current layout of ${A_DISK}:"
  lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS "$A_DISK" | uiBox
  uiInfo "New partitions go into the largest free region; nothing existing is touched."
  uiConfirm "Create the new partitions on ${A_DISK}?" no
}

reviewAndConfirm() {
  local action
  if ((PRESEED && DRY_RUN)); then
    _summaryRows
    return 0
  fi
  while true; do
    _summaryRows
    uiChoose action "Ready?" "Install|install" "Change something|change" "Quit without changes|quit"
    case "$action" in
      install)
        if _confirmDestructive; then
          return 0
        fi
        uiWarn "Not confirmed. Nothing was changed."
        ;;
      change) _changeMenu ;;
      *) exit 0 ;;
    esac
  done
}

askEverything() {
  askIdentity
  askLocale
  askDisk
  askMode
  askBoot
  askBundles
  askShells
  askHardware
  reviewAndConfirm
  askPasswords
}
