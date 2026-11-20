"""Deployed v1 worker. Callers own the transaction."""
def bootstrap(db):
    db.executescript("""
        CREATE TABLE orders(id TEXT PRIMARY KEY NOT NULL);
        CREATE TABLE legacy_ship(order_id TEXT PRIMARY KEY NOT NULL REFERENCES orders(id));
        CREATE VIEW order_summary AS
        SELECT id, CASE WHEN order_id IS NULL THEN 'pending' ELSE 'shipped' END AS status
        FROM orders LEFT JOIN legacy_ship ON id = order_id;
    """)


def ship(db, order):
    db.execute("INSERT OR IGNORE INTO legacy_ship VALUES (?)", (order,))


def status(db, order):
    return db.execute("SELECT status FROM order_summary WHERE id=?", (order,)).fetchone()[0]
