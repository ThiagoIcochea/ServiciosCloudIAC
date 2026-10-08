# Modulo: aws/network

Crea la red independiente de una sucursal en AWS: VPC, subnet publica, Internet
Gateway y tabla de rutas.

## Ejemplo de uso

```hcl
module "network" {
  source      = "../../modules/aws/network"
  name        = "suc-001"
  cidr_block  = "10.10.1.0/24"
  subnet_cidr = "10.10.1.0/26"

  tags = {
    sucursal_id = "suc-001"
    entorno     = "production"
  }
}
```

## Entradas principales

| Variable      | Tipo          | Descripcion                              |
|---------------|---------------|-------------------------------------------|
| `name`        | `string`      | Prefijo de nombre para los recursos.      |
| `cidr_block`  | `string`      | CIDR de la VPC.                           |
| `subnet_cidr` | `string`      | CIDR de la subnet publica.                |
| `tags`        | `map(string)` | Etiquetas comunes.                        |

## Salidas

| Output           | Descripcion              |
|-------------------|--------------------------|
| `vpc_id`          | ID de la VPC.            |
| `subnet_id`       | ID de la subnet publica. |
| `route_table_id`  | ID de la tabla de rutas. |
