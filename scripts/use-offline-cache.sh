#!/usr/bin/env bash
set -e

export npm_config_cache="$PWD/.offline-cache/npm"
export ELECTRON_CACHE="$PWD/.offline-cache/electron"
export ELECTRON_BUILDER_CACHE="$PWD/.offline-cache/electron-builder"

exec "$@"
