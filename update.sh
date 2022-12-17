#!/usr/bin/env bash

# Only allow one instance of this script (Boilerplate taken from `man flock')
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :
[ -d "${HOME}/Dotfiles" ] || exit 1

###########################################################
arg_error=false
refresh=false
stow_everything=false
while [ $# -gt 0 ]; do
	case "$1" in
		-r | --refresh)
			refresh=true
			shift
			;;
		-e | --stow-everything)
			stow_everything=true
			refresh=true
			shift
			;;
		-*)
			echo "Unknown switch: $1" >&2
			arg_error=true
			shift
			;;
		*)
			echo "Unknown positional argument: $1" >&2
			arg_error=true
			shift
			;;
	esac
done
[ ${arg_error} = "true" ] && exit 1
###########################################################


# Wait for networking
while ! ping -c1 github.com &> /dev/null; do
	echo "Waiting for network connection. Sleeping 60s..."
	sleep 60
done

# Stash uncommited changes to preserve machine dependent modifications
cd "${HOME}/Dotfiles" || exit 1
git remote update > /dev/null || exit 2
git stash push --quiet

if [ "${refresh}" = "false" ]; then
	# No changes, nothing to do, pop stash, exit early
	if git diff --quiet "@{u}"; then
		[ -n "$(git stash list)" ] && git stash pop --quiet
		exit 0
	fi
fi

# Update Dotfiles
git pull --rebase --quiet

if [ -n "$(git stash list)" ]; then
	if ! git stash pop --quiet; then
		echo "Unable to pop stash. Changes are incompatible."
		exit 2
	fi
fi

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

		if [ -e "${abs_filename}" ] || [ "${stow_everything}" = "true" ]; then
			# Delete actual files so they can be replaced by appropriate symlinks
			rm -f "${abs_filename}"
			# Add module to the update list when the real file exists
			if ! grep -q "${module}" <<< "${module_list[*]}"; then
				module_list+=("${module}")
			fi
		fi
	fi
done < <(find -L "${HOME}/Dotfiles" -path "${HOME}/Dotfiles/.git" -prune -o -type f -print0)

if [ -z "${module_list[*]}" ];then
	>&2 echo "Cannot find any existing files of modules to stow"
	exit 1
fi

printf "Found and stowing these modules:\n%s\n" "${module_list[*]}"

# Prune potentially dead symlinks and add new ones
stow_output=$(2>&1 stow --dir="${HOME}/Dotfiles" --target="${HOME}" --no-folding --restow "${module_list[@]}")
stow_ec=$?
if [ "$stow_ec" -ne 0 ]; then
	>&2 echo "Error ocurred while stowing modules:"
	>&2 echo
	>&2 echo "${stow_output}"
	exit "${stow_ec}"
fi
