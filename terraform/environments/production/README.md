# Entorno: production

Wrapper delgado sobre `terraform/modules/branch-stack` para las sucursales con
`environment: production` en `config/branches/branches.yaml` (40 de las 50
sucursales en la distribucion academica definida para esta demo).

```powershell
cd terraform/environments/production
../../../tools/terraform.exe init -backend=false
../../../tools/terraform.exe validate
```

No se ejecuta `terraform apply`: no existen credenciales de AWS ni GCP (ver
restriccion fundamental del enunciado).
