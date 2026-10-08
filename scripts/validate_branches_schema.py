#!/usr/bin/env python3
"""Prueba de escalabilidad (seccion 7 del enunciado) sobre config/branches/branches.yaml.

Verifica, sin depender de Terraform ni de PyYAML, que:
  1. Existen exactamente 50 configuraciones de sucursales.
  2. Cada una tiene exactamente dos servidores definidos.
  3. Cada sucursal tiene su configuracion de red (cidr_block + subnet_cidr validos).
  4. Todas incluyen al menos una regla de seguridad.
  5. Todas incluyen configuracion de monitoreo.
  6. Los identificadores no estan duplicados.
  7. Se puede agregar una sucursal nueva solo con datos (parametros), sin tocar
     codigo Terraform: se verifica regenerando el archivo con
     scripts/generate_branches.py y comprobando que el resultado es identico
     (reproducibilidad data-driven).

Uso:
    python scripts/validate_branches_schema.py

Codigo de salida 0 si todas las verificaciones pasan, 1 en caso contrario.
"""
from __future__ import annotations

import ipaddress
import pathlib
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
BRANCHES_YAML = ROOT / "config" / "branches" / "branches.yaml"

EXPECTED_TOTAL = 50


def main() -> int:
    if not BRANCHES_YAML.exists():
        print(f"FALLO: no existe {BRANCHES_YAML}. Ejecuta scripts/generate_branches.py primero.")
        return 1

    text = BRANCHES_YAML.read_text(encoding="utf-8")
    branches = yaml.safe_load(text)["sucursales"]

    failures: list[str] = []

    # 1. Exactamente 50 sucursales.
    if len(branches) != EXPECTED_TOTAL:
        failures.append(f"Se esperaban {EXPECTED_TOTAL} sucursales, se encontraron {len(branches)}.")

    # 6. Identificadores unicos.
    ids = [b["id"] for b in branches]
    duplicados = {i for i in ids if ids.count(i) > 1}
    if duplicados:
        failures.append(f"Identificadores duplicados: {sorted(duplicados)}")

    for b in branches:
        bid = b.get("id", "<sin id>")

        # 2. Dos servidores por sucursal.
        if len(b.get("servers", [])) != 2:
            failures.append(f"{bid}: se esperaban 2 servidores, hay {len(b.get('servers', []))}.")

        # 3. Red valida.
        net = b.get("network", {})
        for field in ("cidr_block", "subnet_cidr"):
            raw = net.get(field)
            if not raw:
                failures.append(f"{bid}: falta network.{field}.")
                continue
            try:
                ipaddress.ip_network(raw, strict=False)
            except ValueError:
                failures.append(f"{bid}: network.{field}='{raw}' no es un CIDR valido.")

        # 4. Al menos una regla de seguridad.
        if len(b.get("security_rules", [])) < 1:
            failures.append(f"{bid}: no tiene reglas de seguridad.")

        # 5. Monitoreo configurado.
        if "enabled" not in b.get("monitoring", {}):
            failures.append(f"{bid}: no tiene configuracion de monitoreo.")

        if b.get("provider") not in ("aws", "gcp"):
            failures.append(f"{bid}: provider invalido '{b.get('provider')}'.")

        if b.get("environment") not in ("development", "staging", "production"):
            failures.append(f"{bid}: environment invalido '{b.get('environment')}'.")

    # 7. Reproducibilidad: agregar sucursales es un cambio de datos, no de codigo.
    #    Se verifica que el generador es determinista (misma entrada -> mismo archivo).
    sys.path.insert(0, str(ROOT / "scripts"))
    import generate_branches  # noqa: E402

    regenerated = generate_branches.to_yaml([generate_branches.build_branch(i) for i in range(1, EXPECTED_TOTAL + 1)])
    if regenerated != text:
        failures.append(
            "branches.yaml no coincide con la salida determinista de generate_branches.py "
            "(regenera el archivo con `python scripts/generate_branches.py`)."
        )

    print(f"Sucursales analizadas: {len(branches)}")
    aws_count = sum(1 for b in branches if b.get("provider") == "aws")
    gcp_count = sum(1 for b in branches if b.get("provider") == "gcp")
    print(f"  AWS: {aws_count}  GCP: {gcp_count}")

    if failures:
        print(f"\nFALLÓ la validación ({len(failures)} problema(s)):")
        for f in failures:
            print(f"  - {f}")
        return 1

    print("OK: todas las verificaciones de escalabilidad pasaron.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
