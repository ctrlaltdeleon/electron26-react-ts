import React from "react";
import ReactDOM from "react-dom/client";

function App() {
  const [systemInfo, setSystemInfo] = React.useState({
    userAgent: navigator.userAgent,
    electronVersion: "Loading...",
    nodeVersion: "Loading...",
    appVersion: "Loading...",
    isDev: false,
    platform: "Loading...",
    arch: "Loading...",
  });

  React.useEffect(() => {
    // Fetch info from main process via IPC
    if (window.electron?.ipcRenderer) {
      window.electron.ipcRenderer
        .invoke("get-app-info")
        .then((info) => {
          setSystemInfo((prev) => ({
            ...prev,
            ...info,
          }));
        })
        .catch((err) => {
          console.error("Failed to get app info:", err);
          setSystemInfo((prev) => ({
            ...prev,
            electronVersion: "IPC failed",
          }));
        });
    }
  }, []);

  const handleSendMessage = () => {
    if (window.electron?.ipcRenderer) {
      window.electron.ipcRenderer.send("test-message", "Hello from React!");
    }
  };

  return (
    <div
      style={{
        fontFamily: "system-ui",
        padding: 24,
        maxWidth: 800,
        margin: "0 auto",
      }}
    >
      <h1>Electron 26 + React + TypeScript</h1>
      <p>If you see this, the renderer is working.</p>

      <div
        style={{
          marginTop: 24,
          padding: 12,
          backgroundColor: "#f0f0f0",
          borderRadius: 4,
        }}
      >
        <h2>System Information</h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "150px 1fr",
            gap: "12px",
          }}
        >
          <strong>User Agent:</strong>
          <span>{systemInfo.userAgent}</span>

          <strong>Electron Version:</strong>
          <span>{systemInfo.electronVersion}</span>

          <strong>Node Version:</strong>
          <span>{systemInfo.nodeVersion}</span>

          <strong>App Version:</strong>
          <span>{systemInfo.appVersion}</span>

          <strong>Platform:</strong>
          <span>{systemInfo.platform}</span>

          <strong>Architecture:</strong>
          <span>{systemInfo.arch}</span>

          <strong>Mode:</strong>
          <span style={{ color: systemInfo.isDev ? "#d4a574" : "#4caf50" }}>
            {systemInfo.isDev ? "Development" : "Production"}
          </span>
        </div>
      </div>

      <div style={{ marginTop: 24 }}>
        <h2>IPC Test</h2>
        <p>
          Click the button below to send a test message to the main process:
        </p>
        <button
          onClick={handleSendMessage}
          style={{
            padding: "8px 16px",
            backgroundColor: "#0078d4",
            color: "white",
            border: "none",
            borderRadius: 4,
            cursor: "pointer",
            fontSize: 14,
          }}
        >
          Send Message to Main
        </button>
        <p style={{ fontSize: 12, color: "#666" }}>
          Check the console to see the message received by the main process.
        </p>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
