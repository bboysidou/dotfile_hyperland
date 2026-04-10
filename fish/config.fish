set -gx EDITOR "nvim"
set -gx VISUAL "nvim"
set -gx MANPAGER "nvim +Man!"

set -gx SQLFLUFF_CONFIG $HOME/.config/nvim/lua/sidouxp3/plugins/lsp/.sqlfluff
set -gx SQL_FORMATTER_CONFIG $HOME/.config/nvim/lua/sidouxp3/plugins/lsp/.sql-formatter.json
set -gx CHROME_EXECUTABLE /usr/bin/chromium

set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
set -gx BUN_INSTALL "$HOME/.bun"

# Android SDK
set -gx ANDROID_HOME $HOME/Android
set -gx ANDROID_SDK_ROOT $ANDROID_HOME

# Aliases
alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias ocr="sh ~/.config/custom_scripts/ocr.sh"
alias sysupdate="sudo pacman -Syu; and yay -Syu"
alias apply-theme="bash ~/.config/custom_scripts/theme/apply_theme.sh"
alias switch-theme="bash ~/.config/custom_scripts/theme/switch_theme.sh"
alias sysclean="paccache -r; and sudo pacman -R (pacman -Qtdq)"
alias ls="eza --icons"
alias ll="eza --icons -l"
alias la="eza --icons -al"

if status is-interactive
end

if test -f "$XDG_RUNTIME_DIR/keyring.fish"
    source "$XDG_RUNTIME_DIR/keyring.fish"
end

# PATH (each entry added once via fish_add_path)
fish_add_path $JAVA_HOME/bin
fish_add_path $BUN_INSTALL/bin
fish_add_path $HOME/flutter/bin
fish_add_path $HOME/fvm/bin
fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $ANDROID_HOME/tools/bin
fish_add_path $ANDROID_HOME/emulator
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.local/bin
