#!/usr/bin/env python3
"""Regenera, en alta resolucion, las capturas de terminal usadas como figuras
del informe (docs/evidence/screenshots/*.png).

Toma SIEMPRE el texto de los logs reales de docs/evidence/ (no inventa
contenido): para cada figura extrae el tramo relevante del log, lo guarda
como extracto temporal y lo dibuja con scripts/render_terminal_screenshot.py
(escala x3, texto nitido en Word/PDF y proyector).

Uso:
    python scripts/render_evidence_screenshots.py
"""
from __future__ import annotations

import pathlib
import re
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
EV = ROOT / "docs" / "evidence"
OUT = EV / "screenshots"
RENDER = ROOT / "scripts" / "render_terminal_screenshot.py"

ANSI = re.compile(r"(\x1b|\^\[)\[[0-9;]*m")


def clean(text: str) -> list[str]:
    return [ANSI.sub("", l).rstrip() for l in text.splitlines()]


def first(pattern: str) -> pathlib.Path:
    return sorted(EV.glob(pattern))[-1]


def between(lines, start, end=None):
    out, on = [], False
    for l in lines:
        if start in l:
            on = True
        elif end and end in l and on:
            break
        if on:
            out.append(l)
    return out


def docker_summary(lines):
    """Resume el log de GitHub Actions del laboratorio Docker: quita el
    prefijo de paso y los comandos del script, y conserva solo las lineas
    de salida (healthchecks, docker compose ps, codigos HTTP, conectividad
    y aislamiento)."""
    out = ["Laboratorio Docker - 2 sucursales (GitHub Actions, runner ubuntu-latest)"]
    current = None
    for raw in lines:
        l = re.sub(r"^\[[^\]]*\] ", "", raw)
        if "##[" in l or l.strip().startswith(("echo", "for ", "if ", "fi", "done", "set ", "shell:", "code=", "cat ", "name=", "port=", "exit", "unhealthy=", "sleep", "break", "docker compose")):
            continue
        if l.startswith("Esperando healthchecks") and ("(1/" in l or "(5/" in l):
            out.append(l)
        elif l.startswith("Los 4 contenedores"):
            out.append(l)
        elif l.startswith("NAME "):
            out.append(f"{'NAME':<13}{'STATUS':<26}PORTS")
        elif re.match(r"^suc0\d-(web|app)01 ", l) and "healthy" in l:
            parts = re.split(r"\s{2,}", l)
            status = next(p for p in parts if p.startswith("Up"))
            port = next(p for p in parts if p.startswith("0.0.0.0")).split(",")[0]
            out.append(f"{parts[0]:<13}{status:<26}{port}")
        elif l.startswith("--- HTTP "):
            m = re.match(r"--- HTTP (\S+) \(puerto (\d+)\) ---", l)
            current = f"{m.group(1)} ({m.group(2)})" if m else None
            if not any(x.startswith("--- Pruebas HTTP") for x in out):
                out.append("--- Pruebas HTTP ---")
        elif l.startswith("status=") and current:
            out.append(f"{current}: {l}")
            current = None
        elif l.startswith("OK:"):
            if "conectividad interna" in l and not any("Conectividad interna" in x for x in out):
                out.append("--- Conectividad interna (misma sucursal) ---")
            if "aislamiento" in l and not any("Aislamiento" in x for x in out):
                out.append("--- Aislamiento de red (entre sucursales) ---")
            out.append(l)
    seen, dedup = set(), []
    for l in out:
        if l not in seen:
            dedup.append(l)
            seen.add(l)
    return dedup


def render(lines, name, title, max_lines=60):
    with tempfile.NamedTemporaryFile("w", suffix=".log", delete=False, encoding="utf-8") as tmp:
        tmp.write("\n".join(lines))
    subprocess.run([sys.executable, str(RENDER), tmp.name, str(OUT / name), "--title", title,
                    "--max-lines", str(max_lines)], check=True)
    pathlib.Path(tmp.name).unlink()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    validate = clean(first("terraform-validate/*.log").read_text(encoding="utf-8"))
    render(validate, "fig-terraform-validate.png", "terraform validate - 3 entornos")

    test = clean(first("terraform-test/*.log").read_text(encoding="utf-8"))
    render(test, "fig-terraform-test.png", "terraform test (mock_provider aws + google)")

    schema = clean(first("scalability/validate-branches-schema-*.log").read_text(encoding="utf-8"))
    render(schema, "fig-scalability-validation.png", "python scripts/validate_branches_schema.py")

    drift = clean(first("drift/*.log").read_text(encoding="utf-8"))
    render(between(drift, "===== 5.", "===== 7."), "fig-drift-deteccion.png",
           "Deteccion de Drift: modificacion manual + terraform plan")
    render(between(drift, "===== 9."), "fig-drift-reconciliacion.png",
           "Reconciliacion de Drift: verificacion final")

    docker = clean(first("docker-lab/*.log").read_text(encoding="utf-8", errors="replace"))
    render(docker_summary(docker), "fig-docker-lab.png", "GitHub Actions: Docker Lab (2 sucursales)")


if __name__ == "__main__":
    main()
