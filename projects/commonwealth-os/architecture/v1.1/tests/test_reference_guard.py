"""Narrow formal-model tests. Run: python -m unittest discover -s tests -v"""
import unittest
from dataclasses import replace
from concurrent.futures import ThreadPoolExecutor
from reference_guard import Passport, Effect, InstitutionalState, authorize_and_commit, Blocked, retains_authorization_information


def fixture():
    p=Passport('org1','jur1','dec1','proposal1','rules1','proof1', True,True,
               frozenset({'PUBLISH_RESOLUTION','SIMULATED_DISBURSEMENT'}),20,1,1,1,200)
    x=Effect('org1','jur1','dec1','proposal1','rules1','SIMULATED_DISBURSEMENT',10,'effect1')
    s=InstitutionalState('org1','jur1','dec1','proposal1','rules1')
    return p,x,s

class Tests(unittest.TestCase):
    def expect_block(self, message, pp=None, xx=None, mod=None):
        p,x,s=fixture()
        if pp: p=replace(p,**pp)
        if xx: x=replace(x,**xx)
        if mod:
            for k,v in mod.items():setattr(s,k,v)
        before_budget = s.budget_remaining
        with self.assertRaisesRegex(Blocked,message): authorize_and_commit(p,x,s)
        self.assertEqual(s.budget_remaining,before_budget)
        self.assertEqual(len(s.committed),0)
    def test_success(self):
        p,x,s=fixture();r=authorize_and_commit(p,x,s)
        self.assertEqual(r['status'],'COMMITTED_IN_MODEL');self.assertEqual(s.budget_remaining,90)
    def test_replay(self):
        p,x,s=fixture();authorize_and_commit(p,x,s)
        with self.assertRaisesRegex(Blocked,'REPLAYED_EFFECT'):authorize_and_commit(p,x,s)
        self.assertEqual(len(s.committed),1)
    def test_wrong_tenant(self):self.expect_block('TENANT_MISMATCH',xx={'tenant_id':'other'})
    def test_wrong_jurisdiction(self):self.expect_block('JURISDICTION_MISMATCH',xx={'jurisdiction_id':'other'})
    def test_wrong_decision(self):self.expect_block('DECISION_MISMATCH',xx={'decision_id':'dec2'})
    def test_election_unverified(self):self.expect_block('ELECTION_UNVERIFIED',pp={'election_verified':False})
    def test_missing_legal_attestation(self):self.expect_block('LEGAL_AUTHORITY_UNASSESSED',pp={'legal_attested':False})
    def test_proposal_swap(self):self.expect_block('PROPOSAL_STALE_OR_WRONG',xx={'proposal_digest':'edited'})
    def test_rule_change(self):self.expect_block('RULE_STALE_OR_WRONG',mod={'current_rule_digest':'new'})
    def test_authority_revocation(self):self.expect_block('STAY_OR_REVOCATION',mod={'revoked':True})
    def test_stay(self):self.expect_block('STAY_OR_REVOCATION',mod={'stayed':True})
    def test_epoch_stale(self):self.expect_block('EPOCH_STALE',mod={'challenge_epoch':2})
    def test_expired(self):self.expect_block('PASSPORT_EXPIRED',mod={'now':201})
    def test_effect_kind(self):self.expect_block('OUTSIDE_EFFECT_SCOPE',xx={'kind':'LIVE_PAYMENT'})
    def test_amount(self):self.expect_block('OUTSIDE_APPROVED_AMOUNT',xx={'amount':21})
    def test_budget(self):self.expect_block('BUDGET_INSUFFICIENT',mod={'budget_remaining':4})
    def test_concurrent_duplicate(self):
        p,x,s=fixture()
        def f(_):
            try:return authorize_and_commit(p,x,s)['status']
            except Blocked as e:return str(e)
        with ThreadPoolExecutor(max_workers=12) as ex: results=list(ex.map(f,range(24)))
        self.assertEqual(results.count('COMMITTED_IN_MODEL'),1)
        self.assertEqual(results.count('REPLAYED_EFFECT'),23)
        self.assertEqual(s.budget_remaining,90)
    def test_semantic_reuse_yes(self):
        B=list(range(16));T=lambda x:bin(x).count('1')
        self.assertTrue(retains_authorization_information(B,T,lambda x:T(x)>=3))
    def test_semantic_reuse_no(self):
        B=list(range(16));T=lambda x:bin(x).count('1')
        self.assertFalse(retains_authorization_information(B,T,lambda x:bool(x&3)))

if __name__=='__main__':unittest.main()
