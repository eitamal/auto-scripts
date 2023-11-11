#!/usr/bin/env bash

# Function to print colored messages
print_message() {
	local purpose="$1"
	local message="$2"

	case $purpose in
	primary) printf "\033[38;5;4m%s\033[0m\n" "$message" ;;
	secondary) printf "\033[3;38;5;7m%s\033[0m\n" "$message" ;;
	success) printf "\033[38;5;2m%s\033[0m\n" "$message" ;;
	danger) printf "\033[1;38;5;1m%s\033[0m\n" "$message" ;;
	warning) printf "\033[1;38;5;3m%s\033[0m\n" "$message" ;;
	info) printf "\033[3;38;5;6m%s\033[0m\n" "$message" ;;
	*) echo "$message" ;;
	esac
}

# Extracts the version number using a regex that supports semver including build/prerelease
extract_version() {
	echo "$1" | grep -oP '\d+\.\d+\.\d+(-[0-9A-Za-z-.]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?'
}

# Checks if the required commands are installed
check_commands() {
	for cmd in curl jq dpkg "$command_name"; do
		if ! command -v "$cmd" >/dev/null; then
			print_message danger "$cmd is required but not installed."
			exit 1
		fi
	done
}

# Gets the current version of the given package installed
get_current_version() {
	package_version=$(extract_version "$($version_command | awk '{print $2}')") # TODO: Find a more generic way to extract the version
	if [ -z "$package_version" ]; then
		print_message danger "Failed to extract the version."
		exit 1
	fi
}

# Fetches metadata from the GitHub API for the latest release of the given package
fetch_metadata() {
	print_message secondary "Fetching metadata for the latest release of $command_name."

	local metadata_url="https://api.github.com/repos/$github_repo/releases/latest"
	metadata=$(curl -sSfL "$metadata_url")

	if [ -z "$metadata" ]; then
		print_message danger "Failed to fetch metadata."
		exit 1
	fi

	latest_version=$(extract_version "$(echo "$metadata" | jq -r '.tag_name')")
	url=$(echo "$metadata" | jq -r ".assets[] | select(.name | test($tagname_matcher)) | .browser_download_url")

	print_message success "Metadata fetched successfully."
}

# Checks if the latest version is greater than the current version
is_latest_version_greater() {
	IFS='.' read -ra current <<<"$package_version"
	IFS='.' read -ra latest <<<"$latest_version"

	for i in "${!current[@]}"; do
		if ((10#${latest[i]} > 10#${current[i]})); then
			return 0
		elif ((10#${latest[i]} < 10#${current[i]})); then
			return 1
		fi
	done

	return 1
}

# Updates the package if a newer version is available
update_package() {
	if is_latest_version_greater; then
		print_message primary "An update is available. Updating $command_name to version $latest_version."

		local file
		file="$(mktemp -d)/$(basename "$url")"

		print_message secondary "Downloading update."
		if ! curl -sSfL "$url" -o "$file"; then
			print_message danger "Failed to download the update."
			exit 1
		fi

		print_message secondary "Installing update."
		if ! sudo dpkg -i "$file"; then
			print_message danger "Failed to install the update."
			exit 1
		fi

		print_message success "$command_name updated successfully to version $latest_version!"
	else
		print_message warning "$command_name is up to date."
	fi
}

# Main function to control the flow of the script
main() {
	if [ "$#" -ne 4 ]; then
		local exit_code=0
		if [ "$#" -ne 0 ]; then
			print_message danger "Invalid number of arguments. Expected 4 received $#"
			exit_code=1
		fi
		echo "Usage: $0 <command_name> <github_repo> <version_command> <tagname_matcher>"
		exit $exit_code
	fi

	command_name="$1"
	github_repo="$2"
	version_command="$3"
	tagname_matcher="$4"

	check_commands
	get_current_version

	print_message info "Package Name: $command_name"
	print_message info "Current Version: $package_version"

	fetch_metadata
	print_message info "Latest Version: $latest_version"
	print_message info "Download URL: $url"

	update_package
}

# Execute the main function
main "$@"
