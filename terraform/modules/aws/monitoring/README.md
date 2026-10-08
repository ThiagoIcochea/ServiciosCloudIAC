# Modulo: aws/monitoring

Crea el Log Group de CloudWatch y una alarma de CPU por servidor de la sucursal.

## Ejemplo de uso

```hcl
module "monitoring" {
  source         = "../../modules/aws/monitoring"
  name           = "suc-001"
  enabled        = true
  retention_days = 14
  instance_ids   = module.compute.instance_ids
}
```
