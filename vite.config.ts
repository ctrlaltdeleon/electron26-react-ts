import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

/*
  Vite configuration for the renderer (React + TypeScript) portion of the app.
  This file is used by the dev server (`vite`) and the production build step.
*/
export default defineConfig({
  // Plugins extend Vite — here we enable React fast refresh and JSX handling.
  plugins: [react()],
  // Base public path when serving the built files. `./` keeps paths relative
  // which is useful for Electron packaged apps loading files from disk.
  base: "./",
  // Build options for the renderer bundle output.
  build: {
    // Output directory for the renderer build (separate from Electron main build).
    outDir: "dist/renderer",
    // Remove previous contents of `outDir` before building to avoid stale files.
    emptyOutDir: true,
  },
});
