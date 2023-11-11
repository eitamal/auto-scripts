#!/usr/bin/env bash

sudo apt update && \
    sudo apt upgrade -y && \
    sudo apt full-upgrade -y && \
    sudo apt autoclean && \
    sudo apt autoremove

rtx self-update

../util/gh-update.sh "bat" "sharkdp/bat" "bat --version" '"^bat_.+amd64\\.deb"'
../util/gh-update.sh "hurl" "Orange-OpenSource/hurl" "hurl --version" '"^hurl_.+amd64\\.deb"'

pipx upgrade-all
brew upgrade
encore version update
