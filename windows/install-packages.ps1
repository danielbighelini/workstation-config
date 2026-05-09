param (
    [string]$LogFile
)

$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Log {

    param (
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $line = "[$timestamp] $Message"

    Write-Host $line

    Add-Content `
        -Path $LogFile `
        -Value $line
}

$packages = @(
    "Microsoft.VisualStudioCode"
    "Microsoft.WindowsTerminal"
    "Microsoft.PowerShell"
    "Git.Git"
)

$vscodeExtensions = @(
    "ms-vscode-remote.remote-wsl"
)

Write-Log "========================================="
Write-Log " Validacao de pacotes Windows"
Write-Log "========================================="

Set-Location C:\

foreach ($package in $packages) {

    $installed = winget list --id $package --exact 2>$null

    if ($installed) {

        Write-Log "[OK] $package ja instalado."
        continue
    }

    Write-Log "Instalando $package ..."

    winget install `
        --id $package `
        --exact `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements
}

Write-Log "========================================="
Write-Log " Validacao extensoes VSCode"
Write-Log "========================================="

foreach ($extension in $vscodeExtensions) {

    $installed = code `
        --list-extensions `
        | Select-String "^$extension$"

    if ($installed) {

        Write-Log "[OK] Extensao $extension ja instalada."
        continue
    }

    Write-Log "Instalando extensao $extension ..."

    code --install-extension $extension
}
