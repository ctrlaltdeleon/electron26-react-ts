# Notes

## Should I install Linux software using .deb or snap (terminal)?

- In Ubuntu VMs, prefer `.deb` over `snap` for development tools like VSCode to avoid sandbox-related issues and keep the environment predictable.

## Ran across a crypto error when trying to build the project?

- Most likely wrong Node/NPM version when it should be 18.20.8/10.8.2.
- For reference, Node 16 was used on the host machine.

## Is Vite strict on the structure of the project?

- No.

## What happens if there's files too large for Git?

- Need to have `git lfs` installed to have the large files to work.
  - What is `git lfs`?
    - Git Large File Storage.
    - Files too big for typical Github repo is placed somewhere else as pointers fill the repo to where the actual files are.
    - Anything more than 100MB? Need to use `git lfs`
  - Why use `git lfs`?
    - Transferring of the `release` folder.
  - Linux
    - `sudo apt update`
    - `sudo apt install git-lfs`
  - MacOS
    - `brew install git-lfs`
  - Windows
    - `git lfs install`
  - Then inside the repo directory:
    - `git lfs pull`
    - Not working? Force it.
      - `git lfs fetch -all`
      - `git lfs checkout`
  - If `git lfs` was installed BEFORE cloning the repo, should be fine.
  - If `git lfs` was installed AFTER cloning the repo, then:
    - `git lfs migrate import --include="release/**`
      - For this example, I just chose the "release" folder since that's where the big files were.
    - `git push --force-with-lease origin main`

## Why won't Linux build a Windows distribution?

- It can, but extremely difficult.
- It requires complex emulation tooling (Wine) or Docker to mimic Windows build environments.
- Going forward, need to use a Docker container with the correct Wine emulation in order to create the build.
- Typical workflow is so:
  - Spin up Wine Docker container
  - `git clone` this repo whether it be within the container or moved into the container
    - Just make sure it was `git clone` in the first place with a computer with `git lfs` already installed or else it won't work!
  - `npm run dist:win`
    - Script name may be changed.

## What to do with the scripts folder?

- Run these scripts on the respective OS in order for files to function correctly.

## Need to update the packages?

- Yes. :(

## Can I run vitest, a testing suite?

- Yes and no.
- Yes the project can, but no because we're not on the correct node.
  - From the vitest website, "Vitest requires Vite >=v6.0.0 and Node >=v20.0.0"
- Went and installed an earlier version which works out well, but did have to touch these files:
  - `vite.config.ts`
  - Create `src/test/setup.ts`

## Why did we add `vite.config.mts` and update scripts?

- `@vitejs/plugin-react` is ESM-only. Vite was trying to load `vite.config.ts` via CommonJS `require`, which fails for ESM-only plugins.
- Renaming the config to `vite.config.mts` forces Vite to load it as ESM so the plugin can be imported correctly.
- The `dev:renderer` and `build:renderer` scripts now pass `--config vite.config.mts` to ensure Vite always uses the ESM config.
- Think of ESM as a “new plug shape” and CommonJS as the “old plug shape”.
- The React plugin only fits the new plug (ESM). Our old config loader used the old plug (CommonJS), so it couldn’t connect.
- Renaming to `.mts` and pointing Vite to it makes it use the new plug shape so everything fits.

## What does ESM mean?

- ESM = ECMAScript Modules. It’s the modern JavaScript way to import/export code using `import` and `export`.
- CommonJS is the older Node.js way using `require()` and `module.exports`.
- ESM is the “new standard” way to connect JavaScript files.
- CommonJS is the “older standard.”
- Some packages only work with the new standard, so we must use it for the config.

## Why add `vitest.config.mts`?

- Tests failed with `document is not defined`, which happens when the test environment is Node (no DOM).
- `vitest.config.mts` explicitly sets `environment: "jsdom"` and uses `src/test/setup.ts`, so React Testing Library can access `document`.
- Tests were running in a place with **no browser**, so there was no `document`.
- `jsdom` is a **fake browser** for tests.
- The new config tells tests to use that fake browser so React tests can run.

## What is the typical Vite + React project structure?

```
project-root/
├─ index.html
├─ package.json
├─ vite.config.ts
├─ tsconfig.json
├─ tsconfig.node.json
├─ public/
│  └─ favicon.svg
└─ src/
   ├─ main.tsx          ← entry point (renderer bootstrap)
   ├─ App.tsx           ← root React component
   ├─ assets/           ← images, fonts, icons
   ├─ components/       ← reusable UI pieces
   │  └─ Button.tsx
   ├─ pages/            ← route-level components (if routing)
   ├─ hooks/            ← custom React hooks
   ├─ utils/            ← pure helpers (formatters, math, etc.)
   ├─ styles/           ← CSS / SCSS / Tailwind
   └─ test/             ← test setup files
      └─ setup.ts
```

## Now what does it look like with Electron included too?

```
project-root/
├─ index.html
├─ package.json
├─ vite.config.ts
├─ electron-builder.yml
├─ tsconfig.json
├─ tsconfig.node.json
├─ tsconfig.electron.json
├─ public/
└─ src/
   ├─ renderer/
   │  ├─ main.tsx          ← Vite entry
   │  ├─ App.tsx
   │  ├─ components/
   │  ├─ hooks/
   │  ├─ pages/
   │  ├─ utils/
   │  ├─ assets/
   │  └─ test/
   │     └─ setup.ts
   │
   ├─ electron/
   │  ├─ electron.ts       ← Electron main process
   │  ├─ preload.ts        ← contextBridge APIs
   │  ├─ ipc/
   │  │  └─ appInfo.ts
   │  └─ utils/
   │
   └─ shared/
      ├─ types/
      ├─ constants/
      └─ schemas/
```

## What should the workflow be now on the online world?

- If changes are made, commit and push.
- Then if ready to bring to offline world, run the "make-offline-ready.sh"
  - Make sure that the shell is `chmod +x make-offline-ready.sh`

## Want to see what is in Nexus?

`npm view socket.io versions --json`
