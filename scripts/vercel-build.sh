#!/usr/bin/env bash

set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.7}"
FLUTTER_DIR="${FLUTTER_DIR:-$PWD/flutter}"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"
FLUTTER_CACHE_DIR="${FLUTTER_CACHE_DIR:-$PWD/.vercel/flutter-cache}"
FLUTTER_ARCHIVE_PATH="${FLUTTER_CACHE_DIR}/${FLUTTER_ARCHIVE}"

: "${SUPABASE_URL:?SUPABASE_URL is required for Vercel builds}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY is required for Vercel builds}"
: "${GOOGLE_MAPS_API_KEY:?GOOGLE_MAPS_API_KEY is required for Vercel builds}"

mkdir -p "${FLUTTER_CACHE_DIR}"

CURRENT_FLUTTER_VERSION=""

if [ -f "${FLUTTER_DIR}/version" ]; then
  CURRENT_FLUTTER_VERSION="$(tr -d '[:space:]' < "${FLUTTER_DIR}/version")"
fi

if [ "${CURRENT_FLUTTER_VERSION}" != "${FLUTTER_VERSION}" ]; then
  rm -rf "${FLUTTER_DIR}"

  if [ ! -f "${FLUTTER_ARCHIVE_PATH}" ]; then
    curl -fsSL --retry 3 "${FLUTTER_URL}" -o "${FLUTTER_ARCHIVE_PATH}"
  fi

  tar -xJf "${FLUTTER_ARCHIVE_PATH}" -C "$(dirname "${FLUTTER_DIR}")"
fi

git config --global --add safe.directory "${FLUTTER_DIR}"

"${FLUTTER_DIR}/bin/flutter" --version
"${FLUTTER_DIR}/bin/flutter" config --enable-web
"${FLUTTER_DIR}/bin/flutter" precache --web
"${FLUTTER_DIR}/bin/flutter" pub get
"${FLUTTER_DIR}/bin/flutter" build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
  --dart-define=GOOGLE_MAPS_API_KEY="${GOOGLE_MAPS_API_KEY}"

sed -i "s|GOOGLE_MAPS_PLACEHOLDER|${GOOGLE_MAPS_API_KEY}|g" build/web/index.html
