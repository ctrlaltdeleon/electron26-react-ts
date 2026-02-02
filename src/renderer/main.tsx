import React from "react";
import ReactDOM from "react-dom/client";

function App() {
  return (
    <div style={{ fontFamily: "system-ui", padding: 24 }}>
      <h1>Electron 26 + React + TypeScript</h1>
      <p>If you see this, the renderer is working.</p>
      <p>Platform: {navigator.userAgent}</p>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
