# Modulo: gcp/security

Crea las reglas de firewall de una sucursal a partir de la misma interfaz
generica `rules` que `aws/security`.

## Ejemplo de uso

```hcl
module "security" {
  source     = "../../modules/gcp/security"
  name       = "suc-002"
  network_id = module.network.network_id

  rules = [
    { name = "allow-http", port = 80, protocol = "tcp", cidr = "0.0.0.0/0", direction = "ingress" },
  ]
}
```
