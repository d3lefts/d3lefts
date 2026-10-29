#!/usr/bin/env python3
"""Offline synthetic security tests: there is no AgentDojo benchmark run."""
import unittest
from authority_gate import Grant, Proposal, canonical_fingerprint, decide


class OfflineGateTests(unittest.TestCase):
    def setUp(self):
        self.original = canonical_fingerprint({
            "recipient": "approved@example.invalid", "body": "Approved body"})
        self.attack = canonical_fingerprint({
            "recipient": "attacker@example.invalid", "body": "Approved body"})
        self.authorized = (Grant("mail", "send", self.original),)

    def test_authorized_exact_send(self):
        p = Proposal("mail", "send", self.original, "assistant")
        self.assertTrue(decide(self.authorized, p).allowed)

    def test_injection_cannot_change_recipient(self):
        p = Proposal("mail", "send", self.attack, "tool_result")
        verdict = decide(self.authorized, p)
        self.assertFalse(verdict.allowed)
        self.assertEqual(verdict.reason, "sensitive_action_without_exact_grant")

    def test_injection_cannot_change_body(self):
        changed = canonical_fingerprint({
            "recipient": "approved@example.invalid", "body": "Modified"})
        self.assertFalse(decide(self.authorized,
                         Proposal("mail", "send", changed, "assistant")).allowed)

    def test_tools_cannot_grant_permission(self):
        p = Proposal("mail", "send", self.attack, "user")
        self.assertFalse(decide(self.authorized, p).allowed)

    def test_missing_grant_denies_sensitive_write(self):
        self.assertFalse(decide(tuple(),
            Proposal("file", "delete", self.original, "assistant")).allowed)

    def test_untrusted_origin_denied(self):
        self.assertFalse(decide(self.authorized,
            Proposal("mail", "send", self.original, "unknown")).allowed)

    def test_unknown_read_denied_by_default(self):
        self.assertFalse(decide(tuple(),
            Proposal("web", "read", self.original, "tool_result")).allowed)

    def test_runner_read_allowlist(self):
        self.assertTrue(decide(tuple(),
            Proposal("calendar", "read", self.original, "assistant"),
            read_only=frozenset({"calendar"})).allowed)

    def test_arguments_canonicalized(self):
        one = canonical_fingerprint({"a": 1, "b": 2})
        two = canonical_fingerprint({"b": 2, "a": 1})
        self.assertEqual(one, two)
        self.assertNotEqual(one, canonical_fingerprint({"a": 1, "b": 3}))

    def test_malformed_fingerprint(self):
        self.assertFalse(decide(self.authorized,
            Proposal("mail", "send", "", "assistant")).allowed)

    def test_malformed_grants(self):
        self.assertFalse(decide([Grant("mail", "send", self.original)],
            Proposal("mail", "send", self.original, "assistant")).allowed)


if __name__ == "__main__":
    unittest.main()
