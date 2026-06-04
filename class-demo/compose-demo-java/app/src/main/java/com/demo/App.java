package com.demo;

import io.javalin.Javalin;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;

public class App {
    private static Connection getConnection() throws Exception {
        String host = System.getenv().getOrDefault("DB_HOST", "db");
        String user = System.getenv().getOrDefault("DB_USER", "root");
        String password = System.getenv().getOrDefault("DB_PASSWORD", "root123");
        String database = System.getenv().getOrDefault("DB_NAME", "training");
        String port = System.getenv().getOrDefault("DB_PORT", "3306");

        String url = "jdbc:mysql://" + host + ":" + port + "/" + database
                + "?allowPublicKeyRetrieval=true&useSSL=false";
        return DriverManager.getConnection(url, user, password);
    }

    public static void main(String[] args) {
        Javalin app = Javalin.create();

        app.get("/", ctx -> ctx.json(Map.of(
                "message", "Docker Compose demo: web + mysql",
                "runtime", "java"
        )));

        app.get("/db-check", ctx -> {
            try (Connection conn = getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) AS total FROM students")) {
                rs.next();
                ctx.json(Map.of("students", rs.getInt("total")));
            } catch (Exception e) {
                ctx.status(500).json(Map.of("error", e.getMessage()));
            }
        });

        app.start("0.0.0.0", 5000);
    }
}
