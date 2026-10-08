<#
.SYNOPSIS
    Demuestra el ciclo de vida del Terraform State local (FASE IV, seccion 12).
#>
param(
    [string]$TerraformBin = "$PSScriptRoot/../../tools/terraform.exe"
)

$ErrorActionPreference = "Stop"
$labDir = $PSScriptRoot
$evidenceDir = Join-Path $labDir "../../docs/evidence/state"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$log = Join-Path $evidenceDir "state-demo-$timestamp.log"

function Step {
    param([string]$Title, [scriptblock]$Action)
    "`n`n===== $Title =====" | Tee-Object -FilePath $log -Append
    $output = & $Action 2>&1 | Out-String
    $output | Tee-Object -FilePath $log -Append
    return $output
}

Push-Location $labDir
try {
    Step "1. Inicializacion - terraform init" { & $TerraformBin init -backend=false }
    Step "2. Creacion de recursos locales - terraform apply" { & $TerraformBin apply -auto-approve }
    Step "3. Consulta del estado - terraform state list" { & $TerraformBin state list }
    Step "4. Consulta del estado - terraform show" { & $TerraformBin show }

    Step "5. Modificacion de configuracion (se agrega suc-003)" {
        (Get-Content "main.tf") -replace '\["suc-001", "suc-002"\]', '["suc-001", "suc-002", "suc-003"]' |
            Set-Content "main.tf"
        Get-Content "main.tf" | Select-String "sucursales_demo" -Context 0,1
    }

    Step "6. Planificacion de cambios - terraform plan" { & $TerraformBin plan }
    Step "7. Actualizacion controlada - terraform apply" { & $TerraformBin apply -auto-approve }
    Step "8. Verificacion - terraform state list (deberia incluir suc-003)" { & $TerraformBin state list }

    Step "9. Eliminacion de recursos de prueba - terraform destroy" { & $TerraformBin destroy -auto-approve }

    Step "10. Revertir main.tf al estado original" {
        (Get-Content "main.tf") -replace '\["suc-001", "suc-002", "suc-003"\]', '["suc-001", "suc-002"]' |
            Set-Content "main.tf"
    }

    Write-Host "`nEvidencia completa guardada en: $log"
}
finally {
    Pop-Location
}
