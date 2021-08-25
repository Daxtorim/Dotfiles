# If not running interactively, don't do anything
case $- in
	*i*) ;;
	  *) return;;
esac


# ================= General Settings ======================

[ -f "${HOME}/Dotfiles/shell-aliases" ] && source "${HOME}/Dotfiles/shell-aliases"

# enable bash completion in interactive shells
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		source /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		source /etc/bash_completion
	fi
fi

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000

# Append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# ================== PROMPT ===============================

# color names for readability
	reset='\033[00m'
	black='\033[30m'
	red='\033[31m'
	green='\033[32m'
	yellow='\033[33m'
	blue='\033[34m'
	magenta='\033[35m'
	cyan='\033[36m'
	white='\033[37m'


# Git integration in prompt
if [ "$(command -v __git_ps1)" ];then
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWUNTRACKEDFILES=1
	GIT_PS1_SHOWSTASHSTATE=1
	alias git_prompt_update='__git_ps1 "-[$cyan%s$white]"'
else
	# no-op to avoid errors if git function is not found
	alias git_prompt_update=''
fi

export PS1="\n\[$white\]╭[\$?]-[\[$yellow\]\u\[$green\]@\[$blue\]\h\[$white\]]-[\[$magenta\]\w\[$white\]]\$(git_prompt_update)\n╰─╸\[$green\]\\$ \[$reset\]"
export PS2="\[$white\]╰─╸\[$green\]\\$ \[$reset\]"
