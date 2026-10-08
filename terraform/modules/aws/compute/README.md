# Modulo: aws/compute

Crea los servidores (instancias EC2) de una sucursal a partir de una lista
generica `servers` con la interfaz comun `{ name, role, size }`, donde `size`
(`small` | `medium` | `large`) se traduce a un `instance_type` de AWS.

## Ejemplo de uso

```hcl
module "compute" {
  source              = "../../modules/aws/compute"
  name                = "suc-001"
  subnet_id           = module.network.subnet_id
  security_group_ids  = [module.security.security_group_id]

  servers = [
    { name = "web-001", role = "web", size = "small" },
    { name = "app-001", role = "app", size = "small" },
  ]

  tags = { sucursal_id = "suc-001" }
}
```

## Notas

- No se usa `data "aws_ami"` porque este proyecto no cuenta con credenciales de
  AWS; la AMI se declara como variable explicita (ver `ami_id`).
- La validacion de `servers` exige al menos un servidor y un `size` valido.
