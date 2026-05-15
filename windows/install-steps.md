# install-steps.md

# Workstation Installation Guide

Guia de instalação e provisionamento de workstation Windows + WSL2 utilizando Ansible.

---

# Verificando status do WSL

```powershell
wsl --status
```

---

# Instalando WSL

## Método recomendado

```powershell
wsl --install
```

## Habilitação manual de feature

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

---

# Atualizando WSL

```powershell
wsl --update
```

---

# Encerrando distribuições WSL

```powershell
wsl --shutdown
```

---

# Desinstalando WSL

```powershell
wsl --uninstall
```

---

# Instalando uma distribuição Linux

## Ubuntu

```powershell
wsl --install -d Ubuntu
```

## Debian

```powershell
wsl --install -d Debian
```

---

# Excluindo uma distribuição Linux

```powershell
wsl --unregister <Distro>
```

## Exemplos

```powershell
wsl --unregister Ubuntu
```

```powershell
wsl --unregister Debian
```

---

# Instalando Visual Studio Code

```powershell
winget install Microsoft.VisualStudioCode
```

---

# Instalando extensões do Visual Studio Code

## WSL

```powershell
code --install-extension ms-vscode-remote.remote-wsl
```

## YAML

```powershell
code --install-extension redhat.vscode-yaml
```

## Ansible

```powershell
code --install-extension redhat.ansible
```

---

# Atualizando Linux

```bash
sudo apt update
sudo apt upgrade -y
```

---

# Instalando Git

```bash
sudo apt install -y git
```

---

# Criando workspace

```bash
mkdir -p ~/workspace
```

---

# Clonando repositório Git

## HTTPS

```bash
git clone https://github.com/danielbighelini/workstation-config.git
```

## SSH (recomendado)

```bash
git clone git@github.com:danielbighelini/workstation-config.git
```

---

# Visualizando configurações de proxy

```bash
env | grep -i proxy
```

---

# Abrindo projeto no Visual Studio Code

```bash
cd ~/workspace/workstation-config
code .
```

---

# Executando bootstrap inicial

```bash
./scripts/bootstrap.sh
```

---

# Executando validação do ambiente

```bash
make doctor
```

---

# Executando provisionamento

```bash
make provision
```

---

# Roteiro rápido de instalação Windows

```powershell
wsl --install
wsl --update

winget install Microsoft.VisualStudioCode

code --install-extension ms-vscode-remote.remote-wsl
code --install-extension redhat.vscode-yaml
code --install-extension redhat.ansible

wsl --install -d Ubuntu
```

---

# Roteiro rápido de instalação Linux

```bash
sudo apt update
sudo apt install -y git

mkdir -p ~/workspace
cd ~/workspace

git clone git@github.com:danielbighelini/workstation-config.git

cd ~/workspace/workstation-config

code .

./scripts/bootstrap.sh

make doctor
make provision
```

---

# Observações Importantes

## Proxy corporativo

Caso esteja em ambiente corporativo com proxy:

```bash
env | grep -i proxy
```

Para abrir um shell sem proxy:

```bash
make noproxy
```

---

## Reinicialização do shell

Após bootstrap e provisionamento:

```bash
source ~/.bashrc
```

Ou reinicie a sessão WSL.

---

# Recomendações

## Utilize SSH para Git

HTTPS funciona, mas SSH:

* evita prompts constantes;
* facilita automação;
* integra melhor com DevContainers;
* simplifica autenticação no GitHub.

---

# Validando instalação

## Validar Ansible

```bash
ansible --version
```

## Validar Docker

```bash
docker --version
```

## Validar PowerShell

```bash
pwsh
```

## Validar VSCode Remote WSL

```bash
code .
```

---

# Troubleshooting

## Reiniciar completamente WSL

```powershell
wsl --shutdown
```

---

## Ver distribuições instaladas

```powershell
wsl --list --verbose
```

---

## Verificar versão do Linux

```bash
cat /etc/os-release
```

---

# Estrutura esperada após provisionamento

```text
~/workspace/workstation-config
├── ansible/
├── dotfiles/
├── scripts/
├── windows/
├── logs/
└── Makefile
```
