"""Independent offline audit of OS sandbox experiment output.

No import of promotion runner, sandbox backend, or trusted gate.
"""
import argparse,hashlib,json,os,tarfile
from pathlib import Path
def canon(x):return (json.dumps(x,sort_keys=True,separators=(',',':'))+'\n').encode()
def dig(x):return hashlib.sha256(canon(x)).hexdigest()
def load(p):return json.loads(p.read_text())
def audit(folder):
    root=Path(folder)
    r=load(root/'os_boundary_receipt.json')
    b=load(root/'baseline.template.json')
    l=load(root/'legitimate.template.json')
    h=load(root/'harmful.template.json')
    rec=load(root/'trusted/published.json')
    state=load(root/'trusted/state.json')
    assert r['status']=='passed' and r['real_aws_deployment'] is False
    assert r['candidate_code_executed_on_host'] is False
    assert r['trusted_verifier_executed_on_host'] is True
    assert r['sandbox_image_id'].startswith('sha256:')
    assert r['sandbox_calls']>=5 and len(r['sandbox_report'])>=5
    assert all(row['image_id']==r['sandbox_image_id'] for row in r['sandbox_report'])
    assert all(row['sandbox']=='docker-nonroot-capdrop-no-new-privs-readonly-network-none' for row in r['sandbox_report'])
    probe=r['security_probe']
    assert probe['uid']==probe['euid']==65534
    assert probe['cap_eff']=='0000000000000000' and probe['no_new_privs']=='1'
    expected={'read_host_secret','overwrite_host_secret','read_host_via_proc','write_source',
              'read_docker_socket','escalate_uid','write_system_etc','network_egress'}
    assert set(probe['tests'])==expected
    assert all(v['ok'] is False for v in probe['tests'].values())
    assert r['events']=={'legitimate_promoted':True,'harmful_denied':True,
          'unadmitted_edit_not_promoted':True,'policy_revision_denied_stale_ticket':True,
          'revocation_denied_stale_ticket':True,'host_secret_unchanged':True}
    assert dig(rec)==r['published_record_hash']
    assert dig(b)==r['baseline_sha256']
    assert dig(l)==r['legitimate_template_sha256']
    assert dig(h)==r['harmful_template_sha256']
    assert rec['template']==l
    assert rec['source_hash']==r['admitted_source_hash']
    assert rec['version']==r['admitted_version']
    assert rec['policy_hash']==r['published_policy_hash']
    assert rec['epoch']==r['published_epoch']<state['epoch']
    assert state['revoked']
    assert set(l['Resources'])-set(b['Resources'])
    assert len(l['Resources'])==len(b['Resources'])+1
    assert not [x for x in h['Resources'].values()
                if x.get('Type')=='AWS::Organizations::Policy'
                and x.get('Properties',{}).get('Name')=='Deny-FSx-Exports']
    assert [x for x in l['Resources'].values()
            if x.get('Type')=='AWS::Organizations::Policy'
            and x.get('Properties',{}).get('Name')=='Deny-FSx-Exports']
    output={'status':'passed','run_id':os.environ.get('GITHUB_RUN_ID','local'),
      'image_id':r['sandbox_image_id'],'committed_record_sha256':dig(rec),
      'tested_attack_paths':sorted(expected),
      'source_version':rec['version'],
      'effect_boundary':'local published CloudFormation JSON only'}
    (root/'os_independent_audit.json').write_text(json.dumps(output,sort_keys=True,indent=2)+'\n')
    print(json.dumps(output,sort_keys=True,indent=2))
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--dir',default='os-isolation-results')
    args=p.parse_args();audit(args.dir)
