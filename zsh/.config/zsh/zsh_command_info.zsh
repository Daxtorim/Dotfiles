#!/usr/bin/env zsh

autoload -U colors && colors

_zsh_time_preexec() {
	_ZSH_COMMAND_TIME_START=$(date "+%s%1N")
	_ZSH_COMMAND_INFO_SHOW=1
}

_zsh_time_precmd() {
	[ -z "${_ZSH_COMMAND_TIME_START}" ] && return

	local execution_time_mil=$(( $(date "+%s%1N") - ${_ZSH_COMMAND_TIME_START} ))
	local execution_time_sec=$(( ${execution_time_mil} / 10 ))

	if [ ${execution_time_sec} -lt 10 ] && [ "${_ZSH_EXIT_ERROR:-0}" -eq 0 ]; then
		_ZSH_COMMAND_INFO_SHOW=0
	fi

	local mil=$(( ${execution_time_mil} % 10 ))
	local sec=$(( ${execution_time_sec} % 60 ))
	local min=$(( ${execution_time_sec} / 60 % 60 ))
	local hrs=$(( ${execution_time_sec} / 3600 ))

	local timer_display=""
	if [ ${hrs} -gt 0 ]; then
		timer_display=$(printf "%dh %dm %ds" "$hrs" "$min" "$sec")
	elif [ ${min} -gt 0 ]; then
		timer_display=$(printf "%dm %ds" "$min" "$sec")
	else
		timer_display=$(printf "%d.%ds" "$sec" "$mil")
	fi

	_ZSH_COMMAND_TIME_INFO="%101F ${timer_display}%f"
}

_zsh_status_precmd() {
	# save exit codes in variable because "local" is a command
	# and overwrites $? and $pipestatus in this scope
	local exit_codes=("${pipestatus[@]}")

	local status_info=""
	local status_color=""

	_ZSH_EXIT_ERROR=0

	local stat
	for stat in ${exit_codes}; do
		if [ ${stat} -gt 0 ]; then
			# Remember error for later
			_ZSH_EXIT_ERROR=1
		fi

		if [ ${stat} -gt 128 ];then
			# process recieved signal, get signal name from exit code
			stat=$(kill -l ${stat})
		fi

		status_info="${status_info}|${stat}"
	done

	# Base success on the pipe's last command
	if [ ${exit_codes[${#exit_codes}]} -eq 0 ]; then
		status_color="✅%70F"
	else
		status_color="❌%160F"
	fi

	if [ ${_ZSH_EXIT_ERROR} -ne 0 ]; then
		# Remove leading "|" from $status_info
		_ZSH_COMMAND_STATUS_INFO="${status_color} ${status_info#\|}%f"
	else
		_ZSH_COMMAND_STATUS_INFO="${status_color}%f"
	fi
}

_zsh_print_cmd_info() {
	if [ "${_ZSH_COMMAND_INFO_SHOW}" -ne 0 ]; then
		print -P "─╸\[${_ZSH_COMMAND_STATUS_INFO}\]\-\[${_ZSH_COMMAND_TIME_INFO}\]\-\[ %T\]"
	fi
	unset _ZSH_COMMAND_INFO_SHOW
}

preexec_functions+=(_zsh_time_preexec)

# status check MUST be the first element to preserve $pipestatus (exit codes) of cmdline
precmd_functions=(_zsh_status_precmd "${precmd_functions[@]}")
precmd_functions+=(_zsh_time_precmd)
precmd_functions+=(_zsh_print_cmd_info)

