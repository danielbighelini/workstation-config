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
# ERROR HANDLING
################################################################################

trap 'fail "Erro na linha ${LINENO}: comando \"${BASH_COMMAND}\" falhou"' ERR

################################################################################
# VALIDATIONS
################################################################################

log "Validando ambiente"

if [[ $EUID -eq 0 ]]; then
  fail "Não execute este script como root"
fi

require_command sudo
require_command apt-get

if [[ ! -f /etc/os-release ]]; then
  fail "Arquivo /etc/os-release não encontrado"
fi

# shellcheck disable=SC1091
source /etc/os-release

case "$ID" in
  ubuntu|debian)
    log "Distribuição suportada detectada: $ID"
    ;;
  *)
    fail "Distribuição não suportada: $ID"
    ;;
esac

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
sudo apt-get update -o Acquire::Retries=3

log "Atualizando pacotes"
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

################################################################################
# INSTALL SYSTEM PACKAGES
################################################################################

log "Instalando ferramentas básicas"

sudo DEBIAN_FRONTEND=noninteractive \
  apt-get install -y \
  -o Acquire::Retries=3 \
  "${PACKAGES[@]}"

################################################################################
# CONFIGURE PIPX
################################################################################

log "Configurando pipx"

# shellcheck disable=SC2016
if ! grep -qF '$HOME/.local/bin' ~/.bashrc; then

  {
    echo
    echo '# Criado por bootstrap.sh do projeto workstation-config'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> ~/.bashrc

fi

################################################################################
# INSTALL/UPGRADE PYTHON TOOLING
################################################################################

log "Instalando/Atualizando tooling Python"

PIPX_INSTALLED="$(pipx list --short)"

for tool in "${PYTHON_TOOLS[@]}"; do

  if grep -q "^${tool} " <<< "$PIPX_INSTALLED"; then

    log "Atualizando tool Python: $tool"
    pipx upgrade "$tool"

  else

    log "Instalando tool Python: $tool"
    pipx install "$tool"

  fi

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
chmod 700 "$HOME/.cache/ansible/tmp"

################################################################################
# VALIDATION
################################################################################

log "Validando instalações"

for pkg in "${PACKAGES[@]}"; do
  dpkg -s "$pkg" >/dev/null 2>&1 \
    || fail "Pacote não instalado: $pkg"
done

for tool in "${PYTHON_TOOLS[@]}"; do
  pipx list --short | grep -q "^${tool} " \
    || fail "Tool Python não instalada: $tool"
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
