# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# ================= General Settings ======================

# Check for available editor
if [ -x "$(command -v nvim)" ];then
	export EDITOR='nvim'
	export VISUAL='nvim'
elif [ -x "$(command -v vim)" ];then
	export EDITOR='vim'
	export VISUAL='vim'
else
	export EDITOR='nano'
	export VISUAL='nano'
fi

# Check for avaliable manpager (prefer basic vim over potentially larger nvim config)
if [ -x "$(command -v vim)" ];then
	export MANPAGER='vim -c "%! col -b" -c "set ft=man nomod nolist norelativenumber" -c "nmap q :q!" -'
elif [ -x "$(command -v nvim)" ];then
	export MANPAGER="nvim +Man!"
else
	export MANPAGER="less"
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
if [ -x "$(command -v git)" ];then
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWUNTRACKEDFILES=1
	GIT_PS1_SHOWSTASHSTATE=1
	alias git_prompt_update='__git_ps1 "-[$cyan%s$white]"'
else
	# no-op to avoid errors if git is not installed
	alias git_prompt_update=''
fi

export PS1="\n\[$white\]╭[\$?]-[\[$yellow\]\u\[$green\]@\[$blue\]\h\[$white\]]-[\[$magenta\]\w\[$white\]]\$(git_prompt_update)\n╰─╸\[$green\]\\$ \[$reset\]"
export PS2="\[$white\]╰─╸\[$green\]\\$ \[$reset\]"



# ================== Aliases ==============================

if [ -f ".bash_aliases" ]; then
	source ".bash_aliases"
fi

if [ -x "$(command -v exa)" ]; then
	alias ls='exa --colour=auto --grid'
	alias la='exa --colour=auto --long --group --header --time-style=long-iso --all --all'
else
	alias ls='ls --color=auto'
	alias la='ls --color=auto -lha'
fi

alias grep='grep --color=auto'
alias cgrep="grep -v '^#\|^$' -R"

# Use correct extraction program based on file extension
function extract()
{
	if [ -f $1 ] ; then
		case $1 in
			*.tar.gz)    tar xzf $1      ;;
			*.tar.bz2)   tar xjf $1      ;;
			*.tar)       tar xf $1       ;;
			*.tgz)       tar xzf $1      ;;
			*.tbz2)      tar xjf $1      ;;
			*.gz)        gunzip $1       ;;
			*.bz2)       bunzip2 $1      ;;
			*.rar)       unrar x $1      ;;
			*.zip)       unzip $1        ;;
			*.Z)         uncompress $1   ;;
			*.7z)        7z x $1         ;;
			*)           echo "'$1' cannot be extracted via >extract<" ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}

