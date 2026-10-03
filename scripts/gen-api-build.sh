#!/usr/bin/env bash
# Paso 2 de la generación del cliente: build_runner (json_serializable) en el paquete generado.
# Ejecutar en Windows (Git Bash) o en CI, con Flutter en el PATH.
set -euo pipefail
cd "$(dirname "$0")/../app/packages/faro_api"
dart pub get
dart run build_runner build --delete-conflicting-outputs
