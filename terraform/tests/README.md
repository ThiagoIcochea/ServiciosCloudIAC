# Pruebas Terraform (`terraform test` + `mock_provider`)

Este directorio contiene las pruebas automatizadas de Terraform exigidas en
la FASE III del enunciado (CP01-CP09). Ninguna prueba se conecta a AWS ni a
GCP: todas usan `mock_provider`, que sustituye al proveedor real por un doble
que genera valores simulados a partir del esquema del proveedor (sin
llamadas de red a la nube).

| Archivo                     | Modulo bajo prueba      | Casos de prueba cubiertos |
|------------------------------|--------------------------|----------------------------|
| `aws_network.tftest.hcl`    | `modules/aws/network`    | CP02, CP06                |
| `aws_compute.tftest.hcl`    | `modules/aws/compute`    | CP02, CP05                |
| `aws_security.tftest.hcl`   | `modules/aws/security`   | CP02, CP07                |
| `aws_monitoring.tftest.hcl` | `modules/aws/monitoring` | CP02, CP08                |
| `gcp_network.tftest.hcl`    | `modules/gcp/network`    | CP03, CP06                |
| `gcp_compute.tftest.hcl`    | `modules/gcp/compute`    | CP03, CP05                |
| `gcp_security.tftest.hcl`   | `modules/gcp/security`   | CP03, CP07                |
| `gcp_monitoring.tftest.hcl` | `modules/gcp/monitoring` | CP03, CP08                |
| `branch_stack.tftest.hcl`   | `modules/branch-stack`   | CP04 (escalabilidad)      |

## Ejecucion local

```powershell
cd terraform/tests
../../tools/terraform.exe init -backend=false
../../tools/terraform.exe test
```

## Que SI valida `mock_provider` y que NO

- SI valida: que la configuracion es internamente consistente (referencias,
  tipos, validaciones de variable, for_each, numero de recursos generados,
  valores de argumentos que dependen de las variables de entrada).
- NO valida: que AWS o GCP aceptarian realmente esa configuracion (limites de
  cuenta, permisos IAM, disponibilidad de la AMI/imagen, cuotas de region,
  etc.). Esas verificaciones solo son posibles con credenciales reales y
  quedan fuera del alcance de este laboratorio (ver restriccion fundamental
  del enunciado).
