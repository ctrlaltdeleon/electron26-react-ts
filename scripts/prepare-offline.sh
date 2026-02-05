#!/usr/bin/env bash
set -euo pipefail

################################################################################
#  WHEN TO USE THIS SCRIPT
################################################################################
#
#  Use this on a machine WITH INTERNET to pre-download and cache everything.
#  Then you can move the repo to a machine WITHOUT internet and still build.
#
#  Example scenario:
#    1. You're at home with WiFi
#    2. You run: ./scripts/prepare-offline.sh --dist-linux --clean
#    3. Script downloads npm packages, Electron, electron-builder into .offline-cache/
#    4. You commit and push to repo (includes .offline-cache/)
#    5. You copy repo to a laptop in the field (no internet)
#    6. On that laptop: ./scripts/use-offline-cache.sh npm ci
#       → Works! Uses .offline-cache/ instead of internet
#
################################################################################

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
DO_DIST_WIN=0
DO_DIST_MAC=0
DO_CLEAN=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/prepare-offline.sh [options]

Options:
  --dist-linux     Also run: npm run dist:linux  (warms electron-builder deeper)
  --dist-win       Also run: npm run dist:win    (warms electron-builder deeper)
  --dist-mac       Also run: npm run dist:mac    (warms electron-builder deeper)
  --clean          Remove node_modules, dist, release before seeding
  --help           Show this help

⚠️  IMPORTANT: Each --dist-* flag MUST RUN ON ITS NATIVE OS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  --dist-linux   → Run this script on LINUX only
  --dist-win     → Run this script on WINDOWS only
  --dist-mac     → Run this script on MACOS only

Reason: Build tools are OS-specific (MSBuild for Windows, clang for macOS, etc.)

Example workflow:
  1. On Linux machine (with internet):
     ./scripts/prepare-offline.sh --dist-linux --clean
  2. On Windows machine (with internet):
     ./scripts/prepare-offline.sh --dist-win --clean
  3. On macOS machine (with internet):
     ./scripts/prepare-offline.sh --dist-mac --clean
  4. Each generates platform-specific caches in .offline-cache/
  5. Commit/push the updated .offline-cache/ to repo

What it does:
  - Forces npm/electron/electron-builder caches into .offline-cache/
  - Runs npm ci and npm run build (and optionally platform-specific dist)
  
  Result: Your repo will have all dependencies cached locally (.offline-cache/)
          You can then transfer the entire repo to an offline machine (same OS).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dist-linux) DO_DIST_LINUX=1; shift ;;
    --dist-win) DO_DIST_WIN=1; shift ;;
    --dist-mac) DO_DIST_MAC=1; shift ;;
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
elif [[ "${DO_DIST_WIN}" -eq 1 ]]; then
  echo "==> Building Windows artifacts (electron-builder) to warm deeper caches..."
  npm run dist:win
elif [[ "${DO_DIST_MAC}" -eq 1 ]]; then
  echo "==> Building macOS artifacts (electron-builder) to warm deeper caches..."
  npm run dist:mac
else
  echo "==> Skipping dist:* (use --dist-linux, --dist-win, or --dist-mac to include)"
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
