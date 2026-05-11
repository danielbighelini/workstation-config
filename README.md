# Workstation Config

Repositório para provisionamento e padronização de ambientes Linux/WSL2 utilizando:

* Ansible
* dotfiles versionados
* scripts de bootstrap/provisionamento
* Infrastructure as Code (IaC)

O objetivo é manter uma workstation:

* reproduzível
* portátil
* versionada
* auditável
* facilmente reconstruível
* consistente entre máquinas

---

# Filosofia do Projeto

Este projeto trata a workstation como infraestrutura declarativa.

Em vez de configurar manualmente:

* shell
* pacotes
* Docker
* PowerShell
* aliases
* Git
* ferramentas de desenvolvimento
* configurações do usuário

...todo o ambiente passa a ser definido em código.

Isso permite:

* rebuild rápido de máquinas
* onboarding simplificado
* versionamento da configuração
* rollback
* padronização operacional
* redução de drift entre ambientes

---

# Arquitetura Geral

O projeto é dividido em duas camadas principais:

| Camada                 | Responsabilidade                                        |
| ---------------------- | ------------------------------------------------------- |
| `scripts/bootstrap.sh` | Prepara runtime local, privilege model e tooling Python |
| `scripts/provision.sh` | Executa convergência declarativa via Ansible            |

---

# Fluxo de Provisionamento

```text
Máquina nova
    ↓
Instalação WSL2/Ubuntu
    ↓
Clone do repositório
    ↓
./scripts/bootstrap.sh
    ↓
./scripts/provision.sh
    ↓
Workstation provisionada
```

---

# Estrutura do Repositório

```text
workstation-config/
├── ansible/
│   ├── ansible.cfg
│   ├── group_vars/
│   │   └── all.yml
│   ├── inventories/
│   │   └── localhost/
│   │       └── hosts.yml
│   ├── playbooks/
│   │   └── workstation.yml
│   └── roles/
│       ├── system_common/
│       ├── system_wsl/
│       ├── system_docker/
│       ├── system_powershell/
│       ├── user_dotfiles/
│       └── user_tooling/
├── dotfiles/
├── logs/
├── scripts/
│   ├── bootstrap.sh
│   └── provision.sh
├── windows/
│   ├── bootstrap.ps1
│   ├── install-packages.ps1
│   ├── install-wsl.ps1
│   └── README.md
├── .gitignore
├── .pre-commit-config.yaml
└── README.md
```

---

# Bootstrap

## `scripts/bootstrap.sh`

Responsável pelo bootstrap inicial da máquina.

Executa:

* validação do ambiente
* configuração de passwordless sudo
* atualização do índice de pacotes
* instalação de runtime base
* instalação de tooling Python via `pipx`
* preparação do runtime Ansible
* logging persistente
* validação pós-instalação

---

## Runtime Base Instalado

Pacotes instalados via `apt`:

* git
* curl
* python3
* python3-pip
* pipx
* shellcheck

---

## Tooling Python

Ferramentas instaladas via `pipx`:

* ansible-core
* ansible-lint
* yamllint
* pre-commit

---

## Características

* fail-fast (`set -Eeuo pipefail`)
* logging com timestamps
* validação de ambiente
* bootstrap idempotente
* runtime Python isolado via `pipx`
* preparação explícita de cache/runtime Ansible
* output persistido em `logs/bootstrap.log`

---

# Runtime Python e Tooling

O projeto utiliza `pipx` para isolamento do tooling Python:

* ansible-core
* ansible-lint
* pre-commit
* yamllint

Motivações:

* evitar dependência de pacotes defasados da distribuição
* manter compatibilidade entre tooling e collections modernas
* garantir consistência entre distros
* reduzir conflitos entre runtime Python do sistema e tooling DevOps

---

# Provisionamento

## `scripts/provision.sh`

Wrapper operacional para execução do Ansible.

Responsabilidades:

* validação do ambiente
* instalação de collections Ansible
* seleção dinâmica de inventory
* logging persistente
* carregamento explícito do `ansible.cfg`
* preservação do contexto do usuário real
* execução do playbook principal

---

## Características

* inventário localhost fixo
* logging persistente
* resolução automática de paths
* runtime Ansible determinístico
* instalação automática de collections
* preservação do contexto do usuário (`SUDO_USER`)

---

## Execução

```bash
./scripts/provision.sh
```

> Observação: O script `scripts/provision.sh` atualmente usa apenas o inventário `localhost`.

---

# Configuração do Ansible

## `ansible/ansible.cfg`

Configuração central do runtime Ansible.

### Estrutura atual

```ini
[defaults]

inventory = ./inventories/localhost/hosts.yml
roles_path = ./roles
collections_paths = ./collections
host_key_checking = False
retry_files_enabled = False
stdout_callback = default
result_format = yaml
timeout = 120
gather_timeout = 60
```

---

# Inventories

O projeto suporta múltiplos ambientes.

Estrutura:

```text
inventories/
└── localhost/
```

Isso permite:

* separar ambientes
* evitar alterações manuais de inventory
* facilitar expansão futura
* suportar múltiplos hosts

---

# Variáveis Globais

## `ansible/group_vars/all.yml`

Variáveis aplicáveis a todos os hosts.

### Estrutura atual

```yaml
---
ansible_python_interpreter: /usr/bin/python3
```

---

# Playbook Principal

## `ansible/playbooks/workstation.yml`

Playbook principal da workstation.

### Estrutura atual

```yaml
---
- name: Configurar system-space
  hosts: localhost
  connection: local

  vars:
    workstation_repo: "/home/{{ ansible_user }}/workspace/workstation-config"

  roles:
    - role: system_common
    - role: system_wsl
    - role: system_docker
    - role: system_powershell

- name: Configurar user-space
  hosts: localhost
  connection: local

  vars:
    workstation_repo: "/home/{{ ansible_user }}/workspace/workstation-config"

  roles:
    - role: user_dotfiles
    - role: user_tooling
```

---

# Roles

## `system_common`

Responsável por:

* atualização de cache apt
* instalação de ferramentas operacionais básicas

### Pacotes atuais

* tree
* net-tools
* dnsutils
* tcpdump
* jq
* unzip
* vim
* tmux
* htop

---

## `system_wsl`

Responsável por ajustes específicos do runtime WSL2.

### O que faz

* mask `getty@tty1.service`
* mask `console-getty.service`

### Objetivo

Evitar serviços desnecessários de TTY em ambientes WSL2.

---

## `system_docker`

Provisiona Docker Engine.

### O que faz

* cria `/etc/apt/keyrings`
* adiciona chave GPG oficial Docker
* adiciona repositório oficial Docker
* instala:

  * docker-ce
  * docker-ce-cli
  * containerd.io
  * docker-buildx-plugin
  * docker-compose-plugin
* habilita serviço Docker
* adiciona usuário ao grupo `docker`
* valida instalação

### Handlers

* notificação de reinício de sessão para atualização do grupo `docker`

---

## `system_powershell`

Provisiona PowerShell via repositório oficial Microsoft.

### O que faz

* cria `/etc/apt/keyrings`
* baixa chave GPG Microsoft
* converte explicitamente keyring GPG
* adiciona repositório APT Microsoft
* instala PowerShell
* valida instalação

---

## `user_dotfiles`

Gerencia configuração do usuário.

### Cria symlinks para

* `~/.bashrc`
* `~/.profile`
* `~/.bash_aliases`
* `~/.gitconfig`

### Origem dos arquivos

```text
dotfiles/
├── bash/
└── git/
```

---

## `user_tooling`

Instala tooling Python e hooks Git no contexto do usuário.

### O que faz

* valida `pipx`
* instala ferramentas Python via `pipx`
* instala hooks `pre-commit`

### Ferramentas atuais

* pre-commit
* ansible-lint
* yamllint

---

# Dotfiles

Os dotfiles são versionados no repositório.

### Arquivos atuais

* `dotfiles/bash/.bashrc`
* `dotfiles/bash/.profile`
* `dotfiles/bash/.bash_aliases`
* `dotfiles/git/.gitconfig`

---

# Logging

Os scripts geram logs persistentes.

### Localização

```text
logs/
```

### Arquivos

| Arquivo           | Descrição                |
| ----------------- | ------------------------ |
| `bootstrap.log`   | execução bootstrap       |
| `provision-*.log` | execução provisionamento |

---

# Filosofia de Privilégio

O projeto utiliza passwordless sudo configurado durante o bootstrap inicial.
Isso garante que o Ansible possa executar ações privilegiadas sem prompts de senha em playbooks locais, reduzindo a necessidade de `become` em tarefas que já rodam no contexto do usuário real.

Motivações:

* compatibilidade com `sudo-rs`
* execução não-interativa do Ansible
* previsibilidade operacional
* eliminação de dependência de prompts interativos

O bootstrap configura automaticamente:

```text
/etc/sudoers.d/workstation
```

com validação via:

```bash
visudo -cf
```

---

# Compatibilidade Ubuntu 26+

Versões recentes do Ubuntu introduziram o `sudo-rs`,
o que atualmente pode causar incompatibilidades parciais
com o mecanismo `become` do Ansible.

O projeto utiliza passwordless sudo durante o bootstrap
para garantir compatibilidade operacional consistente.

---

# Compatibilidade PowerShell Microsoft Repositories

Atualmente os repositórios Microsoft PowerShell
ainda apresentam inconsistências de assinatura GPG
em distribuições bleeding-edge:

* Debian 13 (trixie)
* Ubuntu 26.04 (resolute)

Por estabilidade operacional,
o projeto utiliza temporariamente fallbacks:

| Distro atual | Repositório utilizado |
| ------------ | --------------------- |
| Debian 13    | Debian 12/bookworm    |
| Ubuntu 26.04 | Ubuntu 24.04/noble    |

Isso preserva:

* apt-secure
* validação GPG
* integridade do provisioning

> Nota: no Ubuntu 26.04, o projeto usa o repositório Microsoft PowerShell do Ubuntu 24.04/noble devido à falta de suporte oficial direto para 26.04.
>
> Essa é uma limitação conhecida do repositório Microsoft PowerShell: o suporte oficial para Ubuntu 26.04 ainda não está disponível, então o fallback 24.04/noble é usado para garantir instalação e integridade.

---

# Windows Setup

Para usuários Windows, o projeto inclui scripts PowerShell para pre-bootstrap no host antes da instalação do WSL2.

## Scripts disponíveis

* `windows/bootstrap.ps1`
* `windows/install-packages.ps1`
* `windows/install-wsl.ps1`

---

# Como Usar

## 1. Preparar Windows (Opcional)

```powershell
.\windows\bootstrap.ps1
.\windows\install-packages.ps1
.\windows\install-wsl.ps1
```

Ou:

```powershell
wsl --install
```

---

## 2. Clonar repositório

```bash
git clone git@github.com:SEU_USUARIO/workstation-config.git

cd workstation-config
```

---

## 3. Executar bootstrap

```bash
./scripts/bootstrap.sh
```

---

## 4. Executar provisionamento

```bash
./scripts/provision.sh
```

---

# Boas Práticas Aplicadas

* Infrastructure as Code
* modularização via roles
* inventories separados por ambiente
* logging persistente
* fail-fast
* configuração declarativa
* runtime determinístico
* versionamento completo da workstation
* Fully Qualified Collection Names (FQCN)
* linting com `ansible-lint`
* hooks `pre-commit`
* isolamento Python via `pipx`
* variáveis com prefixo de role

---

# Recomendações Futuras

## Curto prazo

* catálogo declarativo de extensões VSCode
* role Kubernetes
* tags Ansible
* Makefile operacional

## Médio prazo

* CI GitHub Actions
* validação automatizada de bootstrap
* inventories remotos
* dry-run mode
* separation por domínio operacional

## Longo prazo

* suporte multi-host
* integração cloud-init/Packer
* golden images
* suporte multiplataforma
* provisioning híbrido cloud/local

---

# Documentação Adicional

* [Windows Setup Guide](./windows/README.md)

---

# Observações

* O projeto está focado atualmente em Ubuntu/WSL2.
* O runtime foi otimizado para workstation local.
* O provisionamento atual assume ambiente single-user.
* O diretório `logs/` deve permanecer ignorado no Git.
* O projeto utiliza runtime Python isolado via `pipx`.
* O projeto pode evoluir futuramente para automação enterprise mais completa.
