#!/usr/bin/env bash

DOTFILES_URL="${DOTFILES_URL:-https://github.com/bboysidou/dotfile_hyperland.git}"
DOTFILES_PUSH_URL="${DOTFILES_PUSH_URL:-git@github.com:bboysidou/dotfile_hyperland.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
YAY_URL="https://aur.archlinux.org/yay-bin.git"
TPM_URL="https://github.com/tmux-plugins/tpm"
FISHER_URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
GRAPHITE_URL="https://github.com/vinceliuice/Graphite-gtk-theme.git"
GRAPHITE_ARGS="-d ~/.themes -t teal -c dark -s standard -l --tweaks black rimless normal"
DEFAULT_WALLPAPER=".config/quickshell/media/wallpaper/default.png"
WALLPAPER_STATE=".local/state/quickshell/wallpaper"
UV_ENV_FISH='if not contains "$HOME/.local/bin" $PATH
    set -x PATH "$HOME/.local/bin" $PATH
end'
YAY_FLAGS=(-S --noconfirm --needed --answerclean All --answerdiff None --answeredit None --removemake)
DEFAULT_USER="sidouxp3"
HARDCODED_HOME_FILES=(gtk/gtk-3.0/bookmarks gtk/.gtkrc-2.0 hypr/xdph.conf)
SOURCE_COPY="/tmp/installer-src"

userRepo() {
  echo "/home/${A_USER}/.dotfiles"
}

userSudoersOn() {
  writeFile "$(sudoersTempPath)" 440 <<<"${A_USER} ALL=(ALL:ALL) NOPASSWD: ALL"
  inChroot visudo -cf "/etc/sudoers.d/${SUDOERS_TEMP_NAME}"
}

userSudoersOff() {
  if ((DRY_RUN)); then
    echo "  [dry-run] rm -f $(sudoersTempPath)"
    return 0
  fi
  removeTempSudoers
}

userYay() {
  if ((!DRY_RUN)) && [[ -x "${MNT}/usr/bin/yay" ]]; then
    echo "yay already installed"
    return 0
  fi
  retry asUser bash -c "rm -rf /tmp/yay-bin && git clone ${YAY_URL} /tmp/yay-bin && cd /tmp/yay-bin && makepkg -si --noconfirm"
}

userAur() {
  local packages=()
  bundleCollect
  gpuPackages
  packages=("${B_AUR[@]}" "${G_AUR[@]}")
  if ((${#packages[@]} == 0)); then
    echo "no AUR packages selected"
    return 0
  fi
  retry asUser yay "${YAY_FLAGS[@]}" "${packages[@]}"
}

_userClone() {
  local repo
  repo="$(userRepo)"
  if [[ -d "${INSTALLER_DIR}/.git" ]]; then
    run rm -rf "${MNT}${SOURCE_COPY}"
    run cp -a "$INSTALLER_DIR" "${MNT}${SOURCE_COPY}"
    inChroot chown -R "${A_USER}:${A_USER}" "$SOURCE_COPY"
    asUser git clone --recurse-submodules "$SOURCE_COPY" "$repo"
    asUser git -C "$repo" remote set-url origin "$DOTFILES_URL"
  else
    retry asUser git clone --recurse-submodules --branch "$DOTFILES_BRANCH" "$DOTFILES_URL" "$repo"
  fi
  asUser git -C "$repo" remote set-url --push origin "$DOTFILES_PUSH_URL"
}

_userRewriteHome() {
  local repo file
  repo="$(userRepo)"
  [[ "$A_USER" == "$DEFAULT_USER" ]] && return 0
  for file in "${HARDCODED_HOME_FILES[@]}"; do
    asUser sed -i "s|/home/${DEFAULT_USER}|/home/${A_USER}|g" "${repo}/${file}"
  done
  return 0
}

userDotfiles() {
  local repo
  repo="$(userRepo)"
  if ((DRY_RUN)) || [[ ! -d "${MNT}${repo}/.git" ]]; then
    _userClone
  fi
  _userRewriteHome
  gpuConfigureUser "${MNT}${repo}"
  shellConfigureUser "${MNT}${repo}"
  inChroot chown -R "${A_USER}:${A_USER}" "$repo"
  asUser bash "${repo}/install/link.sh" --yes
}

userDirs() {
  asUser xdg-user-dirs-update
}

userFish() {
  asUser bash -c 'mkdir -p "$HOME/.local/bin" && { [[ -e "$HOME/.local/bin/env.fish" ]] || printf "%s\n" "$1" >"$HOME/.local/bin/env.fish"; }' _ "$UV_ENV_FISH"
  asUser fish -c "curl -sL ${FISHER_URL} | source && fisher update"
  asUser fish -c "functions -q tide"
}

userWallpaper() {
  local home="/home/${A_USER}"
  asUser bash -c '[[ -e "$2" ]] || { mkdir -p "$(dirname "$2")" && printf "%s\n" "$1" >"$2"; }' _ "${home}/${DEFAULT_WALLPAPER}" "${home}/${WALLPAPER_STATE}"
}

userTmux() {
  if ((!DRY_RUN)) && [[ -d "${MNT}/home/${A_USER}/.tmux/plugins/tpm" ]]; then
    return 0
  fi
  retry asUser git clone "$TPM_URL" "/home/${A_USER}/.tmux/plugins/tpm"
}

userTheme() {
  asUser bash -c "rm -rf /tmp/graphite && git clone --depth 1 ${GRAPHITE_URL} /tmp/graphite && cd /tmp/graphite && ./install.sh ${GRAPHITE_ARGS}"
}
