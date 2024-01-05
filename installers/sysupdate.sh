#!/usr/bin/env bash

function bgjob() {
    local color_blue="\033[34m"
    local color_red="\033[31m"
    local color_reset="\033[0m"

    local prefix_blue="[$color_blue$1$color_reset]:"
    local prefix_red="[$color_red$1$color_reset]:"

    # Redirect stdout to handle it
    exec 3>&1

    echo "cmd: '${@:2}'"
    # Run the command in the background
    eval "${@:2}" > >(while IFS= read -r line; do
                    echo -e "$prefix_blue $line"
               done >&3) \
           2> >(while IFS= read -r line; do
                    echo -e "$prefix_red $line"
               done >&2) &

    # Close the extra file descriptor
    exec 3>&-
}

function main() {
    local gh_update="$(realpath "$(dirname "$0")/../util/gh-update.sh")"

    bg_pids=()

    local _=$(sudo echo "") # throw away to trigger sudo password prompt
    bgjob apt 'sudo apt update &&
        sudo apt upgrade -y &&
        sudo apt full-upgrade -y &&
        sudo apt autoclean &&
        sudo apt autoremove'
    bg_pids+=($!)

    bgjob bat "$gh_update" bat sharkdp/bat "\"bat --version\"" "\"^bat_.+amd64.deb\""
    bg_pids+=($!)

    bgjob mise mise self-update --yes
    bg_pids+=($!)

    bgjob pipx pipx upgrade-all --quiet --include-injected
    bg_pids+=($!)

    bgjob brew brew upgrade
    bg_pids+=($!)

    bgjob encore encore version update
    bg_pids+=($!)

    any_job_failed=0

    # Wait for all background jobs and check their exit status
    for pid in "${bg_pids[@]}"; do
        wait "$pid"
        exit_status=$?
        if [ $exit_status -ne 0 ]; then
            echo "Job with PID $pid failed with exit status $exit_status"
            any_job_failed=1
        fi
    done

    if [ $any_job_failed -ne 0 ]; then
        >&2
        echo "One or more background jobs failed."
    else
        echo "All background jobs completed successfully."
    fi

    exit "$any_job_failed"
}

main

