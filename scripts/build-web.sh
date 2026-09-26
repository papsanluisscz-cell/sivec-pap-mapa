#!/usr/bin/env bash
# Arma la carpeta web/ que se publica como sitio (Vercel o Cloudflare Pages).
# El sistema es un solo archivo: SIVEC-PAP-sistema.html → web/index.html
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p web
cp SIVEC-PAP-sistema.html web/index.html
BUILD=$(date -u +%Y%m%d%H%M%S)
sed "s/__BUILD__/$BUILD/" scripts/sw.template.js > web/sw.js
echo "web/ lista (versión $BUILD)"
