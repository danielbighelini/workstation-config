<#
.SYNOPSIS
    Instala e configura o WSL2 de forma idempotente.

.DESCRIPTION
    - Valida privilegios administrativos
    - Habilita features necessarias
    - Instala WSL caso necessario
    - Define WSL2 como default
    - Gera logs
    - Trata erros corretamente
    - Valida reboot pendente

.NOTES
    Execute em PowerShell como Administrador.
#>

[CmdletBinding()]
param (
    [string]$LogFile = "$PSScriptRoot\install-wsl.log"
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

function Test-WindowsFeatureEnabled {

    param (
        [string]$FeatureName
    )

    $feature = Get-WindowsOptionalFeature `
        -Online `
        -FeatureName $FeatureName

    return $feature.State -eq "Enabled"
}

function Enable-FeatureIfNeeded {

    param (
        [string]$FeatureName
    )

    if (Test-WindowsFeatureEnabled -FeatureName $FeatureName) {

        Write-Log "Feature [$FeatureName] ja esta habilitada."

        return
    }

    Write-Log "Habilitando feature [$FeatureName]..."

    Enable-WindowsOptionalFeature `
        -Online `
        -FeatureName $FeatureName `
        -All `
        -NoRestart

    Write-Log "Feature [$FeatureName] habilitada."
}

function Test-RebootPending {

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $true
        }
    }

    return $false
}

function Test-WSLInstalled {

    $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue

    return $null -ne $wsl
}

function Install-WSL {

    Write-Log "Executando instalacao do WSL..."

    wsl --install --no-distribution

    if ($LASTEXITCODE -ne 0) {
        throw "Falha durante instalacao do WSL."
    }

    Write-Log "Instalacao do WSL concluida."
}

function Set-WSL2Default {

    Write-Log "Definindo WSL2 como versao padrao..."

    wsl --set-default-version 2

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao definir WSL2 como default."
    }

    Write-Log "WSL2 definido como padrao."
}

# =========================================================
# Execucao principal
# =========================================================

try {

    Write-Log "========================================="
    Write-Log "Inicio da instalacao/configuracao do WSL"
    Write-Log "========================================="

    Assert-Administrator

    Write-Log "Validando features obrigatorias..."

    Enable-FeatureIfNeeded `
        -FeatureName "Microsoft-Windows-Subsystem-Linux"

    Enable-FeatureIfNeeded `
        -FeatureName "VirtualMachinePlatform"

    if (-not (Test-WSLInstalled)) {

        Write-Log "WSL nao encontrado."

        Install-WSL
    }
    else {

        Write-Log "WSL ja instalado."
    }

    Set-WSL2Default

    if (Test-RebootPending) {

        Write-Log "Reboot necessario para concluir configuracao." "WARN"

        Write-Host ""
        Write-Host "Reinicie a maquina antes de utilizar o WSL." -ForegroundColor Yellow
    }
    else {

        Write-Log "Nenhum reboot pendente detectado."
    }

    Write-Log "Processo concluido com sucesso."
}
catch {

    Write-Log $_.Exception.Message "ERROR"

    Write-Host ""
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red

    exit 1
}
