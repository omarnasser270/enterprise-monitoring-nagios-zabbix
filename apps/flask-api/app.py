import os
import time

import pymysql
from flask import Flask, jsonify, request

app = Flask(__name__)
START_TIME = time.time()
STATS = {"requests": 0}


def get_conn():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "192.168.56.23"),
        user=os.getenv("DB_USER", "taskuser"),
        password=os.getenv("DB_PASS", "TaskPass123!"),
        database=os.getenv("DB_NAME", "taskdb"),
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=3,
    )


@app.before_request
def count_request():
    STATS["requests"] += 1


@app.route("/health")
def health():
    try:
        conn = get_conn()
        conn.ping()
        conn.close()
        return jsonify(status="ok", database="up"), 200
    except Exception as e:
        return jsonify(status="degraded", database="down", error=str(e)), 503


@app.route("/tasks", methods=["GET"])
def list_tasks():
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("SELECT id, title, done FROM tasks ORDER BY id")
        rows = cur.fetchall()
    conn.close()
    return jsonify(rows)


@app.route("/tasks", methods=["POST"])
def create_task():
    data = request.get_json(silent=True) or {}
    title = data.get("title")
    if not title:
        return jsonify(error="title is required"), 400
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("INSERT INTO tasks (title) VALUES (%s)", (title,))
    conn.commit()
    conn.close()
    return jsonify(status="created"), 201


@app.route("/metrics-custom")
def metrics_custom():
    try:
        conn = get_conn()
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) AS total, SUM(done = 0) AS pending FROM tasks")
            row = cur.fetchone()
        conn.close()
    except Exception as e:
        return jsonify(error=str(e)), 503
    return jsonify(
        tasks_total=int(row["total"]),
        tasks_pending=int(row["pending"] or 0),
        requests_total=STATS["requests"],
        uptime_seconds=int(time.time() - START_TIME),
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
