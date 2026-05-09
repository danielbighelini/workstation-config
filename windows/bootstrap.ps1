$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$logDir = Join-Path $scriptRoot "logs"

$logFile = Join-Path $logDir "bootstrap.log"

New-Item `
    -ItemType Directory `
    -Force `
    -Path $logDir | Out-Null

function Write-Log {

    param (
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $line = "[$timestamp] $Message"

    Write-Host $line

    Add-Content `
        -Path $logFile `
        -Value $line
}

Write-Log "========================================="
Write-Log " Windows Workstation Bootstrap"
Write-Log "========================================="

& "$scriptRoot/install-wsl.ps1" `
    -LogFile $logFile

& "$scriptRoot/install-packages.ps1" `
    -LogFile $logFile

Write-Log "Bootstrap concluido."
