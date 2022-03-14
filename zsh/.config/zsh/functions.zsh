#!/usr/bin/env zsh

# Function to source files if they exist
function _zsh_source_file() {
	[ -f "$1" ] && . "$1"
}

function zsh_add_file() {
	_zsh_source_file "${ZDOTDIR}/$1"
}

function zsh_add_plugin() {
	if [ ! -d "${PLUGIN_DIR:?}" ]; then
		mkdir -p "${PLUGIN_DIR}"
	fi

	local plugin_name=$(echo $1 | cut -d "/" -f 2)
	if [ ! -d "${PLUGIN_DIR}/${plugin_name}" ]; then
		echo "Installing plugin: ${plugin_name}"
		git clone --depth=1 "https://github.com/$1.git" "${PLUGIN_DIR}/${plugin_name}"
	fi

	_zsh_source_file "${PLUGIN_DIR}/${plugin_name}/${plugin_name}.plugin.zsh" || \
	_zsh_source_file "${PLUGIN_DIR}/${plugin_name}/${plugin_name}.zsh"
}
