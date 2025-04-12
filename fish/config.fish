set -gx EDITOR "nvim"
set -gx VISUAL "nvim"

set -Ux SQLFLUFF_CONFIG $HOME/.config/nvim/lua/sidouxp3/plugins/lsp/.sqlfluff
set -Ux SQL_FORMATTER_CONFIG $HOME/.config/nvim/lua/sidouxp3/plugins/lsp/.sql-formatter.json

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

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
