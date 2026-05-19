<#
.SYNOPSIS
    Instala pacotes essenciais e extensoes VSCode.

.DESCRIPTION
    - Instala winget packages
    - Instala extensoes VSCode
    - Faz validacao robusta
    - Gera logs
    - Trata erros corretamente
    - Funciona em PowerShell 5.1+

.NOTES
    Execute como Administrador.
#>

[CmdletBinding()]
param (
    [string]$LogFile = "$PSScriptRoot\install-packages.log"
)

# =========================================================
# Configuracao global
# =========================================================

$ErrorActionPreference = "Stop"

# =========================================================
# Funcoes
# =========================================================

function Write-Log {

    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $entry = "[$timestamp] [$Level] $Message"

    Write-Host $entry

    Add-Content `
        -Path $LogFile `
        -Value $entry
}

function Assert-Administrator {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    $isAdmin = $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if (-not $isAdmin) {
        throw "Execute este script como Administrador."
    }
}

function Assert-WinGet {

    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $winget) {
        throw "winget nao encontrado."
    }

    Write-Log "winget encontrado."
}

function Update-WinGetSources {

    Write-Log "Atualizando fontes do winget..."

    winget source update

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao atualizar sources do winget."
    }

    Write-Log "Sources do winget atualizadas."
}

function Test-WinGetPackageInstalled {

    param (
        [string]$PackageId
    )

    $output = winget list `
        --id $PackageId `
        --exact `
        --accept-source-agreements 2>&1

    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        return $false
    }

    $text = $output | Out-String

    return $text -match [regex]::Escape($PackageId)
}

function Install-WinGetPackage {

    param (
        [string]$PackageId
    )

    if (Test-WinGetPackageInstalled -PackageId $PackageId) {

        Write-Log "[OK] $PackageId ja instalado."

        return
    }

    Write-Log "Instalando [$PackageId]..."

    winget install `
        --id $PackageId `
        --exact `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao instalar [$PackageId]"
    }

    Write-Log "[OK] $PackageId instalado."
}

function Get-VSCodeCommand {

    $paths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
    )

    foreach ($path in $paths) {

        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Install-VSCodeExtension {

    param (
        [string]$ExtensionId
    )

    $CodeCmd = Get-VSCodeCommand

    if (-not $CodeCmd) {
        throw "VSCode CLI nao encontrada."
    }

    $installed = & $CodeCmd --list-extensions

    if ($installed -contains $ExtensionId) {

        Write-Log "[OK] Extensao [$ExtensionId] ja instalada."

        return
    }

    Write-Log "Instalando extensao [$ExtensionId]..."

    & $CodeCmd `
        --install-extension $ExtensionId `
        --force

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao instalar extensao [$ExtensionId]"
    }

    Write-Log "[OK] Extensao [$ExtensionId] instalada."
}

# =========================================================
# Pacotes
# =========================================================

$Packages = @(
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerShell",
    "Git.Git"
)

# =========================================================
# Extensoes VSCode
# =========================================================

$VSCodeExtensions = @(
    "ms-vscode-remote.remote-wsl",
    "redhat.ansible",
    "ms-python.python",
    "eamodio.gitlens"
)

# =========================================================
# Execucao principal
# =========================================================

try {

    Write-Log "========================================="
    Write-Log "Validacao de pacotes Windows"
    Write-Log "========================================="

    Assert-Administrator

    Assert-WinGet

    Update-WinGetSources

    foreach ($package in $Packages) {

        Install-WinGetPackage `
            -PackageId $package
    }

    Write-Log "========================================="
    Write-Log "Validacao extensoes VSCode"
    Write-Log "========================================="

    foreach ($extension in $VSCodeExtensions) {

        Install-VSCodeExtension `
            -ExtensionId $extension
    }

    Write-Log "========================================="
    Write-Log "Processo concluido com sucesso"
    Write-Log "========================================="
}
catch {

    Write-Log $_.Exception.Message "ERROR"

    Write-Host ""
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red

    exit 1
}
