#!/bin/sh

autoload -U colors && colors

_cust_time_preexec() {
	ZSH_COMMAND_TIME_START=${ZSH_COMMAND_TIME_START:-$(date "+%s%1N")}
}

_cust_time_precmd() {
	if [ $ZSH_COMMAND_TIME_START ]; then
		execution_time_mil=$(($(date "+%s%1N") - $ZSH_COMMAND_TIME_START))
		execution_time_sec=$((${execution_time_mil}/10))

		hrs=$((${execution_time_sec}/3600))
		min=$((${execution_time_sec}%3600/60))
		sec=$((${execution_time_sec}%60))
		mil=$((${execution_time_mil}%10))

		if [ $hrs -gt 0 ]; then
			timer_display=$(printf "%sh %sm %ss" "$hrs" "$min" "$sec")
		elif [ $min -gt 0 ]; then
			timer_display=$(printf "%sm %ss" "$min" "$sec")
		else
			timer_display=$(printf "%s.%ss" "$sec" "$mil")
		fi

		COMMAND_TIME_INFO="%101F ${timer_display}"
		unset ZSH_COMMAND_TIME_START
	fi
}

_cust_status_precmd() {
	ec=$?
	tmp_pipestatus=("$pipestatus[@]")

	unset status_info
	for ((i=1; i <= $#tmp_pipestatus; i++)); do
		stat="${tmp_pipestatus[i]}"

		if [ $stat -gt 0 ]; then
			ec_not_zero=1
		fi

		if [ ${stat} -gt 128 ];then
			stat=$(kill -l $stat)
		fi

		if [ $i -gt 1 ]; then
			stat="|${stat}"
		fi
		status_info="${status_info}${stat}"
	done

	if [ $ec -eq 0 ]; then
		status_color="✅%70F"
	else
		status_color="❌%160F"
	fi

	if [ $ec_not_zero ]; then
		unset ec_not_zero
		COMMAND_STATUS_INFO="${status_color} ${status_info}"
	else
		COMMAND_STATUS_INFO="${status_color}"
	fi
}

_cust_print_cmd_info() {

	if [ $COMMAND_TIME_INFO ]; then
		print -P "─╸\[${COMMAND_STATUS_INFO}%f\]\-\[${COMMAND_TIME_INFO}%f\]\-\[ %T\]"
	fi

	unset COMMAND_TIME_INFO
}

preexec_functions+=(_cust_time_preexec)

# make sure status check is the first element to preserve exit codes and pipestatus of cmdline
precmd_functions=("_cust_status_precmd" "${precmd_functions[@]}")
precmd_functions+=(_cust_time_precmd)
precmd_functions+=(_cust_print_cmd_info)

