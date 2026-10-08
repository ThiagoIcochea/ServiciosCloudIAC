# Arquitectura AWS

```mermaid
flowchart TB
    subgraph VPC["aws_vpc (por sucursal)"]
        SN["aws_subnet\n(publica)"]
        IGW["aws_internet_gateway"]
        RT["aws_route_table\n0.0.0.0/0 -> IGW"]
        SN --- RT
        RT --- IGW
        subgraph SG["aws_security_group"]
            R1["ingress 80/tcp 0.0.0.0/0"]
            R2["ingress 443/tcp 0.0.0.0/0"]
            R3["ingress 22/tcp 10.0.0.0/8"]
        end
        WEB["aws_instance\nweb-XXX"]
        APP["aws_instance\napp-XXX"]
        SN --- WEB
        SN --- APP
        SG -.protege.-> WEB
        SG -.protege.-> APP
    end
    CW["aws_cloudwatch_log_group\n+ metric_alarm (CPU) por servidor"]
    WEB -.metricas.-> CW
    APP -.metricas.-> CW
```

## Recursos por sucursal

| Recurso | Cantidad | Modulo |
|---|---|---|
| `aws_vpc` | 1 | `aws/network` |
| `aws_subnet` | 1 | `aws/network` |
| `aws_internet_gateway` | 1 | `aws/network` |
| `aws_route_table` (+ association) | 1 | `aws/network` |
| `aws_security_group` | 1 | `aws/security` |
| `aws_security_group_rule` | N (segun `security_rules`) | `aws/security` |
| `aws_instance` | 2 | `aws/compute` |
| `aws_cloudwatch_log_group` | 1 | `aws/monitoring` |
| `aws_cloudwatch_metric_alarm` | 2 (una por servidor) | `aws/monitoring` |

Para las 25 sucursales AWS de esta demo: 25 VPC independientes, 50
instancias EC2, 25 Security Groups con 3 reglas cada uno (75 reglas) y 25
Log Groups con 50 alarmas de CPU.

## Justificacion de herramientas

| Herramienta | Por que |
|---|---|
| Terraform | Declarativo, multi-cloud, soporta `mock_provider` para pruebas sin credenciales (requisito del enunciado) |
| VPC por sucursal (no VPC compartida con subnets) | Aislamiento real de red por sucursal (RF-01); simplifica el blast radius de un cambio erroneo |
| Security Group por sucursal (no uno global) | Permite reglas especificas por sucursal sin afectar a las demas (RF-07) |
| CloudWatch | Servicio de monitoreo nativo de AWS, sin infraestructura adicional que administrar |
