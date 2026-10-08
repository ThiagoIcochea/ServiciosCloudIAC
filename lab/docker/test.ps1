<#
.SYNOPSIS
    Ejecuta las pruebas HTTP, de conectividad y de aislamiento de red del
    laboratorio Docker de 2 sucursales (FASE III, seccion 10).

.DESCRIPTION
    1. Verifica que los 4 contenedores esten healthy.
    2. Prueba HTTP contra cada servidor (puertos publicados en localhost).
    3. Prueba conectividad DENTRO de cada sucursal (web <-> app, misma red).
    4. Prueba aislamiento ENTRE sucursales (suc01 NO debe poder alcanzar
       contenedores de suc02 y viceversa).

    Guarda toda la salida en docs/evidence/docker-lab/ con timestamp.
#>
$ErrorActionPreference = "Continue"
$evidenceDir = Join-Path $PSScriptRoot "../../docs/evidence/docker-lab"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$log = Join-Path $evidenceDir "docker-lab-test-$timestamp.log"

$results = @()

function Record {
    param([string]$Test, [bool]$Passed, [string]$Detail)
    $status = if ($Passed) { "PASS" } else { "FAIL" }
    $line = "[$status] $Test - $Detail"
    Write-Host $line
    $line | Tee-Object -FilePath $log -Append | Out-Null
    $script:results += [pscustomobject]@{ Test = $Test; Status = $status; Detail = $Detail }
}

Push-Location $PSScriptRoot
try {
    "===== Laboratorio Docker - pruebas ($timestamp) =====" | Tee-Object -FilePath $log

    "`n--- 1. Estado de contenedores ---" | Tee-Object -FilePath $log -Append
    docker compose ps | Tee-Object -FilePath $log -Append

    "`n--- 2. Pruebas HTTP ---" | Tee-Object -FilePath $log -Append
    $httpTargets = @(
        @{ Name = "suc01-web01"; Url = "http://localhost:8081" },
        @{ Name = "suc01-app01"; Url = "http://localhost:8082" },
        @{ Name = "suc02-web01"; Url = "http://localhost:8091" },
        @{ Name = "suc02-app01"; Url = "http://localhost:8092" }
    )
    foreach ($t in $httpTargets) {
        try {
            $resp = Invoke-WebRequest -Uri $t.Url -UseBasicParsing -TimeoutSec 5
            Record "HTTP $($t.Name)" ($resp.StatusCode -eq 200) "status=$($resp.StatusCode)"
        } catch {
            Record "HTTP $($t.Name)" $false $_.Exception.Message
        }
    }

    "`n--- 3. Conectividad interna (misma sucursal) ---" | Tee-Object -FilePath $log -Append
    $internal = @(
        @{ From = "suc01-web01"; To = "suc01-app01" },
        @{ From = "suc02-web01"; To = "suc02-app01" }
    )
    foreach ($pair in $internal) {
        $out = docker exec $pair.From wget -qO- --timeout=3 "http://$($pair.To)" 2>&1
        Record "Conectividad $($pair.From) -> $($pair.To)" ($LASTEXITCODE -eq 0) "exit=$LASTEXITCODE"
    }

    "`n--- 4. Aislamiento de red entre sucursales ---" | Tee-Object -FilePath $log -Append
    $isolation = @(
        @{ From = "suc01-web01"; To = "suc02-web01" },
        @{ From = "suc02-web01"; To = "suc01-web01" }
    )
    foreach ($pair in $isolation) {
        docker exec $pair.From wget -qO- --timeout=3 "http://$($pair.To)" 2>&1 | Out-Null
        $isolated = ($LASTEXITCODE -ne 0)
        Record "Aislamiento $($pair.From) -X-> $($pair.To)" $isolated "exit=$LASTEXITCODE (se espera distinto de 0: sin acceso)"
    }

    "`n--- Resumen ---" | Tee-Object -FilePath $log -Append
    $results | Format-Table | Out-String | Tee-Object -FilePath $log -Append

    $failed = $results | Where-Object { $_.Status -eq "FAIL" }
    if ($failed) {
        Write-Host "`n$($failed.Count) prueba(s) fallaron. Ver $log"
        exit 1
    } else {
        Write-Host "`nTodas las pruebas pasaron. Evidencia: $log"
        exit 0
    }
}
finally {
    Pop-Location
}
