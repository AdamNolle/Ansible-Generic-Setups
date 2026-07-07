#!/usr/bin/env bash
#
# One-shot Linux bootstrap (Debian/Ubuntu family) for Ansible-Generic-Setups.
# Installs Ansible + git, clones this repo, and runs the linux play. Re-runnable.
#
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-AdamNolle}"          # override: REPO_OWNER=you ./linux.sh
REPO_NAME="Ansible-Generic-Setups"
CLONE_DIR="${HOME}/${REPO_NAME}"

echo "==> Ansible + git"
if ! command -v ansible-playbook &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y ansible git
fi

echo "==> Clone ${REPO_OWNER}/${REPO_NAME}"
if [ -d "${CLONE_DIR}/.git" ]; then
  git -C "${CLONE_DIR}" pull --ff-only
else
  git clone "https://github.com/${REPO_OWNER}/${REPO_NAME}.git" "${CLONE_DIR}"
fi
cd "${CLONE_DIR}"

echo "==> Ansible collections"
ansible-galaxy collection install -r requirements.yml

echo "==> Run the Linux play (you'll be asked for your sudo password)"
exec ansible-playbook site.yml --limit linux -K
