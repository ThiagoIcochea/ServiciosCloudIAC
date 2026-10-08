<#
.SYNOPSIS
    Ejecuta todas las pruebas automatizadas del proyecto que NO requieren
    Docker (terraform test con mock_provider + validacion de esquema).
    El laboratorio Docker se prueba por separado con lab/docker/test.ps1
    (requiere Docker Desktop, ver lab/docker/README.md).
#>
param(
    [string]$TerraformBin = "$PSScriptRoot/../tools/terraform.exe"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path "$PSScriptRoot/.."
$failed = $false

Write-Host "`n=== 1. Esquema de 50 sucursales ===" -ForegroundColor Cyan
python "$root/scripts/validate_branches_schema.py"
if ($LASTEXITCODE -ne 0) { $failed = $true }

Write-Host "`n=== 2. terraform test (mock_provider, aws + gcp) ===" -ForegroundColor Cyan
Push-Location "$root/terraform/tests"
try {
    & $TerraformBin init -backend=false -input=false | Out-Null
    & $TerraformBin test
    if ($LASTEXITCODE -ne 0) { $failed = $true }
}
finally {
    Pop-Location
}

if ($failed) {
    Write-Host "`nAlgunas pruebas FALLARON. Revisa los mensajes anteriores." -ForegroundColor Red
    exit 1
}

Write-Host "`nTodas las pruebas pasaron." -ForegroundColor Green
Write-Host "Recordatorio: el laboratorio Docker (lab/docker) y el monitoreo local" -ForegroundColor Yellow
Write-Host "(lab/monitoring) se prueban por separado y requieren Docker Desktop." -ForegroundColor Yellow
exit 0
