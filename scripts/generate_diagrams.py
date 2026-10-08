#!/usr/bin/env python3
"""Genera los diagramas de arquitectura obligatorios (seccion 19 del
enunciado, "Figuras obligatorias") como imagenes PNG, para incluir en el
informe academico (Word/PDF) y en docs/diagrams/.

No depende de Graphviz ni de ninguna libreria de diagramado: dibuja cajas,
flechas y texto directamente con Pillow (ya disponible en el entorno). El
contenido de cada diagrama replica fielmente los diagramas Mermaid ya
documentados en docs/architecture/*.md (misma informacion, presentacion
apta para un documento Word/PDF).

Uso:
    python scripts/generate_diagrams.py
"""
from __future__ import annotations

import pathlib
import textwrap

from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "docs" / "diagrams"

# Paleta alineada con la identidad UTP (portada): rojo institucional + negro + grises.
RED = (167, 29, 42)
BLACK = (26, 26, 26)
DARK_GRAY = (64, 64, 64)
LIGHT_GRAY = (235, 235, 235)
WHITE = (255, 255, 255)
BLUE = (40, 90, 160)
GREEN = (46, 125, 50)

FONT_PATHS = {
    "regular": r"C:\Windows\Fonts\segoeui.ttf",
    "bold": r"C:\Windows\Fonts\segoeuib.ttf",
    "mono": r"C:\Windows\Fonts\consola.ttf",
}


def font(kind: str, size: int) -> ImageFont.FreeTypeFont:
    path = FONT_PATHS.get(kind, FONT_PATHS["regular"])
    if pathlib.Path(path).exists():
        return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def draw_box(draw: ImageDraw.ImageDraw, xy, label, fill=WHITE, outline=BLACK,
             text_color=BLACK, f=None, width=2, wrap=22):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle([x0, y0, x1, y1], radius=10, fill=fill, outline=outline, width=width)
    f = f or font("regular", 15)
    lines = []
    for raw_line in label.split("\n"):
        lines.extend(textwrap.wrap(raw_line, width=wrap) or [""])
    line_h = f.size + 4
    total_h = line_h * len(lines)
    ty = (y0 + y1) / 2 - total_h / 2
    for line in lines:
        draw.text(((x0 + x1) / 2, ty + line_h / 2), line, fill=text_color, font=f, anchor="mm")
        ty += line_h


def draw_arrow(draw: ImageDraw.ImageDraw, p0, p1, color=DARK_GRAY, width=2, label=None, f=None):
    import math

    draw.line([p0, p1], fill=color, width=width)

    angle = math.atan2(p1[1] - p0[1], p1[0] - p0[0])
    length, spread = 14, 0.45  # spread en radianes (~26 grados por ala)
    back1 = angle + math.pi - spread
    back2 = angle + math.pi + spread
    p_back1 = (p1[0] + length * math.cos(back1), p1[1] + length * math.sin(back1))
    p_back2 = (p1[0] + length * math.cos(back2), p1[1] + length * math.sin(back2))
    draw.polygon([p1, p_back1, p_back2], fill=color)
    if label:
        f = f or font("regular", 12)
        mx, my = (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2
        draw.text((mx, my - 10), label, fill=color, font=f, anchor="mm")


def draw_frame(draw, xy, label, outline=BLACK, fill=WHITE, f=None):
    """Caja contenedora grande con la etiqueta anclada en la esquina
    superior izquierda (no centrada), para que no se superponga con las
    cajas internas."""
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle([x0, y0, x1, y1], radius=12, fill=fill, outline=outline, width=2)
    f = f or font("bold", 14)
    draw.text((x0 + 16, y0 + 14), label, fill=outline, font=f, anchor="lm")


def new_canvas(w, h, title):
    img = Image.new("RGB", (w, h), WHITE)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w, 50], fill=RED)
    d.text((w / 2, 25), title, fill=WHITE, font=font("bold", 20), anchor="mm")
    return img, d


# ---------------------------------------------------------------------------
# Figura 1: Arquitectura general de las 50 sucursales
# ---------------------------------------------------------------------------

def fig_overview():
    img, d = new_canvas(1100, 760, "Figura 1. Arquitectura general - 50 sucursales multi-cloud")
    f_box = font("regular", 14)
    f_small = font("regular", 12)

    draw_box(d, (380, 80, 720, 150), "config/branches/branches.yaml\n(50 sucursales: id, provider, region,\nnetwork, servers, security_rules, monitoring)",
              fill=LIGHT_GRAY, f=f_small, wrap=46)

    draw_box(d, (380, 190, 720, 250), "terraform/modules/branch-stack\nfor_each filtrado por entorno y provider", fill=(255, 244, 230), f=f_box, wrap=40)

    draw_arrow(d, (550, 150), (550, 190))

    # AWS branch
    draw_box(d, (90, 310, 480, 420),
             "modules/aws/*\nnetwork -> security -> compute -> monitoring\n(VPC, SG, EC2, CloudWatch)",
             fill=(255, 235, 235), f=f_box, wrap=40)
    draw_arrow(d, (480, 230), (480, 310), label="provider == aws")

    # GCP branch
    draw_box(d, (620, 310, 1010, 420),
             "modules/gcp/*\nnetwork -> security -> compute -> monitoring\n(VPC Network, Firewall, Compute Engine, Cloud Monitoring)",
             fill=(230, 240, 255), f=f_box, wrap=40)
    draw_arrow(d, (620, 230), (620, 310), label="provider == gcp")

    draw_box(d, (90, 470, 480, 540), "25 sucursales AWS\n(sa-east-1)", fill=WHITE, f=f_box)
    draw_arrow(d, (285, 420), (285, 470))

    draw_box(d, (620, 470, 1010, 540), "25 sucursales GCP\n(southamerica-east1 / us-central1)", fill=WHITE, f=f_box)
    draw_arrow(d, (815, 420), (815, 470))

    draw_box(d, (90, 590, 1010, 680),
             "Entornos: production (40) | staging (6) | development (4)\n"
             "Distribucion AWS/GCP 25/25: supuesto academico para esta demostracion",
             fill=LIGHT_GRAY, f=f_box, wrap=90)
    draw_arrow(d, (285, 540), (400, 590))
    draw_arrow(d, (815, 540), (700, 590))

    img.save(OUT_DIR / "fig-01-arquitectura-general.png")


# ---------------------------------------------------------------------------
# Figura 2: Arquitectura AWS
# ---------------------------------------------------------------------------

def fig_aws():
    img, d = new_canvas(1050, 650, "Figura 2. Arquitectura AWS (por sucursal)")
    f = font("regular", 13)

    draw_frame(d, (60, 90, 990, 560), "aws_vpc (por sucursal)", fill=(255, 245, 245), outline=RED)

    draw_box(d, (100, 150, 420, 210), "aws_subnet (publica)", f=f)
    draw_box(d, (460, 150, 700, 210), "aws_internet_gateway", f=f)
    draw_box(d, (740, 150, 950, 210), "aws_route_table\n0.0.0.0/0 -> IGW", f=f)
    draw_arrow(d, (420, 180), (460, 180))
    draw_arrow(d, (700, 180), (740, 180))

    draw_box(d, (100, 250, 420, 350), "aws_security_group\n- ingress 80/tcp 0.0.0.0/0\n- ingress 443/tcp 0.0.0.0/0\n- ingress 22/tcp 10.0.0.0/8",
              fill=(255, 235, 200), f=f, wrap=30)

    draw_box(d, (500, 260, 680, 330), "aws_instance\nweb-XXX", f=f)
    draw_box(d, (720, 260, 900, 330), "aws_instance\napp-XXX", f=f)
    draw_arrow(d, (420, 300), (500, 295))
    draw_arrow(d, (420, 300), (720, 295))
    draw_arrow(d, (260, 210), (260, 250))

    draw_box(d, (330, 440, 670, 520), "aws_cloudwatch_log_group\n+ metric_alarm (CPU) por servidor", fill=(225, 240, 255), f=f, wrap=36)
    draw_arrow(d, (590, 330), (550, 440), label="metricas")
    draw_arrow(d, (810, 330), (600, 440), label="metricas")

    img.save(OUT_DIR / "fig-02-arquitectura-aws.png")


# ---------------------------------------------------------------------------
# Figura 3: Arquitectura GCP
# ---------------------------------------------------------------------------

def fig_gcp():
    img, d = new_canvas(1050, 650, "Figura 3. Arquitectura GCP (por sucursal)")
    f = font("regular", 13)

    draw_frame(d, (60, 90, 990, 560), "google_compute_network (modo personalizado, por sucursal)",
              fill=(240, 245, 255), outline=BLUE)

    draw_box(d, (100, 150, 420, 210), "google_compute_subnetwork\n(regional)", f=f, wrap=28)
    draw_box(d, (460, 150, 680, 210), "google_compute_router", f=f)
    draw_box(d, (720, 150, 950, 210), "google_compute_router_nat", f=f)
    draw_arrow(d, (420, 180), (460, 180))
    draw_arrow(d, (680, 180), (720, 180))

    draw_box(d, (100, 250, 420, 350), "google_compute_firewall\n(una regla = un recurso)\n- ingress 80/tcp\n- ingress 443/tcp\n- ingress 22/tcp (10.0.0.0/8)",
              fill=(220, 235, 255), f=f, wrap=32)

    draw_box(d, (500, 260, 680, 330), "google_compute_instance\nweb-XXX", f=f, wrap=24)
    draw_box(d, (720, 260, 900, 330), "google_compute_instance\napp-XXX", f=f, wrap=24)
    draw_arrow(d, (420, 300), (500, 295))
    draw_arrow(d, (420, 300), (720, 295))
    draw_arrow(d, (260, 210), (260, 250))

    draw_box(d, (330, 440, 670, 520), "google_monitoring_alert_policy\nCPU > 80%", fill=(220, 245, 220), f=f, wrap=30)
    draw_arrow(d, (590, 330), (550, 440), label="metricas")
    draw_arrow(d, (810, 330), (600, 440), label="metricas")

    img.save(OUT_DIR / "fig-03-arquitectura-gcp.png")


# ---------------------------------------------------------------------------
# Figura 4: Estructura de modulos Terraform
# ---------------------------------------------------------------------------

def fig_modules():
    img, d = new_canvas(1050, 620, "Figura 4. Estructura de modulos Terraform")
    f = font("regular", 13)

    draw_box(d, (380, 80, 670, 140), "terraform/environments/\n{development,staging,production}", f=f, wrap=36, fill=LIGHT_GRAY)
    draw_arrow(d, (525, 140), (525, 180))
    draw_box(d, (380, 180, 670, 240), "modules/branch-stack", fill=(255, 244, 230), f=f)

    draw_box(d, (80, 320, 460, 400), "modules/aws/\nnetwork -> security -> compute -> monitoring", f=f, wrap=36, fill=(255, 235, 235))
    draw_box(d, (590, 320, 970, 400), "modules/gcp/\nnetwork -> security -> compute -> monitoring", f=f, wrap=36, fill=(230, 240, 255))
    draw_arrow(d, (460, 220), (270, 320))
    draw_arrow(d, (590, 220), (780, 320))

    draw_box(d, (80, 460, 460, 520), "config/branches/branches.yaml\n(fuente de verdad, 50 sucursales)", f=f, wrap=36, fill=LIGHT_GRAY)
    draw_arrow(d, (270, 400), (270, 460))
    draw_box(d, (590, 460, 970, 520), "scripts/generate_branches.py\n(genera branches.yaml, determinista)", f=f, wrap=36, fill=LIGHT_GRAY)
    draw_arrow(d, (780, 520), (780, 490))
    draw_arrow(d, (590, 490), (460, 490))

    img.save(OUT_DIR / "fig-04-estructura-modulos.png")


# ---------------------------------------------------------------------------
# Figura 5: Flujo CI/CD
# ---------------------------------------------------------------------------

def fig_cicd():
    img, d = new_canvas(1100, 500, "Figura 5. Flujo CI/CD (comun AWS + GCP)")
    f = font("regular", 12)
    steps = [
        "git push /\nPull Request",
        "terraform fmt\n-check",
        "terraform init\n-backend=false\n(x3 entornos)",
        "terraform\nvalidate",
        "validate_branches\n_schema.py",
        "terraform test\n(mock_provider)",
        "TFLint",
        "Checkov +\ngitleaks",
    ]
    x = 40
    y = 120
    w, h = 120, 90
    gap = 15
    centers = []
    for i, s in enumerate(steps):
        draw_box(d, (x, y, x + w, y + h), s, f=f, wrap=16, fill=LIGHT_GRAY if i % 2 == 0 else WHITE)
        centers.append((x + w, y + h / 2))
        if i > 0:
            draw_arrow(d, (centers[i - 1][0], y + h / 2), (x, y + h / 2))
        x += w + gap

    draw_box(d, (330, 260, 650, 340), "Revision humana via\nPull Request (checklist)", fill=(255, 244, 230), f=f, wrap=30)
    draw_arrow(d, (700, 210), (560, 260))

    draw_box(d, (330, 380, 650, 460), "Merge a main ->\nDespliegue autorizado\n(documentado, NO ejecutado:\nsin credenciales cloud)", fill=(255, 235, 235), f=f, wrap=34)
    draw_arrow(d, (490, 340), (490, 380))

    img.save(OUT_DIR / "fig-05-flujo-cicd.png")


# ---------------------------------------------------------------------------
# Figura 6: Gestion del Terraform State
# ---------------------------------------------------------------------------

def fig_state():
    img, d = new_canvas(1050, 560, "Figura 6. Gestion del Terraform State")
    f = font("regular", 13)

    draw_box(d, (80, 100, 460, 200), "AWS (diseno empresarial)\nS3 + versionado + SSE-KMS\n+ DynamoDB/locking nativo + IAM minimo privilegio",
              fill=(255, 235, 235), f=f, wrap=34)
    draw_box(d, (590, 100, 970, 200), "GCP (diseno empresarial)\nGCS + versionado + cifrado\n+ locking nativo + IAM minimo privilegio",
              fill=(230, 240, 255), f=f, wrap=34)

    draw_box(d, (330, 280, 720, 400), "Laboratorio local (lo que se ejecuta)\nbackend \"local\" + hashicorp/local + hashicorp/random\n"
              "init -> apply -> state list/show -> modificar -> plan -> apply -> destroy",
              fill=LIGHT_GRAY, f=f, wrap=46)
    draw_arrow(d, (270, 200), (450, 280), label="mismo mecanismo,\notro backend")
    draw_arrow(d, (780, 200), (600, 280))

    draw_box(d, (330, 460, 720, 540), "terraform.tfstate NUNCA se versiona\n(.gitignore); riesgo: contiene datos sensibles en texto plano",
              fill=(255, 244, 200), f=f, wrap=40)
    draw_arrow(d, (525, 400), (525, 460))

    img.save(OUT_DIR / "fig-06-terraform-state.png")


# ---------------------------------------------------------------------------
# Figura 7: Procedimiento de Infrastructure Drift
# ---------------------------------------------------------------------------

def fig_drift():
    img, d = new_canvas(1100, 460, "Figura 7. Procedimiento de Infrastructure Drift")
    f = font("regular", 12)
    steps = [
        "1. terraform\napply\n(crea recurso)",
        "2. Modificacion\nmanual fuera\nde Terraform",
        "3. terraform\nplan\n(detecta drift)",
        "4. plan\n-refresh-only\n(confirma)",
        "5. Decision:\nconservar o\nrevertir",
        "6. terraform\napply\n(reconcilia)",
        "7. Verificacion\nfinal",
    ]
    x = 40
    y = 150
    w, h = 130, 110
    gap = 20
    prev = None
    for i, s in enumerate(steps):
        fill = (255, 235, 235) if i == 1 else (220, 245, 220) if i == 5 else LIGHT_GRAY
        draw_box(d, (x, y, x + w, y + h), s, f=f, wrap=16, fill=fill)
        if prev:
            draw_arrow(d, (prev, y + h / 2), (x, y + h / 2))
        prev = x + w
        x += w + gap

    img.save(OUT_DIR / "fig-07-procedimiento-drift.png")


# ---------------------------------------------------------------------------
# Figura 8: Arquitectura del laboratorio local (Docker)
# ---------------------------------------------------------------------------

def fig_docker_lab():
    img, d = new_canvas(1000, 520, "Figura 8. Arquitectura del laboratorio local (Docker)")
    f = font("regular", 13)

    draw_frame(d, (70, 100, 470, 420), "sucursal-01-net", fill=(255, 245, 235), outline=RED)
    draw_box(d, (120, 170, 420, 260), "suc01-web01\nnginx:alpine - :8081", f=f, wrap=26)
    draw_box(d, (120, 300, 420, 390), "suc01-app01\nnginx:alpine - :8082", f=f, wrap=26)
    draw_arrow(d, (270, 260), (270, 300), label="conectividad\ninterna")

    draw_frame(d, (530, 100, 930, 420), "sucursal-02-net", fill=(235, 245, 255), outline=BLUE)
    draw_box(d, (580, 170, 880, 260), "suc02-web01\nnginx:alpine - :8091", f=f, wrap=26)
    draw_box(d, (580, 300, 880, 390), "suc02-app01\nnginx:alpine - :8092", f=f, wrap=26)
    draw_arrow(d, (730, 260), (730, 300), label="conectividad\ninterna")

    d.line([470, 260, 530, 260], fill=RED, width=2)
    d.text((500, 245), "X", fill=RED, font=font("bold", 16), anchor="mm")
    d.text((500, 460), "Sin conectividad entre redes (aislamiento)", fill=BLACK, font=f, anchor="mm")

    img.save(OUT_DIR / "fig-08-laboratorio-docker.png")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    fig_overview()
    fig_aws()
    fig_gcp()
    fig_modules()
    fig_cicd()
    fig_state()
    fig_drift()
    fig_docker_lab()
    print(f"Diagramas generados en {OUT_DIR}")


if __name__ == "__main__":
    main()
