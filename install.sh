#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

echo "Starting installation & configuration..."

echo "Configuring dotfiles..."
cd ./home || exit
find * -type d -exec mkdir -p "${HOME}"/.{} \;
find * -type f -exec ln -sf "${PWD}"/{} "${HOME}"/.{} \;
echo "Completed Configuring dotfiles!"

echo "Installing Homebrew"
CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
echo "Completed Installing Homebrew!"

echo "Installing Homebrew packages..."
brew update
brew bundle install --global --no-lock
brew bundle cleanup --force --global
echo "Completed Installing Homebrew packages!"

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
echo "Completed Installing Oh My Zsh!"

echo "Configuring SSH..."
ssh_home="${HOME}"/.ssh
ssh_key="${ssh_home}"/id_rsa
rm -f "${ssh_key}".pub "${ssh_key}".pem
curl -sS 'https://github.com/syncdk.keys' -o "${ssh_key}".pub
chmod 400 "${ssh_key}".pub
ssh-keygen -f "${ssh_key}".pub -e -m pem >"${ssh_key}".pem
chmod 400 "${ssh_key}".pem
echo "Completed Configuring SSH!"

echo "Configuring Vim..."
vim_home="${HOME}"/.vim
mkdir -p "${vim_home}"/swap
mkdir -p "${vim_home}"/undo
echo "Completed Configuring Vim!"

echo "Configuring Projects..."
project_home="${HOME}"/Projects
mkdir -p "${project_home}"/sandbox
echo "Completed Configuring Projects!"

echo "Completed installation & configuration!"
