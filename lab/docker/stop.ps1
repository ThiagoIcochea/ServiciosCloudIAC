<#
.SYNOPSIS
    Detiene y limpia el laboratorio Docker de 2 sucursales.
#>
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    docker compose down -v
    Write-Host "Laboratorio Docker detenido y limpiado."
}
finally {
    Pop-Location
}
