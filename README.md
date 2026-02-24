# Electron 26 + React + TypeScript Boilerplate (Linux-friendly)

This is a **minimal, clean boilerplate** for building an **Electron app with React and TypeScript**, pinned to **Electron 26.0.0**, and designed to work **reliably on Linux (Ubuntu 22.04)** as well as Windows/macOS.

The goal of this repo is:

- predictable behavior across OSes
- easy debugging of Electron issues
- no “works on my machine” surprises

---

## 🧠 Big Picture (ELI5)

Think of this app as **three separate pieces**:

1. **Renderer**
   - The UI (React + Vite)
   - Basically a website running inside Electron

2. **Main process**
   - Electron’s backend
   - Creates windows and controls the app lifecycle

3. **Preload**
   - A secure bridge between the UI and Electron APIs

Each piece is built separately, then combined when Electron runs.

---

## 🧩 Tech Stack

- Electron: `26.0.0` (pinned)
- React
- TypeScript
- Vite (renderer dev/build)
- electron-builder (packaging)
- Node.js 18 LTS

---

## 📁 Project Structure

```
electron26-react-ts/
├── src/
│   ├── main/
│   │   └── main.ts
│   ├── preload/
│   │   └── preload.ts
│   └── renderer/
│       └── main.tsx
├── dist/              # Compiled output (generated)
├── release/           # Packaged apps (generated)
├── index.html
├── vite.config.ts
├── tsconfig.json
├── tsconfig.electron.json
├── package.json
└── README.md
```

> `dist/` and `release/` are generated and **should not be committed**.

---

## ✅ Requirements (Ubuntu 22.04)

```
sudo apt update
sudo apt install -y git build-essential python3 curl
```

### Node.js (no nvm)

```
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify:

```
node -v
npm -v
```

Expected:

- Node `v18.x.x`

---

## 🚀 Getting Started

### 1️⃣ Clone the repo

```
git clone <your-repo-url>
cd electron26-react-ts
```

### 2️⃣ Install dependencies

```
npm install
```

---

## 🧪 Development Mode

This runs **three things at once**:

- Vite dev server (React)
- TypeScript compiler (Electron main/preload)
- Electron itself

```
npm run dev
```

Expected behavior:

- Vite runs at http://localhost:5173
- Electron window opens
- React hot reload works
- Electron code recompiles on change

---

## 🏗️ Build & Package (Linux)

This is the **real test** for Linux compatibility.

```
npm run dist:linux
```

Artifacts appear in:

```
release/
├── *.AppImage
└── *.deb
```

Run AppImage:

```
chmod +x release/*.AppImage
./release/*.AppImage
```

---

## 🔐 Security Defaults

This boilerplate uses safe Electron defaults:

- `contextIsolation: true`
- `nodeIntegration: false`
- All Node access goes through `preload`

Example preload API:

```
window.api.ping() // "pong"
```

---

## ⚠️ Important Gotchas

### ❌ Do NOT default-import Node modules

This breaks at runtime on Linux:

```
import path from "path"; // ❌
```

Always do:

```
import * as path from "node:path"; // ✅
```

---

### ❌ Do NOT copy node_modules across OSes

If moving between machines:

```
rm -rf node_modules
npm install
```

Native dependencies are OS-specific.

---

## 📦 Transfer Artifacts (Same OS Only)

If you need to move dependencies between machines **on the same OS**, you can
create a zip archive of `node_modules` and place it in:

```
transfer/
```

Example archive naming:

```
node_modules-<branch>-<YYYYMMDD>.zip
```

Unzip it next to `package.json`, and it will restore the dependencies quickly
without a full reinstall.

---

### ⚠️ VS Code (Snap) on Ubuntu

If you see `GLIBCXX` or `gio` errors:

- Run commands from **Ubuntu Terminal**, not VS Code
- Or install VS Code via `.deb` instead of snap

---

## 🎯 Why Electron 26.0.0 Is Pinned

This repo is for:

- diagnosing version-specific issues
- matching an existing Electron 26 setup
- avoiding accidental runtime changes

Upgrade Electron only on purpose.

---

## 🧠 Debug Tips

- Dev works but packaged fails → usually file paths
- Blank window → preload or CSP issue
- Linux-only crash → native dependency or sandbox

---

## 📌 Git Usage

```
git add .
git commit -m "Initial Electron 26 + React + TS boilerplate"
git branch -M main
git push -u origin main
```

---

## ✅ What This Repo Is For

- Linux Electron debugging
- Cross-OS parity testing
- Reproducible bug reports
- Clean starting point for real apps

---

## 🧡 Final Note

If this works but your real app doesn’t,  
the issue is **app-specific code**, not Electron or Ubuntu.

That’s the whole point of this boilerplate.
