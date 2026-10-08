# Estrategia de Terraform State

## Diseno empresarial (AWS)

| Aspecto | Decision |
|---|---|
| Backend | Amazon S3 (`backend "s3"`), un bucket por entorno o un prefijo de clave por entorno (`env:/production/...`) |
| Versionado | S3 Versioning habilitado en el bucket: permite recuperar una version anterior del state ante un apply erroneo |
| Cifrado | SSE-KMS con una CMK dedicada (`sse_algorithm = "aws:kms"`); cifrado en transito via TLS (por defecto en el backend S3 de Terraform) |
| IAM | Rol de ejecucion de CI/CD con politica de minimo privilegio: `s3:GetObject`/`PutObject`/`ListBucket` solo sobre el prefijo del entorno correspondiente, nunca `s3:*` |
| Bloqueo (locking) | Desde Terraform 1.10/1.11, S3 soporta locking nativo via condicional de objeto (`use_lockfile = true`), sin depender de una tabla DynamoDB adicional; para versiones anteriores de Terraform (como la 1.9.x usada en este proyecto) se documenta la alternativa clasica: tabla DynamoDB dedicada (`dynamodb_table`) con `LockID` como clave de particion |

```hcl
# Ejemplo (NO se ejecuta en este proyecto: requeriria credenciales AWS reales)
terraform {
  backend "s3" {
    bucket         = "iac-50-sucursales-tfstate-prod"
    key            = "production/terraform.tfstate"
    region         = "sa-east-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:sa-east-1:111111111111:key/EJEMPLO"
    dynamodb_table = "iac-50-sucursales-tfstate-lock" # Terraform < 1.10
    # use_lockfile = true                             # Terraform >= 1.10
  }
}
```

## Diseno empresarial (GCP)

| Aspecto | Decision |
|---|---|
| Backend | Google Cloud Storage (`backend "gcs"`), un bucket por entorno o prefijo por entorno |
| Versionado | Object Versioning habilitado en el bucket GCS |
| Cifrado | Cifrado en reposo por defecto de GCS (Google-managed); opcionalmente CMEK (Cloud KMS) para cumplimiento adicional |
| IAM | Cuenta de servicio de CI/CD con el rol `roles/storage.objectAdmin` acotado al bucket/prefijo del entorno (principio de minimo privilegio), nunca `roles/owner` |
| Control de concurrencia | GCS implementa locking nativo del backend (basado en generaciones de objeto); no requiere un recurso de bloqueo adicional como DynamoDB |

```hcl
# Ejemplo (NO se ejecuta en este proyecto: requeriria credenciales GCP reales)
terraform {
  backend "gcs" {
    bucket = "iac-50-sucursales-tfstate-prod"
    prefix = "production"
  }
}
```

## Laboratorio local (lo unico que se ejecuta realmente)

`lab/local-terraform/` demuestra, con el backend `local` y recursos
`hashicorp/local` + `hashicorp/random`, el ciclo de vida completo exigido
por el enunciado: inicializacion, creacion, consulta (`state list`, `show`),
modificacion de configuracion, planificacion, actualizacion controlada y
eliminacion (`destroy`). Ver `lab/local-terraform/README.md` y el log de
evidencia generado en `docs/evidence/state/`.

## Riesgos de almacenar informacion sensible en el state

El archivo de estado de Terraform guarda, en texto plano (salvo cifrado del
backend), **todos los atributos de los recursos gestionados**, incluyendo
valores que la configuracion marca como `sensitive` en pantalla pero que
igual quedan en el JSON del state (contrasenas generadas, claves privadas
creadas por el provider, tokens de conexion, IPs internas, metadatos de
seguridad). Por eso:

- El `.tfstate` **nunca** se versiona en Git (ver `.gitignore`).
- El backend remoto debe cifrarse en reposo y en transito.
- El acceso de lectura al state debe tratarse con el mismo cuidado que el
  acceso a secretos (es, de hecho, una fuente de secretos).
- Un `terraform state show` o `terraform output` sin `-json` sensible puede
  filtrar esos valores a logs de CI si no se tiene cuidado (por eso los
  workflows de este proyecto no imprimen outputs completos de entornos con
  datos sensibles reales).
