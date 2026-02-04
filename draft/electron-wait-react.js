const net = require("net");
// When run under foreman/nf each process gets a PORT (5000,5001,...).
// The Electron process will have a PORT one higher than the React process,
// so derive the React dev server port by subtracting 1.
const port = process.env.PORT ? process.env.PORT - 1 : 3000;

process.env.ELECTRON_START_URL = `http://localhost:${port}`;

const client = new net.Socket();

let startedElectron = false;
const tryConnection = () =>
  client.connect({ port: port }, () => {
    client.end();
    if (!startedElectron) {
      console.log("Starting electron...");
      startedElectron = true;
      const exec = require("child_process").exec;
      exec("npm run electron");
    }
  });

tryConnection();

client.on("error", (error) => {
  setTimeout(tryConnection, 1000);
});
