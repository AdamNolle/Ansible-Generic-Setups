#!/usr/bin/env bash
#
# One-shot macOS bootstrap for Ansible-Generic-Setups. Installs the bare minimum
# (Xcode CLT, Homebrew, Ansible), clones this repo, and runs the mac play.
# Safe to re-run. No GitHub login needed — the repo is public.
#
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-AdamNolle}"          # override: REPO_OWNER=you ./mac.sh
REPO_NAME="Ansible-Generic-Setups"
CLONE_DIR="${HOME}/${REPO_NAME}"

echo "==> Xcode Command Line Tools"
xcode-select -p &>/dev/null || xcode-select --install

echo "==> Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$([ -x /opt/homebrew/bin/brew ] && /opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
fi

echo "==> Ansible + git"
brew list ansible &>/dev/null || brew install ansible
brew list git &>/dev/null || brew install git

echo "==> Clone ${REPO_OWNER}/${REPO_NAME}"
if [ -d "${CLONE_DIR}/.git" ]; then
  git -C "${CLONE_DIR}" pull --ff-only
else
  git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "${CLONE_DIR}"
fi
cd "${CLONE_DIR}"

echo "==> Ansible collections"
ansible-galaxy collection install -r requirements.yml

echo "==> Run the macOS play"
exec ansible-playbook site.yml --limit mac
