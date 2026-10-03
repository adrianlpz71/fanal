"""Iconos de Fanal (opción B: el fanal sobre el horizonte, con su reflejo en el agua).

Un solo dibujo (coordenadas 0..104) y de él salen todos los tamaños:
  · app/assets/brand/*.svg      fuentes vectoriales (icono, capas del icono adaptativo)
  · Android: ic_launcher.png (heredado) y capas del icono adaptativo (fondo + primer plano)
  · Web: Icon-192/512, Icon-maskable-192/512 y favicon
  · App: assets/brand/fanal-128.png (logo de la barra superior)

    py scripts/brand_icons.py        (necesita Playwright con Chromium)
"""

from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1] / "app"
TEAL, SEA, LIGHT, PAPER = "#0E5E6F", "#0A4855", "#FFD36E", "#F4F1E8"

# El fanal, los haces y el reflejo (sin fondo), en el espacio 0..104 del icono
FANAL = f"""
<polygon points="37,42 6,31 6,59 37,52" fill="{LIGHT}" opacity="0.35"/>
<polygon points="67,42 98,31 98,59 67,52" fill="{LIGHT}" opacity="0.35"/>
<rect x="42" y="82" width="20" height="3.5" rx="1.5" fill="{LIGHT}" opacity="0.75"/>
<rect x="45" y="89" width="14" height="3.5" rx="1.5" fill="{LIGHT}" opacity="0.55"/>
<rect x="48" y="96" width="8" height="3.5" rx="1.5" fill="{LIGHT}" opacity="0.35"/>
<path d="M36 34 Q52 16 68 34 Z" fill="{PAPER}"/>
<circle cx="52" cy="19" r="2.5" fill="{PAPER}"/>
<rect x="33" y="34" width="38" height="4" rx="1" fill="{PAPER}"/>
<rect x="37" y="38" width="30" height="22" fill="{LIGHT}"/>
<line x1="47" y1="38" x2="47" y2="60" stroke="{TEAL}" stroke-width="2.2"/>
<line x1="57" y1="38" x2="57" y2="60" stroke="{TEAL}" stroke-width="2.2"/>
<rect x="31" y="60" width="42" height="5" rx="1" fill="{PAPER}"/>
<rect x="39" y="65" width="26" height="13" fill="{PAPER}"/>
"""


def svg(body: str, view: int = 104) -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {view} {view}">{body}</svg>'


# Icono completo con las esquinas redondeadas (lanzadores sin icono adaptativo, web, logo)
ICON = svg(
    f'<rect width="104" height="104" rx="22" fill="{TEAL}"/>'
    f'<path d="M0 78 H104 V82 Q104 104 82 104 H22 Q0 104 0 82 Z" fill="{SEA}"/>' + FANAL
)
# A sangre (sin esquinas): para máscaras de la web (la zona segura es el círculo central del 80 %)
BLEED = svg(f'<rect width="104" height="104" fill="{TEAL}"/><rect y="78" width="104" height="26" fill="{SEA}"/>' + FANAL)
# Icono adaptativo de Android: lienzo de 108 dp; se ve el centro (72 dp) y la zona segura es de
# 66 dp. El dibujo de 104 se encaja en los 72 dp visibles.
K = 72 / 104
ADAPTIVE_BG = svg(f'<rect width="108" height="108" fill="{TEAL}"/>'
                  f'<rect y="{18 + 78 * K:.2f}" width="108" height="{108 - 18 - 78 * K:.2f}" fill="{SEA}"/>', 108)
ADAPTIVE_FG = svg(f'<g transform="translate(18 18) scale({K:.4f})">{FANAL}</g>', 108)

DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def render(page, source: str, size: int, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    page.set_viewport_size({"width": size, "height": size})
    page.set_content(
        "<html><body style='margin:0;background:transparent'>"
        + source.replace("<svg ", f'<svg width="{size}" height="{size}" ', 1)
        + "</body></html>"
    )
    page.screenshot(path=str(out), omit_background=True, clip={"x": 0, "y": 0, "width": size, "height": size})


def main() -> None:
    brand = ROOT / "assets" / "brand"
    brand.mkdir(parents=True, exist_ok=True)
    for name, s in {"fanal.svg": ICON, "fanal-bleed.svg": BLEED,
                    "fanal-adaptive-bg.svg": ADAPTIVE_BG, "fanal-adaptive-fg.svg": ADAPTIVE_FG}.items():
        (brand / name).write_text(s, encoding="utf-8")
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        for d, k in DENSITIES.items():
            render(page, ICON, round(48 * k), res / f"mipmap-{d}" / "ic_launcher.png")
            render(page, ADAPTIVE_BG, round(108 * k), res / f"mipmap-{d}" / "ic_launcher_background.png")
            render(page, ADAPTIVE_FG, round(108 * k), res / f"mipmap-{d}" / "ic_launcher_foreground.png")
        web = ROOT / "web"
        render(page, ICON, 192, web / "icons" / "Icon-192.png")
        render(page, ICON, 512, web / "icons" / "Icon-512.png")
        render(page, BLEED, 192, web / "icons" / "Icon-maskable-192.png")
        render(page, BLEED, 512, web / "icons" / "Icon-maskable-512.png")
        render(page, ICON, 64, web / "favicon.png")
        render(page, ICON, 128, brand / "fanal-128.png")
        browser.close()
    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<!-- Icono adaptativo (Android 8+): fondo con el mar y el fanal en primer plano. -->\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n',
        encoding="utf-8",
    )
    print("ok")


if __name__ == "__main__":
    main()
