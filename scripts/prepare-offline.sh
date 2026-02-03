#!/usr/bin/env bash
set -euo pipefail

# prepare-offline.sh
# Pre-warm npm + Electron + electron-builder caches into .offline-cache/
# so the repo can be moved to an offline dev machine and still build/run.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CACHE_ROOT="${ROOT_DIR}/.offline-cache"
NPM_CACHE="${CACHE_ROOT}/npm"
ELECTRON_CACHE="${CACHE_ROOT}/electron"
EB_CACHE="${CACHE_ROOT}/electron-builder"

DO_DIST_LINUX=0
DO_CLEAN=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/prepare-offline.sh [options]

Options:
  --dist-linux     Also run: npm run dist:linux  (warms electron-builder deeper)
  --clean          Remove node_modules, dist, release before seeding
  --help           Show this help

What it does:
  - Forces npm/electron/electron-builder caches into .offline-cache/
  - Runs npm ci and npm run build (and optionally dist:linux)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dist-linux) DO_DIST_LINUX=1; shift ;;
    --clean) DO_CLEAN=1; shift ;;
    --help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

echo "==> Repo root: ${ROOT_DIR}"
echo "==> Cache root: ${CACHE_ROOT}"

mkdir -p "${NPM_CACHE}" "${ELECTRON_CACHE}" "${EB_CACHE}"

# Force caches into the repo (project-local)
export npm_config_cache="${NPM_CACHE}"
export ELECTRON_CACHE="${ELECTRON_CACHE}"
export ELECTRON_BUILDER_CACHE="${EB_CACHE}"

# Make installs more deterministic + quieter in controlled envs
export npm_config_audit=false
export npm_config_fund=false

# Sanity checks
command -v node >/dev/null 2>&1 || { echo "ERROR: node not found"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "ERROR: npm not found"; exit 1; }

echo "==> Node: $(node -v)"
echo "==> npm:  $(npm -v)"

if [[ ! -f package-lock.json ]]; then
  echo "ERROR: package-lock.json not found. This script expects npm lockfiles."
  exit 1
fi

if [[ "${DO_CLEAN}" -eq 1 ]]; then
  echo "==> Cleaning build outputs + node_modules..."
  rm -rf node_modules dist release
fi

echo "==> Installing deps (npm ci) with project-local cache..."
npm ci

echo "==> Building (renderer + electron)..."
npm run build

if [[ "${DO_DIST_LINUX}" -eq 1 ]]; then
  echo "==> Building Linux artifacts (electron-builder) to warm deeper caches..."
  npm run dist:linux
else
  echo "==> Skipping dist:linux (use --dist-linux to include)"
fi

echo
echo "✅ Offline prep complete."
echo "You can now copy these to your offline machine:"
echo "  - the entire repo folder"
echo "  - .offline-cache/ (already inside the repo)"
echo
echo "Next on OFFLINE machine, from repo root:"
echo "  ./scripts/use-offline-cache.sh npm ci --prefer-offline --no-audit"
echo "  ./scripts/use-offline-cache.sh npm run dev"
