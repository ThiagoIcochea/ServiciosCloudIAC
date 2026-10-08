output "instance_ids" {
  description = "Mapa nombre de servidor -> ID de instancia EC2."
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "private_ips" {
  description = "Mapa nombre de servidor -> IP privada."
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}
