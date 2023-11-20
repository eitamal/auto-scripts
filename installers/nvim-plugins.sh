#!/usr/bin/env bash

# Update Neovim plugins using lazy.nvim and commit the changes.

function check_commands() {
	local commands=("$@")
	local missing_commands=()
	for cmd in "${commands[@]}"; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			missing_commands+=("$cmd")
		fi
	done

	if [ ${#missing_commands[@]} -gt 0 ]; then
		echo "The following commands are required but not found: ${missing_commands[*]}" >&2
		exit 1
	fi
}

function update_plugins() {
	nvim --headless "+Lazy! sync" +quitall || {
		echo "Error updating plugins" >&2
		exit 1
	}
}

function commit_changes() {
	local nvim_dir="${1:-$HOME/.config/nvim}"
	local lock_file="${2:-lazy-lock.json}"

	if [[ ! -d "$nvim_dir" ]]; then
		echo "Neovim directory, \"$nvim_dir\", not found." >&2
		exit 1
	fi

	if [[ ! -f "$nvim_dir/$lock_file" ]]; then
		echo "Neovim directory or lock file not found." >&2
		exit 1
	fi

	if ! git -C "$nvim_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		echo "Not a git repository: $nvim_dir" >&2
		exit 1
	fi

	if git -C "$nvim_dir" status --porcelain | rg --quiet "^ M $lock_file"; then
		local changed_lines
		local all_plugins

		changed_lines=$(git -C "$nvim_dir" diff --unified=0 "$lock_file" | rg '^\+[^\+]+') || {
			echo "Error getting changed lines." >&2
			exit 1
		}
		all_plugins=$(jq --raw-output 'keys[]' "$nvim_dir/$lock_file") || {
			echo "Error getting all plugins." >&2
			exit 1
		}

		local updated_plugins=()
		while read -r plugin; do
			if echo "$changed_lines" | rg --quiet "\"$plugin\":"; then
				updated_plugins+=("$plugin")
			fi
		done <<<"$all_plugins"

		git -C "$nvim_dir" add "$lock_file"
		git -C "$nvim_dir" commit --message "chore(plugins): update plugins"$'\n\n'"$(printf '%s\n' "${updated_plugins[@]/#/  - }")"
	else
		echo "No changes to commit."
	fi
}

# Check the required commands are available
check_commands nvim git jq rg

# Update plugins
update_plugins

# Commit changes
commit_changes "$@"
