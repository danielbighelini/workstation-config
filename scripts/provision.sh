#!/usr/bin/env bash

set -Eeuo pipefail

################################################################################
# CONFIG
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ANSIBLE_DIR="${BASE_DIR}/ansible"

ENVIRONMENT="${1:-localhost}"

PLAYBOOK="playbooks/workstation.yml"
INVENTORY="inventories/${ENVIRONMENT}/hosts.yml"

LOG_DIR="${BASE_DIR}/logs"
LOG_FILE="${LOG_DIR}/provision-${ENVIRONMENT}.log"

################################################################################
# USER CONTEXT
################################################################################

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

export HOME="$REAL_HOME"

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

require_command ansible-playbook
require_command python3

[[ -f "${ANSIBLE_DIR}/${PLAYBOOK}" ]] \
  || fail "Playbook não encontrado"

[[ -f "${ANSIBLE_DIR}/${INVENTORY}" ]] \
  || fail "Inventory não encontrado"

################################################################################
# EXECUTION
################################################################################

log "Ambiente selecionado: ${ENVIRONMENT}"

log "Usuário real detectado: ${REAL_USER}"

pushd "$ANSIBLE_DIR" >/dev/null

log "Executando provisionamento Ansible"

ANSIBLE_CONFIG=ansible.cfg \
ansible-playbook \
  -i "$INVENTORY" \
  "$PLAYBOOK" \
  -e ansible_user="$REAL_USER"

popd >/dev/null

################################################################################
# SUMMARY
################################################################################

log "Provisionamento concluído com sucesso"

echo
echo "Playbook executado:"
echo "${ANSIBLE_DIR}/${PLAYBOOK}"

echo
echo "Inventory utilizado:"
echo "${ANSIBLE_DIR}/${INVENTORY}"

echo
echo "Log salvo em:"
echo "$LOG_FILE"
