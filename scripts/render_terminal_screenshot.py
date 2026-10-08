#!/usr/bin/env python3
"""Renderiza un log de texto real (salida de un comando ejecutado) como una
imagen con apariencia de terminal, para usarla como figura en el informe
academico (Word/PDF).

IMPORTANTE: esto NO fabrica contenido. Toma texto de una ejecucion real
(archivo .log ya generado por los scripts de los laboratorios) y solo
cambia su PRESENTACION VISUAL a un estilo de terminal con fondo oscuro,
fuente monoespaciada y coloreado basico de prompts/errores. El contenido es
identico al log de entrada.

Uso:
    python scripts/render_terminal_screenshot.py <input.log> <output.png> \
        [--title "Titulo de la ventana"] [--max-lines 45]
"""
from __future__ import annotations

import argparse
import pathlib
import re

from PIL import Image, ImageDraw, ImageFont

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\consola.ttf",
    r"C:\Windows\Fonts\cascadiamono.ttf",
    r"C:\Windows\Fonts\lucon.ttf",
]

ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

BG = (13, 17, 23)
FG = (201, 209, 217)
GREEN = (63, 185, 80)
RED = (248, 81, 73)
YELLOW = (210, 153, 34)
TITLEBAR = (33, 38, 45)
DOT_RED = (255, 95, 86)
DOT_YELLOW = (255, 189, 46)
DOT_GREEN = (39, 201, 63)


def strip_ansi(text: str) -> str:
    return ANSI_RE.sub("", text)


def line_color(line: str) -> tuple[int, int, int]:
    lower = line.lower()
    if "success" in lower or "pass" in lower or "ok:" in lower or "aprobada" in lower:
        return GREEN
    if "error" in lower or "fail" in lower or "fallo" in lower:
        return RED
    if "warning" in lower or "===" in line or "---" in line:
        return YELLOW
    return FG


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        if pathlib.Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input_log", type=pathlib.Path)
    parser.add_argument("output_png", type=pathlib.Path)
    parser.add_argument("--title", default="PowerShell")
    parser.add_argument("--max-lines", type=int, default=50)
    parser.add_argument("--font-size", type=int, default=15)
    args = parser.parse_args()

    raw = args.input_log.read_text(encoding="utf-8", errors="replace")
    lines = [strip_ansi(l).rstrip() for l in raw.splitlines() if strip_ansi(l).strip() != ""]
    if len(lines) > args.max_lines:
        skipped = len(lines) - args.max_lines
        lines = lines[: args.max_lines]
        lines.append(f"... ({skipped} lineas adicionales omitidas en esta figura; ver log completo en docs/evidence/)")

    font = load_font(args.font_size)
    line_height = int(args.font_size * 1.45)
    padding = 20
    titlebar_h = 34
    max_chars = max((len(l) for l in lines), default=80)
    width = max(900, min(1500, padding * 2 + int(max_chars * args.font_size * 0.62)))
    height = titlebar_h + padding * 2 + line_height * len(lines)

    img = Image.new("RGB", (width, height), BG)
    draw = ImageDraw.Draw(img)

    draw.rectangle([0, 0, width, titlebar_h], fill=TITLEBAR)
    for i, color in enumerate([DOT_RED, DOT_YELLOW, DOT_GREEN]):
        cx = 18 + i * 20
        draw.ellipse([cx - 6, titlebar_h // 2 - 6, cx + 6, titlebar_h // 2 + 6], fill=color)
    draw.text((width / 2, titlebar_h / 2), args.title, fill=(139, 148, 158), font=font, anchor="mm")

    y = titlebar_h + padding
    for line in lines:
        draw.text((padding, y), line, fill=line_color(line), font=font)
        y += line_height

    args.output_png.parent.mkdir(parents=True, exist_ok=True)
    img.save(args.output_png)
    print(f"Guardado: {args.output_png} ({width}x{height})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
