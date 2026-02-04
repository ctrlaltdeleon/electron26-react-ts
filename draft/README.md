# Changes applied to get `npm run dev` and Electron working

This file summarizes the edits and commands I ran while diagnosing and fixing the errors you reported (missing `nf` shim and `react-scripts`/OpenSSL issues), and to make Electron open automatically when running the dev processes.

## High-level summary

- Fixed broken CLI shims under `node_modules/.bin` (`nf`, `react-scripts`, `electron`) by replacing their contents with small shell wrappers that execute the package CLIs via `node`.
- Ensured `foreman` (CLI `nf`) target exists; reinstalled/rebuilt packages where necessary.
- Upgraded `react-scripts` to a newer, compatible version to avoid OpenSSL 3 `ERR_OSSL_EVP_UNSUPPORTED` errors.
- Replaced the temporary `NODE_OPTIONS=--openssl-legacy-provider` workaround with `cross-env` and removed the prefix from the `start` script.
- Added an `electron` process to the `Procfile` and updated `public/electron-wait-react.js` so Electron waits for the React dev server (foreman assigns consecutive ports).
- Rebuilt the Electron native binary for Linux and, when needed, noted the system library fix (`libstdc++6`) to resolve GLIBCXX compatibility issues.
- Committed the changes to git.

## Files I changed

- node_modules/.bin/nf
- node_modules/.bin/react-scripts
- node_modules/.bin/electron
- public/electron-wait-react.js
- Procfile
- package.json (start script & added `cross-env` in devDependencies)

## Commands I ran (in project root)

- Inspect and print files (various `ls`, `sed`)
- `npm install --no-audit --no-fund --save-dev foreman@^3.0.1` (ensure foreman is present)
- `npm rebuild electron --update-binary` (fetch/update Linux Electron binary)
- `npm install --no-audit --no-fund --save-dev react-scripts@latest` (upgrade react-scripts)
- `npm install --no-audit --no-fund --save-dev cross-env` (for cross-platform env vars)
- Patched `node_modules/.bin/*` files with shell wrappers (replacing broken relative references)
- `npm run dev` (to start `nf`/foreman and verify React + Electron processes)
- `npm run electron` (to run Electron alone for debugging)
- `git add -A && git commit -m "chore: install cross-env; remove NODE_OPTIONS from start (react-scripts upgraded)"`

## How to run the dev environment

1. Start the dev processes (React + Electron managed by foreman):

```bash
cd /home/acdeleon/BRT/brt-frontend
npm run dev
```

Let the command run (don’t press Ctrl+C). `nf` will start both the React process (webpack dev server) and the Electron wait script; once React compiles, Electron will open automatically.

2. To run Electron separately (after React is serving):

```bash
npm run electron
```

## Notes and troubleshooting

- If Electron fails with a `GLIBCXX_3.4.29 not found` (or similar) error, upgrade the host `libstdc++6`:

```bash
sudo apt-get update
sudo apt-get install -y libstdc++6
```

This is a host/VM dependency; I rebuilt the electron binary during the troubleshooting, but the system libs must be compatible.

- You may still see harmless warnings such as `MaxListenersExceededWarning` or webpack/webpack-dev-server deprecation warnings; they do not prevent the app from working.

## How to revert my changes

- To revert everything I changed in the repository, use git to reset to the previous commit or discard files you don't want:

```bash
git log --oneline
git revert <commit-hash>   # or
git checkout -- <file>     # to restore specific files
```

If you want me to move this summary into the project's main `README.md` or to a changelog file, I can do that.

---

If you'd like, I can now:

- Remove the temporary bin-wrapper edits and reinstall node_modules cleanly, or
- Tidy up commits and create a small changelog entry, or
- Add a short developer note to the main `README.md` linking to this file.

Tell me which you prefer.
