$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$packages = @(
    "Microsoft.VisualStudioCode"
    "Microsoft.WindowsTerminal"
    "Microsoft.PowerShell"
    "Git.Git"
)

$vscodeExtensions = @(
    "ms-vscode-remote.remote-wsl"
)

Write-Host ""
Write-Host "========================================="
Write-Host " Validacao de pacotes Windows"
Write-Host "========================================="
Write-Host ""

Set-Location C:\

foreach ($package in $packages) {

    $installed = winget list --id $package --exact 2>$null

    if ($installed) {

        Write-Host "[OK] $package ja instalado."
        continue
    }

    Write-Host ""
    Write-Host "Instalando $package ..."
    Write-Host ""

    winget install `
        --id $package `
        --exact `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements
}

Write-Host ""
Write-Host "========================================="
Write-Host " Validacao extensoes VSCode"
Write-Host "========================================="
Write-Host ""

foreach ($extension in $vscodeExtensions) {

    $installed = code `
        --list-extensions `
        | Select-String "^$extension$"

    if ($installed) {

        Write-Host "[OK] Extensao $extension ja instalada."
        continue
    }

    Write-Host ""
    Write-Host "Instalando extensao $extension ..."
    Write-Host ""

    code --install-extension $extension
}
