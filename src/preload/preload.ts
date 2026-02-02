import { contextBridge } from "electron";

contextBridge.exposeInMainWorld("api", {
  ping: () => "pong"
});

export type Api = {
  ping: () => string;
};

declare global {
  interface Window {
    api: Api;
  }
}
