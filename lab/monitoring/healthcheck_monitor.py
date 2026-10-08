#!/usr/bin/env python3
"""Monitoreo local ligero para el laboratorio Docker de 2 sucursales
(FASE III, seccion 11 del enunciado).

Por que no Prometheus + Grafana en este laboratorio
-----------------------------------------------------
Prometheus + Grafana es la opcion recomendada y se documenta como tal en
docs/architecture/monitoring-strategy.md para un entorno empresarial real.
Para ESTE laboratorio especifico se descarta por dos restricciones del
entorno de desarrollo declaradas en el enunciado:
  - 8 GB de RAM totales, sin GPU dedicada, compartidos con VS Code, el
    navegador y el resto del sistema operativo.
  - El enunciado pide evitar levantar numerosos contenedores simultaneos; un
    stack Prometheus+Grafana+exporters suma 3-4 contenedores adicionales
    (~500-800 MB de RAM) solo para monitorear 4 contenedores de aplicacion.

Este script hace polling HTTP + `docker inspect`/`docker stats` directamente
sobre los 4 contenedores del laboratorio y escribe metricas estructuradas
(JSON Lines) y un resumen legible en docs/evidence/. Es deliberadamente
simple: favorece consumo de recursos minimo sobre funcionalidad.

Uso:
    python lab/monitoring/healthcheck_monitor.py --iterations 3 --interval 5
"""
from __future__ import annotations

import argparse
import json
import pathlib
import subprocess
import time
import urllib.request
from datetime import datetime, timezone

CONTAINERS = ["suc01-web01", "suc01-app01", "suc02-web01", "suc02-app01"]
HTTP_TARGETS = {
    "suc01-web01": "http://localhost:8081",
    "suc01-app01": "http://localhost:8082",
    "suc02-web01": "http://localhost:8091",
    "suc02-app01": "http://localhost:8092",
}

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
EVIDENCE_DIR = ROOT / "docs" / "evidence" / "monitoring"


def check_http(url: str, timeout: float = 3.0) -> tuple[bool, int | None]:
    try:
        with urllib.request.urlopen(url, timeout=timeout) as resp:
            return True, resp.status
    except Exception:
        return False, None


def docker_stats_snapshot() -> dict:
    try:
        out = subprocess.run(
            [
                "docker", "stats", "--no-stream", "--format",
                "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}",
            ] + CONTAINERS,
            capture_output=True, text=True, timeout=10, check=False,
        )
    except FileNotFoundError:
        return {"error": "docker CLI no disponible en este equipo"}

    stats = {}
    for line in out.stdout.strip().splitlines():
        parts = line.split(",")
        if len(parts) == 4:
            name, cpu, mem_usage, mem_pct = parts
            stats[name] = {"cpu": cpu, "mem_usage": mem_usage, "mem_pct": mem_pct}
    return stats


def health_status() -> dict:
    statuses = {}
    for name in CONTAINERS:
        try:
            out = subprocess.run(
                ["docker", "inspect", "--format", "{{.State.Health.Status}}", name],
                capture_output=True, text=True, timeout=5, check=False,
            )
            statuses[name] = out.stdout.strip() or "desconocido"
        except FileNotFoundError:
            statuses[name] = "docker no disponible"
    return statuses


def run_once() -> dict:
    timestamp = datetime.now(timezone.utc).isoformat()
    http_results = {name: check_http(url) for name, url in HTTP_TARGETS.items()}
    return {
        "timestamp": timestamp,
        "http": {name: {"up": up, "status_code": code} for name, (up, code) in http_results.items()},
        "container_health": health_status(),
        "resource_usage": docker_stats_snapshot(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iterations", type=int, default=3)
    parser.add_argument("--interval", type=float, default=5.0)
    args = parser.parse_args()

    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)
    out_file = EVIDENCE_DIR / f"monitoring-{datetime.now().strftime('%Y%m%d-%H%M%S')}.jsonl"

    with out_file.open("w", encoding="utf-8") as fh:
        for i in range(args.iterations):
            snapshot = run_once()
            fh.write(json.dumps(snapshot, ensure_ascii=False) + "\n")
            fh.flush()
            print(f"[{i+1}/{args.iterations}] {snapshot['timestamp']}")
            for name, http in snapshot["http"].items():
                estado = "UP" if http["up"] else "DOWN"
                print(f"  {name}: HTTP={estado} health={snapshot['container_health'].get(name)}")
            if i < args.iterations - 1:
                time.sleep(args.interval)

    print(f"\nEvidencia guardada en: {out_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
