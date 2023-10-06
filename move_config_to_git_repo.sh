#!/bin/bash

DEFAULT_SRC="${HOME}"
WS_CFG_DIR="${HOME}/workstation_config"
CONFIG_DIR="${WS_CFG_DIR}/config"
MANIFEST_LOG="${WS_CFG_DIR}/logs/symlink_manifest"

show_help() {
	echo "Usage: $0 [OPTIONS] [FILES || DIR]"
	echo "  -h, --help       Show help."
	echo "  --dry-run        Display actions without performing them."
	echo "  --undo           Undo specific symlink operations."
	echo "  FILES            List of files to be moved and symlinked."
	# TODO: echo "  DIR              Directory of files to be symlinked."
}

# If --dry-run is set, don't actually do anything, just echo the actions that
# would be performed.
dry_run=0
# If --undo is set, select a line from the manifest file to undo.
undo=0
# Create an array to hold file arguments.
file_args=()

# Handle options
while :; do
	case $1 in
	-h | --help)
		show_help
		exit
		;;
	--dry-run)
		dry_run=1
		;;
	--undo)
		undo=1
		;;
	--)
		shift
		break
		;;
	-*)
		echo "Unknown option: $1"
		show_help
		exit 1
		;;
	*)
		[[ -z $1 ]] && break
		# If it's not an option, it's a file argument.
		file_args+=("$1")
		;;
	esac
	# Remove this argument before the next iteration.
	shift
	# If we're out of arguments, stop the loop.
	[[ -z $1 ]] && break
done

if [[ ! -d ${CONFIG_DIR} ]]; then
	read -p "Directory ${CONFIG_DIR} does not exist. Create? [y/n] " -n 1 -r REPLY
	echo
	if [[ ${REPLY} =~ ^[Yy]$ ]]; then
		mkdir -p "${CONFIG_DIR}"
	else
		echo "Exiting..."
		exit 1
	fi
fi

# Function to record and perform actions
do_action() {
	local action="$1"
	local undo_action="$2"
	local manifest_line="${action} ||| ${undo_action}"

	if [[ ${dry_run} -eq 1 ]]; then
		echo "DRY-RUN: ${action}"
	else
		echo "${manifest_line}" >>"${MANIFEST_LOG}"
		eval "${action}"
	fi
}

# Function to perform undo
undo_action() {
	if [[ -f ${MANIFEST_LOG} ]]; then
		cat -n "${MANIFEST_LOG}"
		read -p "Select a line number to undo (0 to exit): " -r line_number
		[[ ${line_number} -eq 0 ]] && exit 0

		local manifest_line
		local undo
		manifest_line=$(sed -n "${line_number}p" "${MANIFEST_LOG}")
		undo="${manifest_line##* ||| }"

		echo "Undoing: ${undo}"
		eval "${undo}" && sed -i "${line_number}d" "${MANIFEST_LOG}"
	else
		echo "Manifest file does not exist. Nothing to undo."
		exit 1
	fi
}

if [[ ${undo} -eq 1 ]]; then
	undo_action
	exit 0
fi

# Function to get the files, excluding those that match ./.gitignore patterns
get_filtered_files() {
	local dir="$1"
	local find_results=""
	local gitignore=".gitignore"

	# If the directory doesn't exist, return 0:
	[[ ! -d ${dir} ]] && return 0

	find_results=$(find "${dir}" -maxdepth 1 -type f)
	[[ -z ${find_results} ]] && return 0

	if [[ -f ${gitignore} ]]; then
		echo "${find_results}" | while read -r file; do
			if ! git check-ignore -q "$(basename "${file}")"; then
				echo "${file}"
			fi
		done
	else
		# If .gitignore doesn't exist, return all files (but still try to support a
		# future use case if a different ~/**.gitignore should be honored):
		${find_results}
	fi
}

if [[ ${#file_args[@]} -eq 0 ]]; then
	filtered_files=$(get_filtered_files "${DEFAULT_SRC}")
	[[ -z ${filtered_files} ]] && exit 0

	echo "${filtered_files}" | while read -r f; do
		# Skip if not a regular file:
		[[ -f ${f} ]] || continue
		filename=$(basename "${f}")
		echo "${filename}"

		# If symlink:
		if [[ -L ${f} ]]; then
			# Check if link is broken:
			if [[ ! -e ${f} ]]; then
				do_action "echo \"${f} is broken.\""
			fi
		# If not symlink:
		else
			if [[ ! -f "${CONFIG_DIR}/${filename}" ]]; then
				do_action "mv \"${f}\" \"${CONFIG_DIR}/\" && ln -s \"${CONFIG_DIR}/${filename}\" \"${f}\"" "trash \"${f}\" && mv \"${CONFIG_DIR}/${filename}\" \"${f}\""
			fi
		fi
	done
# One or more arguments:
else
	echo "${#file_args[@]} args supplied."
	for f in "${file_args[@]}"; do
		if [[ ! -f ${f} ]] && [[ ! -d ${f} ]]; then
			echo "File/directory ${f} does not exist. Skipping..."
			continue
		fi
		dir=$(dirname "${f}")
		filename=$(basename "${f}")

		do_action "mv \"${f}\" \"${CONFIG_DIR}/\" && ln -s \"${CONFIG_DIR}/${filename}\" \"${dir}/${filename}\"" "trash \"${f}\" && mv \"${CONFIG_DIR}/${filename}\" \"${f}\""
	done
fi
