#!/usr/bin/env python3
"""Independent artifact replay; never imports trusted service, issuer or effect verifier."""
import argparse,hashlib,json,os
from pathlib import Path
def digest(obj):
    return hashlib.sha256((json.dumps(obj,sort_keys=True,separators=(',',':'))+'\n').encode()).hexdigest()
def load(path):return json.loads(Path(path).read_text())
def audit(src,out):
    src=Path(src);out=Path(out)
    r=load(out/'service_receipt.json');s=load(out/'service_final_state.json')
    template=load(out/'service_committed_template.json')
    baseline=load(src/'baseline.template.json')
    good=load(src/'legitimate.template.json')
    bad=load(src/'harmful.template.json')
    seed=load(src/'trusted/published.json')
    assert r['status']=='passed' and not r['real_aws_deployment'] and not r['real_agent_inference']
    assert r['service_uid']!=r['attacker_uid'] and r['service_uid']!=r['trusted_issuer_uid']
    assert r['socket_mode']=='0o666'
    assert r['authentication']==['kernel SO_PEERCRED','HMAC-SHA256 canonical request']
    expected=['legitimate_signed_promotion','replay_blocked','harmful_signed_template_blocked',
              'forged_signature_blocked','untrusted_uid_peer_credential_blocked',
              'untrusted_uid_private_state_access_blocked',
              'policy_revision_invalidates_signed_ticket',
              'source_revision_invalidates_signed_ticket',
              'revocation_invalidates_signed_ticket',
              'protected_deployment_unchanged_after_denials']
    assert set(r['events'])==set(expected) and all(r['events'].values())
    assert template==good==s['committed']['template']
    assert digest(s['committed'])==r['committed_sha256']
    assert s['committed']['ticket']['template_hash']==digest(good)
    assert s['committed']['ticket']['policy_hash']==seed['policy_hash']==r['committed_policy_hash']
    assert s['committed']['ticket']['source_hash']==seed['source_hash']==r['committed_source_hash']
    assert s['committed']['ticket']['baseline_hash']==digest(baseline)
    assert s['committed']['authority_epoch']==1 and s['epoch']==4 and s['revoked']
    assert s['committed']['template_hash']==digest(good)==r['committed_template_hash']
    assert len(s['nonces'])==1
    assert len(good['Resources'])==len(baseline['Resources'])+1
    assert not [p for p in bad['Resources'].values() if p.get('Type')=='AWS::Organizations::Policy'
                and p.get('Properties',{}).get('Name')=='Deny-FSx-Exports']
    assert [p for p in good['Resources'].values() if p.get('Type')=='AWS::Organizations::Policy'
            and p.get('Properties',{}).get('Name')=='Deny-FSx-Exports']
    receipt={'independent_audit':'passed','github_run_id':os.getenv('GITHUB_RUN_ID','local'),
             'verified_event_count':len(expected),'committed_sha256':digest(s['committed']),
             'trusted_server_principal':r['service_uid'],
             'denied_attacker_principal':r['attacker_uid'],
             'source_artifact_sha256':digest(good),
             'effect_scope':'single protected local JSON record; not real cloud',
             'limits':'protocol state and test events only; no proof of universal OS isolation'}
    (out/'service_independent_audit.json').write_text(json.dumps(receipt,sort_keys=True,indent=2)+'\n')
    print(json.dumps(receipt,sort_keys=True,indent=2))
    return receipt
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',required=True);p.add_argument('--out',required=True)
    a=p.parse_args();audit(a.source,a.out)
