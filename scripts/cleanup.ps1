<#
.SYNOPSIS
    Limpia todos los artefactos locales generados por los laboratorios
    (estado de Terraform, contenedores Docker, evidencia temporal).
#>
$ErrorActionPreference = "Continue"
$root = Resolve-Path "$PSScriptRoot/.."

Write-Host "Limpiando lab/local-terraform..." -ForegroundColor Cyan
Push-Location "$root/lab/local-terraform"
if (Test-Path ".terraform") { & "$root/tools/terraform.exe" destroy -auto-approve 2>$null }
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue ".terraform", "terraform.tfstate*", "output"
Pop-Location

Write-Host "Limpiando lab/drift..." -ForegroundColor Cyan
& "$root/lab/drift/cleanup.ps1"

Write-Host "Deteniendo laboratorio Docker (si esta activo)..." -ForegroundColor Cyan
Push-Location "$root/lab/docker"
docker compose down -v 2>$null
Pop-Location

Write-Host "Limpiando directorios .terraform de entornos..." -ForegroundColor Cyan
foreach ($envDir in @("development", "staging", "production")) {
    $path = "$root/terraform/environments/$envDir"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$path/.terraform", "$path/terraform.tfstate*"
}
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$root/terraform/tests/.terraform"

Write-Host "`nLimpieza completa." -ForegroundColor Green
