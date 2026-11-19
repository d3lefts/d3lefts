"""Intentionally shallow smoke controls; not the benchmark grader."""
import os
from pathlib import Path
import tempfile
import unittest
from authorityepoch import Authority, packet, ticket

class Smoke(unittest.TestCase):
    def setUp(self):
        self.t = tempfile.TemporaryDirectory()
        self.addCleanup(self.t.cleanup)
        self.secret = b'trusted-' * 4
        self.gate = Authority(Path(self.t.name) / 'authority.json', self.secret, os.getuid())
        self.baseline = {'resources': {'audit': True, 'retention': True}}
        self.gate.bootstrap('a' * 64, 1, self.baseline)

    def send(self, data):
        return self.gate.handle(packet(self.secret, data), os.getuid())

    def test_status_after_bootstrap(self):
        self.assertTrue(self.send({'op': 'status'})['baseline_certified'])

    def test_normal_promote_and_persistence(self):
        state = self.gate.store.read()
        token = ticket(state, self.baseline, 'nonce-0000000001')
        self.assertTrue(self.send({'op': 'promote', 'effect': self.baseline, 'ticket': token})['ok'])
        self.assertEqual(self.gate.store.read()['committed']['effect'], self.baseline)

    def test_invalid_hmac_rejected(self):
        before = self.gate.store.read()
        self.assertFalse(self.gate.handle(packet(b'bad-key', {'op': 'status'}), os.getuid())['ok'])
        self.assertEqual(before, self.gate.store.read())

if __name__ == '__main__':
    unittest.main()
