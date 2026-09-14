import sqlite3

db = "data/comm_log.db"
sql = open("sql/05_final_reconciliation.sql", encoding="utf-8").read()

with sqlite3.connect(db) as conn:
    result = conn.execute(sql).fetchone()[0]

assert result == 22, f"Expected 22, got {result}"
print(f"Validation passed: target_base = {result}")
