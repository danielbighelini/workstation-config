# Workstation Config

Repositório para provisionamento e padronização do meu ambiente Linux/WSL2 utilizando:

- WSL2
- Ubuntu LTS
- Ansible
- Git
- Bootstrap scripts

O objetivo é manter uma workstation:

- reproduzível
- versionada
- portátil
- auditável
- facilmente reconstruível

---

# Objetivos

Este projeto busca:

- Padronizar múltiplas workstations
- Reduzir drift entre ambientes
- Automatizar configuração de ferramentas
- Versionar configuração pessoal/técnica
- Permitir rebuild rápido do ambiente
- Centralizar bootstrap e provisioning

---

# Arquitetura

A abordagem adotada é:

- WSL2 como runtime Linux principal
- Configuração declarativa via Ansible
- Dotfiles versionados
- Bootstrap mínimo e idempotente
- Separação entre:
  - laboratório
  - configuração pessoal
  - projetos

---

# Estrutura do Repositório

```text
workstation-config/
├── ansible/
├── dotfiles/
├── scripts/
├── docs/
├── bootstrap.sh
└── README.md
```

---

# Pré-requisitos

## Windows

- Windows 11
- WSL2 habilitado
- Virtual Machine Platform habilitado

## Linux

Distribuição recomendada:

- Ubuntu 24.04 LTS

---

# Instalação Inicial

## Instalar WSL2

```powershell
wsl --install -d Ubuntu-24.04
```

---

# Configuração SSH

## Gerar chave SSH

```bash
ssh-keygen -t ed25519 -C "seu_email"
```

## Testar autenticação

```bash
ssh -T git@github.com
```

---

# Clone do Repositório

```bash
git clone git@github.com:SEU_USUARIO/workstation-config.git
```

---

# Bootstrap Inicial

```bash
cd workstation-config

chmod +x bootstrap.sh

./bootstrap.sh
```

---

# Provisionamento Ansible

Atualmente o provisioning local é executado com:

```bash
sudo ansible-playbook ansible/playbooks/workstation.yml
```

---

# Workflow Operacional

## Atualizar repositório

```bash
git pull
```

## Executar provisioning

```bash
sudo ansible-playbook ansible/playbooks/workstation.yml
```

---

# Convenções

## Workspace

Todos os projetos ficam preferencialmente em:

```text
~/workspace
```

## Separação de responsabilidades

| Diretório --| Objetivo |
|-------------|----------|
| ansible-lab | laboratório/estudos |
| workstation-config | configuração da workstation |
| projetos | projetos gerais |

---

# Troubleshooting

## WSL consumindo muita memória

```powershell
wsl --shutdown
```

## Reiniciar ambiente WSL

```powershell
wsl --shutdown
```

---

# Roadmap

Itens planejados:

- [ ] Dotfiles automatizados
- [ ] Symlinks gerenciados via Ansible
- [ ] Docker provisioning
- [ ] Dev Containers
- [ ] VSCode automation
- [ ] Multi-workstation profiles
- [ ] Secrets management
- [ ] Backup strategy
- [ ] Shell customization
