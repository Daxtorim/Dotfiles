#!/bin/bash
# shellcheck disable=1091,2034

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return ;;
esac

# ================= General Settings ======================

set_default_shell()
{
	# only change to zsh if this is the first start up of the terminal
	[ -n "${REPLACED_BASH_WITH_ZSH}" ] && return 0
	REPLACED_BASH_WITH_ZSH=1
	export REPLACED_BASH_WITH_ZSH

	local preferred_shell
	preferred_shell="$(command -v zsh)"
	if [ -n "${preferred_shell}" ]; then
		SHELL=${preferred_shell}
		export SHELL
		exec "${preferred_shell}"
	fi
}
set_default_shell

enable_autocompletion()
{
	if ! shopt -oq posix; then
		if [ -f /usr/share/bash-completion/bash_completion ]; then
			. /usr/share/bash-completion/bash_completion
		elif [ -f /etc/bash_completion ]; then
			. /etc/bash_completion
		fi
	fi
}
enable_autocompletion

[ -f "${HOME}/Dotfiles/shell-aliases" ] && . "${HOME}/Dotfiles/shell-aliases"
[ -f /usr/share/fzf/shell/key-bindings.bash ] && . /usr/share/fzf/shell/key-bindings.bash
[ -f /usr/share/fzf/shell/completion.bash ] && . /usr/share/fzf/shell/completion.bash

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
if [ "$(command -v __git_ps1)" ]; then
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWUNTRACKEDFILES=1
	GIT_PS1_SHOWSTASHSTATE=1
	alias git_prompt_update='__git_ps1 "-[$cyan%s$white]"'
else
	# no-op to avoid errors if git function is not found
	alias git_prompt_update=''
fi

if [ -f "/run/.containerenv" ]; then
	toolbox_name=\($(grep 'name=' "/run/.containerenv" | sed -e 's/^name="\(.*\)"$/\1/')\)
else
	toolbox_name=""
fi

PS1="\n\[$white\]╭[\$?]-[\[$yellow\]\u\[$green\]@\[$blue\]\h$toolbox_name\[$white\]]-[\[$magenta\]\w\[$white\]]\$(git_prompt_update)\n╰─╸\[$green\]\\$ \[$reset\]"
PS2="\[$white\]╺─╸\[$green\]\\$ \[$reset\]"
