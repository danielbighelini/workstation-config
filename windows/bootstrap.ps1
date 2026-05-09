$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================="
Write-Host " Windows Workstation Bootstrap"
Write-Host "========================================="
Write-Host ""

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$scriptRoot/install-wsl.ps1"
& "$scriptRoot/install-packages.ps1"

Write-Host ""
Write-Host "Bootstrap concluído."
Write-Host ""
