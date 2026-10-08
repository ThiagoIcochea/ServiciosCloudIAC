<#
.SYNOPSIS
    Limpia el laboratorio de Drift (recursos locales, estado y cache de init).
#>
param(
    [string]$TerraformBin = "$PSScriptRoot/../../tools/terraform.exe"
)

$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    if (Test-Path ".terraform") {
        & $TerraformBin destroy -auto-approve
    }
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue ".terraform", "terraform.tfstate", "terraform.tfstate.backup", "output"
    Write-Host "Laboratorio de Drift limpiado."
}
finally {
    Pop-Location
}
