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

Write-Log "========================================="
Write-Log " Validacao WSL2"
Write-Log "========================================="

try {

    $null = wsl --status

    Write-Log "WSL ja esta instalado."

}
catch {

    Write-Log "WSL nao encontrado."
    Write-Log "Instalando WSL2..."

    wsl --install

    Write-Log "Instalacao do WSL concluida."
    Write-Log "Pode ser necessario reiniciar o Windows."
}
