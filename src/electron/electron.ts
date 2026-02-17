import { app, BrowserWindow, ipcMain, dialog, session } from "electron";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

// Constants
const CRASH_RELOAD_DELAY_MS = 1000; // Delay before reloading after a renderer crash

function createWindow() {
  const win = new BrowserWindow({
    width: 1100,
    height: 750,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  // Mirror renderer console output to the main process terminal.
  win.webContents.on(
    "console-message",
    (_event, level, message, line, sourceId) => {
      console.log(`[renderer:${level}] ${message} (${sourceId}:${line})`);
    },
  );

  // Handle renderer process crashes - show dialog instead of black screen
  win.webContents.on("render-process-gone", (event, details) => {
    console.error("Renderer process crashed:", details);
    dialog.showErrorBox(
      "Renderer Process Crashed",
      `The renderer process has crashed.\nReason: ${details.reason}\nExit Code: ${details.exitCode}\n\nThe app will attempt to reload.`,
    );
    // Attempt to reload the window after a short delay
    setTimeout(() => {
      if (!win.isDestroyed()) {
        win.reload();
      }
    }, CRASH_RELOAD_DELAY_MS);
  });

  // Handle unresponsive renderer
  win.on("unresponsive", () => {
    console.error("Window became unresponsive");
    dialog.showErrorBox(
      "Window Unresponsive",
      "The window has become unresponsive. This may be due to STIG restrictions or GPU issues.",
    );
  });

  const devUrl = process.env.VITE_DEV_SERVER_URL;

  if (devUrl) {
    win.loadURL(devUrl).catch((err) => {
      console.error("Failed to load dev URL:", err);
      dialog.showErrorBox(
        "Failed to Load Dev Server",
        `Could not connect to Vite dev server at ${devUrl}\n\nError: ${err.message}\n\nMake sure the dev server is running.`,
      );
    });
  } else {
    // Packaged: load built renderer
    const indexHtmlPath = path.join(__dirname, "../renderer/index.html");
    win.loadFile(indexHtmlPath).catch((err) => {
      console.error("Failed to load renderer:", err);
      dialog.showErrorBox(
        "Failed to Load Application",
        `Could not load the application from ${indexHtmlPath}\n\nError: ${err.message}`,
      );
    });
  }
}

// Get app info for the renderer
function getAppInfo() {
  return {
    electronVersion: process.versions.electron,
    nodeVersion: process.versions.node,
    appVersion: app.getVersion(),
    isDev: !app.isPackaged,
    platform: process.platform,
    arch: process.arch,
  };
}

// Prevent a GPU crash on some Linux systems
app.disableHardwareAcceleration();

// Additional STIG-friendly switches for offline/restricted environments
// These help with systems that have GPU restrictions or security policies
app.commandLine.appendSwitch("disable-dev-shm-usage"); // Helps with shared memory issues in restricted environments
app.commandLine.appendSwitch("disable-gpu-compositing"); // Additional GPU safeguard

app.whenReady().then(() => {
  // Safely load Chrome DevTools extension if it exists
  // This prevents crashes when the extension directory is missing
  const extensionPath = path.join(__dirname, "extensions", "react-devtools");
  if (fs.existsSync(extensionPath)) {
    try {
      session.defaultSession
        .loadExtension(extensionPath, { allowFileAccess: true })
        .then(() => {
          console.log("Chrome DevTools extension loaded successfully");
        })
        .catch((err) => {
          console.warn("Failed to load Chrome extension:", err.message);
        });
    } catch (err: any) {
      console.warn("Error loading extension:", err.message);
    }
  } else {
    console.log(
      "Chrome DevTools extension not found at",
      extensionPath,
      "- skipping (this is normal in dev mode)",
    );
  }

  // Handle IPC requests from renderer
  ipcMain.handle("get-app-info", () => {
    return getAppInfo();
  });

  // Example: Handle IPC messages from renderer
  ipcMain.on("test-message", (event, message) => {
    console.log("Message from renderer:", message);
  });

  createWindow();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

// Handle GPU process crashes
app.on("gpu-process-crashed", (event, killed) => {
  console.error("GPU process crashed. Killed:", killed);
  dialog.showErrorBox(
    "GPU Process Crashed",
    "The GPU process has crashed. This is common in STIG'd environments.\n\nHardware acceleration is already disabled, but the app may need to restart.",
  );
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
