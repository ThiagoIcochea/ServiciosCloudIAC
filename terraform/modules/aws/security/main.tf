# Modulo: seguridad por sucursal (AWS)
# Crea un Security Group por sucursal y sus reglas (RF-03), a partir de una
# lista generica compatible con el modulo equivalente de GCP.

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security Group de la sucursal ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

locals {
  rules_by_name = { for r in var.rules : r.name => r }
}

resource "aws_security_group_rule" "this" {
  for_each = local.rules_by_name

  type              = each.value.direction
  security_group_id = aws_security_group.this.id
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  cidr_blocks       = [each.value.cidr]
  description       = each.value.name
}
