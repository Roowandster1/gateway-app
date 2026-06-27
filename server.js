const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

// Serve index.html and any static assets sitting next to it
app.use(express.static(__dirname));

// Any other path falls back to the gateway
app.get("*", (_req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

app.listen(PORT, () => console.log(`Gateway running on :${PORT}`));
