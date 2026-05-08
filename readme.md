# Workstation Config

Repositório para provisionamento e padronização do ambiente Linux/WSL2 usando Ansible, dotfiles e scripts de bootstrap.

O objetivo é manter uma workstation:

- reproduzível
- portátil
- versionada
- auditável
- facilmente reconstruível

---

# Visão Geral

Este projeto centraliza a configuração do ambiente de desenvolvimento em uma única base de código.
Ele combina:

- `bootstrap.sh` para instalação inicial de pacotes básicos
- Ansible para provisionamento declarativo
- dotfiles versionados em `dotfiles/`
- um wrapper de conveniência em `scripts/provision.sh`

---

# Estrutura do Repositório

```text
workstation-config/
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── hosts.yml
│   ├── playbooks/
│   │   └── workstation.yml
│   └── roles/
│       ├── common/
│       │   └── tasks/main.yml
│       ├── dotfiles/
│       │   └── tasks/main.yml
│       ├── docker/
│       │   └── tasks/main.yml
│       └── shell/
│           └── tasks/
├── dotfiles/
│   ├── bash/
│   │   ├── .bashrc
│   │   └── .profile
│   └── git/
│       └── .gitconfig
├── docs/
├── scripts/
│   └── provision.sh
├── bootstrap.sh
├── .gitignore
└── README.md
```

---

# Componentes Principais

## `bootstrap.sh`

Instala as dependências iniciais no sistema:

- git
- curl
- wget
- unzip
- python3
- python3-pip
- ansible
- vim
- tmux
- jq
- htop

## `ansible/ansible.cfg`

Configura o Ansible para usar:

- inventário local
- `roles_path` em `./roles`
- `host_key_checking = False`
- `retry_files_enabled = False`
- saída em YAML
- Python 3 como interpretador padrão

> Nota: o arquivo de inventário atual está em `ansible/inventory/hosts.yml`.
> Se o Ansible não localizar o inventário automaticamente, execute o playbook com:
>
> ```bash
> sudo ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/workstation.yml
> ```

---

## Ansible Playbook Principal

`ansible/playbooks/workstation.yml` define a execução local no host `localhost` e registra o repositório em:

```yaml
workstation_repo: "{{ ansible_facts.env.HOME }}/workspace/workstation-config"
```

O playbook aplica os roles:

- `common`
- `dotfiles`
- `docker`

O role `shell` existe na estrutura, mas ainda não contém tarefas definidas.

---

# O que o Ansible faz hoje

## `ansible/roles/common/tasks/main.yml`

Instala os pacotes básicos:

- tree
- net-tools
- dnsutils
- tcpdump
- curl
- jq
- unzip
- git

## `ansible/roles/docker/tasks/main.yml`

Provisiona o Docker Engine no Ubuntu:

- cria `/etc/apt/keyrings`
- adiciona chave GPG do Docker
- adiciona repositório oficial do Docker
- instala:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin
- inicia e habilita o serviço Docker
- adiciona o usuário atual ao grupo `docker`
- exibe a versão instalada do Docker

## `ansible/roles/dotfiles/tasks/main.yml`

Cria symlinks para os arquivos de configuração do usuário:

- `~/.bashrc` → `dotfiles/bash/.bashrc`
- `~/.profile` → `dotfiles/bash/.profile`
- `~/.bash_aliases` → `dotfiles/bash/.bash_aliases` (adicione este arquivo se desejar aliases personalizados)
- `~/.gitconfig` → `dotfiles/git/.gitconfig`

---

# Dotfiles

Os arquivos versionados atualmente são:

- `dotfiles/bash/.bashrc`
- `dotfiles/bash/.profile`
- `dotfiles/git/.gitconfig`

Se quiser adicionar aliases permanentes, crie `dotfiles/bash/.bash_aliases`.

---

# Uso

## Clonar o repositório

```bash
git clone git@github.com:SEU_USUARIO/workstation-config.git
cd workstation-config
```

## Executar bootstrap inicial

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## Executar provisionamento Ansible

```bash
sudo ansible-playbook ansible/playbooks/workstation.yml
```

ou, opcionalmente:

```bash
./scripts/provision.sh
```

---

# Recomendações de manutenção

- Mantenha o repositório atualizado com `git pull`
- Atualize os dotfiles e role de Ansible juntos
- Verifique se o inventário está no caminho correto antes de rodar o playbook

---

# Observações

- O role `shell` existe, mas atualmente não possui tarefas configuradas.
- A documentação em `docs/` está disponível para expandir com guias adicionais.
- O `.gitignore` já ignora arquivos de cache, logs, dados do Ansible, VS Code e arquivos temporários de sistema.
