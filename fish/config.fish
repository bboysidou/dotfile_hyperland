set -gx EDITOR "nvim"
set -gx VISUAL "nvim"

set -Ux SQLFLUFF_CONFIG $HOME/.config/nvim/lua/sidouxp3/plugins/lsp/.sqlfluff
set -Ux SQL_FORMATTER_CONFIG $HOME/.config/nvim/lua/sidouxp3/plugins/lsp/.sql-formatter.json
set -Ux PATH $PATH $HOME/.fvm_flutter/bin
set -Ux CHROME_EXECUTABLE /usr/bin/chromium

set -x JAVA_HOME /usr/lib/jvm/java-21-openjdk
set -x PATH $JAVA_HOME/bin $PATH

alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias ocr="sh ~/.config/custom_scripts/ocr.sh"
alias sysupdate="sudo pacman -Syu"
alias sysclean="paccache -r & sudo pacman -R $(pacman -Qtdq)"

alias ls="eza --icons"
alias ll="eza --icons -l"
alias la="eza --icons -al"
if status is-interactive
    # Commands to run in interactive sessions can go here
end


if test -f "$XDG_RUNTIME_DIR/keyring.fish"
    source "$XDG_RUNTIME_DIR/keyring.fish"
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
set --export MANPAGER "nvim +Man!"
set --export PATH $HOME/flutter/bin $PATH


# FVM
set --export PATH /home/sidouxp3/.fvm_flutter/bin $PATH
fish_add_path "$HOME/fvm/bin"

# Android SDK
set -x ANDROID_HOME $HOME/Android
set -x ANDROID_SDK_ROOT $ANDROID_HOME

fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $ANDROID_HOME/tools/bin
fish_add_path $ANDROID_HOME/emulator

