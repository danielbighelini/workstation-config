$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "========================================="
Write-Host " Validação WSL2"
Write-Host "========================================="
Write-Host ""

try {

    $null = wsl --status

    Write-Host "WSL já está instalado."
    Write-Host ""

}
catch {

    Write-Host "WSL não encontrado."
    Write-Host "Instalando WSL2..."
    Write-Host ""

    wsl --install

    Write-Host ""
    Write-Host "Instalação do WSL concluída."
    Write-Host "Pode ser necessário reiniciar o Windows."
    Write-Host ""
}
