# Modulo: gcp/compute

Crea los servidores (instancias de Compute Engine) de una sucursal a partir de
la misma interfaz generica `servers` que `aws/compute`.

## Ejemplo de uso

```hcl
module "compute" {
  source                = "../../modules/gcp/compute"
  name                  = "suc-002"
  zone                  = "southamerica-east1-a"
  subnetwork_self_link  = module.network.subnetwork_self_link

  servers = [
    { name = "web-002", role = "web", size = "small" },
    { name = "app-002", role = "app", size = "small" },
  ]

  tags = { sucursal_id = "suc-002" }
}
```
