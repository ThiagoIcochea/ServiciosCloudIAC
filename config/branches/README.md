# config/branches/branches.yaml

Fuente de verdad de las 50 sucursales. **No se edita a mano**: se genera con
`python scripts/generate_branches.py` (determinista: misma logica, mismo
archivo de salida, verificado por `scripts/validate_branches_schema.py`).

## Esquema por sucursal

```yaml
- id: "suc-001"                # unico, formato suc-NNN
  name: "Sucursal 01 - Lima Centro"
  provider: "aws"               # "aws" | "gcp"
  region: "sa-east-1"
  environment: "production"     # "development" | "staging" | "production"
  network:
    cidr_block: "10.10.1.0/24"
    subnet_cidr: "10.10.1.0/26"
  servers:                      # exactamente 2 (RF-02)
    - { name: "web-001", role: "web", size: "small" }
    - { name: "app-001", role: "app", size: "small" }
  security_rules:               # al menos 1 (RF-03)
    - { name: "allow-http", port: 80, protocol: "tcp", cidr: "0.0.0.0/0", direction: "ingress" }
  monitoring:
    enabled: true
    retention_days: 14
  tags:
    sucursal_id: "suc-001"
    entorno: "production"
    proveedor: "aws"
    proyecto: "iac-50-sucursales"
    ciudad: "Lima Centro"
```

## Por que este archivo es el "patron comun"

Los 8 modulos Terraform (`terraform/modules/aws/*`, `terraform/modules/gcp/*`)
y el modulo orquestador (`terraform/modules/branch-stack`) NO contienen
ningun dato especifico de sucursal. Agregar, quitar o modificar una
sucursal es, siempre, un cambio en este archivo — nunca en un `.tf`. Esto se
verifica automaticamente:

- `scripts/validate_branches_schema.py`: valida el esquema de datos (50
  sucursales, 2 servidores, red valida, reglas, monitoreo, IDs unicos).
- `terraform/tests/branch_stack.tftest.hcl`: valida que Terraform procese
  correctamente esos datos (conteos por entorno y por proveedor).

## Distribucion AWS/GCP (supuesto academico)

Sucursales con `id` impar -> AWS; `id` par -> GCP (25/25). Ver justificacion
en [`docs/architecture/overview.md`](../../docs/architecture/overview.md#4-supuesto-academico-de-distribucion-awsgcp).
