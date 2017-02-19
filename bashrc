script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
. $script_dir/my-funcs

# aliases
alias ls='ls -F --color=auto'
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias ps='LANG=C ps'
alias reload_bashrc='. ~/.bashrc'
alias rb=reload_bashrc
alias df='LANG=C df'
alias bu='backup-file'
