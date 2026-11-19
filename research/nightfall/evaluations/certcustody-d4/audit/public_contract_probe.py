#!/usr/bin/env python3
"""Finite separate proof-custody attack suite; no Lean replay or hidden model grade."""
import argparse, hashlib, json, shutil, sys, tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'candidate'))
from certcustody import verify_checkout, git_blob

FIXTURE=ROOT/'candidate/fixture'
KEY=(FIXTURE/'fixture.key').read_bytes()

def edit_manifest(root,fn):
    p=root/'manifest.json';d=json.loads(p.read_text())
    fn(d);p.write_text(json.dumps(d,sort_keys=True,indent=2)+'\n')

def edit_receipts(root,fn):
    p=root/'trusted_receipts.json';d=json.loads(p.read_text())
    fn(d);p.write_text(json.dumps(d,sort_keys=True,indent=2)+'\n')

def checked_tamper(root):
    (root/'sources/Alpha.lean').write_text('replacement')
def pending_tamper(root):
    (root/'sources/Beta.lean').write_text('changed pending source without attestation')
def unknown_file(root):
    (root/'sources/Gamma.lean').write_text('example : True := trivial')
def duplicate_path(root):
    edit_manifest(root,lambda m:m['records'].append(dict(m['records'][1],claim_id='BETA-TWO')))
def duplicate_claim(root):
    edit_manifest(root,lambda m:m['records'][1].update(claim_id='ALPHA'))
def wrong_hmac(root):
    edit_receipts(root,lambda d:d['receipts'][0].update(hmac='0'*64))
def forged_theorem(root):
    edit_manifest(root,lambda d:d['records'][0].update(theorem='Example.wrong'))
def forged_ci_head(root):
    edit_manifest(root,lambda d:d['records'][0].update(ci_head='b'*40))
def wrong_receipt_source(root):
    edit_receipts(root,lambda d:d['receipts'][0]['body'].update(source_path='sources/Beta.lean'))
def pending_ci(root):
    edit_manifest(root,lambda d:d['records'][1].update(ci_run=222,ci_head='f'*40,theorem='Fake.theorem'))
def fake_priority(root):
    edit_manifest(root,lambda d:d['records'][1].update(priority='proven-novel'))
def symlink_escape(root):
    external=root.parent/'external.lean';external.write_text('example : True := trivial')
    (root/'sources/External.lean').symlink_to(external)
    edit_manifest(root,lambda m:m['records'].append({
        'path':'sources/External.lean','status':'pending','claim_id':'EXTERNAL',
        'blob_sha1':git_blob(external.read_bytes()),'ci_head':None,'ci_run':None,
        'theorem':None,'priority':'unverified'}))
def traversal(root):
    other=root.parent/'outside.lean';other.write_text('example : True := trivial')
    edit_manifest(root,lambda m:m['records'].append({
        'path':'../outside.lean','status':'pending','claim_id':'OUTSIDE',
        'blob_sha1':git_blob(other.read_bytes()),'ci_head':None,'ci_run':None,
        'theorem':None,'priority':'unverified'}))
def duplicate_receipt(root):
    edit_receipts(root,lambda d:d['receipts'].append(dict(d['receipts'][0])))
def reorder(root):
    edit_manifest(root,lambda m:m['records'].reverse())
def missing(root):
    (root/'sources/Beta.lean').unlink()

# Predicted baseline behavior frozen before the CI run. These expectations
# characterize the broken seed; they are not the contract of a correct repair.
CASES=[
 ('clean_fixture',lambda _:None,'ACCEPT','ACCEPT'),
 ('reordered_manifest',reorder,'ACCEPT','ACCEPT'),
 ('changed_checked_source',checked_tamper,'REJECT','REJECT'),
 ('changed_pending_source',pending_tamper,'ACCEPT','REJECT'),
 ('unregistered_lean_file',unknown_file,'ACCEPT','REJECT'),
 ('duplicate_manifest_path',duplicate_path,'ACCEPT','REJECT'),
 ('duplicate_claim_id',duplicate_claim,'ACCEPT','REJECT'),
 ('forged_receipt_hmac',wrong_hmac,'ACCEPT','REJECT'),
 ('changed_theorem_name',forged_theorem,'ACCEPT','REJECT'),
 ('changed_ci_commit',forged_ci_head,'ACCEPT','REJECT'),
 ('receipt_for_wrong_source',wrong_receipt_source,'ACCEPT','REJECT'),
 ('pending_claims_success',pending_ci,'ACCEPT','REJECT'),
 ('pending_claims_novelty',fake_priority,'ACCEPT','REJECT'),
 ('symlink_outside_sources',symlink_escape,'ACCEPT','REJECT'),
 ('traversal_outside_sources',traversal,'ACCEPT','REJECT'),
 ('duplicate_signed_receipt',duplicate_receipt,'ACCEPT','REJECT'),
 ('missing_registered_source',missing,'REJECT','REJECT'),
]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--mode',choices=['seed','candidate','observe'],default='observe')
    ap.add_argument('--output',type=Path)
    args=ap.parse_args()
    rows=[]
    for name,mutation,seed,required in CASES:
        with tempfile.TemporaryDirectory(prefix='nf-custody-') as tmp:
            checkout=Path(tmp)/'project'
            shutil.copytree(FIXTURE,checkout)
            mutation(checkout)
            try:
                obj=verify_checkout(checkout,checkout/'trusted_receipts.json',KEY)
                if obj.get('schema')!='nightfall.certcustody.report.v1':
                    raise ValueError('invalid report')
                actual,err='ACCEPT',None
            except Exception as exc:
                actual,err='REJECT',type(exc).__name__
        rows.append({'case':name,'seed_expected':seed,'corrected_required':required,
                     'observed':actual,'error':err})
    mismatches=[x['case'] for x in rows if
        (args.mode=='seed' and x['observed']!=x['seed_expected'])
        or (args.mode=='candidate' and x['observed']!=x['corrected_required'])]
    report={'schema':'nightfall.certcustody.public-probe.v1','mode':args.mode,
      'candidate_audit_sha256':hashlib.sha256((ROOT/'candidate/certcustody/audit.py').read_bytes()).hexdigest(),
      'total':len(rows),'accepted':sum(x['observed']=='ACCEPT' for x in rows),
      'rejected':sum(x['observed']=='REJECT' for x in rows),'mismatches':mismatches,
      'cases':rows,'scope':'internal finite semantic probe; not a private grader, Lean run or model result'}
    result=json.dumps(report,sort_keys=True,indent=2)+'\n'
    if args.output:
        args.output.parent.mkdir(parents=True,exist_ok=True)
        args.output.write_text(result)
    print(result,end='')
    return int(bool(mismatches))
if __name__=='__main__':
    sys.exit(main())
