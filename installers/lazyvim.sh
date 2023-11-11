#!/usr/bin/env bash
# This is a simple script to install my fork of LazyVim

# neovim directory - required
cfg_dir="$HOME/.config/nvim"
# neovim cache/state directories - optional
opt_dirs=("$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim")
backup_dirs=($cfg_dir "${opt_dirs[@]}")

for $dir in ${backup_dirs[@]}; do
  # Backup neovim directories
  if [ -d $dir ]; then
    mv "$dir"{,.bak}
  fi
done

# clone repo
repo="eitamal/lazyvim"
git clone git@github:$repo.git $cfg_dir

# start nvim and don't forget to run :checkhealth

