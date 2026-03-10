import os

from flask import Flask, jsonify
import pymysql

app = Flask(__name__)


def get_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "db"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "root123"),
        database=os.getenv("DB_NAME", "training"),
        port=int(os.getenv("DB_PORT", "3306")),
        cursorclass=pymysql.cursors.DictCursor,
    )


@app.get("/")
def home():
    return jsonify({"message": "Docker Compose demo: web + mysql"})


@app.get("/db-check")
def db_check():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS total FROM students")
            row = cursor.fetchone()
        return jsonify({"students": row["total"]})
    finally:
        conn.close()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
