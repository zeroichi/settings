script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
. $script_dir/my-funcs

case "$(uname)" in
Darwin)
    # macOS aliases
    alias ls='ls -FG'
    ;;
*)
    # GNU style aliases
    alias ls='ls -F --color=auto'
    ;;
esac

# common aliases
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias ps='LANG=C ps'
alias reload_bashrc='. ~/.bashrc'
alias rb=reload_bashrc
alias df='LANG=C df'
alias bu='backup-file'

if [ "$(lsb_release -is 2>&1)" = "Ubuntu" ]; then
    alias updatepkg="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"
fi
