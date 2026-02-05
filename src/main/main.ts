import { app, BrowserWindow, ipcMain } from "electron";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

function createWindow() {
  const win = new BrowserWindow({
    width: 1100,
    height: 750,
    webPreferences: {
      preload: path.join(__dirname, "../preload/preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  const devUrl = process.env.VITE_DEV_SERVER_URL;

  if (devUrl) {
    win.loadURL(devUrl);
  } else {
    // Packaged: load built renderer
    const indexHtmlPath = path.join(__dirname, "../renderer/index.html");
    win.loadFile(indexHtmlPath);
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

app.whenReady().then(() => {
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

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
