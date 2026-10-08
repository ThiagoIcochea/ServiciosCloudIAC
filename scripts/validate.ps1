<#
.SYNOPSIS
    Ejecuta todas las validaciones estaticas del proyecto (CP01, CP02, CP03,
    CP04, CP11): fmt, validate en los 3 entornos, y el esquema de las 50
    sucursales. No requiere Docker ni credenciales cloud.
#>
param(
    [string]$TerraformBin = "$PSScriptRoot/../tools/terraform.exe"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path "$PSScriptRoot/.."
$failed = $false

Write-Host "`n=== 1. terraform fmt -check -recursive ===" -ForegroundColor Cyan
& $TerraformBin fmt -check -recursive "$root/terraform"
if ($LASTEXITCODE -ne 0) { $failed = $true }

Write-Host "`n=== 2. Esquema de 50 sucursales (scripts/validate_branches_schema.py) ===" -ForegroundColor Cyan
python "$root/scripts/validate_branches_schema.py"
if ($LASTEXITCODE -ne 0) { $failed = $true }

foreach ($env in @("development", "staging", "production")) {
    Write-Host "`n=== 3. terraform validate ($env) ===" -ForegroundColor Cyan
    Push-Location "$root/terraform/environments/$env"
    try {
        & $TerraformBin init -backend=false -input=false | Out-Null
        & $TerraformBin validate
        if ($LASTEXITCODE -ne 0) { $failed = $true }
    }
    finally {
        Pop-Location
    }
}

if ($failed) {
    Write-Host "`nValidacion FALLIDA. Revisa los mensajes anteriores." -ForegroundColor Red
    exit 1
}

Write-Host "`nTodas las validaciones pasaron." -ForegroundColor Green
exit 0
