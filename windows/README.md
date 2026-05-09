````markdown
# Windows Bootstrap

Camada de bootstrap Windows da workstation.

Responsável por provisionar componentes do host Windows necessários para o ambiente híbrido Windows + WSL2.

---

# Objetivo

Automatizar o setup inicial do host Windows antes do provisionamento Linux/WSL.

Esta camada instala e valida:

- WSL2
- PowerShell 7
- Visual Studio Code
- Windows Terminal
- Git for Windows

---

# Arquitetura

O projeto utiliza modelo híbrido:

| Camada | Runtime |
|---|---|
| Linux provisioning | WSL2 + Ansible |
| Windows bootstrap | PowerShell Windows |

O repositório permanece armazenado no WSL:

```text
~/workspace/workstation-config
```

Os scripts PowerShell ficam versionados no mesmo repositório:

```text
windows/
```

E são executados diretamente no host Windows via:

```bash
pwsh.exe
```

---

# Estrutura

```text
windows/
├── logs/
│   └── .gitkeep
├── bootstrap.ps1
├── install-packages.ps1
├── install-wsl.ps1
└── README.md
```

---

# Scripts

## `bootstrap.ps1`

Orquestrador principal.

Responsável por:

- validar ambiente
- inicializar logging
- executar instalação WSL
- executar instalação de pacotes Windows
- centralizar fluxo operacional

### Logging

O script gera logs persistentes em:

```text
windows/logs/bootstrap.log
```

---

## `install-wsl.ps1`

Responsável por:

- validar existência do WSL2
- instalar WSL2 apenas se ausente
- evitar reinstalações desnecessárias

### Comportamento

- se WSL já existir:
  - apenas informa status
- se WSL estiver ausente:
  - executa `wsl --install`

---

## `install-packages.ps1`

Provisiona ferramentas Windows utilizando `winget`.

### Pacotes atuais

- Microsoft.VisualStudioCode
- Microsoft.WindowsTerminal
- Microsoft.PowerShell
- Git.Git

### Extensões VSCode instaladas

- ms-vscode-remote.remote-wsl

### Comportamento

- valida se pacote já está instalado
- instala apenas pacotes ausentes
- evita mensagens de upgrade desnecessárias
- valida extensões VSCode instaladas
- instala apenas extensões ausentes

---

# Logging

Os scripts PowerShell geram logs persistentes.

### Localização

```text
windows/logs/
```

### Arquivos

| Arquivo | Descrição |
|---|---|
| bootstrap.log | execução bootstrap Windows |

### Características

- timestamps
- append persistente
- troubleshooting simplificado
- output simultâneo console + arquivo

---

# Execução

Os scripts devem ser executados a partir do WSL utilizando:

```bash
pwsh.exe -ExecutionPolicy Bypass -File windows/bootstrap.ps1
```

---

# Importante

## NÃO utilizar:

```bash
pwsh
```

Porque:

```text
pwsh = PowerShell Linux
```

E o bootstrap precisa executar no host Windows.

---

# Runtime correto

Utilize:

```bash
pwsh.exe
```

Porque:

```text
pwsh.exe = PowerShell Windows
```

---

# Requisitos

## Windows

- Windows 11 recomendado
- `winget` disponível
- virtualização habilitada

## WSL

- Ubuntu recomendado
- repositório clonado em:

```text
~/workspace/workstation-config
```

---

# Filosofia

O bootstrap Windows possui foco em:

- simplicidade
- previsibilidade
- idempotência básica
- redução de dependências manuais
- consistência operacional

O objetivo NÃO é substituir ferramentas enterprise de image management.

---

# Roadmap Futuro

Possíveis evoluções:

- instalação automática Ubuntu
- validação WSL version
- reboot detection
- terminal settings
- Nerd Fonts
- Git Credential Manager
- Dev Home
- Docker Desktop
- winget upgrade workflow
- logs estruturados por componente

---

# Observações

- O bootstrap Windows complementa o provisionamento Linux/Ansible.
- O projeto utiliza arquitetura híbrida Windows + WSL2.
- O source of truth permanece centralizado no WSL.
- Os scripts PowerShell são executados no host Windows via bridge WSL.
- O VSCode Remote WSL é tratado como componente Windows-side.
- Extensões remotas adicionais devem ser gerenciadas preferencialmente via VSCode Settings Sync.
````
