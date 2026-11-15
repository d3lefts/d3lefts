#!/usr/bin/env python3
"""Source-to-baseline binding regression against the ACTUAL authority_service.

Only the local service-owned JSON effect is tested; no cloud deployment.
Uses independent_effect_verifier unchanged. No test-only verifier bypass.
"""
import copy
import hashlib
import json
import multiprocessing as mp
import os
from pathlib import Path
import tempfile
import time
import unittest

import authority_service as gate
from independent_effect_verifier import check_baseline, check_promotion

POLICY = {
    'mission': 'add-applied-interpretability-ou',
    'allowed_ou': 'Applied-Interpretability',
    'allowed_parent': 'Research',
    'required_tags': {'CostCenter':'Research',
                      'DataClassification':'Restricted',
                      'SecurityTier':'High'},
    'policy_version': 1,
}


def fixtures():
    baseline = {'Resources': {
        'ResearchOU': {'Type':'AWS::Organizations::OrganizationalUnit',
                       'Properties':{'Name':'Research','ParentId':{'Ref':'root'},
                                     'Tags':[{'Key':'DataClassification','Value':'Internal'}]}},
        'WeightsOU': {'Type':'AWS::Organizations::OrganizationalUnit',
                      'Properties':{'Name':'Weight-Storage','ParentId':{'Ref':'root'},
                                    'Tags':[{'Key':'DataClassification','Value':'Restricted'}]}},
        'PolicyDenyFSX': {'Type':'AWS::Organizations::Policy',
                          'Properties':{'Name':'Deny-FSx-Exports',
                                        'TargetIds':[{'Ref':'WeightsOU'}],
                                        'Content':{'Statement':[{
                                            'Effect':'Deny','Resource':'*',
                                            'Action':['fsx:CreateDataRepositoryTask',
                                                      'fsx:CopyBackup',
                                                      'fsx:CreateDataRepositoryAssociation',
                                                      'fsx:UpdateDataRepositoryAssociation']
                                        }]}}}
    }}
    candidate=copy.deepcopy(baseline)
    candidate['Resources']['AppliedInterpretabilityOU']={
        'Type':'AWS::Organizations::OrganizationalUnit',
        'Properties':{'Name':'Applied-Interpretability','ParentId':{'Ref':'ResearchOU'},
                      'Tags':[{'Key':k,'Value':v} for k,v in POLICY['required_tags'].items()]}}
    candidate['Resources']['PolicyDenyFSX']['Properties']['TargetIds'].append(
        {'Ref':'AppliedInterpretabilityOU'})
    return baseline,candidate


def ticket(state,template,nonce='n'*20):
    return {'op':'promote','ticket':{
        'epoch':state['epoch'], 'version':state['version'],
        'source_hash':state['source_hash'],
        'policy_hash':state['policy_hash'],
        'baseline_hash':state['baseline_hash'],
        'template_hash':gate.digest(template),'nonce':nonce},'template':template}


def signed_process(state,body,key,uid=None,signature=None):
    actual_uid=os.getuid()
    msg={'__peer_uid__':actual_uid if uid is None else uid,
         'body':body,'signature':gate.sign(key,body) if signature is None else signature}
    return gate.process(state,msg,actual_uid,key)


def refresh_body(state,baseline):
    return {'op':'rebaseline','source_hash':state['source_hash'],
            'version':state['version'],'baseline':baseline}


class SourceBaselineBinding(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(prefix='nf-source-binding-')
        self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)
        self.baseline,self.good=fixtures()
        self.key=b'S'*32
        (self.root/'shared_key').write_bytes(self.key)
        check_baseline(self.baseline)
        check_promotion(self.baseline,self.good,POLICY)
        self.state=gate.initialize(self.root,{
            'version':'source-v1','source_hash':'a'*64,
            'policy_hash':gate.digest(POLICY),
            'baseline_hash':gate.digest(self.baseline)
        },self.baseline,POLICY)

    def operate(self,body,uid=None,signature=None):
        before=self.state
        next_state,response=signed_process(before,body,self.key,uid,signature)
        self.state=next_state
        return before,response

    def change_source(self,newhash='b'*64,version='source-v2'):
        _,reply=self.operate({'op':'advance','kind':'source',
                              'source_hash':newhash,'version':version})
        self.assertTrue(reply['ok'])
        return reply

    def test_new_ticket_cannot_reuse_old_baseline_after_source_change(self):
        old_ticket=ticket(self.state,self.good)
        self.change_source()
        self.assertIsNone(self.state['baseline_source_hash'])
        self.assertIsNone(self.state['baseline_source_version'])
        before,reply=self.operate(ticket(self.state,self.good))
        self.assertEqual(reply['reason'],'baseline_requires_recertification')
        self.assertIs(self.state,before)
        _,reply=self.operate(old_ticket)
        self.assertEqual(reply['reason'],'stale_or_revoked_authority')
        _,status=self.operate({'op':'status'})
        self.assertFalse(status['baseline_certified'])
        self.assertIsNone(status['committed_digest'])

    def test_valid_rebaseline_restores_authority_with_new_epoch(self):
        self.change_source()
        pre_refresh=ticket(self.state,self.good,nonce='a'*20)
        _,reply=self.operate(refresh_body(self.state,self.baseline))
        self.assertTrue(reply['ok'])
        self.assertEqual(reply['reason'],'baseline_recertified_for_current_source')
        self.assertEqual(self.state['epoch'],3)
        self.assertEqual(self.state['baseline_source_hash'],self.state['source_hash'])
        self.assertEqual(self.state['baseline_source_version'],self.state['version'])
        _,old=self.operate(pre_refresh)
        self.assertEqual(old['reason'],'stale_or_revoked_authority')
        fresh=ticket(self.state,self.good,nonce='b'*20)
        before,grant=self.operate(fresh)
        self.assertTrue(grant['ok'])
        self.assertEqual(grant['reason'],'committed_by_trusted_service')
        self.assertEqual(self.state['committed']['template'],self.good)
        self.assertEqual(self.state['committed']['ticket']['source_hash'],before['source_hash'])
        self.assertEqual(grant['commit_sha256'],gate.digest(self.state['committed']))

    def test_incorrect_refresh_is_denied_and_does_not_change_state(self):
        self.change_source()
        invalid={'Resources':{}}
        before,reply=self.operate(refresh_body(self.state,invalid))
        self.assertEqual(reply['reason'],'baseline_verification_denied')
        self.assertIs(self.state,before)
        body=refresh_body(self.state,self.baseline)
        body['source_hash']='c'*64
        before,reply=self.operate(body)
        self.assertEqual(reply['reason'],'invalid_baseline_attestation')
        self.assertIs(self.state,before)

    def test_missing_binding_fields_fail_closed(self):
        self.state=dict(self.state)
        self.state.pop('baseline_source_hash')
        self.state.pop('baseline_source_version')
        before,reply=self.operate(ticket(self.state,self.good))
        self.assertEqual(reply['reason'],'baseline_requires_recertification')
        self.assertIs(self.state,before)

    def test_revoke_blocks_refresh_and_grant(self):
        self.change_source()
        _,reply=self.operate({'op':'revoke'})
        self.assertTrue(reply['ok'])
        before,reply=self.operate(refresh_body(self.state,self.baseline))
        self.assertEqual(reply['reason'],'revoked_authority_cannot_rebaseline')
        self.assertIs(self.state,before)
        _,reply=self.operate(ticket(self.state,self.good))
        self.assertEqual(reply['reason'],'stale_or_revoked_authority')

    def test_bad_template_still_denied_after_refresh(self):
        self.change_source()
        self.operate(refresh_body(self.state,self.baseline))
        bad=copy.deepcopy(self.good)
        bad['Resources']['PolicyDenyFSX']['Properties']['Content']['Statement'][0]['Action'].remove(
            'fsx:CopyBackup')
        before,reply=self.operate(ticket(self.state,bad))
        self.assertEqual(reply['reason'],'independent_effect_verifier_denied')
        self.assertIs(self.state,before)

    def test_source_race_after_status_fails_closed(self):
        old_ticket=ticket(self.state,self.good)
        _,status=self.operate({'op':'status'})
        self.assertTrue(status['baseline_certified'])
        self.change_source()
        before,reply=self.operate(old_ticket)
        self.assertFalse(reply['ok'])
        self.assertEqual(reply['reason'],'stale_or_revoked_authority')
        self.assertIs(self.state,before)

    def test_replay_forgery_and_wrong_peer_are_denied(self):
        t=ticket(self.state,self.good)
        _,reply=self.operate(t)
        self.assertTrue(reply['ok'])
        _,replay=self.operate(t)
        self.assertEqual(replay['reason'],'replayed_authorization')
        fresh=ticket(self.state,self.good,nonce='z'*20)
        before,forged=self.operate(fresh,signature='0'*64)
        self.assertEqual(forged['reason'],'invalid_attestation_signature')
        self.assertIs(self.state,before)
        before,bad_peer=self.operate(fresh,uid=os.getuid()+100000)
        self.assertEqual(bad_peer['reason'],'unauthorized_os_principal')
        self.assertIs(self.state,before)

    def test_lost_response_needs_commit_reconciliation(self):
        t=ticket(self.state,self.good)
        before,grant=self.operate(t)
        self.assertTrue(grant['ok'])
        # Deliberately discard grant as if the transport response were lost:
        # the caller cannot infer rollback. It must inspect committed_digest.
        expected=gate.digest({'template':self.good,'ticket':t['ticket'],
                              'template_hash':gate.digest(self.good),
                              'authority_epoch':before['epoch']})
        _,status=self.operate({'op':'status'})
        self.assertEqual(status['committed_digest'],expected)
        _,again=self.operate(t)
        self.assertEqual(again['reason'],'replayed_authorization')

    def test_policy_change_can_invalidate_semantics_independently(self):
        amended=dict(POLICY,policy_version=2)
        _,reply=self.operate({'op':'advance','kind':'policy','policy':amended})
        self.assertTrue(reply['ok'])
        _,status=self.operate({'op':'status'})
        self.assertTrue(status['baseline_certified']) # source unchanged
        before,reply=self.operate(ticket(self.state,self.good))
        self.assertEqual(reply['reason'],'independent_effect_verifier_denied')
        self.assertIs(self.state,before)

    def test_repeat_source_advance_same_bytes_requires_reattest(self):
        self.change_source('a'*64,'source-v1')
        self.assertFalse((self.state.get('baseline_source_hash')==self.state['source_hash'] and
                          self.state.get('baseline_source_version')==self.state['version']))
        _,reply=self.operate(ticket(self.state,self.good))
        self.assertEqual(reply['reason'],'baseline_requires_recertification')

    def test_actual_socket_process_persists_source_binding(self):
        sock=self.root/'authority.sock'
        ctx=mp.get_context('fork')
        proc=ctx.Process(target=gate.serve,args=(str(self.root),str(sock),os.getuid()))
        proc.start()
        try:
            for _ in range(150):
                if sock.exists(): break
                if not proc.is_alive(): self.fail('authority service terminated')
                time.sleep(.01)
            self.assertTrue(sock.exists())
            def send(body): return gate.request(sock,body,self.key)
            source={'op':'advance','kind':'source',
                    'source_hash':'d'*64,'version':'source-v3'}
            self.assertTrue(send(source)['ok'])
            status=send({'op':'status'})
            self.assertFalse(status['baseline_certified'])
            on_disk=json.loads((self.root/'authority.json').read_text())
            denied=send(ticket(on_disk,self.good))
            self.assertEqual(denied['reason'],'baseline_requires_recertification')
            self.assertIsNone(send({'op':'status'})['committed_digest'])
            self.assertTrue(send(refresh_body(on_disk,self.baseline))['ok'])
            newer=json.loads((self.root/'authority.json').read_text())
            self.assertTrue(send(ticket(newer,self.good))['ok'])
            status=send({'op':'status'})
            self.assertTrue(status['baseline_certified'])
            self.assertIsNotNone(status['committed_digest'])
            persisted=json.loads((self.root/'authority.json').read_text())
            self.assertEqual(persisted['committed']['ticket']['source_hash'],'d'*64)
        finally:
            proc.terminate();proc.join(4)
            if proc.is_alive():proc.kill();proc.join(4)


if __name__=='__main__':
    unittest.main(verbosity=2)
