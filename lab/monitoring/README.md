# Monitoreo local ligero

Alternativa ligera a Prometheus + Grafana para el laboratorio Docker de 2
sucursales (ver justificacion completa en el docstring de
`healthcheck_monitor.py` y en `docs/architecture/monitoring-strategy.md`).

```powershell
cd lab/docker
./start.ps1
cd ../monitoring
python healthcheck_monitor.py --iterations 5 --interval 10
```

Genera un archivo `.jsonl` en `docs/evidence/monitoring/` con, para cada
iteracion: estado HTTP de los 4 servidores, estado de `healthcheck` de
Docker y uso de CPU/memoria por contenedor (`docker stats`).

## Ejecucion real: GitHub Actions (CI)

Igual que `lab/docker`, este script se ejecuta realmente en
`.github/workflows/docker-lab.yml` (runner `ubuntu-latest`, con el
laboratorio Docker ya activo) en vez de en el equipo de desarrollo local
(sin Docker Desktop operativo). La evidencia JSONL real se publica como
artifact del workflow y se guarda en `docs/evidence/monitoring/`.
