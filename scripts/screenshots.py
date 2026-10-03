"""Capturas con el usuario demo (Playwright + Chromium headless).

Requisitos: la API local con los datos demo (`python -m app.demo --reset`) y la web compilada con
`--dart-define=API_ORIGIN=http://localhost:8100` servida en http://localhost:5050.

Dos modos:

    py scripts/screenshots.py [--out public/screenshots] [--theme dark]   # las 5 del README
    py scripts/screenshots.py --audit fase0-antes [--only gastos,planes] [--sizes movil,escritorio]
    py scripts/screenshots.py --audit texto-130 --text-scale 1.3     # texto del sistema al 130 %

El modo auditoría recorre todas las rutas principales en 4 anchos (390×844, 820×1180, 1440×900 y
1920×1080) y en los dos temas. Por cada ruta guarda lo que se ve en pantalla y, además, una captura
"larga" (misma anchura, alto grande) con la pantalla entera. Salida en `data/ui-shots/<etiqueta>/`
(git-ignored: son cientos de imágenes; solo usan el usuario demo).
"""

import argparse
import json
import urllib.request
from pathlib import Path

from playwright.sync_api import sync_playwright

BASE = "http://localhost:5050"
API = "http://localhost:8100/api"
EMAIL, PASSWORD = "demo@faro.example", "demo-faro-2026"  # usuario demo local (app/demo.py)

README_SIZE = {"width": 412, "height": 915}
README_SHOTS = [
    ("1-expenses", "/gastos"),
    ("2-months", "/gastos/meses"),
    ("3-investments", "/inversiones"),
    ("4-net-worth", "/patrimonio"),
    ("5-fire", "/planes/independencia"),
]

SIZES = {
    "movil": (390, 844),
    "tablet": (820, 1180),
    "escritorio": (1440, 900),
    "grande": (1920, 1080),
}
TALL = 2600  # alto de la captura larga

# (nombre, ruta, pestaña a pulsar o None). "{asset}" se sustituye por el primer activo con posición.
# Desde la fase 1 del rediseño las pestañas de Planes son rutas; las de antes (`/planes` + pestaña)
# siguen funcionando por redirección.
ROUTES = [
    ("gastos", "/gastos", None),
    ("gastos-meses", "/gastos/meses", None),
    ("gastos-meses-resumen", "/gastos/meses/resumen", None),
    ("gastos-estadisticas", "/gastos/estadisticas", None),
    ("gastos-compromisos", "/gastos/compromisos", None),
    ("gastos-gestionar", "/gastos/gestionar", None),
    ("gastos-fraccionadas", "/gastos/fraccionadas", None),
    ("gastos-recurrentes", "/gastos/recurrentes", None),
    ("gastos-fijos", "/gastos/fijos", None),
    ("gastos-cuentas", "/gastos/cuentas", None),
    ("gastos-personas", "/gastos/personas", None),
    ("gastos-deudas", "/gastos/deudas", None),
    ("gastos-seguimientos", "/gastos/seguimientos", None),
    ("gastos-categorias", "/gastos/categorias", None),
    ("gastos-ciclos", "/gastos/ciclos", None),
    ("gastos-importar", "/gastos/importar", None),
    ("gastos-ajustes", "/gastos/ajustes", None),
    ("inversiones", "/inversiones", None),
    ("inversiones-activo", "/inversiones/activo/{asset}", None),
    ("inversiones-aportar", "/inversiones/aportar", None),
    ("inversiones-rendimiento", "/inversiones/rendimiento", None),
    ("inversiones-aportaciones", "/inversiones/aportaciones", None),
    ("inversiones-operaciones", "/inversiones/operaciones", None),
    ("inversiones-gestionar", "/inversiones/gestionar", None),
    ("inversiones-objetivos", "/inversiones/objetivos", None),
    ("inversiones-activos", "/inversiones/activos", None),
    ("inversiones-periodicas", "/inversiones/periodicas", None),
    ("inversiones-exposicion", "/inversiones/exposicion", None),
    ("inversiones-plataformas", "/inversiones/plataformas", None),
    ("inversiones-importar", "/inversiones/importar", None),
    ("importar-tutorial", "/inversiones/importar?fuente=myinvestor&paso=2", None),
    ("importar-subir", "/gastos/importar?fuente=banco&paso=3", None),
    ("inversiones-ajustes", "/inversiones/ajustes", None),
    ("patrimonio", "/patrimonio", None),
    ("patrimonio-evolucion", "/patrimonio/evolucion", None),
    ("patrimonio-informe-fiscal", "/patrimonio/informe-fiscal", None),
    ("planes-independencia", "/planes/independencia", None),
    ("planes-supuestos", "/planes/independencia/supuestos", None),
    ("planes-comparar", "/planes/independencia/comparar", None),
    ("planes-interes-compuesto", "/planes/interes-compuesto", None),
    ("planes-objetivos", "/planes/objetivos", None),
    ("planes-impuestos", "/planes/impuestos", None),
    ("planes-revision", "/planes/revision", None),
    ("mas", "/mas", None),
]


def first_asset_id() -> str:
    """Primer activo con posición del usuario demo (para la ficha de activo)."""
    req = urllib.request.Request(
        f"{API}/auth/login",
        data=json.dumps({"email": EMAIL, "password": PASSWORD}).encode(),
        headers={"content-type": "application/json", "X-Faro-Client": "android"},
    )
    token = json.load(urllib.request.urlopen(req))["access_token"]
    req = urllib.request.Request(f"{API}/inv/portfolio", headers={"Authorization": f"Bearer {token}"})
    portfolio = json.load(urllib.request.urlopen(req))
    for c in portfolio["classes"]:
        for p in c["positions"]:
            if p["units"] not in ("0", "0.0000000000"):
                return p["asset"]["id"]
    raise SystemExit("El usuario demo no tiene posiciones")


def login(page) -> None:
    """Flutter dibuja en un canvas: se activa la capa de accesibilidad para tener campos reales."""
    page.goto(f"{BASE}/#/login")
    page.wait_for_selector("flt-semantics-placeholder", state="attached", timeout=30000)
    page.wait_for_timeout(800)
    page.evaluate("document.querySelector('flt-semantics-placeholder').click()")
    page.wait_for_timeout(800)
    boxes = page.get_by_role("textbox")
    for box, text in ((boxes.nth(0), EMAIL), (boxes.nth(1), PASSWORD)):
        box.click()
        page.wait_for_timeout(500)  # sin esta pausa se pierde la primera tecla
        page.keyboard.type(text, delay=40)
    page.keyboard.press("Enter")
    page.wait_for_function("location.hash.startsWith('#/gastos')", timeout=30000)
    page.wait_for_timeout(2500)


def set_text_scale(page, scale: float) -> None:
    """Texto del sistema más grande: Flutter web toma la escala del tamaño de letra de <html> (16 px
    = 100 %) y la sigue al cambiar, igual que con el zoom de texto del navegador."""
    if scale != 1:
        page.evaluate(f"document.documentElement.style.fontSize = '{16 * scale}px'")
        page.wait_for_timeout(800)


def set_theme(page, theme: str) -> None:
    """Faro es oscuro por defecto (no sigue al sistema): el tema se elige en Tú → Apariencia y se
    recuerda en el navegador."""
    if theme != "light":
        return
    goto(page, "/mas", None)
    page.get_by_role("button", name="Claro", exact=True).click()
    page.wait_for_timeout(1200)


def goto(page, route: str, tab: str | None) -> None:
    page.evaluate(f"location.hash = '#{route}'")
    page.wait_for_load_state("networkidle")
    page.wait_for_timeout(2500)
    if tab:
        page.get_by_role("tab", name=tab).click()
        page.wait_for_timeout(1800)
    page.mouse.move(0, 0)  # sin tooltips ni hover


def readme(args) -> None:
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport=README_SIZE, device_scale_factor=2, color_scheme=args.theme,
                                locale="es-ES", timezone_id="Atlantic/Canary")
        login(page)
        set_theme(page, args.theme)
        for name, route in README_SHOTS:
            goto(page, route, None)
            page.screenshot(path=str(out / f"{name}.png"))
            print("ok", name)
        browser.close()


def audit(args) -> None:
    root = Path("data/ui-shots") / args.audit
    only = set(args.only.split(",")) if args.only else None
    routes = [r for r in ROUTES if not only or any(r[0].startswith(o) for o in only)]
    sizes = args.sizes.split(",") if args.sizes else list(SIZES)
    asset = first_asset_id()
    with sync_playwright() as p:
        browser = p.chromium.launch()
        for theme in (args.themes.split(",") if args.themes else ("dark", "light")):
            for size in sizes:
                w, h = SIZES[size]
                out = root / f"{size}-{theme}"
                out.mkdir(parents=True, exist_ok=True)
                ctx = browser.new_context(viewport={"width": w, "height": h}, color_scheme=theme,
                                          locale="es-ES", timezone_id="Atlantic/Canary")
                page = ctx.new_page()
                login(page)
                set_theme(page, theme)
                set_text_scale(page, args.text_scale)
                for name, route, tab in routes:
                    if args.skip_existing and (out / f"{name}.png").exists():
                        continue
                    try:
                        page.set_viewport_size({"width": w, "height": h})
                        goto(page, route.replace("{asset}", asset), tab)
                        page.screenshot(path=str(out / f"{name}.png"))
                        if not args.no_tall:
                            page.set_viewport_size({"width": w, "height": max(h, TALL)})
                            page.wait_for_timeout(1500)
                            page.screenshot(path=str(out / f"{name}--larga.png"))
                        print("ok", size, theme, name, flush=True)
                    except Exception as e:  # una ruta rota no para el resto
                        print("ERROR", size, theme, name, type(e).__name__, str(e)[:120], flush=True)
                ctx.close()
        browser.close()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="public/screenshots")
    ap.add_argument("--theme", default="dark", choices=["dark", "light"])
    ap.add_argument("--audit", metavar="ETIQUETA", help="modo auditoría: todas las rutas, 4 anchos, 2 temas")
    ap.add_argument("--only", help="prefijos de nombre separados por comas (p. ej. gastos,planes)")
    ap.add_argument("--sizes", help=f"subconjunto de {','.join(SIZES)}")
    ap.add_argument("--themes", help="dark,light (por defecto los dos)")
    ap.add_argument("--skip-existing", action="store_true", help="no repite las capturas que ya existen")
    ap.add_argument("--no-tall", action="store_true", help="sin la captura larga")
    ap.add_argument("--text-scale", type=float, default=1, help="tamaño del texto del sistema (1.3 = 130 %%)")
    args = ap.parse_args()
    if args.audit:
        audit(args)
    else:
        readme(args)


if __name__ == "__main__":
    main()
