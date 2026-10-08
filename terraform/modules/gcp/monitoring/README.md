# Modulo: gcp/monitoring

Crea una politica de alerta de Cloud Monitoring por alto uso de CPU en las
instancias de la sucursal. Equivalente funcional de `aws/monitoring`.

## Ejemplo de uso

```hcl
module "monitoring" {
  source         = "../../modules/gcp/monitoring"
  name           = "suc-002"
  enabled        = true
  retention_days = 14
}
```

## Limitacion documentada

La retencion de logs en Cloud Logging se gestiona mediante *log buckets* a
nivel de proyecto (`google_logging_project_bucket_config`), no por sucursal.
`retention_days` se conserva como metadato de configuracion pero no crea un
recurso de retencion independiente por sucursal.
