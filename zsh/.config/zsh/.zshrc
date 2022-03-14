# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/cache
zmodload zsh/complist
compinit
_comp_options+=(globdots)                                       # Include hidden files.

## Options section
setopt extendedglob              # Extended globbing. Allows using regular expressions with *
setopt appendhistory             # Immediately append history instead of overwriting
setopt histignorealldups         # If a new command is a duplicate, remove the older one
setopt autocd                    # if only directory path is entered, cd there.
setopt inc_append_history        # commands are added to the history immediately, otherwise only when shell exits.
setopt nobeep                    # No beep
unsetopt BEEP                    # For real, NO BEEP


CACHE_DIR=${XDG_CACHE_HOME:-"${HOME}/.cache"}/zsh
PLUGIN_DIR=${CACHE_DIR}/plugins

mkdir -p "${CACHE_DIR}"
HISTFILE=${CACHE_DIR}/zsh_history.txt
HISTSIZE=2000000
SAVEHIST=1500000


# Helper functions
if [ -f "${ZDOTDIR}/functions.zsh" ]; then
	. "${ZDOTDIR}/functions.zsh"
else
	echo "Cannot source helper functions. Cannot load config!"
	return 1 # exit would kill the shell
fi

# General shell agnostic aliases
_zsh_source_file "${HOME}/Dotfiles/shell-aliases"

# System specific options
zsh_add_file "zshrc_local.zsh"

# General files
zsh_add_file "extract_archives.zsh"
zsh_add_file "zsh_command_info.zsh"

# Plugins
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"

# Prompt
zsh_add_plugin "romkatv/powerlevel10k"
_zsh_source_file "${PLUGIN_DIR}/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt edit ~/.config/zsh/.p10k.zsh.
zsh_add_file ".p10k.zsh"

# Keybindings
bindkey "^R" history-incremental-pattern-search-backward

# vi mode and fix for "broken" (aka default) vi behavior for backspace key
bindkey -v
bindkey '^?' backward-delete-char
