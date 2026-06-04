const express = require("express");

const app = express();
const port = 8000;

app.get("/", (_req, res) => {
  res.json({
    message: "Dockerfile demo is running",
    topic: "Build image and run container",
    runtime: "nodejs",
  });
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Server listening on port ${port}`);
});
