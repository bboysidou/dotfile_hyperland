#!/usr/bin/env bash

STATE_DIR="${STATE_DIR:-/tmp/installer}"
LOG_FILE="${STATE_DIR}/install.log"
ANSWERS_FILE="${STATE_DIR}/answers"
LAYOUT_FILE="${STATE_DIR}/layout"
DONE_FILE="${STATE_DIR}/done"
MNT="${MNT:-/mnt}"
DRY_RUN="${DRY_RUN:-0}"
TTY_RUN=0
TTY_COLS=80
RETRY_ATTEMPTS=3
RETRY_FIRST_DELAY=5
SUDOERS_TEMP_NAME="99-installer"

ANSWER_VARS=(
  A_HOSTNAME A_USER A_TZ A_LOCALE A_KEYMAP
  A_DISK A_MODE A_BOOT A_BUNDLES A_EXCLUDE
  A_CPU A_NVIDIA A_SHELLS A_LOGIN_SHELL A_TERMINALS
  A_DEFAULT_TERMINAL A_LIMINE_SCAN A_SNAPPER
)

LAYOUT_VARS=(L_DISK L_ESP L_ROOT L_XBOOT L_ESP_MOUNT L_NEW_ESP)

stateInit() {
  mkdir -p "$STATE_DIR"
  touch "$LOG_FILE" "$DONE_FILE"
  chmod 700 "$STATE_DIR"
}

run() {
  if ((DRY_RUN)); then
    printf '  [dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  if ((TTY_RUN)); then
    SHELL=/bin/bash script -qefc "stty cols ${TTY_COLS} 2>/dev/null; $(printf '%q ' "$@")" /dev/null
    return
  fi
  "$@"
}

writeFile() {
  local path="$1" mode="${2:-644}" body
  body="$(cat)"
  if ((DRY_RUN)); then
    printf '  [dry-run] write %s (mode %s)\n' "$path" "$mode"
    sed 's/^/      | /' <<<"$body"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$body" >"$path"
  chmod "$mode" "$path"
}

retry() {
  local attempt delay="$RETRY_FIRST_DELAY"
  for ((attempt = 1; attempt <= RETRY_ATTEMPTS; attempt++)); do
    if "$@"; then
      return 0
    fi
    if ((attempt == RETRY_ATTEMPTS)); then
      return 1
    fi
    echo "attempt ${attempt}/${RETRY_ATTEMPTS} failed, retrying in ${delay}s: $*"
    sleep "$delay"
    delay=$((delay * 3))
  done
}

inChroot() {
  run arch-chroot "$MNT" "$@"
}

asUser() {
  run arch-chroot "$MNT" runuser -u "$A_USER" -- \
    env HOME="/home/${A_USER}" USER="$A_USER" LOGNAME="$A_USER" "$@"
}

saveVars() {
  local file="$1" var
  shift
  for var in "$@"; do
    printf '%s=%q\n' "$var" "${!var-}"
  done >"$file"
  chmod 600 "$file"
}

loadVars() {
  [[ -f "$1" ]] || return 0
  # shellcheck source=/dev/null
  source "$1"
}

saveAnswers() {
  saveVars "$ANSWERS_FILE" "${ANSWER_VARS[@]}"
}

saveLayout() {
  saveVars "$LAYOUT_FILE" "${LAYOUT_VARS[@]}"
}

stageDone() {
  grep -qxF "$1" "$DONE_FILE" 2>/dev/null
}

markStage() {
  if ((!DRY_RUN)); then
    echo "$1" >>"$DONE_FILE"
  fi
}

resetStages() {
  : >"$DONE_FILE"
}

sudoersTempPath() {
  echo "${MNT}/etc/sudoers.d/${SUDOERS_TEMP_NAME}"
}

removeTempSudoers() {
  local path
  path="$(sudoersTempPath)"
  if [[ -f "$path" ]]; then
    rm -f "$path"
  fi
}
