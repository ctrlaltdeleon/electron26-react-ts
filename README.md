# Electron + React + TypeScript Boilerplate

A compact Electron app with a Vite-powered React renderer and TypeScript on both sides.

## Requirements

- Node 18 (see `.nvmrc`)
- npm

## Quick start (online)

```bash
npm ci
npm run dev
```

## Essential scripts

- `npm run dev` — Vite dev server + TypeScript watch for Electron + Electron app
- `npm run build` — builds renderer and compiles Electron code
- `npm run dist:linux` — Linux packaging (AppImage, deb)
- `npm run dist:win` / `npm run dist:mac` — platform-specific packaging
- `npm run test` — Vitest (dev mode)
- `npm run test:run` — Vitest (CI mode)

## Offline workflow (Ubuntu 22)

These scripts create and use local caches for npm, Electron, and electron-builder.

### 1) On an online Ubuntu 22 machine

```bash
./make-offline-ready.sh --dist-linux
```

This creates a tarball like:

```
electron-react-ts-offline-YYYYMMDD-HHMMSS-gitsha.tar.gz
```

### 2) Transfer the tarball

Copy the tarball to the offline Ubuntu 22 machine and extract it.

### 3) On the offline machine

```bash
./use-offline-ready.sh
npm ci --offline --prefer-offline --no-audit
npm run dev
```

Notes:

- Use the same OS and CPU architecture as the online machine.
- The caches live in `.npm-cache/`, `.electron-cache/`, `.electron-builder-cache/`.

## Project layout (key parts)

```
dist/                # Build outputs (generated)
release/             # Packaged outputs (generated)
src/
  renderer/          # React app (entry: src/renderer/main.tsx)
  electron/          # Electron main + preload
index.html           # Renderer HTML (mounts React into #root)
vite.config.mts      # Vite config (ESM)
vitest.config.mts    # Vitest config (jsdom)
tsconfig.json        # Shared TS config
tsconfig.electron.json # Electron TS config (CommonJS output)
```

## Notes

- The Vite config is ESM (`vite.config.mts`) because `@vitejs/plugin-react` is ESM-only.
- `vitest.config.mts` uses `jsdom` so React tests can access `document`.
- `index.html` includes a CSP; tighten it for production (avoid `unsafe-*`).

## Security reminders

- Keep `contextIsolation: true` and `nodeIntegration: false`.
- Expose minimal APIs through `preload` only.
