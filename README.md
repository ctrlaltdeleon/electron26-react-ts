# Electron 26 + React + TypeScript (concise)

A compact starter for an Electron app with a Vite-powered React renderer and TypeScript for both renderer and Electron code.

Quick overview

- Renderer: React + Vite (dev server, ES modules)
- Main: Electron main process (CommonJS output)
- Preload: Secure bridge exposing minimal APIs to the renderer

What changed / notes

- Renderer built to `dist/renderer`; Electron main/preload compiled to `dist/`.
- `index.html` is the renderer entry and mounts React into `#root`.
- `tsconfig.json` is the shared config; `tsconfig.electron.json` overrides for main/preload.
- Vite `base: "./"` keeps built files relative for packaged apps.
- CSP is present in `index.html` — tighten for production (avoid `unsafe-inline`).

Essential scripts

- `npm run dev` — starts Vite, tsc watch for Electron, and Electron (development)
- `npm run build` — builds renderer and compiles Electron code
- `npm run dist:linux` — builds and packages Linux artifacts (AppImage, deb)
- `npm run dist:win` / `npm run dist:mac` — platform-specific packaging

Project layout (important parts)

```
src/
  renderer/      # React app (entry: src/renderer/main.tsx)
  electron/      # Electron main process (electron.ts)
  preload/       # Preload scripts (expose safe APIs)
index.html       # Renderer HTML; mounts to #root and loads /src/renderer/main.tsx
vite.config.ts   # Vite config (renderer)
tsconfig.json    # Shared TypeScript config
tsconfig.electron.json # Electron-specific config (CommonJS, outDir: dist)
package.json     # Scripts, deps, and electron-builder config
release/         # Packaged outputs (generated)
dist/            # Build outputs (generated)
```

Security & best practices (short)

- Use `contextIsolation: true` and `nodeIntegration: false` in the main process.
- Keep native/privileged APIs inside `preload` and expose minimal surface area.
- Audit CSP in `index.html` and remove `unsafe-*` entries for production builds.

Dev tips

- If dev works but packaged app is blank, check `index.html` paths, CSP, and preload API availability.
- When switching OS/machine, delete `node_modules` and re-run `npm install`.
- Use `npm audit` and `npm outdated` regularly.

Further improvements (suggested next steps)

- Add ESLint + Prettier and pre-commit hooks.
- Add CI workflow to lint, test, and build artifacts.
- Consider `dependabot` or `renovate` for automated dependency updates.

Contact / extend

This README is intentionally short. If you want, I can:

- Annotate `package.json` scripts and `build` config inline
- Add a small CI workflow
- Add ESLint and Husky scaffolding
