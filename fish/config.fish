alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias sysupdate="sudo pacman -Syu"
alias sysclean="paccache -r & sudo pacman -R $(pacman -Qtdq)"

alias ls="eza --icons"
alias ll="eza --icons -l"
alias la="eza --icons -al"
if status is-interactive
    # Commands to run in interactive sessions can go here
end
