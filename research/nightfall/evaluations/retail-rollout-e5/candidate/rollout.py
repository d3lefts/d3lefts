"""Incomplete rollout implementation. Callers own the transaction."""
def install(db):
    db.execute("""CREATE TABLE IF NOT EXISTS parts(
        order_id TEXT NOT NULL, part TEXT NOT NULL, shipped INTEGER NOT NULL,
        PRIMARY KEY(order_id, part))""")


def write(db, order, part, shipped):
    db.execute("INSERT OR REPLACE INTO parts VALUES (?, ?, ?)", (order, part, int(shipped)))


def read(db, order):
    return dict(db.execute("SELECT part, shipped FROM parts WHERE order_id=?", (order,)))


def backfill(db, limit):
    rows = db.execute("SELECT order_id FROM legacy_ship ORDER BY order_id LIMIT ?", (limit,)).fetchall()
    for order, in rows:
        write(db, order, "primary", True)
    return len(rows)
