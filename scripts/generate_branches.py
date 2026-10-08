#!/usr/bin/env python3
"""Genera config/branches/branches.yaml con la definicion logica de las 50 sucursales.

Este script es la UNICA fuente de verdad para la distribucion de sucursales entre
AWS y Google Cloud Platform. La distribucion (25 AWS / 25 GCP, alternadas) es un
SUPUESTO ACADEMICO definido para esta demostracion -- en un caso real la asignacion
dependeria de criterios de negocio (latencia, costos, presencia regional, contratos
marco, etc.) que no aplican a este laboratorio academico.

Uso:
    python scripts/generate_branches.py

Salida:
    config/branches/branches.yaml
"""
from __future__ import annotations

import pathlib

TOTAL_SUCURSALES = 50

# NOTA DE DISENO: todas las sucursales AWS de esta demo comparten una sola
# region. El provider "aws" de Terraform configura la region a nivel de
# provider (no por recurso); soportar multiples regiones exigiria alias de
# provider por region (aws.sa_east_1, aws.us_east_1, ...), lo cual se
# documenta como extension empresarial futura (docs/architecture) y no se
# implementa aqui para mantener el laboratorio simple y sin credenciales.
# GCP si declara "region"/"zone" a nivel de RECURSO (no de provider), por lo
# que puede combinar varias regiones con una unica configuracion de provider.
AWS_REGIONS = ["sa-east-1"]
GCP_REGIONS = ["southamerica-east1", "us-central1"]

CIUDADES = [
    "Lima Centro", "Lima Norte", "Lima Sur", "Lima Este", "Callao",
    "Arequipa", "Trujillo", "Chiclayo", "Piura", "Cusco",
    "Huancayo", "Iquitos", "Tacna", "Ica", "Pucallpa",
    "Chimbote", "Tarapoto", "Juliaca", "Cajamarca", "Ayacucho",
    "Huaraz", "Puno", "Abancay", "Moquegua", "Tumbes",
]

SECURITY_RULE_TEMPLATES = [
    {"name": "allow-http", "port": 80, "protocol": "tcp", "cidr": "0.0.0.0/0", "direction": "ingress"},
    {"name": "allow-https", "port": 443, "protocol": "tcp", "cidr": "0.0.0.0/0", "direction": "ingress"},
    {"name": "allow-ssh-internal", "port": 22, "protocol": "tcp", "cidr": "10.0.0.0/8", "direction": "ingress"},
]


def build_branch(index: int) -> dict:
    """index es 1-based (1..50)."""
    is_aws = index % 2 == 1  # impares -> AWS, pares -> GCP (supuesto academico)
    provider = "aws" if is_aws else "gcp"
    ciudad = CIUDADES[(index - 1) % len(CIUDADES)]
    region_list = AWS_REGIONS if is_aws else GCP_REGIONS
    region = region_list[index % len(region_list)]
    environment = "production" if index <= 40 else ("staging" if index <= 46 else "development")

    octeto_proveedor = 10 if is_aws else 20
    cidr_block = f"10.{octeto_proveedor}.{index}.0/24"
    subnet_cidr = f"10.{octeto_proveedor}.{index}.0/26"

    size_web = "small"
    size_app = "small" if index % 5 != 0 else "medium"  # algunas sucursales con mas carga

    branch = {
        "id": f"suc-{index:03d}",
        "name": f"Sucursal {index:02d} - {ciudad}",
        "provider": provider,
        "region": region,
        "environment": environment,
        "network": {
            "cidr_block": cidr_block,
            "subnet_cidr": subnet_cidr,
        },
        "servers": [
            {"name": f"web-{index:03d}", "role": "web", "size": size_web},
            {"name": f"app-{index:03d}", "role": "app", "size": size_app},
        ],
        "security_rules": SECURITY_RULE_TEMPLATES,
        "monitoring": {
            "enabled": True,
            "retention_days": 14 if environment == "production" else 7,
        },
        "tags": {
            "sucursal_id": f"suc-{index:03d}",
            "entorno": environment,
            "proveedor": provider,
            "proyecto": "iac-50-sucursales",
            "ciudad": ciudad,
        },
    }
    return branch


def to_yaml(branches: list[dict]) -> str:
    """Serializador YAML minimo y determinista (evita depender de PyYAML)."""
    lines: list[str] = ["# Archivo generado automaticamente por scripts/generate_branches.py", "# NO editar a mano: regenerar con `python scripts/generate_branches.py`", "sucursales:"]

    def esc(value: str) -> str:
        return f'"{value}"'

    for b in branches:
        lines.append(f'  - id: {esc(b["id"])}')
        lines.append(f'    name: {esc(b["name"])}')
        lines.append(f'    provider: {esc(b["provider"])}')
        lines.append(f'    region: {esc(b["region"])}')
        lines.append(f'    environment: {esc(b["environment"])}')
        lines.append('    network:')
        lines.append(f'      cidr_block: {esc(b["network"]["cidr_block"])}')
        lines.append(f'      subnet_cidr: {esc(b["network"]["subnet_cidr"])}')
        lines.append('    servers:')
        for s in b["servers"]:
            lines.append(f'      - name: {esc(s["name"])}')
            lines.append(f'        role: {esc(s["role"])}')
            lines.append(f'        size: {esc(s["size"])}')
        lines.append('    security_rules:')
        for r in b["security_rules"]:
            lines.append(f'      - name: {esc(r["name"])}')
            lines.append(f'        port: {r["port"]}')
            lines.append(f'        protocol: {esc(r["protocol"])}')
            lines.append(f'        cidr: {esc(r["cidr"])}')
            lines.append(f'        direction: {esc(r["direction"])}')
        lines.append('    monitoring:')
        lines.append(f'      enabled: {str(b["monitoring"]["enabled"]).lower()}')
        lines.append(f'      retention_days: {b["monitoring"]["retention_days"]}')
        lines.append('    tags:')
        for k, v in b["tags"].items():
            lines.append(f'      {k}: {esc(v)}')
        lines.append("")
    return "\n".join(lines) + "\n"


def main() -> None:
    branches = [build_branch(i) for i in range(1, TOTAL_SUCURSALES + 1)]
    ids = [b["id"] for b in branches]
    assert len(ids) == len(set(ids)), "Identificadores de sucursal duplicados"
    assert len(branches) == TOTAL_SUCURSALES

    out_path = pathlib.Path(__file__).resolve().parent.parent / "config" / "branches" / "branches.yaml"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(to_yaml(branches), encoding="utf-8")

    aws_count = sum(1 for b in branches if b["provider"] == "aws")
    gcp_count = sum(1 for b in branches if b["provider"] == "gcp")
    print(f"Generadas {len(branches)} sucursales -> {out_path}")
    print(f"  AWS: {aws_count}  GCP: {gcp_count}")


if __name__ == "__main__":
    main()
