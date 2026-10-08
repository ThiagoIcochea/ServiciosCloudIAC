# Modulo: gcp/network

Crea la red independiente de una sucursal en GCP: VPC Network en modo
personalizado, Subnetwork regional, Cloud Router y Cloud NAT.

## Ejemplo de uso

```hcl
module "network" {
  source      = "../../modules/gcp/network"
  name        = "suc-002"
  project_id  = "academic-demo-project"
  region      = "southamerica-east1"
  subnet_cidr = "10.20.2.0/26"

  tags = {
    sucursal_id = "suc-002"
    entorno     = "production"
  }
}
```
