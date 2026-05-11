#!/usr/bin/env bash

set -Eeuo pipefail

################################################################################
# CONFIG
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

LOG_DIR="${BASE_DIR}/logs"
LOG_FILE="${LOG_DIR}/bootstrap.log"

PACKAGES=(
  git
  curl
  wget
  python3
  python3-pip
  pipx
  shellcheck
)

PYTHON_TOOLS=(
  ansible-core
  ansible-lint
  yamllint
  pre-commit
)

################################################################################
# LOGGING
################################################################################

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

################################################################################
# FUNCTIONS
################################################################################

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log() {
  echo
  echo "[$(timestamp)] ============================================================"
  echo "[$(timestamp)] $1"
  echo "[$(timestamp)] ============================================================"
}

fail() {
  echo
  echo "[$(timestamp)] [ERRO] $1"
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 \
    || fail "Comando obrigatório não encontrado: $1"
}

################################################################################
# VALIDATIONS
################################################################################

log "Validando ambiente"

require_command sudo
require_command apt-get

################################################################################
# PASSWORDLESS SUDO
################################################################################

log "Configurando passwordless sudo"

if [[ ! -f /etc/sudoers.d/workstation ]]; then

  log "Criando configuracao passwordless sudo"

  echo "${USER} ALL=(ALL) NOPASSWD: ALL" | \
    sudo tee /etc/sudoers.d/workstation >/dev/null

  sudo chmod 0440 /etc/sudoers.d/workstation

  sudo visudo -cf /etc/sudoers.d/workstation \
    || fail "Arquivo sudoers inválido"

else

  log "Passwordless sudo já configurado"

fi


################################################################################
# APT UPDATE
################################################################################

log "Atualizando índice de pacotes"

sudo apt-get update

################################################################################
# INSTALL SYSTEM PACKAGES
################################################################################

log "Instalando ferramentas básicas"

sudo DEBIAN_FRONTEND=noninteractive \
  apt-get install -y "${PACKAGES[@]}"

################################################################################
# CONFIGURE PIPX
################################################################################

log "Configurando pipx"

pipx ensurepath --force

export PATH="$HOME/.local/bin:$PATH"

################################################################################
# INSTALL PYTHON TOOLING
################################################################################

log "Instalando tooling Python"

for tool in "${PYTHON_TOOLS[@]}"; do
  pipx uninstall "$tool" >/dev/null 2>&1 || true
done

for tool in "${PYTHON_TOOLS[@]}"; do
  pipx install "$tool"
done

################################################################################
# PREPARE ANSIBLE RUNTIME
################################################################################

log "Preparando runtime Ansible"

mkdir -p "$HOME/.ansible"
mkdir -p "$HOME/.ansible/tmp"
mkdir -p "$HOME/.cache/ansible/tmp"

chmod 700 "$HOME/.ansible"
chmod 700 "$HOME/.ansible/tmp"

################################################################################
# VALIDATION
################################################################################

log "Validando instalações"

for cmd in \
  git \
  python3 \
  pipx \
  shellcheck \
  ansible \
  ansible-lint \
  yamllint \
  pre-commit; do

  command -v "$cmd" >/dev/null 2>&1 \
    || fail "Falha na instalação de: $cmd"

done

################################################################################
# SUMMARY
################################################################################

log "Bootstrap concluído com sucesso"

echo
echo "Ferramentas instaladas:"
printf ' - %s\n' "${PACKAGES[@]}"

echo
echo "Ferramentas Python:"
printf ' - %s\n' "${PYTHON_TOOLS[@]}"

echo
echo "Log salvo em:"
echo "$LOG_FILE"
