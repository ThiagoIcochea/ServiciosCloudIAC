## Descripcion

<!-- Que cambia y por que. Enlaza la sucursal/modulo/entorno afectado. -->

## Tipo de cambio

- [ ] Nuevo modulo o recurso Terraform
- [ ] Modificacion de sucursal(es) existente(s) en `config/branches/branches.yaml`
- [ ] Correccion de bug
- [ ] Pipeline / CI-CD
- [ ] Documentacion

## Checklist de aprobacion (FASE V, seccion 13)

- [ ] `terraform fmt -check -recursive` pasa localmente.
- [ ] `terraform validate` pasa en los 3 entornos afectados.
- [ ] `terraform test` (mock_provider) pasa.
- [ ] No se agregaron archivos `.tfstate`, `.tfvars` reales, claves ni tokens.
- [ ] TFLint y Checkov no reportan hallazgos criticos nuevos (o estan
      documentados y justificados).
- [ ] Si se agrego/modifico una sucursal, `python scripts/validate_branches_schema.py`
      pasa.

## Revision humana requerida antes de aprobar

- [ ] Revisar el `terraform plan` (mock) generado por el pipeline.
- [ ] Confirmar que el cambio no afecta sucursales fuera del alcance descrito.
- [ ] Confirmar que ningun paso de este PR ejecuta `terraform apply` contra
      AWS/GCP reales (no existen credenciales en este proyecto).

## Evidencia

<!-- Capturas o logs relevantes, o enlace al run de GitHub Actions. -->
