# Matriz de trazabilidad

| Requisito | Solucion | Herramienta | Prueba | Evidencia |
|---|---|---|---|---|
| RF-01 Red independiente por sucursal | `modules/aws/network`, `modules/gcp/network` | Terraform, AWS VPC, GCP VPC Network | CP02, CP03, CP06 | `terraform/tests/aws_network.tftest.hcl`, `gcp_network.tftest.hcl` |
| RF-02 Dos servidores por sucursal | `modules/aws/compute`, `modules/gcp/compute` | Terraform, EC2, Compute Engine | CP02, CP03, CP05 | `aws_compute.tftest.hcl`, `gcp_compute.tftest.hcl` |
| RF-03 Reglas de seguridad | `modules/aws/security`, `modules/gcp/security` | Terraform, Security Groups, Firewall Rules | CP02, CP03, CP07 | `aws_security.tftest.hcl`, `gcp_security.tftest.hcl` |
| RF-04 Monitoreo | `modules/aws/monitoring`, `modules/gcp/monitoring` | Terraform, CloudWatch, Cloud Monitoring | CP02, CP03, CP08 | `aws_monitoring.tftest.hcl`, `gcp_monitoring.tftest.hcl` |
| RF-05 Soporte AWS + GCP | `modules/branch-stack` (filtra por `provider`) | Terraform | CP02, CP03, CP04 | `branch_stack.tftest.hcl` |
| RF-06 Agregar sucursal sin duplicar modulos | `config/branches/branches.yaml` + `for_each` | Terraform `yamldecode`, Python | CP04, CP15 | `validate_branches_schema.py`, `branch_stack.tftest.hcl` |
| RF-07 Modificar una sucursal sin afectar a las demas | `for_each` por `id` (clave estable) en todos los modulos | Terraform | CP04 | `terraform plan` dirigido (`-target`) documentado en `docs/user-guide` |
| RF-08 Entornos separados | `terraform/environments/{development,staging,production}` | Terraform | CP01 | `terraform validate` por entorno (ver `docs/evidence`) |
| RF-09 Estado aislado por entorno | `backend "local"` con `path` propio por entorno (diseno real: prefijo S3/GCS por entorno) | Terraform | CP12 | `docs/architecture/terraform-state-strategy.md` |
| Sin credenciales cloud | Modulos sin `data` sources que requieran API real; valores de ejemplo | Terraform | CP01, CP02, CP03 | `terraform validate` sin backend remoto |
| Sin secretos en el repositorio | `.gitignore`, `gitleaks`, verificacion adicional en CI | git, gitleaks, GitHub Actions | CP11 | `.github/workflows/terraform-security.yml` |
| Deteccion de Infrastructure Drift | `lab/drift` (provider local) | Terraform, PowerShell | CP13, CP14 | `lab/drift/run_drift_demo.ps1`, `docs/evidence/drift/` |
| Pipeline CI/CD comun AWS+GCP | `.github/workflows/terraform-ci.yml` | GitHub Actions | CP10 | Runs reales (fmt, validate, test, TFLint, Checkov, gitleaks, drift-check) en https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions |
| Laboratorio local de 2 sucursales | `lab/docker` | Docker Compose, GitHub Actions (runner ubuntu-latest) | CP16 | Run real exitoso: https://github.com/ThiagoIcochea/ServiciosCloudIAC/actions/runs/37832592874, `docs/evidence/docker-lab/` |

> Esta matriz se actualiza al finalizar la implementacion (seccion 4 del
> enunciado). Version vigente: ver fecha del ultimo commit que modifico este
> archivo.
