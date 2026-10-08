output "security_group_id" {
  description = "ID del Security Group creado para la sucursal."
  value       = aws_security_group.this.id
}
