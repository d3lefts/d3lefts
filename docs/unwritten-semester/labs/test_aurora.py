import csv
import tempfile
import unittest
from pathlib import Path

from aurora import FIELDS, simulate, summarize
from audit import verify_trace


class AuroraTests(unittest.TestCase):
    def test_deterministic_replay(self):
        a = list(simulate(seed=7, trials=150, policy='quorum'))
        b = list(simulate(seed=7, trials=150, policy='quorum'))
        self.assertEqual(a, b)

    def test_policy_independent_world(self):
        a = list(simulate(seed=11, trials=200, policy='any'))
        b = list(simulate(seed=11, trials=200, policy='quorum'))
        for x, y in zip(a, b):
            self.assertEqual(tuple(x[k] for k in ('event', 'common_outage', 'a', 'b', 'c')),
                             tuple(y[k] for k in ('event', 'common_outage', 'a', 'b', 'c')))

    def test_valid_ranges(self):
        with self.assertRaises(ValueError):
            list(simulate(trials=0))
        with self.assertRaises(ValueError):
            list(simulate(common_fail=1.1))
        with self.assertRaises(ValueError):
            list(simulate(prevalence=-0.1))

    def _write(self, rows, destination):
        with destination.open('w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=FIELDS)
            w.writeheader()
            w.writerows(rows)

    def test_audit_matches_summary(self):
        rows = list(simulate(seed=32, trials=333, policy='quorum'))
        with tempfile.TemporaryDirectory() as td:
            file = Path(td) / 'trace.csv'
            self._write(rows, file)
            verified = verify_trace(file)
            reported = summarize(rows)
            for key in reported:
                self.assertEqual(reported[key], verified[key])

    def test_tamper_detection(self):
        rows = list(simulate(seed=19, trials=85, policy='any'))
        rows[0]['alarm'] = 1 - rows[0]['alarm']
        with tempfile.TemporaryDirectory() as td:
            file = Path(td) / 'broken.csv'
            self._write(rows, file)
            with self.assertRaises(ValueError):
                verify_trace(file)

    def test_total_common_outage(self):
        rows = list(simulate(trials=150, common_fail=1.0))
        self.assertTrue(all(r['operable'] == 0 and r['alarm'] == 0 for r in rows))


if __name__ == '__main__':
    unittest.main()
