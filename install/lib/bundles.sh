#!/usr/bin/env bash

AUR_PREFIX="aur:"
SOLAAR_UDEV_RULE="/etc/udev/rules.d/99-solaar.rules"
FAIL2BAN_JAIL="/etc/fail2ban/jail.local"
UFW_CONF="/etc/ufw/ufw.conf"
DOCKER_ROOTLESS_PACKAGE="docker-rootless-extras"
DOCKER_ROOTLESS_SOCKET="docker.socket"
DOCKER_ROOTLESS_CONTEXT="rootless"
DEFAULT_UID=1000

B_PKGS=()
B_AUR=()

bundleDir() {
  echo "${INSTALLER_DIR}/install/bundles"
}

bundleNames() {
  local file name
  for file in "$(bundleDir)"/*.list; do
    name="$(basename "$file" .list)"
    echo "${name#*-}"
  done
}

bundleFile() {
  local file
  for file in "$(bundleDir)"/*-"$1".list; do
    echo "$file"
    return 0
  done
}

bundleMeta() {
  sed -n "s/^#: $2=//p" "$(bundleFile "$1")" | head -1
}

bundleEntries() {
  grep -v -e '^#' -e '^[[:space:]]*$' "$(bundleFile "$1")"
}

bundleDefaults() {
  local name default picked=()
  while read -r name; do
    default="$(bundleMeta "$name" default)"
    case "$default" in
      on) picked+=("$name") ;;
    esac
  done < <(bundleNames)
  echo "${picked[*]}"
}

bundleSelected() {
  [[ "$1" == core || " ${A_BUNDLES} " == *" $1 "* ]]
}

packageExcluded() {
  [[ " ${A_EXCLUDE} " == *" $1 "* ]]
}

packageWanted() {
  local bundle="$1" package="$2"
  bundleSelected "$bundle" && ! packageExcluded "$package"
}

bundleCollect() {
  local name entry
  B_PKGS=()
  B_AUR=()
  while read -r name; do
    bundleSelected "$name" || continue
    while read -r entry; do
      if [[ "$entry" == "${AUR_PREFIX}"* ]]; then
        entry="${entry#"$AUR_PREFIX"}"
        packageExcluded "$entry" || B_AUR+=("$entry")
      else
        packageExcluded "$entry" || B_PKGS+=("$entry")
      fi
    done < <(bundleEntries "$name")
  done < <(bundleNames)
  return 0
}

_bundleSecurity() {
  if packageWanted security ufw; then
    run sed -i 's/^ENABLED=.*/ENABLED=yes/' "${MNT}${UFW_CONF}"
    inChroot systemctl enable ufw.service
  fi
  if packageWanted security fail2ban; then
    writeFile "${MNT}${FAIL2BAN_JAIL}" <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled = false
EOF
    inChroot systemctl enable fail2ban.service
  fi
  if packageWanted security apparmor; then
    inChroot systemctl enable apparmor.service
  fi
  return 0
}

bundleDockerRootless() {
  packageWanted docker docker && [[ "${A_DOCKER_MODE:-rootless}" == rootless ]]
}

bundleAurPackages() {
  if bundleDockerRootless; then
    echo "$DOCKER_ROOTLESS_PACKAGE"
  fi
  return 0
}

_bundleDockerSystem() {
  packageWanted docker docker || return 0
  case "${A_DOCKER_MODE:-rootless}" in
    rootless) return 0 ;;
    group)
      inChroot usermod -aG docker "$A_USER"
      inChroot systemctl enable docker.service
      ;;
    *) inChroot systemctl enable docker.service ;;
  esac
}

_bundleDockerUser() {
  local uid
  uid="$(arch-chroot "$MNT" id -u "$A_USER" 2>/dev/null || echo "$DEFAULT_UID")"
  inChroot systemctl --global enable "$DOCKER_ROOTLESS_SOCKET"
  asUser docker context create "$DOCKER_ROOTLESS_CONTEXT" --docker "host=unix:///run/user/${uid}/docker.sock"
  asUser docker context use "$DOCKER_ROOTLESS_CONTEXT"
}

bundleSecurityLsm() {
  packageWanted security apparmor
}

bundleSystemHooks() {
  _bundleDockerSystem
  if packageWanted android android-udev; then
    inChroot usermod -aG adbusers "$A_USER"
  fi
  if packageWanted peripherals solaar; then
    writeFile "${MNT}${SOLAAR_UDEV_RULE}" <<<'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"'
  fi
  if packageWanted core power-profiles-daemon; then
    inChroot systemctl enable power-profiles-daemon.service
  fi
  _bundleSecurity
}

bundleUserHooks() {
  local repo="/home/${A_USER}/.dotfiles"
  if bundleSelected browsers; then
    uiStep --optional "Browser hardware acceleration flags" asUser bash "${repo}/install/browsers.sh"
  fi
  if bundleDockerRootless; then
    uiStep "Rootless Docker socket and CLI context" _bundleDockerUser
  fi
  return 0
}

bundleUserStepCount() {
  local count=0
  if bundleSelected browsers; then count=$((count + 1)); fi
  if bundleDockerRootless; then count=$((count + 1)); fi
  echo "$count"
}

bundleNotes() {
  if bundleSelected android; then
    echo "Android: run ~/.dotfiles/install/android_dev.sh after the first login (SDK licences need you)."
  fi
  return 0
}
