#!/usr/bin/env bash


# Only allow one instance of this script (Boilerplate taken from `man flock')
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

# Wait for networking
while ! ping -c1 github.com &>/dev/null
do
	sleep 1
done

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
	case "$1" in
		--user=*)
				user="${1#*=}"
				;;
		--module-list=*)
				module_list="${1#*=}"
				;;
		*)
			printf "***************************\n"
			printf "* Error: Invalid argument!*\n"
			printf "***************************\n"
			exit 2
	esac
	shift
done

user=${user:=$USER}
[ -d "/home/${user}/Dotfiles" ] || exit 3

# Stash uncommited changes to preserve machine dependent modifications
cd "/home/${user}/Dotfiles"
git remote update &>/dev/null
git stash push --quiet


# Only allow skip when no modules where specified on the commandline
if [ -z "${module_list}" ]; then
	if git diff --quiet @{u}; then
		# Nothing to do, pop stash, exit early
		[ ! "$(git stash list)" = "" ] && git stash pop --quiet
		#######
		exit
		#######
	fi
fi

# Update Dotfiles
git pull --quiet
[ ! "$(git stash list)" = "" ] && git stash pop --quiet

# Get all files in the repo in a way that handles newlines in filenames gracefully (except .git directory)
dotfiles=$(find "/home/${user}/Dotfiles" -path "/home/${user}/Dotfiles/.git" -prune -o -type f -print0 | xargs -0 -I {} printf '%s,' {})
IFS=','
for repo_filename in $dotfiles
do
	# Replace newlines in filenames with placeholder for commands that work on a line by line basis
	sane_filename=$(sed -z 's/\n/@NEWLINE@/' <<< "${repo_filename}")

	# Get module name
	tmp_module=$(cut -d'/' -f5- <<< "${sane_filename}")
	module=$(cut -d'/' -f-1 <<< "${tmp_module}")

	# Cut "/home/$user/Dotfiles/$module/" out of filename (gets rid of files outside of modules as well)
	tmp_filename=$(cut -d'/' -f6- <<< "${sane_filename}")
	if [ -n "${tmp_filename}" ]; then
		# Get real filename again
		rel_filename=$(sed -z 's/@NEWLINE@/\n/' <<< "${tmp_filename}")
		abs_filename="/home/${user}/${rel_filename}"

		# Add module to a list when the real file exists
		if [ -e "${abs_filename}" ]; then
			# Delete actual files so they can be replaced by appropriate symlinks
			if [ ! -L "${abs_filename}" ]; then
				rm -f ${abs_filename}
			fi
			if [ -z "$(grep ${module} <<< ${module_list})" ]; then
				module_list=$(printf '%s %s' "${module_list}" "${module}")
			fi
		fi
	fi
done

# Prune potentially dead symlinks and add new ones
IFS=' '
stow --dir="/home/${user}/Dotfiles" --target="/home/${user}" --no-folding --restow $module_list
