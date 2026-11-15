#!/usr/bin/env python3
"""Two-trace refinement test: previously audited finite policy -> actual service.

Assumes no unmodeled source advance during the finite mission, which is
separately attacked in test_source_baseline_binding.py. Cost units are
symbolic, not measured wall-clock or actual operational expenses.
"""
import os
from pathlib import Path
import sys
import tempfile
import unittest

import authority_service as gate
from test_source_baseline_binding import POLICY,fixtures,ticket,refresh_body,signed_process

ROOT=Path(__file__).resolve().parents[1]/'assurance'/'source-baseline-refinement-v0.2'
sys.path.insert(0,str(ROOT))
import synthesize as game


class GameToServiceRefinement(unittest.TestCase):
    def test_audited_policy_replays_on_both_actual_source_episodes(self):
        source_model=ROOT/'source_epoch_game.json'
        raw,states,goal,initial,actions=game.parse_model(source_model)
        values,policy=game.synthesize(states,goal,actions)
        self.assertEqual(initial,3)
        self.assertEqual(str(values[initial]),'4')
        self.assertEqual(policy['3'],'status')
        self.assertEqual(policy['1'],'promote_epoch1')
        self.assertEqual(policy['2'],'rebaseline_epoch2')
        self.assertEqual(policy['4'],'promote_epoch3')

        for mode in ('ready1','unbound2'):
            with self.subTest(initial_concrete_state=mode):
                with tempfile.TemporaryDirectory(prefix='nf-game-to-service-') as tmp:
                    root=Path(tmp)
                    baseline,good=fixtures()
                    key=b'R'*32
                    (root/'shared_key').write_bytes(key)
                    state=gate.initialize(root,{
                        'version':'source-v1','source_hash':'a'*64,
                        'policy_hash':gate.digest(POLICY),
                        'baseline_hash':gate.digest(baseline)},baseline,POLICY)
                    def step(body):
                        nonlocal state
                        state,reply=signed_process(state,body,key)
                        return reply
                    if mode=='unbound2':
                        changed=step({'op':'advance','kind':'source',
                                      'source_hash':'b'*64,
                                      'version':'source-v2'})
                        self.assertTrue(changed['ok'])
                        self.assertEqual(state['epoch'],2)
                    status=step({'op':'status'})
                    self.assertTrue(status['ok'])
                    symbolic_cost=1  # audited policy's first action: status
                    if mode=='ready1':
                        self.assertTrue(status['baseline_certified'])
                        self.assertEqual(policy['1'],'promote_epoch1')
                    else:
                        self.assertFalse(status['baseline_certified'])
                        self.assertEqual(policy['2'],'rebaseline_epoch2')
                        fresh=step(refresh_body(state,baseline))
                        self.assertTrue(fresh['ok'])
                        self.assertEqual(state['epoch'],3)
                        self.assertEqual(policy['4'],'promote_epoch3')
                        symbolic_cost+=1
                    granted=step(ticket(state,good,nonce='p'*20))
                    self.assertTrue(granted['ok'],granted)
                    symbolic_cost+=2
                    self.assertEqual(symbolic_cost,3 if mode=='ready1' else 4)
                    self.assertEqual(state['committed']['template'],good)
                    self.assertEqual(state['committed']['ticket']['epoch'],
                                     state['committed']['authority_epoch'])
                    self.assertEqual(state['committed']['ticket']['source_hash'],
                                     state['baseline_source_hash'])

    def test_source_interleaving_outside_restricted_game_aborts_commit(self):
        with tempfile.TemporaryDirectory(prefix='nf-extra-interleaving-') as tmp:
            root=Path(tmp);baseline,good=fixtures();key=b'R'*32
            (root/'shared_key').write_bytes(key)
            state=gate.initialize(root,{
                'version':'v1','source_hash':'a'*64,
                'policy_hash':gate.digest(POLICY),
                'baseline_hash':gate.digest(baseline)},baseline,POLICY)
            stale=ticket(state,good)
            state,stat=signed_process(state,{'op':'status'},key)
            self.assertTrue(stat['baseline_certified'])
            state,advance=signed_process(state,{
                'op':'advance','kind':'source','source_hash':'b'*64,'version':'v2'},key)
            self.assertTrue(advance['ok'])
            unchanged,denied=signed_process(state,stale,key)
            self.assertIs(unchanged,state)
            self.assertEqual(denied['reason'],'stale_or_revoked_authority')
            self.assertIsNone(state['committed'])


if __name__=='__main__':
    unittest.main(verbosity=2)
