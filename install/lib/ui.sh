#!/usr/bin/env bash

UI_ACCENT="#89b4fa"
UI_OK="#a6e3a1"
UI_WARN="#f9e2af"
UI_ERR="#f38ba8"
UI_MUTED="#7f849c"
UI_WIDTH=72
UI_LIST_HEIGHT=15
UI_LOG_TAIL=20
UI_SPIN_POLL=0.2
UI_BAR_WIDTH=30
UI_STEP_NUM=0
UI_STEP_TOTAL=0
HAS_GUM=0

uiInit() {
  if command -v gum >/dev/null 2>&1 && [[ -t 0 && -t 1 ]]; then
    HAS_GUM=1
  fi
}

uiBanner() {
  if ((HAS_GUM)); then
    gum style --border double --border-foreground "$UI_ACCENT" --foreground "$UI_ACCENT" \
      --bold --align center --width "$UI_WIDTH" --padding "1 2" --margin "1 0" "$@"
  else
    printf '\n========================================\n'
    printf '  %s\n' "$@"
    printf '========================================\n\n'
  fi
}

uiHeader() {
  printf '\n[%s] ##### %s\n' "$(date '+%F %T')" "$1" >>"$LOG_FILE"
  if ((HAS_GUM)); then
    gum style --border rounded --border-foreground "$UI_ACCENT" --foreground "$UI_ACCENT" \
      --bold --padding "0 2" --margin "1 0 0 0" "$1"
  else
    printf '\n----- %s -----\n' "$1"
  fi
}

_uiLine() {
  local color="$1" symbol="$2"
  shift 2
  if ((HAS_GUM)); then
    gum style --foreground "$color" "${symbol} $*"
  else
    printf '%s %s\n' "$symbol" "$*"
  fi
}

uiInfo() { _uiLine "$UI_MUTED" "•" "$@"; }
uiOk() { _uiLine "$UI_OK" "✓" "$@"; }
uiWarn() { _uiLine "$UI_WARN" "!" "$@"; }
uiError() { _uiLine "$UI_ERR" "✗" "$@"; }

uiBox() {
  local color="${1:-$UI_MUTED}" body
  body="$(cat)"
  if ((HAS_GUM)); then
    gum style --border normal --border-foreground "$color" --padding "0 1" --width "$UI_WIDTH" "$body"
  else
    printf '%s\n' "$body" | sed 's/^/  | /'
  fi
}

uiInput() {
  local __var="$1" label="$2" default="${3:-}" value
  if ((HAS_GUM)); then
    value="$(gum input --header "$label" --value "$default" --width "$UI_WIDTH")" || return 1
  else
    read -rp "$label [$default]: " value
  fi
  printf -v "$__var" '%s' "${value:-$default}"
}

uiPassword() {
  local __var="$1" label="$2" first second
  while true; do
    if ((HAS_GUM)); then
      first="$(gum input --password --header "$label")" || return 1
      second="$(gum input --password --header "$label (again)")" || return 1
    else
      read -rsp "$label: " first
      echo
      read -rsp "$label (again): " second
      echo
    fi
    if [[ -z "$first" ]]; then
      uiWarn "The password cannot be empty."
    elif [[ "$first" != "$second" ]]; then
      uiWarn "The passwords do not match."
    else
      break
    fi
  done
  printf -v "$__var" '%s' "$first"
}

uiConfirm() {
  local question="$1" default="${2:-no}" reply
  if ((HAS_GUM)); then
    if [[ "$default" == yes ]]; then
      gum confirm --default "$question"
    else
      gum confirm --default=false "$question"
    fi
    return
  fi
  if [[ "$default" == yes ]]; then
    read -rp "$question [Y/n]: " reply
    [[ ! "$reply" =~ ^[Nn]$ ]]
  else
    read -rp "$question [y/N]: " reply
    [[ "$reply" =~ ^[Yy]$ ]]
  fi
}

uiChoose() {
  local __var="$1" header="$2" value i reply
  shift 2
  if ((HAS_GUM)); then
    value="$(for value in "$@"; do
      [[ "$value" == *"|"* ]] && echo "$value" || echo "${value}|${value}"
    done | gum choose --header "$header" --height "$UI_LIST_HEIGHT" --label-delimiter '|')" || return 1
  else
    echo "$header"
    i=1
    for value in "$@"; do
      printf '  %2d) %s\n' "$i" "${value%%|*}"
      i=$((i + 1))
    done
    while true; do
      read -rp "Choice [1]: " reply
      reply="${reply:-1}"
      if [[ "$reply" =~ ^[0-9]+$ ]] && ((reply >= 1 && reply <= $#)); then
        break
      fi
    done
    value="${!reply}"
    if [[ "$value" == *"|"* ]]; then
      value="${value#*|}"
    fi
  fi
  printf -v "$__var" '%s' "$value"
}

uiMulti() {
  local __var="$1" header="$2" selected="$3" value reply
  shift 3
  if ((HAS_GUM)); then
    value="$(printf '%s\n' "$@" | gum choose --no-limit --header "$header" \
      --height "$UI_LIST_HEIGHT" --selected "$selected")" || return 1
  else
    echo "$header"
    printf '  %s\n' "$@"
    read -rp "Keep which (space separated) [${selected//,/ }]: " reply
    value="${reply:-${selected//,/ }}"
    if [[ "$value" == "*" ]]; then
      value="$*"
    fi
  fi
  printf -v "$__var" '%s' "$(tr '\n' ' ' <<<"$value" | sed 's/ *$//')"
}

uiFilter() {
  local __var="$1" header="$2" default="$3" value list
  list="$(cat)"
  if ((HAS_GUM)); then
    value="$(gum filter --header "$header" --value "$default" --height "$UI_LIST_HEIGHT" <<<"$list")" || return 1
  else
    while true; do
      read -rp "$header [$default]: " value
      value="${value:-$default}"
      if grep -qxF "$value" <<<"$list"; then
        break
      fi
      uiWarn "Not in the list: $value"
    done
  fi
  printf -v "$__var" '%s' "$value"
}

uiTypedConfirm() {
  local expected="$1" prompt="$2" typed
  if ((HAS_GUM)); then
    typed="$(gum input --header "$prompt" --placeholder "$expected" --width "$UI_WIDTH")" || return 1
  else
    read -rp "$prompt: " typed
  fi
  [[ "$typed" == "$expected" ]]
}

_uiTtyCols() {
  local cols
  cols="$({ stty size </dev/tty; } 2>/dev/null | awk '{print $2}')"
  echo "${cols:-$TTY_COLS}"
}

_uiLogClean() {
  sed -u -e 's/\r$//' -e 's/.*\r//' -e 's/\x1b\[[0-9;?]*[A-Za-z]//g'
}

_uiProgress() {
  local finished="$1" label="$2" filled empty
  filled=$((finished * UI_BAR_WIDTH / UI_STEP_TOTAL))
  printf -v empty '%*s' $((UI_BAR_WIDTH - filled)) ''
  printf -v filled '%*s' "$filled" ''
  _uiLine "$UI_ACCENT" "${filled// /█}${empty// /░}" "$label"
}

uiProgressDone() {
  if ((UI_STEP_TOTAL)); then
    _uiProgress "$UI_STEP_TOTAL" "${UI_STEP_TOTAL}/${UI_STEP_TOTAL} · complete"
  fi
}

_uiRunBackground() {
  local title="$1" verbose="$2" pid cols
  shift 2
  if ((DRY_RUN)); then
    (
      set -Eeuo pipefail
      "$@"
    ) > >(tee -a "$LOG_FILE") 2>&1 &
  elif ((verbose)); then
    cols="$(_uiTtyCols)"
    (
      set -o pipefail
      (
        set -Eeuo pipefail
        trap 'echo "failed (exit $?): ${BASH_COMMAND}" >&2' ERR
        TTY_RUN=1
        TTY_COLS="$cols"
        "$@"
      ) 2>&1 </dev/null | tee /dev/fd/3 | _uiLogClean >>"$LOG_FILE"
    ) 3>&1 &
  else
    (
      set -Eeuo pipefail
      trap 'echo "failed (exit $?): ${BASH_COMMAND}" >&2' ERR
      "$@"
    ) >>"$LOG_FILE" 2>&1 </dev/null &
  fi
  pid=$!
  if ((HAS_GUM && !DRY_RUN && !verbose)); then
    gum spin --spinner dot --spinner.foreground "$UI_ACCENT" --title "$title" -- \
      bash -c "while kill -0 ${pid} 2>/dev/null; do sleep ${UI_SPIN_POLL}; done" || true
  elif ((!DRY_RUN && !verbose)); then
    printf '  … %s\n' "$title"
  fi
  wait "$pid"
}

_uiFailureMenu() {
  local title="$1" optional="$2" choice options=("Retry" "Open a shell, then decide" "Abort")
  uiError "$title failed" >&2
  tail -n "$UI_LOG_TAIL" "$LOG_FILE" | uiBox "$UI_ERR" >&2
  uiInfo "Full log: $LOG_FILE" >&2
  if ((optional)); then
    options=("Retry" "Skip (this step is optional)" "Open a shell, then decide" "Abort")
  fi
  if [[ ! -t 0 ]]; then
    echo abort
    return
  fi
  uiChoose choice "What now?" "${options[@]}" >&2
  case "$choice" in
    Retry) echo retry ;;
    Skip*) echo skip ;;
    Open*) echo shell ;;
    *) echo abort ;;
  esac
}

uiStep() {
  local optional=0 verbose=0 status err_trap title action
  while [[ "$1" == --* ]]; do
    case "$1" in
      --optional) optional=1 ;;
      --verbose) verbose=1 ;;
    esac
    shift
  done
  title="$1"
  shift
  if ((UI_STEP_TOTAL)); then
    UI_STEP_NUM=$((UI_STEP_NUM < UI_STEP_TOTAL ? UI_STEP_NUM + 1 : UI_STEP_TOTAL))
  fi
  while true; do
    printf '\n[%s] ==> %s\n' "$(date '+%F %T')" "$title" >>"$LOG_FILE"
    if ((UI_STEP_TOTAL)); then
      _uiProgress $((UI_STEP_NUM - 1)) "${UI_STEP_NUM}/${UI_STEP_TOTAL} · ${title}"
    elif ((DRY_RUN || verbose)); then
      uiInfo "$title"
    fi
    err_trap="$(trap -p ERR)"
    trap - ERR
    set +e
    _uiRunBackground "$title" "$verbose" "$@"
    status=$?
    set -e
    eval "${err_trap:-trap - ERR}"
    if ((status == 0)); then
      ((DRY_RUN)) || uiOk "$title"
      return 0
    fi
    action="$(_uiFailureMenu "$title" "$optional")"
    case "$action" in
      retry) continue ;;
      skip)
        uiWarn "Skipped: $title"
        return 0
        ;;
      shell)
        uiInfo "Type 'exit' to come back to the installer."
        bash -i || true
        ;;
      *)
        uiError "Aborted at: $title"
        exit 1
        ;;
    esac
  done
}

uiSummary() {
  local row body=""
  for row in "$@"; do
    body+="$(printf '%-14s %s' "${row%%=*}" "${row#*=}")"$'\n'
  done
  printf '%s' "$body" | uiBox "$UI_ACCENT"
}
