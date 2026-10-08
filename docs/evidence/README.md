# Evidencia

Salidas reales de la ejecucion de pruebas y laboratorios de este proyecto,
organizadas por tipo. Nada en esta carpeta esta fabricado: cada archivo es
la captura textual de un comando ejecutado realmente en el equipo de
desarrollo (ver `docs/academic/plan-de-pruebas.md` para el detalle de cada
caso de prueba).

| Carpeta | Contenido | Generado por |
|---|---|---|
| `terraform-validate/` | Salida de `terraform fmt`/`validate` en los 3 entornos | `scripts/validate.ps1` |
| `terraform-test/` | Salida de `terraform test` (mock_provider) | `scripts/test.ps1` |
| `state/` | Logs del laboratorio de Terraform State | `lab/local-terraform/run_state_demo.ps1` |
| `drift/` | Logs del laboratorio de Infrastructure Drift | `lab/drift/run_drift_demo.ps1` |
| `docker-lab/` | Resultados reales de pruebas HTTP/conectividad/aislamiento | `.github/workflows/docker-lab.yml` (runner ubuntu-latest) |
| `monitoring/` | Snapshots JSONL reales de monitoreo local | `.github/workflows/docker-lab.yml` (`healthcheck_monitor.py`, mismo run) |
| `scalability/` | Evidencia de CP15 (incorporacion de una sucursal nueva) | Ejecucion manual documentada en `docs/academic/plan-de-pruebas.md` |
| `github-actions/` | Capturas/enlaces de ejecuciones reales del pipeline | Tras la publicacion autorizada del repositorio |
