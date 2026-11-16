"""Offline verifier for Commonwealth OS *fictional* exported receipts.

Only establishes internal consistency and possession of the corresponding LOCAL
fixture signing key. No external key authenticity, legal or election assurance.
"""
from __future__ import annotations
from hashlib import sha256
from pathlib import Path
import argparse
import base64
import json
import sys
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'workflow'))
from independent_checker import verify  # noqa: E402


def check(receipt):
    p=receipt['passport']; e=receipt['evidence']
    passed, failures=verify(p,e)
    problems=list(failures)
    entries=receipt.get('local_attestations',[])
    if not entries:problems.append('no local demo attestations supplied')
    event_roots={row['seq']:row['hash'] for row in e['events']}
    for a in entries:
        try:
            payload=a['payload']
            doc=json.dumps(payload,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()
            Ed25519PublicKey.from_public_bytes(base64.b64decode(a['public_key'],validate=True)).verify(
                base64.b64decode(a['signature'],validate=True),doc)
            if payload['event_root']!=event_roots.get(a['seq']):problems.append('local receipt root mismatch')
            if (payload['tenant'],payload['item_id'])!=(e['tenant'],e['item_id']):problems.append('local receipt scope mismatch')
            if payload['legal_authority'] is not False or payload['external_key_custody'] is not False:
                problems.append('unsupported legal attestation')
        except Exception as exc:
            problems.append('invalid local signature: '+type(exc).__name__)
    if len(entries)!=len({a.get('seq') for a in entries}):problems.append('duplicate local receipt sequence')
    return not problems,tuple(problems)


def main():
    parser=argparse.ArgumentParser(description='Verify a Commonwealth OS fictional demo evidence bundle')
    parser.add_argument('file',type=Path)
    args=parser.parse_args()
    result=check(json.loads(args.file.read_text()))
    print(json.dumps({'consistent':result[0],'errors':result[1],
                      'scope':'INTERNAL_REPLAY_AND_LOCAL_DEMO_SIGNATURE_ONLY'},indent=2))
    sys.exit(0 if result[0] else 1)

if __name__=='__main__':main()
