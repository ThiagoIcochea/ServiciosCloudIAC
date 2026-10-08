# Guia de usuario — ejecucion local

Todos los comandos asumen PowerShell desde la raiz del repositorio, en un
equipo Windows 11 sin credenciales de AWS/GCP. El binario de Terraform es
portatil (`tools/terraform.exe`, descargado directamente de HashiCorp, no
instalado a nivel de sistema).

## 1. Requisitos

| Herramienta | Version usada | Obligatoria |
|---|---|---|
| Git | 2.53+ | Si |
| Terraform CLI | 1.9.8 (portatil, `tools/terraform.exe`) | Si |
| Python | 3.14 | Si (validaciones de esquema) |
| PyYAML | 6.0+ (`pip install pyyaml`) | Si |
| GitHub CLI (`gh`) | 2.102+ | Solo para publicar el repositorio |
| Docker Desktop | — | Solo para `lab/docker` y `lab/monitoring` (no disponible en el equipo de desarrollo de este proyecto) |

## 2. Validaciones estaticas (CP01, CP04, CP11)

```powershell
./scripts/validate.ps1
```

## 3. Pruebas automatizadas sin Docker (CP02, CP03, CP04, CP09)

```powershell
./scripts/test.ps1
```

## 4. Laboratorio de Terraform State (CP12)

```powershell
cd lab/local-terraform
./run_state_demo.ps1
```

## 5. Laboratorio de Infrastructure Drift (CP13, CP14)

```powershell
cd lab/drift
./run_drift_demo.ps1
```

## 6. Laboratorio Docker de 2 sucursales (CP16 — requiere Docker Desktop)

```powershell
cd lab/docker
./start.ps1
./test.ps1
./stop.ps1
```

## 7. Monitoreo local (requiere el laboratorio Docker activo)

```powershell
cd lab/monitoring
python healthcheck_monitor.py --iterations 5 --interval 10
```

## 8. Agregar una sucursal nueva (RF-06)

1. Editar `scripts/generate_branches.py`: ajustar `TOTAL_SUCURSALES` y, si
   corresponde, `CIUDADES`.
2. Regenerar los datos:
   ```powershell
   python scripts/generate_branches.py
   ```
3. Validar:
   ```powershell
   python scripts/validate_branches_schema.py
   ./scripts/test.ps1
   ```
4. **Ningun archivo `.tf` deberia cambiar** (verificar con `git status
   terraform/`).

## 9. Limpieza completa

```powershell
./scripts/cleanup.ps1
```
