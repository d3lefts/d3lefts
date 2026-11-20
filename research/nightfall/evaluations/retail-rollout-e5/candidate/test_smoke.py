import sqlite3
import unittest

import legacy
import rollout


class Smoke(unittest.TestCase):
    def test_new_part(self):
        with sqlite3.connect(":memory:") as db:
            legacy.bootstrap(db)
            db.execute("INSERT INTO orders VALUES ('abc')")
            rollout.install(db)
            rollout.write(db, "abc", "extra", True)
            self.assertEqual(rollout.read(db, "abc")["extra"], True)
