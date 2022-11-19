#!/usr/bin/env bash

# Only allow one instance of this script (Boilerplate taken from `man flock')
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :
[ -d "${HOME}/Dotfiles" ] || exit 1

###########################################################
arg_error=0
while [ $# -gt 0 ]; do
	case "$1" in
		-r | --refresh)
			refresh=true
			;;
		-e | --stow-everything)
			stow_everything=true
			;;
		-*)
			echo "Unknown switch: $1" >&2
			arg_error=1
			;;
		*)
			echo "Unknown positional argument: $1" >&2
			arg_error=1
			;;
	esac
done
[ ${arg_error} -ne 0 ] && exit 1
###########################################################


# Check if cron job exists and update it if not
cronjob="#>>>>>> Dotfile-Update
@hourly ${HOME}/Dotfiles/update.sh &> /dev/null
@reboot ${HOME}/Dotfiles/update.sh &> /dev/null
#<<<<<< Dotfile-Update"
found_jobs="$(crontab -l | grep -zoE '#>>>>> Dotfile-Update.*#<<<<< Dotfile-Update' | tr -d '\0')"

if [[ "${found_jobs}" != "${cronjob}" ]]; then
	echo -e "$(crontab -l | sed -e '/#>>>>>> Dotfile-Update/,/#<<<<<< Dotfile-Update/d')\n${cronjob}" | crontab -
fi

# Wait for networking
while ! ping -c1 github.com &> /dev/null; do
	echo "Waiting for network connection. Sleeping 60s..."
	sleep 60
done

# Stash uncommited changes to preserve machine dependent modifications
cd "${HOME}/Dotfiles" || exit 1
git remote update &> /dev/null || exit 2
git stash push --quiet

if [ -z "${refresh}" ]; then
	# No changes, nothing to do, pop stash, exit early
	if git diff --quiet "@{u}"; then
		[ -n "$(git stash list)" ] && git stash pop --quiet
		exit 0
	fi
fi

# Update Dotfiles
git pull --rebase --quiet

[ -n "$(git stash list)" ] && {
	git stash pop --quiet || {
		echo "Unable to pop stash. Changes are incompatible."
		exit 2
	}
}

# Get all files in the repo (except .git directory)
while IFS= read -r -d $'\0' repo_filename; do
	# Replace newlines in filenames with placeholder for commands that work on a line by line basis
	sane_filename=$(sed -z 's/\n/@NEWLINE@/' <<< "${repo_filename}")

	# Get module name
	tmp_module=$(cut -d'/' -f5- <<< "${sane_filename}")
	module=$(cut -d'/' -f-1 <<< "${tmp_module}")

	# Cut "/home/${USER}/Dotfiles/$module/" out of filename (gets rid of files outside of modules as well)
	tmp_filename=$(cut -d'/' -f6- <<< "${sane_filename}")
	if [ -n "${tmp_filename}" ]; then
		# Get real filename again
		rel_filename=$(sed -z 's/@NEWLINE@/\n/' <<< "${tmp_filename}")
		abs_filename="${HOME}/${rel_filename}"

		if [ -n "${stow_everything}" ]; then
			if ! grep -q "${module}" <<< "${module_list[*]}"; then
				module_list+=("${module}")
			fi
		fi

		if [ -e "${abs_filename}" ]; then
			# Delete actual files so they can be replaced by appropriate symlinks
			if [ ! -L "${abs_filename}" ]; then
				rm -f "${abs_filename}"
			fi
			# Add module to the update list when the real file exists
			if ! grep -q "${module}" <<< "${module_list[*]}"; then
				module_list+=("${module}")
			fi
		fi
	fi
done < <(find "${HOME}/Dotfiles" -path "${HOME}/Dotfiles/.git" -prune -o -type f -print0)

printf "Found and stowing these modules:\n%s\n" "${module_list[*]}"

# Prune potentially dead symlinks and add new ones
stow --dir="${HOME}/Dotfiles" --target="${HOME}" --no-folding --restow "${module_list[@]}"
