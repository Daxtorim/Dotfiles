# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "${cache_dir}"

#: General Options                          {{{
unsetopt BEEP                          # Do not make a sound when encountering errors
setopt AUTO_CD                         # Automatically cd into directories without specifying `cd`
setopt GLOB_DOTS                       # Do not require a leading dot to be matched explicitly
setopt EXTENDED_GLOB                   # Give ~, #, ^ special meaning for patterns in filename generation
setopt INTERACTIVE_COMMENTS            # Allow comments in interactive multi-line command chains
setopt BANG_HIST                       # Use »!« to start history expansion

# Open command line in editor
bindkey -e
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

autoload -Uz colors; colors
#}}}

#: Completions                              {{{

autoload -Uz compinit; compinit
zmodload zsh/complist

# zstyle ':completion:<function>:<completer>:<command>:<argument>:<tag>' <option> <value>

zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${cache_dir}/zcompcache"

zstyle ':completion:*' completer \
	_extensions _complete _approximate _ignored

# 1. case-sensitive prefix match;
# 2. case-insensitiv prefix match;
# 3. case-sensitive substring match;
# 4. case-insensitiv substring match
zstyle ':completion:*' matcher-list \
	'' \
	'm:{a-zA-Z}={A-Za-z}' \
	'l:|=* r:|=*' \
	'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'

zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' list-prompt '%F{black}Last line: %L Position: %P%f'
zstyle ':completion:*' select-prompt '%F{black}Selected: %M Position: %P%f'

zstyle ':completion:*:approximate:*' max-errors 2

zstyle ':completion:*:*:-command-:*' group-order \
	aliases builtins functions commands

zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}  -- %d --%f'
zstyle ':completion:*:*:*:*:messages' format '%F{blue}  -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format '%F{red}  -- no matches found --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}  !? Corrections for »%o« (errors: %e)%f'

bindkey '\t' expand-or-complete-prefix               # <Tab> to complete words, ignoring suffix if it exists
bindkey -M menuselect '^[[Z' reverse-menu-complete   # <S-Tab> to go through completion menu in reverse

unsetopt LIST_AMBIGUOUS                # Show completion menu even if something can be inserted
setopt NOMATCH                         # Print error when filename generation does not produce matches
setopt COMPLETE_IN_WORD                # Allow completion to begin at the cursor rather than the end of the word
#}}}

#: Directory stack                          {{{
setopt AUTO_PUSHD                      # Push the current directory visited on the stack
setopt PUSHD_IGNORE_DUPS               # Do not store duplicates in the stack
setopt PUSHD_SILENT                    # Do not print the directory stack after pushd or popd
# show first 10 items on the directory stack and make aliases for them
alias d='dirs -v | sed '\''11,$d'\'
for index ({1..9}) alias "$index"="cd +${index}"; unset index
#}}}

#: History options                          {{{
setopt INC_APPEND_HISTORY              # Write to the history file immediately, not when the shell exits
setopt HIST_IGNORE_ALL_DUPS            # Delete old recorded entry if new entry is a duplicate
setopt HIST_IGNORE_SPACE               # Don't record any entry starting with a space
HISTFILE="${cache_dir}/zhistory"
HISTSIZE=50000
SAVEHIST=50000
#}}}

#: Plugins                                  {{{
if [ ! -f "${HOME}/.local/share/zap/zap.zsh" ]; then
	echo "Installing Zap plugin manager:"
	if ! git clone https://github.com/zap-zsh/zap.git "${HOME}/.local/share/zap"; then
		>2 echo "❌ Failed to install Zap!"
		return 2
	fi
fi
. "${HOME}/.local/share/zap/zap.zsh"

plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "hlissner/zsh-autopair"
plug "romkatv/powerlevel10k" # Prompt

_source() { [ -f "$1" ] && . "$1"; }
_source "${HOME}/Dotfiles/shell-aliases"
_source "${ZDOTDIR}/zsh_command_info.zsh"
_source "${ZDOTDIR}/p10k-settings.zsh"
_source "/usr/share/fzf/shell/completion.zsh"
_source "/usr/share/fzf/shell/key-bindings.zsh"
#}}}

#: kitty integration                        {{{
if [ "${TERM}" = "xterm-kitty" ] && [ -n "${KITTY_SHELL_DATA_DIR}" ]; then
	export KITTY_SHELL_INTEGRATION="enabled"
	autoload -Uz -- "${KITTY_SHELL_DATA_DIR}/zsh/kitty-integration"
	kitty-integration
	unfunction kitty-integration
fi
#}}}

# vim:fdm=marker:fdl=0:
