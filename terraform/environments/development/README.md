# Entorno: development

Wrapper delgado sobre `terraform/modules/branch-stack` para las sucursales con
`environment: development` (4 de las 50 sucursales en la distribucion
academica definida para esta demo).

```powershell
cd terraform/environments/development
../../../tools/terraform.exe init -backend=false
../../../tools/terraform.exe validate
```
