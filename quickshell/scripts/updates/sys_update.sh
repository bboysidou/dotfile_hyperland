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
TMUX_SESSION="sys-update"
PAUSE_PROMPT="Press any key to close"
MIRRORLIST="/etc/pacman.d/mirrorlist"
MIRRORLIST_BACKUP="/etc/pacman.d/mirrorlist.bak"
MIRROR_MAX_AGE_DAYS=7
MIRROR_MIN_SERVERS=5
SECONDS_PER_DAY=86400
REFLECTOR_ARGS=(--verbose --protocol https --age 12 --completion-percent 100 --latest 50 --sort rate --number 15 --connection-timeout 5 --download-timeout 5)
NEWS_URL="https://archlinux.org/feeds/news/"
NEWS_TIMEOUT_SECONDS=15
NEWS_FIRST_RUN_ITEMS=3
NEWS_WRAP_COLUMNS=100
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sys-update"
LAST_RUN_FILE="$STATE_DIR/last-run"
LOG_DIR="$STATE_DIR/logs"
LOG_KEEP=15
PACMAN_LOG="/var/log/pacman.log"
PACMAN_CACHE="/var/cache/pacman/pkg"
DEFAULT_DIFFPROG="nvim -d"
CRITICAL_PACKAGES='^(linux(-lts|-zen|-hardened)?(-headers)?|linux-firmware.*|systemd|glibc|mesa|nvidia.*|hyprland|quickshell.*|pacman|grub|mkinitcpio|archlinux-keyring|sudo|pam)$'
STEP_SKIPPED=2
ACCENT_COLOR=5
HEADER_WIDTH=80

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_RED=$'\033[31m'
C_GREEN=$'\033[32m'
C_YELLOW=$'\033[33m'
C_BLUE=$'\033[34m'
C_MAGENTA=$'\033[35m'
C_CYAN=$'\033[36m'

assumeYes=0
mirrorMode="auto"
mirrorsChanged=0
nothingToUpgrade=0
cancelled=0
summaryShown=0
sudoPid=""
inhibitPid=""
currentStep=""
stepIndex=0
stepTotal=0
stepStart=0
runStartIso="$(date +%Y-%m-%dT%H:%M:%S%z)"
runStartEpoch="$(date +%s)"
stepResults=()
warnings=()

hasGum() {
  command -v gum >/dev/null
}

banner() {
  if hasGum; then
    gum style --border rounded --border-foreground "$ACCENT_COLOR" --padding "0 2" --margin "1 0" --bold "$@"
    return
  fi
  local line
  printf '\n%s╭──%s %s%s%s\n' "$C_MAGENTA" "$C_RESET" "$C_BOLD" "$1" "$C_RESET"
  shift
  for line in "$@"; do
    printf '%s│%s  %s\n' "$C_MAGENTA" "$C_RESET" "$line"
  done
  printf '%s╰──%s\n' "$C_MAGENTA" "$C_RESET"
}

stepHeader() {
  local title stamp rule
  title="━━━ [${stepIndex}/${stepTotal}] $1 "
  stamp=" $(date +%H:%M:%S)"
  printf -v rule '%*s' $((HEADER_WIDTH - ${#title} - ${#stamp})) ''
  printf '\n%s%s%s%s%s%s\n' "$C_CYAN$C_BOLD" "$title" "$C_RESET$C_CYAN" "${rule// /━}" "$C_DIM" "$stamp$C_RESET"
}

say() {
  printf '%s::%s %s\n' "$C_BLUE$C_BOLD" "$C_RESET" "$1"
}

info() {
  printf '   %s%-18s%s %s\n' "$C_DIM" "$1" "$C_RESET" "$2"
}

ok() {
  printf '   %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$1"
}

warn() {
  warnings+=("[${currentStep:-setup}] $1")
  printf '   %s⚠ warning:%s %s\n' "$C_YELLOW$C_BOLD" "$C_RESET" "$1"
}

die() {
  warnings+=("[${currentStep:-setup}] FATAL: $1")
  printf '   %s✗ error:%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$1" >&2
  exit 1
}

run() {
  printf '   %s$ %s%s\n' "$C_DIM" "$*" "$C_RESET"
  "$@"
}

cancel() {
  cancelled=1
  exit 0
}

confirm() {
  local question="$1" default="${2:-no}" reply hint="[y/N]"
  if ((assumeYes)); then
    printf '   %s? %s -> %s (--yes)%s\n' "$C_DIM" "$question" "$default" "$C_RESET"
    [[ "$default" == "yes" ]]
    return
  fi
  if hasGum; then
    gum confirm --default="$([[ "$default" == "yes" ]] && echo true || echo false)" "$question"
    return
  fi
  [[ "$default" == "yes" ]] && hint="[Y/n]"
  read -rp "   ? ${question} ${hint} " reply
  [[ -z "$reply" ]] && reply="$default"
  [[ "$reply" == [yY]* ]]
}

usage() {
  cat <<EOF
Usage: sys_update.sh [options]

  --mirrors      refresh the mirrorlist with reflector even if it is recent
  --no-mirrors   never touch the mirrorlist
  -y, --yes      answer every question with its default (pacman still asks)
  -h, --help     show this help

Logs: ${LOG_DIR}  (view with: less -R <file>)
EOF
}

parseArgs() {
  while (($#)); do
    case "$1" in
      --mirrors) mirrorMode="force" ;;
      --no-mirrors) mirrorMode="skip" ;;
      -y | --yes) assumeYes=1 ;;
      -h | --help) usage; exit 0 ;;
      *) usage; printf '\nunknown option: %s\n' "$1" >&2; exit 64 ;;
    esac
    shift
  done
}

enterTmux() {
  if [[ -n "${TMUX:-}" ]] || ! command -v tmux >/dev/null; then
    return 0
  fi
  exec tmux new-session -A -s "$TMUX_SESSION" -e "SYS_UPDATE_PAUSE=${SYS_UPDATE_PAUSE:-}" "${BASH_SOURCE[0]}" "$@"
}

enterLog() {
  if [[ -n "${SYS_UPDATE_LOG:-}" ]] || ! command -v script >/dev/null; then
    return 0
  fi
  mkdir -p "$LOG_DIR"
  find "$LOG_DIR" -maxdepth 1 -name '*.log' -printf '%T@ %p\n' | sort -rn | tail -n +"$LOG_KEEP" | cut -d' ' -f2- | xargs -r rm -f
  SYS_UPDATE_LOG="$LOG_DIR/$(date +%Y-%m-%d_%H%M%S).log"
  export SYS_UPDATE_LOG
  exec script --quiet --flush --return --command "$(printf '%q ' "${BASH_SOURCE[0]}" "$@")" "$SYS_UPDATE_LOG"
}

pauseIfAsked() {
  if [[ "${SYS_UPDATE_PAUSE:-}" == 1 ]]; then
    printf '\n'
    read -rsn1 -p "$PAUSE_PROMPT" _
  fi
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

recordStep() {
  stepResults+=("$1|$currentStep|$((SECONDS - stepStart))")
  currentStep=""
}

onExit() {
  local status=$?
  if [[ -n "$currentStep" ]]; then
    if ((cancelled)); then recordStep "cancelled"; else recordStep "failed"; fi
  fi
  stopBackground
  ((summaryShown)) || showSummary "$status"
  pauseIfAsked
}

runStep() {
  local fn="$1"
  stepIndex=$((stepIndex + 1))
  currentStep="$2"
  stepStart=$SECONDS
  stepHeader "$2"
  "$fn"
  case $? in
    0) recordStep "ok" ;;
    "$STEP_SKIPPED") recordStep "skipped" ;;
    *) recordStep "warning" ;;
  esac
}

lastFullUpgrade() {
  grep -F 'starting full system upgrade' "$PACMAN_LOG" 2>/dev/null | tail -1 | cut -c2-25
}

mirrorAgeDays() {
  echo $((($(date +%s) - $(stat -c %Y "$MIRRORLIST")) / SECONDS_PER_DAY))
}

serverCount() {
  grep -c '^Server' "$1"
}

lineCount() {
  grep -c . <<<"$1"
}

toolStatus() {
  local tool list=()
  for tool in gum reflector yay snapper paccache checkupdates pacdiff fakeroot python3 tmux script; do
    if command -v "$tool" >/dev/null; then
      list+=("${C_GREEN}${tool}${C_RESET}")
    else
      list+=("${C_RED}${tool}${C_RESET}")
    fi
  done
  echo "${list[*]}"
}

startBackground() {
  say "Authenticating sudo"
  sudo -v || die "sudo authentication failed"
  while sleep "$SUDO_REFRESH_SECONDS"; do
    sudo -n true 2>/dev/null || exit
  done &
  sudoPid=$!
  ok "sudo kept alive in background (pid ${sudoPid})"
  systemd-inhibit --what="$INHIBIT_WHAT" --mode=block --who="$INHIBIT_WHO" --why="$INHIBIT_WHY" sleep infinity &
  inhibitPid=$!
  ok "holding ${INHIBIT_WHAT} inhibitor (pid ${inhibitPid})"
}

stepPreflight() {
  local freeGib
  info "host" "$(uname -n)"
  info "running kernel" "$(uname -r)"
  info "uptime" "$(uptime -p)"
  info "last full upgrade" "$(lastFullUpgrade || echo unknown)"
  info "packages" "$(pacman -Q | wc -l) installed, $(pacman -Qm | wc -l) foreign/AUR, $(pacman -Qtdq | wc -l) orphans"
  info "mirrorlist" "$(serverCount "$MIRRORLIST") servers, $(mirrorAgeDays) day(s) old"
  info "pacman cache" "$(du -sh "$PACMAN_CACHE" 2>/dev/null | cut -f1)"
  info "tools" "$(toolStatus)"
  info "log file" "${SYS_UPDATE_LOG:-none (script(1) missing)}"
  freeGib=$(($(df --output=avail -B1G / | tail -1)))
  info "free on /" "${freeGib} GiB (minimum ${MIN_FREE_GIB} GiB)"
  ((freeGib >= MIN_FREE_GIB)) || die "only ${freeGib} GiB free on /, need ${MIN_FREE_GIB} GiB"
  hasGum || warn "gum is not installed, using the plain fallback UI (sudo pacman -S gum)"
  startBackground
}

printNews() {
  python3 -I - "$1" "$2" "$3" "$NEWS_WRAP_COLUMNS" <<'PY'
import email.utils, html, re, sys, textwrap
import xml.etree.ElementTree as ET

path, since, first, width = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
items = []
for item in ET.parse(path).getroot().iter("item"):
    stamp = email.utils.parsedate_to_datetime(item.findtext("pubDate")).timestamp()
    items.append((stamp, item.findtext("title") or "", item.findtext("link") or "", item.findtext("description") or ""))
items.sort(reverse=True)
chosen = [i for i in items if i[0] > since] if since > 0 else items[:first]

def toText(raw):
    raw = re.sub(r"<li[^>]*>", "\n• ", raw)
    raw = re.sub(r"<(br|/p|/li|/pre|/h\d)[^>]*>", "\n", raw)
    text = html.unescape(re.sub(r"<[^>]+>", "", raw))
    paragraphs = [p.strip() for p in text.split("\n") if p.strip()]
    return "\n".join(textwrap.fill(p, width, initial_indent="     ", subsequent_indent="     ", break_long_words=False) for p in paragraphs)

for stamp, title, link, desc in chosen:
    date = email.utils.formatdate(stamp, localtime=True)
    print(f"\n   \033[1;35m▶ {title}\033[0m\n   \033[2m{date}  {link}\033[0m\n{toText(desc)}")
PY
}

stepNews() {
  local feed since=0 output
  [[ -f "$LAST_RUN_FILE" ]] && since="$(<"$LAST_RUN_FILE")"
  if ((since > 0)); then
    info "news since" "$(date -d "@${since}" '+%Y-%m-%d %H:%M') (last successful run)"
  else
    info "first run" "showing the latest ${NEWS_FIRST_RUN_ITEMS} items"
  fi
  feed="$(mktemp)"
  if ! run curl --fail --silent --show-error --location --max-time "$NEWS_TIMEOUT_SECONDS" -o "$feed" "$NEWS_URL"; then
    rm -f "$feed"
    warn "could not fetch Arch news from ${NEWS_URL}, read it manually before continuing"
    confirm "Continue without the news?" yes || cancel
    return 1
  fi
  output="$(printNews "$feed" "$since" "$NEWS_FIRST_RUN_ITEMS")"
  local parsed=$?
  rm -f "$feed"
  ((parsed == 0)) || { warn "could not parse the news feed"; return 1; }
  if [[ -z "$output" ]]; then
    ok "no new Arch news since the last run"
    return 0
  fi
  printf '%s\n\n' "$output"
  confirm "Read the news above. Continue with the update?" yes || cancel
}

showMirrorDiff() {
  local old="$1" new="$2"
  comm -13 <(grep '^Server' "$old" | sort) <(grep '^Server' "$new" | sort) | sed "s/^/   ${C_GREEN}+ /; s/\$/${C_RESET}/"
  comm -23 <(grep '^Server' "$old" | sort) <(grep '^Server' "$new" | sort) | sed "s/^/   ${C_RED}- /; s/\$/${C_RESET}/"
}

installMirrorlist() {
  local tmp="$1"
  run sudo cp -p "$MIRRORLIST" "$MIRRORLIST_BACKUP" || { warn "backup failed, keeping the current mirrorlist"; return 1; }
  run sudo install -m 644 -o root -g root "$tmp" "$MIRRORLIST" || { warn "could not install the new mirrorlist"; return 1; }
  mirrorsChanged=1
  ok "mirrorlist replaced, previous one saved to ${MIRRORLIST_BACKUP}"
}

dropUnratedMirrors() {
  local mirrorFile="$1" rateLog="$2" patterns dead
  dead="$(awk '$3 == "INFO:" && $5 == "0.00" && $6 == "KiB/s" {print $4}' "$rateLog")"
  [[ -z "$dead" ]] && return 0
  say "Dropping mirrors that failed the speed test (0 KiB/s)"
  sed "s/^/   ${C_RED}- /; s/\$/${C_RESET}/" <<<"$dead"
  warn "$(lineCount "$dead") mirror(s) failed the speed test and were left out"
  patterns="$(mktemp)"
  sed 's/^/Server = /' <<<"$dead" >"$patterns"
  grep -vF -f "$patterns" "$mirrorFile" >"${mirrorFile}.rated"
  mv "${mirrorFile}.rated" "$mirrorFile"
  rm -f "$patterns"
}

stepMirrors() {
  local age tmp rateLog count status
  age="$(mirrorAgeDays)"
  info "current list" "$(serverCount "$MIRRORLIST") servers, ${age} day(s) old, refresh after ${MIRROR_MAX_AGE_DAYS} days"
  info "mode" "$mirrorMode"
  if [[ "$mirrorMode" == "skip" ]] || { [[ "$mirrorMode" == "auto" ]] && ((age < MIRROR_MAX_AGE_DAYS)); }; then
    ok "mirrorlist is recent enough, not touching it (use --mirrors to force)"
    return "$STEP_SKIPPED"
  fi
  command -v reflector >/dev/null || { warn "reflector is not installed, keeping the current mirrorlist"; return 1; }
  tmp="$(mktemp)"
  rateLog="$(mktemp)"
  say "Rating mirrors worldwide, this downloads a test file from each candidate (a few minutes)"
  if ! run reflector "${REFLECTOR_ARGS[@]}" --save "$tmp" 2>&1 | tee "$rateLog"; then
    rm -f "$tmp" "$rateLog"
    warn "reflector failed, keeping the current mirrorlist"
    return 1
  fi
  dropUnratedMirrors "$tmp" "$rateLog"
  rm -f "$rateLog"
  count="$(serverCount "$tmp")"
  if ((count < MIRROR_MIN_SERVERS)); then
    rm -f "$tmp"
    warn "only ${count} working mirrors found (minimum ${MIRROR_MIN_SERVERS}), keeping the current mirrorlist"
    return 1
  fi
  say "New mirrorlist (${count} servers, fastest first)"
  grep '^Server' "$tmp" | nl -w5 -s'  '
  say "Changes against the current list"
  showMirrorDiff "$MIRRORLIST" "$tmp"
  installMirrorlist "$tmp"
  status=$?
  rm -f "$tmp"
  return "$status"
}

printUpdates() {
  local name old arrow new color
  while read -r name old arrow new _; do
    [[ -z "$name" || "$arrow" != "->" ]] && continue
    color=""
    [[ "$name" =~ $CRITICAL_PACKAGES ]] && color="$C_RED$C_BOLD"
    printf '   %s%-36s%s %s%-24s%s -> %s%s%s\n' "$color" "$name" "$C_RESET" "$C_DIM" "$old" "$C_RESET" "$C_GREEN" "$new" "$C_RESET"
  done <<<"$1"
}

fetchRepoUpdates() {
  local output rc
  output="$(checkupdates --nocolor 2>&1)"
  rc=$?
  case $rc in
    0) printf '%s' "$output" ;;
    2) ;;
    *) printf '%s\n' "$output" >&2; return "$rc" ;;
  esac
}

stepPreview() {
  local repo="" aur="" repoCount=0 aurCount=0 critical
  say "Checking official repositories (checkupdates, temporary database copy)"
  repo="$(fetchRepoUpdates)" || die "checkupdates failed, cannot list pending updates"
  [[ -n "$repo" ]] && repoCount="$(lineCount "$repo")"
  if command -v yay >/dev/null; then
    say "Checking AUR (yay -Qua)"
    aur="$(yay -Qua 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -- ' -> ')"
    [[ -n "$aur" ]] && aurCount="$(lineCount "$aur")"
  fi
  if ((repoCount)); then
    say "Repository updates: ${repoCount}"
    printUpdates "$repo"
  fi
  if ((aurCount)); then
    say "AUR updates: ${aurCount}"
    printUpdates "$aur"
  fi
  critical="$(printf '%s\n%s\n' "$repo" "$aur" | awk 'NF {print $1}' | grep -E "$CRITICAL_PACKAGES" | paste -sd' ')"
  [[ -n "$critical" ]] && printf '\n   %scritical packages in this update:%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$critical"
  if ((repoCount + aurCount == 0)); then
    nothingToUpgrade=1
    ok "system is up to date"
    return 0
  fi
  printf '\n'
  confirm "Upgrade ${repoCount} repo + ${aurCount} AUR packages?" yes || cancel
}

nothingToDo() {
  ((nothingToUpgrade)) || return 1
  ok "nothing to upgrade, skipping"
}

stepCache() {
  nothingToDo && return "$STEP_SKIPPED"
  info "cache before" "$(du -sh "$PACMAN_CACHE" 2>/dev/null | cut -f1)"
  run sudo paccache -v -rk"$CACHE_KEEP_VERSIONS" || warn "paccache failed for installed packages"
  run sudo paccache -v -ruk0 || warn "paccache failed for uninstalled packages"
  info "cache after" "$(du -sh "$PACMAN_CACHE" 2>/dev/null | cut -f1)"
}

stepSnapshot() {
  nothingToDo && return "$STEP_SKIPPED"
  if ! command -v snapper >/dev/null || ! sudo snapper list-configs 2>/dev/null | grep -qw "$SNAPPER_CONFIG"; then
    ok "no snapper config '${SNAPPER_CONFIG}', no snapshot taken"
    return "$STEP_SKIPPED"
  fi
  if ! run sudo snapper -v -c "$SNAPPER_CONFIG" create -c number -d "$SNAPSHOT_DESCRIPTION" -p; then
    warn "snapshot failed, continuing without one"
    return 1
  fi
  run sudo snapper -v -c "$SNAPPER_CONFIG" cleanup number || { warn "snapshot cleanup failed"; return 1; }
}

stepUpgrade() {
  nothingToDo && return "$STEP_SKIPPED"
  local sync="-Sy"
  if ((mirrorsChanged)); then
    sync="-Syy"
    info "database refresh" "forced (-Syy) because the mirrors changed"
  fi
  say "Updating archlinux-keyring first"
  run sudo pacman "$sync" --needed --noconfirm archlinux-keyring || die "keyring update failed"
  say "Upgrading the system"
  run sudo pacman -Su --verbose || die "system upgrade failed"
}

stepAur() {
  nothingToDo && return "$STEP_SKIPPED"
  command -v yay >/dev/null || { ok "yay not installed"; return "$STEP_SKIPPED"; }
  if ! yay -Qua 2>/dev/null | grep -q -- ' -> '; then
    ok "no AUR updates"
    return "$STEP_SKIPPED"
  fi
  run yay -Sua || { warn "AUR upgrade failed"; return 1; }
}

stepOrphans() {
  local orphans list
  orphans="$(pacman -Qtdq)"
  if [[ -z "$orphans" ]]; then
    ok "no orphan packages"
    return 0
  fi
  say "Orphan packages (installed as dependencies, no longer required)"
  LC_ALL=C pacman -Qtdi | awk -F' *: ' '/^Name/{n=$2} /^Version/{v=$2} /^Description/{printf "   %-36s %-24s %s\n", n, v, $2}'
  confirm "Remove them?" no || { warn "$(lineCount "$orphans") orphan package(s) kept"; return 1; }
  mapfile -t list <<<"$orphans"
  run sudo pacman -Rns "${list[@]}" || { warn "orphan removal failed"; return 1; }
}

pacmanLogSinceStart() {
  awk -v start="[${runStartIso}]" 'substr($0, 1, length(start)) >= start' "$PACMAN_LOG"
}

stepReport() {
  local log action count
  log="$(pacmanLogSinceStart)"
  if [[ -z "$log" ]]; then
    ok "pacman logged nothing during this run"
    return 0
  fi
  for action in upgraded installed removed downgraded reinstalled; do
    count="$(grep -c "\[ALPM\] ${action} " <<<"$log")"
    ((count)) && info "$action" "$count"
  done
  say "Every package change in this run"
  grep -E '\[ALPM\] (upgraded|installed|removed|downgraded|reinstalled) ' <<<"$log" | sed -E 's/^\[([^]]+)\] \[ALPM\] /   \1  /'
  if ! grep -qiE 'warning|error|fail' <<<"$log"; then
    ok "no warnings or errors in ${PACMAN_LOG}"
    return 0
  fi
  say "Warnings and errors logged by pacman and its hooks"
  grep -iE 'warning|error|fail' <<<"$log" | sed "s/^/   ${C_YELLOW}/; s/\$/${C_RESET}/"
  warn "pacman logged $(grep -ciE 'warning|error|fail' <<<"$log") warning/error line(s), listed above"
  return 1
}

stepConfigFiles() {
  local files
  command -v pacdiff >/dev/null || { warn "pacdiff not installed (pacman-contrib)"; return 1; }
  files="$(pacdiff --output 2>/dev/null)"
  if [[ -z "$files" ]]; then
    ok "no .pacnew or .pacsave files"
    return 0
  fi
  say "Config files waiting for a merge"
  sed 's/^/   /' <<<"$files"
  if ! confirm "Merge them now with pacdiff?" no; then
    warn "$(lineCount "$files") .pacnew/.pacsave file(s) left unmerged"
    return 1
  fi
  run env DIFFPROG="${DIFFPROG:-$DEFAULT_DIFFPROG}" pacdiff --sudo || { warn "pacdiff exited with an error"; return 1; }
}

checkFailedUnits() {
  local failed userFailed
  failed="$(systemctl --failed --no-legend --plain --no-pager)"
  userFailed="$(systemctl --user --failed --no-legend --plain --no-pager)"
  if [[ -z "$failed$userFailed" ]]; then
    ok "no failed systemd units"
    return 0
  fi
  say "Failed systemd units"
  [[ -n "$failed" ]] && sed 's/^/   system  /' <<<"$failed"
  [[ -n "$userFailed" ]] && sed 's/^/   user    /' <<<"$userFailed"
  warn "some systemd units are in a failed state"
  return 1
}

checkJournal() {
  local journal
  journal="$(sudo journalctl --boot --priority err --since "@${runStartEpoch}" --no-pager --quiet 2>/dev/null)"
  if [[ -z "$journal" ]]; then
    ok "no journal errors during this run"
    return 0
  fi
  say "Journal errors logged during this run"
  sed 's/^/   /' <<<"$journal"
  warn "$(lineCount "$journal") error line(s) in the journal during the update"
  return 1
}

stepHealth() {
  local status=0
  checkFailedUnits || status=1
  checkJournal || status=1
  return "$status"
}

rebootReason() {
  local pid
  if [[ ! -d "/usr/lib/modules/$(uname -r)" ]]; then
    echo "the running kernel ($(uname -r)) was replaced"
    return 0
  fi
  pid="$(pgrep -x "$HYPRLAND_PROCESS" | head -1)"
  if [[ -n "$pid" && "$(readlink "/proc/${pid}/exe")" == *"(deleted)"* ]]; then
    echo "Hyprland was upgraded"
  fi
}

summaryLine() {
  local status="$1" name="$2" secs="$3" icon color
  case "$status" in
    ok) icon="✓" color="$C_GREEN" ;;
    skipped) icon="–" color="$C_DIM" ;;
    warning | cancelled) icon="!" color="$C_YELLOW" ;;
    *) icon="✗" color="$C_RED" ;;
  esac
  printf '   %s%s %-26s%s %4ss  %s\n' "$color" "$icon" "$name" "$C_RESET" "$secs" "$status"
}

summaryTitle() {
  if (($1 != 0)); then
    echo "Update FAILED (exit $1)"
  elif ((cancelled)); then
    echo "Update cancelled by you"
  elif ((${#warnings[@]})); then
    echo "Update finished with ${#warnings[@]} warning(s)"
  else
    echo "Update finished cleanly"
  fi
}

showSummary() {
  local entry status name secs w reason
  summaryShown=1
  banner "$(summaryTitle "$1")" "Total time: $((SECONDS / 60))m $((SECONDS % 60))s" "Log: ${SYS_UPDATE_LOG:-none}"
  for entry in "${stepResults[@]}"; do
    IFS='|' read -r status name secs <<<"$entry"
    summaryLine "$status" "$name" "$secs"
  done
  if ((${#warnings[@]})); then
    printf '\n   %sWarnings%s\n' "$C_YELLOW$C_BOLD" "$C_RESET"
    for w in "${warnings[@]}"; do
      printf '   %s•%s %s\n' "$C_YELLOW" "$C_RESET" "$w"
    done
  fi
  reason="$(rebootReason)"
  [[ -n "$reason" ]] && printf '\n   %sReboot recommended:%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$reason"
  [[ -n "${SYS_UPDATE_LOG:-}" ]] && printf '\n   %sFull log: less -R %s%s\n' "$C_DIM" "$SYS_UPDATE_LOG" "$C_RESET"
  return 0
}

offerReboot() {
  [[ -z "$(rebootReason)" ]] && return 0
  if confirm "Reboot now?" no; then
    systemctl reboot
  fi
}

main() {
  parseArgs "$@"
  enterTmux "$@"
  enterLog "$@"
  trap onExit EXIT
  trap 'warn "interrupted (SIGINT)"; exit 130' INT
  trap 'warn "terminated (SIGTERM)"; exit 143' TERM
  trap 'warn "terminal closed (SIGHUP)"; exit 129' HUP
  local entry steps=(
    "stepPreflight|Preflight"
    "stepNews|Arch news"
    "stepMirrors|Mirrors (reflector)"
    "stepPreview|Pending updates"
    "stepCache|Package cache"
    "stepSnapshot|Snapshot"
    "stepUpgrade|System upgrade"
    "stepAur|AUR upgrade"
    "stepOrphans|Orphans"
    "stepReport|Transaction report"
    "stepConfigFiles|Config files (.pacnew)"
    "stepHealth|System health"
  )
  stepTotal=${#steps[@]}
  banner "System update" "$(date '+%A %d %B %Y, %H:%M')" "mirrors: ${mirrorMode}   assume yes: ${assumeYes}"
  for entry in "${steps[@]}"; do
    runStep "${entry%%|*}" "${entry#*|}"
  done
  mkdir -p "$STATE_DIR"
  echo "$runStartEpoch" >"$LAST_RUN_FILE"
  stopBackground
  showSummary 0
  offerReboot
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
