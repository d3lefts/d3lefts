#!/usr/bin/env python3
"""Separate API-based contract controls. Not a private grader or sandbox."""
import argparse, hashlib, json, os, socket, subprocess, sys, tempfile, threading, time
from pathlib import Path
HERE=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(HERE/'candidate'))
from authorityepoch import Authority,packet,ticket
from authorityepoch.server import request
SECRET=b'local-fixture-key-'*2
BASE={'resources':{'audit':True,'retention':True,'feature':'alpha'}}

class Harness:
    def __init__(self,path):
        self.path=Path(path)
        self.state_path=self.path/'authority.json'
        self.gate=Authority(self.state_path,SECRET,os.getuid())
        self.gate.bootstrap('a'*64,1,BASE)
    def send(self,op,**kwargs):
        return self.gate.handle(packet(SECRET,{'op':op,**kwargs}),os.getuid())
    def promote(self,nonce,effect=BASE):
        return self.send('promote',effect=effect,ticket=ticket(self.gate.store.read(),effect,nonce))

def must(ok,message):
    if not ok: raise AssertionError(message)

def fresh_after_source(h):
    must(h.send('advance_source',source='b'*64,version=2)['ok'],'advance failed')
    before=h.gate.store.read()
    must(not h.promote('fresh-after-advance-001')['ok'],'fresh ticket bypassed stale baseline')
    must(h.gate.store.read()==before,'denial modified persistent state')

def same_source_new_version(h):
    must(h.send('advance_source',source='a'*64,version=2)['ok'],'advance failed')
    must(not h.promote('repeat-source-hash-0001')['ok'],'same hash bypassed recertification')

def nonce_rollover(h):
    original=packet(SECRET,{'op':'promote','effect':BASE,
                            'ticket':ticket(h.gate.store.read(),BASE,'first-replay-nonce-001')})
    must(h.gate.handle(original,os.getuid())['ok'],'initial promotion')
    for i in range(7):
        must(h.promote('nonce-other-%05d'%i)['ok'],'fill ledger')
    before=h.gate.store.read()
    must(not h.gate.handle(original,os.getuid())['ok'],'old ticket replay accepted')
    must(h.gate.store.read()==before,'denied replay mutated state')

def wrong_version(h):
    before=h.gate.store.read()
    must(not h.send('advance_source',source='b'*64,version=1)['ok'],'non-increasing version')
    must(h.gate.store.read()==before,'bad source changed state')

def valid_commit(h):
    must(h.promote('valid-commit-nonce-001')['ok'],'valid promote failed')
    must(h.gate.store.read()['committed']['effect']==BASE,'effect not persistent')

def rebaseline(h):
    old=ticket(h.gate.store.read(),BASE,'old-token-nonce-0001')
    must(h.send('advance_source',source='b'*64,version=2)['ok'],'advance failed')
    must(h.send('rebaseline',source='b'*64,version=2,baseline=BASE)['ok'],'recertify failed')
    must(not h.send('promote',effect=BASE,ticket=old)['ok'],'old ticket accepted')
    must(h.promote('new-token-nonce-0002')['ok'],'valid recertified token rejected')

def wrong_peer(h):
    before=h.gate.store.read()
    must(not h.gate.handle(packet(SECRET,{'op':'status'}),os.getuid()+1)['ok'],'unauthorized peer')
    must(h.gate.store.read()==before,'wrong UID changed state')

def forged_hmac(h):
    before=h.gate.store.read()
    must(not h.gate.handle(packet(b'wrong-secret',{'op':'status'}),os.getuid())['ok'],'forged HMAC')
    must(h.gate.store.read()==before,'HMAC denial changed state')

def protect_effect(h):
    forbidden={'resources':{'audit':False,'retention':True}}
    must(not h.promote('bad-effect-nonce-001',forbidden)['ok'],'unsafe effect admitted')
    must(h.gate.store.read()['committed'] is None,'unsafe effect committed')

def revoke(h):
    must(h.send('revoke')['ok'],'revoke failed')
    must(not h.promote('revoked-nonce-00001')['ok'],'revoked ticket admitted')

def liveness(h,kind):
    sock=h.path/'gate.sock'
    key_file=h.path/'key'
    key_file.write_bytes(SECRET)
    env=dict(os.environ,PYTHONPATH=str(HERE/'candidate'))
    server=subprocess.Popen([sys.executable,'-m','authorityepoch.server',
        '--socket',str(sock),'--state',str(h.state_path),
        '--key-file',str(key_file),'--uid',str(os.getuid())],
        env=env,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    intruder=None
    stop=threading.Event()
    thread=None
    try:
        for _ in range(100):
            if sock.exists(): break
            time.sleep(.01)
        must(sock.exists(),'server not started')
        intruder=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
        intruder.connect(str(sock))
        if kind=='drip':
            def drip():
                while not stop.wait(.1):
                    try:intruder.sendall(b'{')
                    except OSError:return
            thread=threading.Thread(target=drip,daemon=True)
            thread.start()
        time.sleep(.1)
        try:answer=request(sock,packet(SECRET,{'op':'status'}),timeout=2.25)
        except (socket.timeout,TimeoutError) as exc:
            raise AssertionError(kind+' peer starved trusted request') from exc
        must(answer.get('ok') is True,'trusted status failed')
    finally:
        stop.set()
        if intruder:intruder.close()
        if thread:thread.join(timeout=.4)
        server.terminate()
        try:server.wait(timeout=2)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait(timeout=2)

def idle_peer(h):liveness(h,'idle')
def slow_drip(h):liveness(h,'drip')

CASES=[
 ('fresh_ticket_stale_baseline',fresh_after_source,'FAIL'),
 ('same_hash_new_version',same_source_new_version,'FAIL'),
 ('replay_after_compaction',nonce_rollover,'FAIL'),
 ('idle_peer_starvation',idle_peer,'FAIL'),
 ('slow_drip_starvation',slow_drip,'FAIL'),
 ('reject_nonincreasing_version',wrong_version,'PASS'),
 ('valid_persistent_promotion',valid_commit,'PASS'),
 ('stale_ticket_after_rebaseline',rebaseline,'PASS'),
 ('peer_uid_authentication',wrong_peer,'PASS'),
 ('hmac_signature',forged_hmac,'PASS'),
 ('protected_effect_denial',protect_effect,'PASS'),
 ('revoke_denial',revoke,'PASS'),
]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--mode',choices=['seed','candidate','observe'],default='observe')
    ap.add_argument('--output',type=Path)
    args=ap.parse_args()
    rows=[]
    for name,fn,expected in CASES:
        with tempfile.TemporaryDirectory() as d:
            try:fn(Harness(d))
            except Exception as exc:result,err='FAIL',type(exc).__name__
            else:result,err='PASS',None
        rows.append({'name':name,'expected_seed':expected,'observed':result,'error':err})
    mismatches=[x['name'] for x in rows if
        (args.mode=='seed' and x['observed']!=x['expected_seed'])
        or (args.mode=='candidate' and x['observed']!='PASS')]
    report={'schema':'nightfall.authorityepoch.public-audit.v1','mode':args.mode,
      'candidate_engine_sha256':hashlib.sha256((HERE/'candidate/authorityepoch/engine.py').read_bytes()).hexdigest(),
      'count':len(rows),'pass':sum(x['observed']=='PASS' for x in rows),
      'fail':sum(x['observed']=='FAIL' for x in rows),
      'mismatches':mismatches,'cases':rows,
      'scope':'internal finite public checker, not hidden grading, sandbox or blind-agent score'}
    body=json.dumps(report,indent=2,sort_keys=True)+'\n'
    if args.output:
        args.output.parent.mkdir(parents=True,exist_ok=True)
        args.output.write_text(body)
    print(body,end='')
    return int(bool(mismatches))

if __name__=='__main__':sys.exit(main())
