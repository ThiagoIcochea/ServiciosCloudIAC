# Gestion de secretos

## Lo implementado en este repositorio

- `.gitignore` excluye `*.tfstate`, `*.tfvars` (salvo `*.tfvars.example`),
  `.terraformrc`, `*.pem`, `*.key`, `secrets.auto.tfvars`, `.env` y el
  binario portatil de Terraform (`tools/`).
- `.github/workflows/terraform-security.yml` ejecuta `gitleaks` (escaneo de
  secretos en el historial de commits) y una verificacion adicional por
  patrones (`custom-secrets-check`) que falla el pipeline si aparece algun
  `.tfstate`, `.tfvars` real, `.pem` o `.key` versionado.
- Todas las variables "sensibles" de los modulos (`project_id`, `ami_id`,
  etc.) tienen valores de **ejemplo academico** como default, nunca
  credenciales reales, y se documentan como tales en cada modulo.
- Principio de minimo privilegio aplicado en el diseno de IAM documentado en
  `terraform-state-strategy.md` y `cicd-pipeline.md` (roles acotados por
  entorno/prefijo, nunca permisos de administrador completo).

## Uso futuro (empresarial, no implementado por falta de credenciales)

| Mecanismo | Proposito |
|---|---|
| AWS Secrets Manager | Almacenar credenciales de aplicacion (ej. contrasenas de base de datos) referenciadas desde Terraform via data source, nunca como variable en texto plano |
| Google Secret Manager | Equivalente en GCP; acceso via IAM condicionado por cuenta de servicio |
| GitHub OIDC | Autenticacion de GitHub Actions hacia AWS (`sts:AssumeRoleWithWebIdentity`) y GCP (Workload Identity Federation) sin guardar claves de acceso de larga duracion como secretos de GitHub |
| IAM / Cloud IAM | Roles de minimo privilegio por entorno y por pipeline (plan vs. apply con permisos distintos) |

## Que NO existe en este repositorio (verificado)

- Ninguna clave de AWS (`AKIA...`), token de GCP, ni archivo de credenciales
  de cuenta de servicio (`*.json` de service account).
- Ningun archivo `.tfstate` versionado.
- Ningun `terraform.tfvars` con valores reales (solo `*.tfvars.example` si
  aplica).

Verificable con:

```powershell
git ls-files | Select-String -Pattern '\.tfstate|\.pem$|\.key$|service-account.*\.json'
```
