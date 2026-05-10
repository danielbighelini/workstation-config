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

| Camada                   | Responsabilidade                           |
| ------------------------ | ------------------------------------------ |
| `scripts/bootstrap.sh`   | Instala dependências mínimas do sistema    |
| `scripts/provision.sh`   | Executa o Ansible com inventories e logging |

---

# Fluxo de Provisionamento

```text
Máquina nova
    ↓
Instalação WSL2/Ubuntu
    ↓
Clone do repositório
    ↓
sudo ./scripts/bootstrap.sh
    ↓
sudo ./scripts/provision.sh
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
│   │   ├── localhost/
│   │   │   └── hosts.yml
│   │   └── development/
│   │       └── hosts.yml
│   ├── playbooks/
│   │   └── workstation.yml
│   └── roles/
│       ├── system_common/
│       │   ├── defaults/main.yml
│       │   ├── meta/main.yml
│       │   └── tasks/main.yml
│       ├── system_docker/
│       │   ├── defaults/main.yml
│       │   ├── handlers/main.yml
│       │   ├── meta/main.yml
│       │   └── tasks/main.yml
│       ├── system_powershell/
│       │   ├── defaults/main.yml
│       │   ├── meta/main.yml
│       │   └── tasks/main.yml
│       ├── user_dotfiles/
│       │   ├── defaults/main.yml
│       │   ├── meta/main.yml
│       │   └── tasks/main.yml
│       ├── user_tooling/
│       │   ├── defaults/main.yml
│       │   ├── meta/main.yml
│       │   └── tasks/main.yml

├── dotfiles/
│   ├── bash/
│   │   ├── .bashrc
│   │   ├── .profile
│   │   └── .bash_aliases
│   └── git/
│       └── .gitconfig
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
└── README.md
```

### Diretório `.ansible/`

Diretório local do Ansible para armazenar:

* `collections/`: coleções Ansible Galaxy instaladas localmente
* `modules/`: módulos customizados
* `roles/`: roles Ansible Galaxy instaladas localmente

Este diretório permite isolamento de dependências Ansible específicas do projeto.

---

# Componentes Principais

## `scripts/bootstrap.sh`

Responsável pelo bootstrap inicial da máquina.

Executa:

* validação de dependências
* atualização do índice de pacotes
* instalação de ferramentas básicas
* logging persistente
* validação pós-instalação

### Ferramentas instaladas

* git
* curl
* wget
* unzip
* python3
* python3-pip
* ansible
* vim
* tmux
* jq
* htop

### Características

* fail-fast (`set -Eeuo pipefail`)
* logging com timestamps
* validações de ambiente
* execução idempotente via `apt-get`
* output persistido em `logs/bootstrap.log`

---

## `scripts/provision.sh`

Wrapper operacional para execução do Ansible.

Responsabilidades:

* validação do ambiente
* seleção dinâmica de inventory
* logging persistente
* carregamento explícito do `ansible.cfg`
* preservação do contexto do usuário real (`sudo`)
* execução do playbook principal

### Características

* suporte a múltiplos ambientes
* logging por ambiente
* resolução automática de paths
* preservação do contexto do usuário (`SUDO_USER`)
* execução consistente do runtime Ansible

### Execução

```bash
sudo ./scripts/provision.sh
```

### Ambiente customizado

```bash
sudo ./scripts/provision.sh development
```

---

# Configuração do Ansible

## `ansible/ansible.cfg`

Configuração central do runtime Ansible.

### Configurações principais

| Configuração                  | Função                            |
| ----------------------------- | --------------------------------- |
| `inventory`                   | inventário padrão                 |
| `roles_path`                  | localização das roles             |
| `host_key_checking = False`   | desabilita validação SSH host key |
| `retry_files_enabled = False` | desabilita retry files            |
| `stdout_callback = default`   | saída padrão                      |
| `result_format = yaml`        | formatação legível de resultados  |
| `timeout`                     | timeout global                    |
| `gather_timeout`              | timeout de facts                  |

### Estrutura atual

```ini
[defaults]

inventory = ./inventories/localhost/hosts.yml
roles_path = ./roles
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
├── localhost/
└── development/
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

### Configurações atuais

```yaml
---
# Global variables for all hosts
ansible_python_interpreter: /usr/bin/python3
```

---

# Playbook Principal

## `ansible/playbooks/workstation.yml`

Playbook principal da workstation.

### Responsabilidades

* execução local
* carregamento das roles
* definição de variáveis de repositório

### Estrutura atual

```yaml
- name: Configurar system-space
  hosts: localhost
  connection: local

  vars:
    workstation_repo: "/home/{{ ansible_user }}/workspace/workstation-config"

  roles:
    - role: system_common
    - role: system_docker
    - role: system_powershell

- name: Configurar user-space
  hosts: localhost
  connection: local

  become: true
  become_user: "{{ ansible_user }}"

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
* instalação de pacotes básicos
* configuração base do sistema

### Pacotes atuais

* tree
* net-tools
* dnsutils
* tcpdump
* curl
* jq
* unzip
* git
* pipx

## `system_docker`

Provisiona Docker Engine no Ubuntu.

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

* `Avisar necessidade de reiniciar sessão`: Notifica quando o usuário precisa reiniciar a sessão para aplicar mudanças no grupo docker

## `system_powershell`

Instala e valida o PowerShell no Ubuntu.

### O que faz

* instala dependências de repositório
* baixa e registra o pacote Microsoft para APT
* atualiza cache apt
* instala `powershell`
* valida a instalação e exibe a versão

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

## `user_tooling`

Instala ferramentas de desenvolvimento Python e hook de git no contexto do usuário.

### O que faz

* valida se `pipx` está instalado
* instala pacotes Python via `pipx`
* instala hooks do `pre-commit` no repositório

### Ferramentas instaladas

* `pre-commit`
* `ansible-lint`

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

# Windows Setup

Para usuários Windows, o projeto inclui scripts PowerShell para pre-bootstrap no host antes de instalar o WSL2.

## Scripts Disponíveis

* `windows/bootstrap.ps1`: Instala dependências base no Windows.
* `windows/install-packages.ps1`: Instala ferramentas adicionais.
* `windows/install-wsl.ps1`: Instala e configura WSL2 automaticamente.

## Como Usar

Execute os scripts em ordem no PowerShell como administrador:

```powershell
.\windows\bootstrap.ps1
.\windows\install-packages.ps1
.\windows\install-wsl.ps1
```

Isso prepara o host Windows para o ambiente WSL2.

---

# Como Usar

## 1. Preparar Windows (Opcional)

Para setup automático com PowerShell:

```powershell
cd workstation-config
.\windows\bootstrap.ps1
.\windows\install-packages.ps1
.\windows\install-wsl.ps1
```

Ou instalar WSL2 manualmente:

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

# Filosofia de Privilégio

Atualmente o projeto utiliza:

```bash
./scripts/provision.sh
```

## Compatibilidade Debian

Atualmente o repositório Microsoft PowerShell para Debian 13 (trixie)
ainda apresenta inconsistências de assinatura GPG.

Por compatibilidade e estabilidade operacional,
o provisioning utiliza temporariamente o repositório Debian 12 (bookworm)
para instalação do PowerShell em ambientes Debian testing/trixie.

---

# Boas Práticas Aplicadas

* Infrastructure as Code
* modularização via roles
* inventories separados por ambiente
* logging persistente
* paths dinâmicos
* fail-fast
* configuração declarativa
* versionamento completo da workstation
* Fully Qualified Collection Names (FQCN)
* linting com `ansible-lint`
* handlers para notificações
* variáveis com prefixo de role

---

# Recomendações Futuras

## Curto prazo

* adicionar novas roles
* expandir catálogo declarativo de extensões VSCode
* configurar workspace settings do VS Code
* adicionar role Kubernetes

## Médio prazo

* separar roles de sistema e usuário
* adicionar tags Ansible
* adicionar modo dry-run
* adicionar CI para validação de playbooks

## Longo prazo

* suporte multi-host
* inventories remotos
* integração cloud-init/Packer
* suporte multiplataforma
* golden images

---

# Documentação Adicional

* [Windows Setup Guide](./windows/README.md) - Scripts PowerShell para setup nativo Windows

---

# Observações

* O projeto está focado atualmente em Ubuntu/WSL2.
* O runtime foi otimizado para workstation local.
* O provisionamento atual assume ambiente single-user.
* O diretório `logs/` deve permanecer ignorado no Git.
* O projeto pode evoluir futuramente para automação enterprise mais completa.
