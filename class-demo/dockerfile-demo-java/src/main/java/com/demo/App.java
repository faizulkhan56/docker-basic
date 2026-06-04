package com.demo;

import io.javalin.Javalin;
import java.util.Map;

public class App {
    public static void main(String[] args) {
        Javalin app = Javalin.create();

        app.get("/", ctx -> ctx.json(Map.of(
                "message", "Dockerfile demo is running",
                "topic", "Build image and run container",
                "runtime", "java"
        )));

        app.get("/health", ctx -> ctx.json(Map.of("status", "ok")));

        app.start("0.0.0.0", 8000);
    }
}
