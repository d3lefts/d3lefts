import tempfile
import unittest
from pathlib import Path
from dispatchq import WorkQueue


class PublicQueueTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.now = 100.0
        self.db = Path(self.tmp.name) / 'queue.sqlite'
        self.queue = WorkQueue(self.db, clock=lambda: self.now)

    def test_submit_and_claim(self):
        self.assertTrue(self.queue.submit('a', 'data'))
        lease, = self.queue.claim('worker')
        self.assertEqual((lease.job_id, lease.payload, lease.attempts), ('a', 'data', 1))
        self.assertEqual(self.queue.status('a')['state'], 'leased')

    def test_finish(self):
        self.queue.submit('a', '{}')
        lease, = self.queue.claim('worker')
        self.assertTrue(self.queue.finish('a', lease.token))
        self.assertEqual(self.queue.status('a')['state'], 'done')

    def test_due(self):
        self.queue.submit('a', 'data', due_at=150)
        self.assertEqual(self.queue.claim('worker'), [])
        self.now = 150.0
        self.assertEqual(len(self.queue.claim('worker')), 1)


if __name__ == '__main__':
    unittest.main()
