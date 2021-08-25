# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
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
	[ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
}

function zsh_add_plugin() {
	if [ ! -d "$ZDOTDIR/plugins" ]; then
		mkdir "$ZDOTDIR/plugins"
	fi
	
	PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
	if [ ! -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then
		git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
	fi

	zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
	zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
}


# Sourcing files
zsh_add_file "${HOME}/Dotfiles/shell-aliases"
zsh_add_file "zsh-prompt"
zsh_add_file "extract_archives.zsh"
# Plugins
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"


bindkey "^R" history-incremental-pattern-search-backward
