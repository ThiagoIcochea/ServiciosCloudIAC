# Modulo: computo por sucursal (AWS)
# Crea los servidores (EC2) de una sucursal a partir de una lista generica de
# "servers" (interfaz comun con el modulo equivalente de GCP). Dos servidores
# por sucursal es el patron minimo exigido por el caso (RF-02).

locals {
  servers_by_name = { for s in var.servers : s.name => s }
}

resource "aws_instance" "this" {
  for_each = local.servers_by_name

  ami                    = var.ami_id
  instance_type          = var.size_to_instance_type[each.value.size]
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(var.tags, {
    Name = "${var.name}-${each.value.name}"
    role = each.value.role
  })
}
