# Laboratorio de Terraform State (local)

Demuestra el ciclo de vida completo del estado de Terraform (inicializacion,
creacion, consulta, modificacion, planificacion, actualizacion controlada y
eliminacion) usando unicamente recursos locales, ya que el proyecto no cuenta
con credenciales de AWS ni GCP.

```powershell
cd lab/local-terraform
./run_state_demo.ps1
```

## Relacion con la estrategia empresarial de estado (AWS/GCP)

Este laboratorio usa backend `local` (`terraform.tfstate` en disco) solo para
fines didacticos. La estrategia documentada para produccion
(`docs/architecture/terraform-state-strategy.md`) especifica backend remoto
(S3 con DynamoDB / GCS con locking nativo), versionado, cifrado y IAM de
minimo privilegio. **El archivo `terraform.tfstate` de este laboratorio
nunca se sube al repositorio** (ver `.gitignore`): puede contener
informacion sensible en texto plano, igual que ocurriria con el estado real
de AWS/GCP.
