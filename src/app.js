const express = require("express");
const path = require("path");

const app = express();
const startedAt = Date.now();

// Values injected at build/deploy time by the pipeline
const info = {
  name: "devops-cicd-demo",
  version: process.env.APP_VERSION || "dev",
  commit: process.env.GIT_COMMIT || "local",
  builtAt: process.env.BUILD_TIME || "not built by pipeline",
};

app.disable("x-powered-by");
app.use(express.static(path.join(__dirname, "..", "public")));

// Used by Docker HEALTHCHECK and the deploy script
app.get("/health", (req, res) => res.status(200).json({ status: "ok" }));

app.get("/api/info", (req, res) => {
  res.json({ ...info, uptimeSeconds: Math.floor((Date.now() - startedAt) / 1000) });
});

module.exports = app;
