# Modulo: aws/security

Crea el Security Group de una sucursal y sus reglas a partir de una lista
generica `rules` con la interfaz comun `{ name, port, protocol, cidr, direction }`.

## Ejemplo de uso

```hcl
module "security" {
  source = "../../modules/aws/security"
  name   = "suc-001"
  vpc_id = module.network.vpc_id

  rules = [
    { name = "allow-http", port = 80, protocol = "tcp", cidr = "0.0.0.0/0", direction = "ingress" },
  ]
}
```
