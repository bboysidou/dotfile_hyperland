#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LINKS_FILE="${SCRIPT_DIR}/links.list"
BACKUP_DIR="${HOME}/.config-backup/$(date +%Y%m%d-%H%M%S)"
DIFF_PREVIEW_LINES=40

MODE="link"
DRY_RUN=0
ASSUME_YES=0
PROBLEMS=0

_usage() {
  cat <<EOF
Usage: link.sh [--check | --dry-run] [--yes]

Links every entry of install/links.list from ${REPO_DIR} into \$HOME.
  --check    report targets that are missing or not linked into the repo; change nothing
  --dry-run  print what would happen; change nothing
  --yes      do not ask before backing up an existing target
EOF
}

_parseArgs() {
  while (($#)); do
    case "$1" in
      --check) MODE=check ;;
      --dry-run) DRY_RUN=1 ;;
      --yes) ASSUME_YES=1 ;;
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

_expand() {
  echo "${1/#\~/$HOME}"
}

_isLinked() {
  [[ -L "$2" && "$(readlink -f "$2")" == "$(readlink -f "$1")" ]]
}

_run() {
  if ((DRY_RUN)); then
    printf '  [dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

_confirm() {
  local reply
  ((ASSUME_YES)) && return 0
  read -rp "  Back up ${1/#$HOME/\~} and replace it with a link? [y/N] " reply </dev/tty
  [[ "$reply" =~ ^[Yy]$ ]]
}

_preview() {
  local src="$1" target="$2"
  if [[ -L "$target" ]]; then
    echo "  currently a link to $(readlink "$target")"
  elif diff -rq "$target" "$src" >/dev/null 2>&1; then
    echo "  identical to the repo copy"
  else
    echo "  differs from the repo copy:"
    diff -rq "$target" "$src" 2>/dev/null | head -n "$DIFF_PREVIEW_LINES" | sed 's/^/    /' || true
  fi
}

_backup() {
  local target="$1" rel dest
  rel="${target#"$HOME"/}"
  dest="${BACKUP_DIR}/${rel}"
  _run mkdir -p "$(dirname "$dest")"
  _run mv "$target" "$dest"
  echo "  backed up to ${dest/#$HOME/\~}"
}

_linkEntry() {
  local src="$1" target="$2"
  if [[ ! -e "$src" ]]; then
    echo "skip   ${src#"$REPO_DIR"/} (not in the repo)"
    return 0
  fi
  if _isLinked "$src" "$target"; then
    echo "ok     ${target/#$HOME/\~}"
    return 0
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    echo "exists ${target/#$HOME/\~}"
    _preview "$src" "$target"
    if ! _confirm "$target"; then
      echo "  left as it is"
      PROBLEMS=$((PROBLEMS + 1))
      return 0
    fi
    _backup "$target"
  fi
  _run mkdir -p "$(dirname "$target")"
  _run ln -sfn "$src" "$target"
  echo "linked ${target/#$HOME/\~} -> ${src#"$REPO_DIR"/}"
}

_checkEntry() {
  local src="$1" target="$2"
  if _isLinked "$src" "$target"; then
    return 0
  fi
  if [[ -e "$target" ]]; then
    echo "not linked  ${target/#$HOME/\~}"
  else
    echo "missing     ${target/#$HOME/\~}"
  fi
  PROBLEMS=$((PROBLEMS + 1))
}

main() {
  local source target
  _parseArgs "$@"
  while read -r source target; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    target="$(_expand "$target")"
    if [[ "$MODE" == check ]]; then
      _checkEntry "${REPO_DIR}/${source}" "$target"
    else
      _linkEntry "${REPO_DIR}/${source}" "$target"
    fi
  done <"$LINKS_FILE"
  if ((PROBLEMS)); then
    echo "${PROBLEMS} entries not linked"
    if [[ "$MODE" == check ]]; then
      exit 1
    fi
  elif [[ "$MODE" == check ]]; then
    echo "every entry links into ${REPO_DIR/#$HOME/\~}"
  fi
  return 0
}

main "$@"
