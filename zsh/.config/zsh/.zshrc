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

HISTFILE="$ZDOTDIR/zsh_history"
HISTSIZE=2000000
SAVEHIST=1500000

# Function to source files if they exist
function zsh_add_file() {
	[ -f "$ZDOTDIR/$1" ] && . "$ZDOTDIR/$1"
}

function zsh_add_plugin() {
	if [ ! -d "$ZDOTDIR/plugins" ]; then
		mkdir "$ZDOTDIR/plugins"
	fi
	
	PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
	if [ ! -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then
		git clone --depth=1 "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
	fi

	zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
	zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
}

# General shell agnostic aliases (not within the zsh directory)
[ -f "${HOME}/Dotfiles/shell-aliases" ] && . "${HOME}/Dotfiles/shell-aliases"

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
zsh_add_file "plugins/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
zsh_add_file ".p10k.zsh"

# Keybindings
bindkey "^R" history-incremental-pattern-search-backward
