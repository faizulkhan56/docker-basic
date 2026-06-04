const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
const port = 5000;

async function getConnection() {
  return mysql.createConnection({
    host: process.env.DB_HOST || "db",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "root123",
    database: process.env.DB_NAME || "training",
    port: Number(process.env.DB_PORT || "3306"),
  });
}

app.get("/", (_req, res) => {
  res.json({
    message: "Docker Compose demo: web + mysql",
    runtime: "nodejs",
  });
});

app.get("/db-check", async (_req, res) => {
  let conn;
  try {
    conn = await getConnection();
    const [rows] = await conn.execute("SELECT COUNT(*) AS total FROM students");
    res.json({ students: Number(rows[0].total) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  } finally {
    if (conn) {
      await conn.end();
    }
  }
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Server listening on port ${port}`);
});
