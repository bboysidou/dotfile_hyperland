#!/usr/bin/env bash
# Pending package updates (repo via checkupdates, AUR via yay).
# Bars on multiple outputs run this concurrently, and two checkupdates runs
# collide on the pacman db, so the query is locked and cached.

cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-updates.cache"
ttl=600

exec 9>"${cache}.lock"
flock 9

if [ -f "$cache" ] && [ $(( $(date +%s) - $(stat -c %Y "$cache") )) -lt "$ttl" ]; then
  cat "$cache"
  exit 0
fi

repo=$(timeout 120 checkupdates 2>/dev/null)
aur=$(timeout 120 yay -Qua 2>/dev/null)

repo_n=$([ -n "$repo" ] && wc -l <<<"$repo" || echo 0)
aur_n=$([ -n "$aur" ] && wc -l <<<"$aur" || echo 0)
total=$((repo_n + aur_n))

if [ "$total" -eq 0 ]; then
  printf '{"text":"","tooltip":"System up to date","class":"updated"}\n' | tee "$cache"
  exit 0
fi

list=$(printf '%s\n%s' "$repo" "$aur" | sed '/^$/d' | head -30)
[ "$total" -gt 30 ] && list="$list
…and $((total - 30)) more"

tooltip=$(printf '%s repo · %s AUR\n\n%s' "$repo_n" "$aur_n" "$list" |
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' |
  sed ':a;N;$!ba;s/\n/\\n/g')

printf '{"text":"󰚰 %s","tooltip":"%s","class":"has-updates"}\n' "$total" "$tooltip" | tee "$cache"
