# Estrategia de monitoreo

## Nivel empresarial (AWS / GCP, definido en Terraform)

- **AWS**: `modules/aws/monitoring` crea un `aws_cloudwatch_log_group` por
  sucursal (retencion configurable via `branches.yaml`) y una
  `aws_cloudwatch_metric_alarm` de CPU por servidor. En produccion real se
  ampliaria con `aws_sns_topic` para notificaciones y dashboards de
  CloudWatch.
- **GCP**: `modules/gcp/monitoring` crea una `google_monitoring_alert_policy`
  de CPU por sucursal. En produccion real se asociaria a
  `google_monitoring_notification_channel` (email/Slack/PagerDuty) y a un
  log bucket de retencion configurada a nivel de proyecto.

## Nivel laboratorio local (lo que se ejecuta realmente sin credenciales)

Se evaluaron las opciones sugeridas por el enunciado:

| Opcion | Evaluacion para este laboratorio |
|---|---|
| Prometheus + Grafana + cAdvisor | Descartada: 3-4 contenedores adicionales, cientos de MB de RAM, para monitorear solo 4 contenedores de aplicacion en una maquina de 8 GB sin GPU. Documentada como la opcion correcta a nivel empresarial. |
| Metricas de contenedores (`docker stats`) | Usada: nativa de Docker, sin instalar nada adicional. |
| Logs | Usados: `docker logs`, capturados como evidencia en `docs/evidence/`. |
| Health checks | Usados: `HEALTHCHECK` nativo de Docker en `docker-compose.yml` (`lab/docker`), consultado via `docker inspect`. |

**Decision**: `lab/monitoring/healthcheck_monitor.py`, un script Python sin
dependencias externas (solo `urllib` y `subprocess` de la libreria
estandar) que hace polling HTTP + `docker stats`/`docker inspect` y escribe
un JSONL de evidencia. Es la alternativa mas ligera que cumple los 5
aspectos pedidos (metricas de contenedores, logs, health checks) sin exceder
los recursos disponibles.

## Limitacion documentada

Al depender de Docker (no disponible en el equipo de desarrollo, ver
`lab/docker/README.md`), la ejecucion real de `healthcheck_monitor.py` queda
pendiente/bloqueada junto con el resto del laboratorio Docker. El script esta
completo e implementado.
