#!/usr/bin/env bash
# Paso 1 de la generación del cliente Dart de la API (ejecutar en WSL/Linux, raíz del repo):
#   1) vuelca backend/openapi.json desde la app FastAPI (sin arrancar servidor)
#   2) genera el cliente con openapi-generator (dart-dio + json_serializable) en Docker
#   3) lo sincroniza en app/packages/faro_api (conservando .dart_tool de Windows)
# Paso 2: scripts/gen-api-build.sh (build_runner), en Windows o CI.
# La CI ejecuta ambos y falla si el resultado difiere de lo commiteado.
set -euo pipefail
cd "$(dirname "$0")/.."

GEN_VERSION="v7.10.0"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

# Construir la imagen ANTES y con la salida a stderr: si `run` tuviera que construirla, su log
# acabaría dentro de openapi.json (pasó en la CI, donde la imagen no existe).
docker compose -f infra/compose.yaml build -q api >&2
docker compose -f infra/compose.yaml run --rm --no-deps -T api python - > backend/openapi.json <<'PY'
import json
from app.main import app
spec = app.openapi()
# dart-dio no sabe generar anyOf[string, integer] (ValidationError.loc de FastAPI):
# para el cliente basta con "cualquier valor".
spec["components"]["schemas"]["ValidationError"]["properties"]["loc"]["items"] = {}
# dart-dio genera código inválido para enums con valor por defecto ("Enums can't be
# instantiated"): se quita el default en el cliente. El servidor conserva el suyo y el cliente
# omite los campos nulos (includeIfNull: false), así que el resultado es el mismo.
for schema in spec["components"]["schemas"].values():
    for prop in schema.get("properties", {}).values():
        if "enum" in prop:
            prop.pop("default", None)
        # Defaults de lista/diccionario: dart-dio genera `= []` no constante (no compila)
        if isinstance(prop.get("default"), (list, dict)):
            prop.pop("default")
print(json.dumps(spec, indent=2, ensure_ascii=False))
PY

docker run --rm -u "$(id -u):$(id -g)" -v "$PWD/backend":/spec:ro -v "$OUT":/out \
  "openapitools/openapi-generator-cli:${GEN_VERSION}" generate \
  -i /spec/openapi.json \
  -g dart-dio \
  -o /out \
  --additional-properties=pubName=faro_api,pubLibrary=faro_api,serializationLibrary=json_serializable,dateLibrary=core,nullableFields=true \
  --type-mappings=decimal=String \
  --skip-validate-spec >/dev/null

# Dinero: format "decimal" → String (por defecto lo genera como double: prohibido para
# importes). La app lo convierte a Decimal (core/money.dart).
# El generador fija sdk >=2.17, pero json_serializable actual emite sintaxis de Dart 3.8
# (null-aware elements): se sube la restricción del paquete generado.
sed -i "s/sdk: '>=2.17.0 <4.0.0'/sdk: '>=3.8.0 <4.0.0'/" "$OUT/pubspec.yaml"
grep -q "sdk: '>=3.8.0" "$OUT/pubspec.yaml"

mkdir -p app/packages/faro_api
rsync -a --delete --exclude .dart_tool --exclude pubspec.lock --exclude .packages \
  "$OUT"/ app/packages/faro_api/

echo "Cliente generado. Paso 2 (Windows/CI): scripts/gen-api-build.sh"
