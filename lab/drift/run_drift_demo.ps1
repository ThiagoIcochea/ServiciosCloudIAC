<#
.SYNOPSIS
    Reproduce el escenario de Infrastructure Drift (FASE VI, seccion 15).

.DESCRIPTION
    1. terraform init + apply -> crea el recurso local_file administrado.
    2. Se registra el estado inicial (terraform show, terraform state list).
    3. Se modifica manualmente el archivo generado (simulando un cambio
       manual urgente en produccion, fuera de Terraform).
    4. terraform plan -> detecta la diferencia (drift).
    5. terraform plan -refresh-only -> confirma el drift sin proponer revertirlo.
    6. Se decide reconciliar: terraform apply -> vuelve el recurso al estado
       declarado en el codigo (politica: el codigo es la fuente de verdad).
    7. Se verifica el resultado final.

    Todas las salidas de cada paso se guardan en docs/evidence/drift/ con
    timestamp, como evidencia real (no fabricada) de la ejecucion.
#>

param(
    [string]$TerraformBin = "$PSScriptRoot/../../tools/terraform.exe"
)

$ErrorActionPreference = "Stop"
$labDir = $PSScriptRoot
$evidenceDir = Join-Path $labDir "../../docs/evidence/drift"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$log = Join-Path $evidenceDir "drift-demo-$timestamp.log"

function Step {
    param([string]$Title, [scriptblock]$Action)
    "`n`n===== $Title =====" | Tee-Object -FilePath $log -Append
    $output = & $Action 2>&1 | Out-String
    $output | Tee-Object -FilePath $log -Append
    return $output
}

Push-Location $labDir
try {
    Step "1. terraform init" { & $TerraformBin init -backend=false }
    Step "2. terraform apply (crea el recurso gestionado)" { & $TerraformBin apply -auto-approve }
    Step "3. Estado inicial - terraform state list" { & $TerraformBin state list }
    Step "4. Estado inicial - terraform show" { & $TerraformBin show }

    $configPath = Join-Path $labDir "output/suc-001-server.conf"
    Step "5. Modificacion manual fuera de Terraform (simula cambio urgente en produccion)" {
        "# Modificado manualmente FUERA de Terraform (incidente simulado)" | Out-File -Append -Encoding utf8 $configPath
        "max_connections=9999  # cambiado a mano, sin pasar por Terraform" | Out-File -Append -Encoding utf8 $configPath
        Get-Content $configPath
    }

    Step "6. terraform plan (deberia detectar drift)" { & $TerraformBin plan }
    Step "7. terraform plan -refresh-only (confirma el drift sin proponer revertirlo)" { & $TerraformBin plan -refresh-only }
    Step "8. Decision: reconciliar aplicando la configuracion declarada (el codigo es la fuente de verdad)" {
        & $TerraformBin apply -auto-approve
    }
    Step "9. Verificacion final - contenido del archivo reconciliado" { Get-Content $configPath }
    Step "10. Verificacion final - terraform state list" { & $TerraformBin state list }

    Write-Host "`nEvidencia completa guardada en: $log"
}
finally {
    Pop-Location
}
