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
  unzip
  python3
  python3-pip
  ansible
  vim
  tmux
  jq
  htop
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
# APT UPDATE
################################################################################

log "Atualizando índice de pacotes"

sudo apt-get update

################################################################################
# INSTALL PACKAGES
################################################################################

log "Instalando ferramentas básicas"

sudo DEBIAN_FRONTEND=noninteractive \
  apt-get install -y "${PACKAGES[@]}"

################################################################################
# VALIDATION
################################################################################

log "Validando instalações"

for pkg in git python3 ansible jq htop; do
  command -v "$pkg" >/dev/null 2>&1 \
    || fail "Falha na instalação de: $pkg"
done

################################################################################
# SUMMARY
################################################################################

log "Bootstrap concluído com sucesso"

echo
echo "Ferramentas instaladas:"
printf ' - %s\n' "${PACKAGES[@]}"

echo
echo "Log salvo em:"
echo "$LOG_FILE"