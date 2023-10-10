#!/bin/bash

DEFAULT_SRC_DIR="${HOME}"
SRC_DIR=""
WS_CFG_DIR="${HOME}/workstation_config"
CONFIG_DIR="${WS_CFG_DIR}/config"
MANIFEST_LOG="${WS_CFG_DIR}/logs/symlink_manifest"

# If --verbose is set, print verbose output.
verbose=false
# If --dry-run is set, don't actually do anything, just echo the actions that
# would be performed.
dry_run=false
# If --interactive is set, prompt for each file.
interactive=false
# If --undo is set, select a line from the manifest file to undo.
undo=false
# Create an array to hold file arguments.
file_args=()
# Create a variable to hold the new name for the file.
target_file_name=""

show_help() {
	echo "Usage: $0 [OPTIONS] [ DIR or FILES ]"
	echo "  -h, --help       	Show help."
	echo "  -v, --verbose       Verbose output."
	echo "  -i, --interactive   Prompt for each file."
	echo "  --dry-run        	Display actions without performing them."
	echo "  --undo           	Undo specific symlink operations."
	echo "  -N, --new-name      New name for the file in the repo."
	echo
	echo "  FILES            	List of files to be moved and symlinked."
	echo "  DIR 				Directory of files to be symlinked."
}

# Handle options
while :; do
	case $1 in
	-h | --help)
		show_help
		exit
		;;
	-v | --verbose)
		verbose=true
		;;
	-i | --interactive)
		interactive=true
		;;
	--dry-run)
		dry_run=true
		;;
	--undo)
		undo=true
		;;
	-N | --new-name)
		if [[ -z $2 ]]; then
			echo "ERROR: --new-name requires an argument."
			exit 1
		fi
		target_file_name="$2"
		shift
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
		if [[ -d $1 ]]; then
			SRC_DIR="$1"
		elif [[ -f $1 ]]; then
			file_args+=("$1")
		else
			echo "ERROR: $1 is not a valid file or directory."
			exit 2
		fi
		;;
	esac
	# Remove this argument before the next iteration.
	shift
	# If we're out of arguments, stop the loop.
	[[ -z $1 ]] && break
done

verbose_echo() {
	if ${verbose}; then
		echo "$@"
		echo
	fi
}

# If no source directory is specified, use the default.
if [[ -z ${SRC_DIR} ]]; then
	SRC_DIR="${DEFAULT_SRC_DIR}"
fi
verbose_echo "Source directory: ${SRC_DIR}"
# If no files are specified, use the files in the source directory.
if [[ ${#file_args[@]} -eq 0 ]]; then
	file_args=$(find "${SRC_DIR}" -maxdepth 1 -type f)
fi
verbose_echo "File arguments: "
verbose_echo "${file_args}"

if [[ ! -d ${CONFIG_DIR} ]]; then
	read -p "Directory ${CONFIG_DIR} does not exist. Create? [y/n] " -r create_config_dir_response
	echo
	if [[ ${create_config_dir_response} =~ ^[Yy]$ ]]; then
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

	if ${dry_run}; then
		echo "DRY-RUN: ${manifest_line}"
	else
		verbose_echo "Recording action in manifest file: ${MANIFEST_LOG}"
		echo "${manifest_line}" >>"${MANIFEST_LOG}"
		eval "${action}"
	fi
}

# Function to perform undo
undo_action() {
	if [[ ! -f ${MANIFEST_LOG} ]]; then
		echo "Manifest file does not exist. Nothing to undo."
		exit 1
	fi

	line_number=-1
	until [[ ${line_number} -eq 0 || "${line_number}" =~ ^[Qq]$ ]]; do
		cat -n "${MANIFEST_LOG}"
		read -p "Select a line number to undo (0 to exit): " -r line_number

		local manifest_line
		local undo
		manifest_line=$(sed -n "${line_number}p" "${MANIFEST_LOG}")
		undo="${manifest_line##* ||| }"
		if ${interactive}; then
			echo "Commands that will run: ${undo}."
			echo
			read -p "Proceed? [y/n] " -r -n 1 undo_requested
			echo
			if [[ ! ${undo_requested} =~ ^[Yy]$ ]]; then
				echo "Cancelled action."
				continue
			fi
		fi

		if ${dry_run}; then
			echo "DRY-RUN: ${undo}"
		else
			verbose_echo "Undoing with: ${undo}"
			eval "${undo}" && sed -i "${line_number}d" "${MANIFEST_LOG}"
		fi
	done
}

# Function to get the files, excluding those that match ./.gitignore patterns
get_filtered_files() {
	local source_dir="$1"
	local find_results=""
	local gitignore=".gitignore"

	# If the directory doesn't exist, return 0:
	[[ ! -d ${source_dir} ]] && return 0

	# If the directory doesn't contain any files, return 0:
	find_results=$(find "${source_dir}" -maxdepth 1 -type f)
	[[ -z ${find_results} ]] && return 0

	if [[ -f ${gitignore} ]]; then
		for file_path in ${find_results}; do
			if ! git check-ignore -q "$(basename "${file_path}")"; then
				echo "${file_path}"
			fi
		done
	else
		# TODO: support a future use case if a different ~/**.gitignore should be honored
		# If .gitignore doesn't exist, return all files:
		${find_results}
	fi
}

if ${undo}; then
	undo_action
	exit 0
fi

filtered_files=$(get_filtered_files "${SRC_DIR}")
verbose_echo "Filtered files: ${filtered_files}"
for file_name in ${filtered_files}; do
	verbose_echo "File: ${file_name}"
	if ${interactive}; then
		read -p "Symlink ${file_name}? [y/n] " -r symlink_requested
		echo
		if [[ ! ${symlink_requested} =~ ^[Yy]$ ]]; then
			echo "Skipping..."
			continue
		fi
	fi

	old_path="${file_name}"
	new_path="${CONFIG_DIR}/$(basename "${old_path}")"

	until [[ ! -e ${new_path} ]]; do
		read -p "File ${new_path} already exists. Choose a new name? [y/n] " -r new_name_requested

		if [[ ${new_name_requested} =~ ^[Yy]$ ]]; then
			read -p "Enter new name: " -r target_file_name_generic
			new_path="${CONFIG_DIR}/${target_file_name_generic}"
		else
			echo "Skipping..."
			continue 2
		fi
	done

	action_str="mv \"${old_path}\" \"${new_path}\" && ln -s \"${new_path}\" \"${old_path}\""
	undo_str="trash \"${old_path}\" && mv \"${new_path}\" \"${old_path}\""

	echo
	verbose_echo "Action: ${action_str}"
	verbose_echo "Undo: ${undo_str}"

	do_action "${action_str}" "${undo_str}"

done
# # One or more arguments:
# else
# 	for file_name in "${file_args[@]}"; do
# 		if [[ ! -f ${file_name} ]] && [[ ! -d ${file_name} ]]; then
# 			echo "File/directory ${file_name} does not exist. Skipping..."
# 			continue
# 		fi
# 		old_path="${file_name}"

# 		if [[ -n ${target_file_name} ]]; then
# 			new_path="${CONFIG_DIR}/${target_file_name}"
# 		else
# 			filename=$(basename "${old_path}")
# 			new_path="${CONFIG_DIR}/${filename}"
# 		fi
# 		while [[ -f ${new_path} ]]; do
# 			read -p "File ${new_path} already exists. Choose a new name? [y/n] " -n 1 -r new_name_requested
# 			echo
# 			if [[ ${new_name_requested} =~ ^[Yy]$ ]]; then
# 				read -p "Enter new name: " -r target_file_name
# 				new_path="${CONFIG_DIR}/${target_file_name}"
# 			else
# 				echo "Skipping..."
# 				break
# 			fi
# 		done

# 		[[ -f ${new_path} ]] && continue

# 		action_str="mv \"${old_path}\" \"${new_path}\" && ln -s \"${new_path}\" \"${old_path}\""
# 		undo_str="trash \"${old_path}\" && mv \"${new_path}\" \"${old_path}\""

# 		echo "Action: ${action_str}"
# 		echo "Undo: ${undo_str}"

# 		do_action "${action_str}" "${undo_str}"

# 	done
# fi
