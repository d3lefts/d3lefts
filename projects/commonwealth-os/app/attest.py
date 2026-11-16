"""Synthetic event custody and LOCAL-KEY Ed25519 demo attestation.

Not a government PKI, externally anchored signature, or secure-election system.
"""
from __future__ import annotations
from dataclasses import asdict
from pathlib import Path
from hashlib import sha256
import base64
import json
import os
import sqlite3
import time
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey
from cryptography.hazmat.primitives import serialization


def canonical(d):
    return json.dumps(d,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()


def prepare_attest(connect,db_path):
    with connect(db_path) as c:
        c.executescript('''
        CREATE TABLE IF NOT EXISTS journal_entries (
          tenant TEXT NOT NULL, item_id TEXT NOT NULL, seq INTEGER NOT NULL,
          event_hash TEXT NOT NULL, event_json TEXT NOT NULL,
          PRIMARY KEY(tenant,item_id,seq),
          FOREIGN KEY(tenant,item_id) REFERENCES items(tenant,id));
        CREATE TRIGGER IF NOT EXISTS journal_no_update BEFORE UPDATE ON journal_entries
          BEGIN SELECT RAISE(ABORT,'immutable event journal'); END;
        CREATE TRIGGER IF NOT EXISTS journal_no_delete BEFORE DELETE ON journal_entries
          BEGIN SELECT RAISE(ABORT,'immutable event journal'); END;
        CREATE TABLE IF NOT EXISTS demo_attestations (
          tenant TEXT NOT NULL, item_id TEXT NOT NULL, seq INTEGER NOT NULL,
          scope TEXT NOT NULL, root TEXT NOT NULL, payload_json TEXT NOT NULL,
          signature TEXT NOT NULL, public_key TEXT NOT NULL, created_at INTEGER NOT NULL,
          PRIMARY KEY(tenant,item_id,seq),
          FOREIGN KEY(tenant,item_id) REFERENCES items(tenant,id));
        CREATE TRIGGER IF NOT EXISTS attest_no_update BEFORE UPDATE ON demo_attestations
          BEGIN SELECT RAISE(ABORT,'immutable demo attestation'); END;
        CREATE TRIGGER IF NOT EXISTS attest_no_delete BEFORE DELETE ON demo_attestations
          BEGIN SELECT RAISE(ABORT,'immutable demo attestation'); END;
        ''')
        # Allows fixture DB upgrades without altering past event hashes.
        for row in c.execute('SELECT tenant,id,state_json FROM items'):
            state=json.loads(row['state_json'])
            for ev in state['events']:
                c.execute('INSERT OR IGNORE INTO journal_entries VALUES (?,?,?,?,?)',
                    (row['tenant'],row['id'],ev['seq'],ev['hash'],json.dumps(ev,sort_keys=True,separators=(',',':'))))


def check_custody(conn,w):
    rows=conn.execute('SELECT seq,event_hash,event_json FROM journal_entries WHERE tenant=? AND item_id=? ORDER BY seq',
                      (w.tenant,w.item_id)).fetchall()
    if len(rows)!=len(w.events):return False
    for row,ev in zip(rows,w.events):
        if row['seq']!=ev.seq or row['event_hash']!=ev.hash:
            return False
        if json.loads(row['event_json'])!=asdict(ev):
            return False
    # Reconstruct snapshot fields independently from the immutable event rows.
    # This catches a modified cached JSON status/text/tally even when event hashes
    # have not changed. It is not a complete formal replay of jurisdictional law.
    try:
        stage=None; text=None; rev=None; votes=[]; certifier=''; tally=None
        reviewers=[]; publication=''; locked=''; rule_lock=''; roster_lock=''
        from hashlib import sha256
        from workflow_model import digest
        next_states={'SUBMIT_REVIEW':'IN_REVIEW','SET_AGENDA':'AGENDA_SET',
            'OPEN_DEBATE':'DELIBERATING','LOCK_MOTION':'MOTION_LOCKED',
            'OPEN_BALLOT':'BALLOT_OPEN','CLOSE_BALLOT':'BALLOT_CLOSED'}
        for ev in w.events:
            name=ev.name; payload=ev.payload
            if name in ('CREATE','AMEND'):
                text=payload['text'];rev=payload['revision'];stage='DRAFT'
            elif name in next_states:
                stage=next_states[name]
                if name=='LOCK_MOTION':
                    locked=payload['motion'];rule_lock=payload['rule'];roster_lock=digest(sorted(w.roster))
            elif name=='CAST':
                votes.append((ev.actor,payload['choice']))
            elif name=='CERTIFY':
                stage=payload['outcome'];tally=tuple(payload['tally']);certifier=ev.actor
            elif name=='PREPARE_PUBLICATION':stage='PUBLICATION_REVIEW'
            elif name=='REVIEW_PUBLICATION':reviewers.append(ev.actor)
            elif name=='APPROVE_PUBLICATION_PREVIEW':
                reviewers.append(ev.actor);stage='PUBLISHED';publication=payload['public_projection_hash']
            elif name=='VOID':stage='VOIDED'
            else:return False
        return (stage==w.status and text==w.text and rev==w.revision and
            tuple(votes)==w.casts and certifier==w.certifier and tally==w.tally and
            tuple(reviewers)==w.release_reviewers and publication==w.publication_hash and
            locked==w.locked_motion_hash and rule_lock==w.locked_rule_hash and
            roster_lock==w.locked_roster_hash and w.mode in ('DEMO','ADVISORY'))
    except (ValueError,TypeError,KeyError,AttributeError):
        return False


def add_journal(conn,w):
    e=w.events[-1]
    conn.execute('INSERT INTO journal_entries VALUES (?,?,?,?,?)',
                 (w.tenant,w.item_id,e.seq,e.hash,json.dumps(asdict(e),sort_keys=True,separators=(',',':'))))


def _keyfile(db_path):return Path(str(db_path)+'.demo-ed25519')


def load_key(db_path):
    """Local file key for fictional demonstration ONLY; no external trust anchor."""
    p=_keyfile(db_path)
    if not p.exists():
        key=Ed25519PrivateKey.generate()
        raw=key.private_bytes(serialization.Encoding.Raw,serialization.PrivateFormat.Raw,serialization.NoEncryption())
        try:
            fd=os.open(str(p),os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600)
        except FileExistsError:pass
        else:
            with os.fdopen(fd,'wb') as f:f.write(raw)
    return Ed25519PrivateKey.from_private_bytes(p.read_bytes())


def public_key(key):
    raw=key.public_key().public_bytes(serialization.Encoding.Raw,serialization.PublicFormat.Raw)
    return base64.b64encode(raw).decode()


def issue_attestation(conn,w,db_path):
    if w.status not in ('CERTIFIED','REJECTED','PUBLISHED'):
        raise ValueError('Attestations require a completed simulated decision')
    payload={'scheme':'CW-LOCAL-ED25519-DEMO-v1','tenant':w.tenant,'item_id':w.item_id,
             'event_root':w.log_root,'event_seq':len(w.events),
             'status':w.status,'motion_hash':w.locked_motion_hash,
             'tally':list(w.tally),'legal_authority':False,'external_key_custody':False}
    key=load_key(db_path)
    sig=base64.b64encode(key.sign(canonical(payload))).decode()
    conn.execute('INSERT INTO demo_attestations VALUES (?,?,?,?,?,?,?,?,?)',
                 (w.tenant,w.item_id,len(w.events),'PUBLIC_PREVIEW' if w.status=='PUBLISHED' else 'DEMO_DECISION',
                  w.log_root,canonical(payload).decode(),sig,public_key(key),int(time.time())))


def verify_one(row):
    try:
        payload=json.loads(row['payload_json'])
        key=Ed25519PublicKey.from_public_bytes(base64.b64decode(row['public_key'],validate=True))
        key.verify(base64.b64decode(row['signature'],validate=True),canonical(payload))
        return payload.get('event_root')==row['root'] and payload.get('legal_authority') is False and payload.get('external_key_custody') is False
    except Exception:
        return False


def attestation_bundle(conn,w):
    rows=conn.execute('SELECT * FROM demo_attestations WHERE tenant=? AND item_id=? ORDER BY seq',(w.tenant,w.item_id)).fetchall()
    byseq={ev.seq:ev.hash for ev in w.events}
    out=[]
    for row in rows:
        entry=dict(row)
        entry['verified_local_signature']=verify_one(row) and byseq.get(row['seq'])==row['root']
        entry['payload']=json.loads(entry.pop('payload_json'))
        out.append(entry)
    return out
