#!/usr/bin/env bash

ESP_GUID="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
ESP_TYPE="ef00"
XBOOT_TYPE="ea00"
LINUX_TYPE="8300"
WIPE_ESP_SIZE="+2G"
NEW_BOOT_PART_MIB=1024
ESP_MIN_FREE_MIB=500
MIN_ROOT_MIB=40960
BTRFS_OPTS="noatime,compress=zstd:3,space_cache=v2,discard=async"
ESP_MOUNT_OPTS="fmask=0077,dmask=0077"
BTRFS_SUBVOLS=("@:" "@home:home" "@log:var/log" "@pkg:var/cache/pacman/pkg" "@docker:var/lib/docker" "@tmp:tmp")
BTRFS_SWAP_SUBVOL="@swap:swap"
PROBE_DIR="/tmp/installer-probe"

OS_PROBER_OUT=""

diskBootDevice() {
  local src
  src="$(findmnt -no SOURCE /run/archiso/bootmnt 2>/dev/null || true)"
  if [[ -n "$src" ]]; then
    lsblk -npo PKNAME "$src" 2>/dev/null | head -1
  fi
  return 0
}

diskList() {
  local boot dev
  boot="$(diskBootDevice)"
  while read -r dev; do
    [[ -z "$dev" || "$dev" == /dev/zram* || "$dev" == "$boot" ]] && continue
    [[ "$(lsblk -dno TYPE "$dev")" == disk ]] || continue
    [[ "$(lsblk -dno RO "$dev" | tr -d ' ')" == 0 ]] || continue
    echo "$dev"
  done < <(lsblk -dnpo NAME -e 7,11)
  return 0
}

diskDescribe() {
  local dev="$1" size model tran
  size="$(lsblk -dno SIZE "$dev" | tr -d ' ')"
  model="$(lsblk -dno MODEL "$dev" | sed 's/ *$//')"
  tran="$(lsblk -dno TRAN "$dev" | tr -d ' ')"
  printf '%s · %s · %s' "$size" "${model:-unknown model}" "${tran:-?}"
}

partPath() {
  local disk="$1" number="$2" file
  for file in /sys/class/block/"$(basename "$disk")"/*/partition; do
    [[ -r "$file" ]] || continue
    if [[ "$(cat "$file")" == "$number" ]]; then
      echo "/dev/$(basename "$(dirname "$file")")"
      return 0
    fi
  done
  if ((DRY_RUN)); then
    echo "${disk}<part${number}>"
  fi
  return 0
}

partNumbers() {
  local file
  for file in /sys/class/block/"$(basename "$1")"/*/partition; do
    [[ -r "$file" ]] && cat "$file"
  done
  return 0
}

diskEsps() {
  lsblk -lnpo NAME,PARTTYPE "$1" 2>/dev/null | awk -v g="$ESP_GUID" 'tolower($2) == g {print $1}'
}

_probeMount() {
  mkdir -p "$PROBE_DIR"
  mount -o ro "$1" "$PROBE_DIR" 2>/dev/null
}

_probeUmount() {
  umount "$PROBE_DIR" 2>/dev/null || true
}

espOsNames() {
  local esp="$1" entry
  ((EUID == 0)) || return 0
  _probeMount "$esp" || return 0
  for entry in "$PROBE_DIR"/EFI/*/; do
    [[ -d "$entry" ]] || continue
    case "$(basename "$entry")" in
      Microsoft) echo "Windows" ;;
      BOOT | Boot | boot | systemd | Linux | tools) ;;
      *) basename "$entry" ;;
    esac
  done
  _probeUmount
  return 0
}

espHasWindows() {
  local esp="$1" found=1
  ((EUID == 0)) || return 1
  _probeMount "$esp" || return 1
  if [[ -f "$PROBE_DIR/EFI/Microsoft/Boot/bootmgfw.efi" ]]; then
    found=0
  fi
  _probeUmount
  return "$found"
}

espFreeMib() {
  local esp="$1" free=0
  if ((EUID == 0)) && _probeMount "$esp"; then
    free="$(df -BM --output=avail "$PROBE_DIR" | tail -1 | tr -dc '0-9')"
    _probeUmount
  fi
  echo "${free:-0}"
}

diskProbeOs() {
  OS_PROBER_OUT=""
  if ((EUID == 0)) && command -v os-prober >/dev/null 2>&1; then
    OS_PROBER_OUT="$(os-prober 2>/dev/null || true)"
  fi
  return 0
}

diskOsTags() {
  local disk="$1" esp part long tags=()
  while read -r esp; do
    [[ -n "$esp" ]] || continue
    while read -r long; do
      [[ -n "$long" ]] && tags+=("$long")
    done < <(espOsNames "$esp")
  done < <(diskEsps "$disk")
  while IFS=: read -r part long _; do
    [[ -n "$part" ]] || continue
    if [[ "$(lsblk -npo PKNAME "$part" 2>/dev/null | head -1)" == "$disk" ]]; then
      tags+=("$long")
    fi
  done <<<"$OS_PROBER_OUT"
  if lsblk -lno FSTYPE "$disk" 2>/dev/null | grep -qx BitLocker; then
    tags+=("BitLocker")
  fi
  if ((${#tags[@]})); then
    printf '%s\n' "${tags[@]}" | sort -u | paste -sd, - | sed 's/,/, /g'
  fi
  return 0
}

diskLargestFree() {
  { parted -m -s "$1" unit MiB print free 2>/dev/null || true; } | awk -F: '
    $5 ~ /^free/ {
      s = $2; e = $3; z = $4
      gsub(/MiB/, "", s); gsub(/MiB/, "", e); gsub(/MiB/, "", z)
      if (z + 0 > best) { best = z + 0; bs = s; be = e }
    }
    END { if (best > 0) printf "%d %d %d\n", int(bs) + 1, int(be), int(best) }'
}

diskPlanAlongside() {
  local disk="$1" esp free
  L_DISK="$disk"
  L_NEW_ESP=0
  L_XBOOT=""
  esp="$(diskEsps "$disk" | head -1)"
  if [[ -z "$esp" ]]; then
    L_ESP="new"
    L_NEW_ESP=1
    L_ESP_MOUNT="/boot"
    return 0
  fi
  L_ESP="$esp"
  free="$(espFreeMib "$esp")"
  if ((free >= ESP_MIN_FREE_MIB)); then
    L_ESP_MOUNT="/boot"
  else
    L_ESP_MOUNT="/efi"
    L_XBOOT="new"
  fi
  return 0
}

diskPlanWipe() {
  L_DISK="$1"
  L_ESP="new"
  L_NEW_ESP=1
  L_XBOOT=""
  L_ESP_MOUNT="/boot"
}

_diskSettle() {
  run partprobe "$1" || true
  run udevadm settle
}

_diskRelease() {
  local disk="$1" part
  run swapoff -a || true
  if mountpoint -q "$MNT"; then
    run umount -R "$MNT"
  fi
  while read -r part; do
    [[ -n "$part" ]] || continue
    if findmnt -rno TARGET "$part" >/dev/null 2>&1; then
      run umount "$part"
    fi
  done < <(lsblk -lnpo NAME "$disk" | tail -n +2)
  return 0
}

diskApplyWipe() {
  local disk="$L_DISK"
  _diskRelease "$disk"
  run wipefs -af "$disk"
  run sgdisk --zap-all "$disk"
  run sgdisk -n "1:0:${WIPE_ESP_SIZE}" -t "1:${ESP_TYPE}" -c 1:EFI \
    -n 2:0:0 -t "2:${LINUX_TYPE}" -c 2:ROOT "$disk"
  _diskSettle "$disk"
  L_ESP="$(partPath "$disk" 1)"
  L_ROOT="$(partPath "$disk" 2)"
  run mkfs.fat -F32 -n EFI "$L_ESP"
  run mkfs.btrfs -f -L ROOT "$L_ROOT"
  saveLayout
}

_diskNewPart() {
  local disk="$1" name="$2" fs="$3" start="$4" end="$5" type="$6" before number
  before="$(partNumbers "$disk" | sort -n)"
  run parted -s -a optimal "$disk" unit MiB mkpart "$name" "$fs" "$start" "$end" >&2
  _diskSettle "$disk" >&2
  number="$(comm -13 <(echo "$before") <(partNumbers "$disk" | sort -n) | head -1)"
  if [[ -z "$number" ]]; then
    ((DRY_RUN)) || return 1
    number="N"
  fi
  run sgdisk -t "${number}:${type}" "$disk" >&2
  partPath "$disk" "$number"
}

diskApplyAlongside() {
  local disk="$L_DISK" start end size cursor part
  read -r start end size < <(diskLargestFree "$disk") || true
  if ((${size:-0} < MIN_ROOT_MIB)); then
    echo "largest free region is ${size:-0} MiB, need ${MIN_ROOT_MIB} MiB"
    return 1
  fi
  _diskRelease "$disk"
  cursor="$start"
  if ((L_NEW_ESP)); then
    part="$(_diskNewPart "$disk" EFI fat32 "$cursor" $((cursor + NEW_BOOT_PART_MIB)) "$ESP_TYPE")"
    run mkfs.fat -F32 -n EFI "$part"
    L_ESP="$part"
    cursor=$((cursor + NEW_BOOT_PART_MIB))
  fi
  if [[ "$L_XBOOT" == new ]]; then
    part="$(_diskNewPart "$disk" XBOOTLDR fat32 "$cursor" $((cursor + NEW_BOOT_PART_MIB)) "$XBOOT_TYPE")"
    run mkfs.fat -F32 -n XBOOTLDR "$part"
    L_XBOOT="$part"
    cursor=$((cursor + NEW_BOOT_PART_MIB))
  fi
  L_ROOT="$(_diskNewPart "$disk" ROOT btrfs "$cursor" "$end" "$LINUX_TYPE")"
  run mkfs.btrfs -f -L ROOT "$L_ROOT"
  saveLayout
}

diskSubvolumes() {
  printf '%s\n' "${BTRFS_SUBVOLS[@]}"
  if [[ "${A_HIBERNATE:-no}" == yes ]]; then
    echo "$BTRFS_SWAP_SUBVOL"
  fi
}

diskCreateSubvolumes() {
  local entry
  run mount "$L_ROOT" "$MNT"
  while read -r entry; do
    run btrfs subvolume create "${MNT}/${entry%%:*}"
  done < <(diskSubvolumes)
  run umount "$MNT"
}

diskMount() {
  local entry name target
  if mountpoint -q "$MNT"; then
    return 0
  fi
  while read -r entry; do
    name="${entry%%:*}"
    target="${MNT}/${entry#*:}"
    run mkdir -p "$target"
    run mount -o "${BTRFS_OPTS},subvol=${name}" "$L_ROOT" "$target"
  done < <(diskSubvolumes)
  if [[ -n "$L_XBOOT" ]]; then
    run mkdir -p "${MNT}/boot" "${MNT}/efi"
    run mount -o "$ESP_MOUNT_OPTS" "$L_XBOOT" "${MNT}/boot"
    run mount -o "$ESP_MOUNT_OPTS" "$L_ESP" "${MNT}/efi"
  else
    run mkdir -p "${MNT}/boot"
    run mount -o "$ESP_MOUNT_OPTS" "$L_ESP" "${MNT}/boot"
  fi
  return 0
}

diskEspPath() {
  echo "${L_ESP_MOUNT:-/boot}"
}

diskPartUuid() {
  lsblk -dno PARTUUID "$1" 2>/dev/null | tr -d ' '
}

diskUuid() {
  local uuid
  uuid="$(blkid -s UUID -o value "$1" 2>/dev/null || true)"
  if [[ -z "$uuid" ]]; then
    if ((DRY_RUN)); then
      echo "<uuid-of-$1>"
      return 0
    fi
    echo "no filesystem UUID for $1" >&2
    return 1
  fi
  echo "$uuid"
}

otherWindowsEsps() {
  local disk esp
  while read -r disk; do
    [[ "$disk" == "$L_DISK" ]] && continue
    while read -r esp; do
      [[ -n "$esp" ]] || continue
      if espHasWindows "$esp"; then
        echo "$esp"
      fi
    done < <(diskEsps "$disk")
  done < <(diskList)
  return 0
}
