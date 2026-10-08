<#
.SYNOPSIS
    Inicia el laboratorio Docker de 2 sucursales (FASE III, seccion 10).
#>
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    docker compose up -d
    docker compose ps
}
finally {
    Pop-Location
}
