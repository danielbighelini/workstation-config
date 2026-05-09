$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$packages = @(
    "Microsoft.VisualStudioCode"
    "Microsoft.WindowsTerminal"
    "Microsoft.PowerShell"
    "Git.Git"
)

Write-Host ""
Write-Host "========================================="
Write-Host " Validacao de pacotes Windows"
Write-Host "========================================="
Write-Host ""

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
