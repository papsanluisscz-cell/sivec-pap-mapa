#!/usr/bin/env bash
# Sello de versión del SIVEC: huella digital (SHA-256) de cada archivo del sistema, con fecha y commit.
# Sirve como prueba de autoría y de qué versión se entregó a cada cliente. Uso: bash scripts/sello-version.sh
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION=$(grep -o "SIVEC_VERSION = '[^']*'" SIVEC-PAP-sistema.html | sed "s/SIVEC_VERSION = '//; s/ ·.*//; s/'//")
mkdir -p docs/empresa/versiones
OUT="docs/empresa/versiones/SIVEC-v${VERSION}-huellas.txt"
{
  echo "SIVEC PAP/VPH · versión ${VERSION}"
  echo "Fecha del sello: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Commit: $(git rev-parse HEAD 2>/dev/null || echo 'sin git')"
  echo "Autor: [[Nombre del autor]]"
  echo
  echo "SHA-256  archivo"
  sha256sum SIVEC-PAP-sistema.html SUPABASE-SQL.md scripts/*.sh scripts/*.js web/*.html web/*.js web/manifest.webmanifest 2>/dev/null
} > "$OUT"
echo "Sello guardado en $OUT"
