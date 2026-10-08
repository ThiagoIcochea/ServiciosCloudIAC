# Modulo: branch-stack

Modulo compuesto que lee `config/branches/branches.yaml`, filtra las
sucursales de un `environment` dado y provisiona, para cada una, los cuatro
recursos exigidos por el caso (red, dos servidores, reglas de seguridad y
monitoreo), en AWS o en GCP segun el campo `provider` de cada sucursal.

Es el unico punto donde se "ensamblan" los 8 modulos base
(`aws/{network,compute,security,monitoring}` y
`gcp/{network,compute,security,monitoring}`). Los entornos
(`terraform/environments/development|staging|production`) son wrappers
delgados de este modulo: **agregar una sucursal nueva es agregar una entrada
en `branches.yaml`, no escribir Terraform nuevo.**

## Ejemplo de uso

```hcl
module "branches" {
  source         = "../../modules/branch-stack"
  environment    = "production"
  gcp_project_id = "academic-demo-project"
}
```

## Limitacion de diseno documentada

Todas las sucursales AWS de esta demo comparten una unica region (`sa-east-1`)
porque el provider `aws` fija la region a nivel de provider, no de recurso.
Soportar varias regiones AWS simultaneas requeriria alias de provider
(`aws.sa_east_1`, `aws.us_east_1`, ...) pasados explicitamente a cada modulo,
lo cual se documenta en `docs/architecture` como extension empresarial futura
y queda fuera del alcance de este laboratorio academico sin credenciales.
GCP si puede combinar varias regiones con un unico provider porque
`region`/`zone` se declaran a nivel de recurso.
