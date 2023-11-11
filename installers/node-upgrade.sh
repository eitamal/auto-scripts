#!/usr/bin/env bash

# Catppuccin Macchiato Colour Palette
ROSEWATER="\e[38;2;244;219;214m"
# FLAMINGO="\e[38;2;240;198;198m"
# PINK="\e[38;2;245;189;230m"
# MAUVE="\e[38;2;198;160;246m"
RED="\e[38;2;237;135;150m"
# MAROON="\e[38;2;238;153;160m"
# PEACH="\e[38;2;245;169;127m"
YELLOW="\e[38;2;238;212;159m"
GREEN="\e[38;2;166;218;149m"
TEAL="\e[38;2;139;213;202m"
# SKY="\e[38;2;145;215;227m"
# SAPPHIRE="\e[38;2;125;196;228m"
BLUE="\e[38;2;138;173;244m"
# LAVENDER="\e[38;2;183;189;248m"
TEXT="\e[38;2;202;211;245m"
SUBTEXT1="\e[38;2;184;192;224m"
# SUBTEXT0="\e[38;2;165;173;203m"
# OVERLAY2="\e[38;2;147;154;183m"
# OVERLAY1="\e[38;2;128;135;162m"
# OVERLAY0="\e[38;2;110;115;141m"
# SURFACE2="\e[38;2;91;96;120m"
SURFACE1="\e[38;2;73;77;100m"
# SURFACE0="\e[38;2;54;58;79m"
# BASE="\e[38;2;36;39;58m"
# MANTLE="\e[38;2;30;32;48m"
# CRUST="\e[38;2;24;25;38m"

RESET="\e[0m"
THEMED_RESET="$TEXT"
BOLD="\e[1m"
ITALIC="\e[3m"

# A function to print styled text and revert to default style - properly handling nested styles
# Arguments:
#   $1 - The style to apply (default: TEXT)
#   $2 - The text to print
#   $3 - newline character (default: \n)
styled_print() {
	local style="${1:-$TEXT}"
	local text
	text=$(replace_last_reset "$style" "$2")
	local newline="${3:-\n}"

	echo -ne "${RESET}${style}${text}${THEMED_RESET}${newline}"
}

replace_last_reset() {
	local style="$1"
	local input_text="$2"

	# If the input text contains the THEMED_RESET code
	if [[ "$input_text" == *"$THEMED_RESET"* ]]; then
		# Use parameter expansion to remove everything after the last THEMED_RESET code
		local prefix="${input_text%"$THEMED_RESET"*}"

		# Use parameter expansion to get everything after the last THEMED_RESET code
		local suffix="${input_text##*"$THEMED_RESET"}"

		# Reconstruct the string with the style code in place of the last THEMED_RESET
		echo "${prefix}${style}${suffix}"
	else
		echo "$input_text"
	fi
}

# Function to format the Node version
version() {
	styled_print "${BLUE}${ITALIC}" "v$1" ""
}

# Function to print error messages
error() {
	styled_print "$RED" "${2:-"❌ "}$1"
}

# Function to print success messages
success() {
	styled_print "$GREEN" "${2:-"✅ "}$1"
}

# Function to print info messages
info() {
	styled_print "$TEAL" "${2:-"ℹ️  "}$1"
}

# Function to print warning messages
warning() {
	styled_print "$YELLOW" "${2:-"⚠️  "}$1"
}

separator() {
	styled_print "$SURFACE1" "------------------------------------------" "\n\n"
}

header() {
	styled_print "${ROSEWATER}${BOLD}" "${1:-"🦿 "}"
}

subtext() {
	styled_print "$SUBTEXT1" "$1"
}

blank_line() {
	echo -e "${THEMED_RESET}\n"
}

reset() {
	echo -e "$RESET"
}

# Function to install and verify a Node version
install_node_version() {
	if ! rtx install "node@$1"; then
		error "Failed to install Node version $(version "$1")."
		exit 1
	fi
}

reinstall_npm_packages() {
	local node_version="node@$1"
	local npm_packages="$2"

	if [ -n "$npm_packages" ]; then
		info "Reinstalling npm packages" "📦 "
		info "Packages to reinstall:" ""
		for pkg in $npm_packages; do
			subtext "  💠 $pkg"
		done

		# Reinstall the npm packages for the new Node version
		local log_file
		log_file=$(mktemp "npm_install_XXXXXX_$(date +"%Y-%m-%d_%H-%M-%S").log")
		if ! rtx exec "$node_version" --command "npm install -g $npm_packages" >"$log_file" 2>&1; then
			error "Some packages failed to install. Please check the npm error output at $(subtext "$log_file")."
		else
			subtext "All packages have been reinstalled successfully."
			[ -n "$log_file" ] && rm "$log_file"
		fi
	else
		info "No packages found for reinstallation."
	fi
}

reshim() {
	subtext "Refreshing shims"
	rtx reshim node 1>/dev/null
}

main() {
	# Reset the style so that it doesn't affect the rest of the script
	reset

	header "Node Updater $(subtext "(using rtx)")"
	separator

	# Check if rtx is available
	if ! command -v rtx &>/dev/null; then
		error "rtx is not found in PATH. Please ensure rtx is installed and available."
		exit 1
	fi

	info "Checking Node version..." "🔍 "

	# Get the current and latest versions
	current_version=$(rtx global node)
	latest_version=$(rtx latest node)

	# Check if current_version or latest_version is empty
	if [[ -z "$current_version" || -z "$latest_version" ]]; then
		error "Error fetching Node versions. Please ensure rtx is functioning properly."
		exit 1
	fi

	formatted_current_version="$(version "$current_version")"
	formatted_latest_version="$(version "$latest_version")"

	subtext "Current: $formatted_current_version"
	subtext "Latest:  $formatted_latest_version"
	separator

	# Check if already up to date
	if [[ "$current_version" == "$latest_version" ]]; then
		success "You're already on the latest version of Node." "✨ "
		exit 0
	fi

	# Display the current version and the version you're updating to
	info "Updating $formatted_current_version ➡️ $formatted_latest_version" "🔄 "
	# Install the latest version of Node
	install_node_version "$latest_version"

	subtext "Version $formatted_latest_version installed."
	subtext "Checking for globally installed packages"

	# Get a list of globally installed npm packages
	npm_packages=$(rtx exec "node@$current_version" --command "npm ls -g --depth=0 --parseable=true --loglevel=error" | awk -F/ '{if ($NF != "lib") print $NF}' | grep -vE '^(npm|corepack)$')
	reinstall_npm_packages "$latest_version" "$npm_packages"

	# Inform the user that we're switching to the latest version of Node
	subtext "Switching to $formatted_latest_version"
	# Set the global version to the latest version
	rtx global node "$latest_version"
	subtext "Refreshing shims"
	# Refresh shims to ensure correct npm version is used
	rtx reshim node 1>/dev/null

	blank_line

	success "Node has been updated to $formatted_latest_version." "🎉 "
	# Reset the style so that it doesn't affect external applications
	reset
}

main
