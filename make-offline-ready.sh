#!/usr/bin/env bash
set -euo pipefail

# make-offline-ready.sh
# Run on ONLINE Ubuntu 22 to create an offline-ready tarball for Ubuntu 22.
#
# Usage:
#   ./make-offline-ready.sh
#   ./make-offline-ready.sh --dist-linux   # warms packaging caches too (recommended)
#   ./make-offline-ready.sh --dist         # runs your npm run dist
#   ./make-offline-ready.sh --out /path/to/output-dir
# Output (auto-named) in offline-transfers/ by default:
#   electron-react-ts-offline-YYYYMMDD-HHMMSS-gitsha.tar.gz

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { printf "\n==> %s\n" "$*"; }
die() { printf "\nERROR: %s\n" "$*" >&2; exit 1; }

DO_DIST=0
DO_DIST_LINUX=0
OUT_DIR="$ROOT/offline-transfers"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dist) DO_DIST=1 ;;
    --dist-linux) DO_DIST_LINUX=1 ;;
    --out)
      shift
      [[ $# -gt 0 ]] || die "--out requires a directory path"
      OUT_DIR="$1"
      ;;
    -h|--help)
      cat <<'EOF'
make-offline-ready.sh

Creates an offline-ready tarball for an Electron + React + TS project.

Usage:
  ./make-offline-ready.sh
  ./make-offline-ready.sh --dist-linux     # recommended: warms electron-builder caches for Linux packaging
  ./make-offline-ready.sh --dist           # runs npm run dist
  ./make-offline-ready.sh --out /path/to/output-dir

Output is auto-named (defaults to offline-transfers/):
  electron-react-ts-offline-YYYYMMDD-HHMMSS-gitsha.tar.gz
EOF
      exit 0
      ;;
    *)
      die "Unknown arg: $1 (use --help)"
      ;;
  esac
  shift
done

cd "$ROOT"
[[ -f "$ROOT/package.json" ]] || die "Run this from project root (package.json not found)."

command -v node >/dev/null 2>&1 || die "Node is not installed or not on PATH."
command -v npm  >/dev/null 2>&1 || die "npm is not installed or not on PATH."

NODE_VER="$(node -v | sed 's/^v//')"
NODE_MAJOR="${NODE_VER%%.*}"
[[ "$NODE_MAJOR" == "18" ]] || die "Node must be 18.x (found v$NODE_VER)."

say "Node OK: v$NODE_VER"
say "npm  OK:  v$(npm -v)"

# Best-effort: stop common watch processes so tar doesn't see files changing mid-archive
say "Stopping common dev/watch processes (best effort)"
pkill -f "vite" 2>/dev/null || true
pkill -f "electron" 2>/dev/null || true
pkill -f "tsc -p" 2>/dev/null || true
pkill -f "tsc" 2>/dev/null || true

# 1) Clean install once (ensures lockfile tree resolves)
say "Clean install (npm ci)"
rm -rf node_modules
npm ci

# 2) Create/fill project-local npm cache
say "Creating/filling project-local npm cache (.npm-cache)"
mkdir -p "$ROOT/.npm-cache"
npm config set cache "$ROOT/.npm-cache" --location=project >/dev/null

rm -rf node_modules
npm ci

# 3) Create/fill Electron + electron-builder caches
say "Creating Electron caches"
mkdir -p "$ROOT/.electron-cache" "$ROOT/.electron-builder-cache"

export ELECTRON_CACHE="$ROOT/.electron-cache"
export ELECTRON_BUILDER_CACHE="$ROOT/.electron-builder-cache"

say "Running build to warm caches"
npm run build

if [[ "$DO_DIST_LINUX" -eq 1 ]]; then
  say "Running dist:linux to fully warm electron-builder caches (recommended)"
  npm run dist:linux
elif [[ "$DO_DIST" -eq 1 ]]; then
  say "Running dist to warm electron-builder caches"
  npm run dist
else
  say "Skipping dist step (pass --dist-linux for best offline packaging readiness)"
fi

# 4) Auto-name archive with timestamp + git commit hash
say "Preparing archive name"
TS="$(date +%Y%m%d-%H%M%S)"

GIT_SHA="nogit"
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # short SHA (8 chars)
  GIT_SHA="$(git rev-parse --short=8 HEAD 2>/dev/null || echo nogit)"
fi

ARCHIVE_NAME="electron-react-ts-offline-${TS}-${GIT_SHA}.tar.gz"
mkdir -p "$OUT_DIR"
ARCHIVE_PATH="$OUT_DIR/$ARCHIVE_NAME"

say "Creating tarball: $ARCHIVE_NAME"

# Correct tar ordering: excludes BEFORE '.' and use ./ paths for clarity
tar -czf "$ARCHIVE_PATH" \
  --exclude=./node_modules \
  --exclude=./dist \
  --exclude=./release \
  --exclude=./.git \
  --exclude=./coverage \
  --exclude=./.vite \
  --exclude=./.cache \
  .

say "Tarball created: $ARCHIVE_PATH"
say "Included caches (sizes):"
du -sh "$ROOT/.npm-cache" "$ROOT/.electron-cache" "$ROOT/.electron-builder-cache" 2>/dev/null || true

say "Done."
