output "vpc_id" {
  description = "ID de la VPC creada para la sucursal."
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "ID de la subnet publica de la sucursal."
  value       = aws_subnet.this.id
}

output "route_table_id" {
  description = "ID de la tabla de rutas de la sucursal."
  value       = aws_route_table.this.id
}
