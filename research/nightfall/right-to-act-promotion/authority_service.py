#!/usr/bin/env python3
"""Trusted Linux-peer-authenticated, HMAC-authenticated local promotion service.

One protected JSON database contains authoritative source/policy epoch,
used nonces, and locally committed deployment template. Atomic local rename
is the ONLY protected effect in this experiment; no AWS deployment.
"""
from __future__ import annotations
import argparse, hashlib, hmac, json, os, pathlib, socket, struct, tempfile, time
from independent_effect_verifier import check_promotion, EffectViolation
MAX_REQUEST=900_000
CONNECTION_DEADLINE_SECONDS=2.0

def canon(obj):
    return (json.dumps(obj,sort_keys=True,separators=(',',':'),ensure_ascii=True)+'\n').encode()

def digest(obj):return hashlib.sha256(canon(obj)).hexdigest()
def sign(key,body):return hmac.new(key,canon(body),hashlib.sha256).hexdigest()
def verify(key,body,signature):
    return isinstance(signature,str) and hmac.compare_digest(sign(key,body),signature)

def atomic(path,obj):
    path=pathlib.Path(path)
    fd,tmp=tempfile.mkstemp(prefix='.trusted-',dir=path.parent)
    try:
        with os.fdopen(fd,'wb') as stream:
            os.fchmod(stream.fileno(),0o600)
            stream.write(canon(obj));stream.flush();os.fsync(stream.fileno())
        os.replace(tmp,path)
        directory_fd=os.open(path.parent,os.O_RDONLY)
        try:os.fsync(directory_fd)
        finally:os.close(directory_fd)
    finally:
        if os.path.exists(tmp):os.unlink(tmp)

def initialize(trust,record,baseline,policy):
    trust=pathlib.Path(trust)
    if (trust/'authority.json').exists():raise RuntimeError('refuse to reset existing trusted authority')
    assert digest(policy)==record['policy_hash'], 'upstream policy fingerprint disagreement'
    assert digest(baseline)==record['baseline_hash'], 'upstream baseline fingerprint disagreement'
    state={'epoch':1,'version':record['version'],'source_hash':record['source_hash'],
           'policy_hash':record['policy_hash'],'policy':policy,
           'baseline_hash':record['baseline_hash'],'baseline':baseline,
           'revoked':False,'nonces':[],'committed':None}
    atomic(trust/'authority.json',state)
    return state

def process(state,message,auth_uid,key):
    """Pure, fail-closed transition executed by one service process."""
    caller_uid=message.pop('__peer_uid__',None)
    if caller_uid!=auth_uid:return state,{'ok':False,'reason':'unauthorized_os_principal'}
    body=message.get('body')
    if not isinstance(body,dict) or not verify(key,body,message.get('signature')):
        return state,{'ok':False,'reason':'invalid_attestation_signature'}
    operation=body.get('op')
    if operation=='status':
        return state,{'ok':True,'epoch':state['epoch'],'revoked':state['revoked'],
                      'source_hash':state['source_hash'],'policy_hash':state['policy_hash'],
                      'version':state['version'],'committed_digest':(
                          digest(state['committed']) if state['committed'] else None)}
    if operation=='promote':
        t=body.get('ticket')
        template=body.get('template')
        if not isinstance(t,dict) or not isinstance(template,dict):
            return state,{'ok':False,'reason':'malformed_payload'}
        expected={'epoch','version','source_hash','policy_hash','baseline_hash','template_hash','nonce'}
        if set(t)!=expected or not isinstance(t['nonce'],str) or len(t['nonce'])<16:
            return state,{'ok':False,'reason':'malformed_ticket'}
        if state['revoked'] or any(t.get(k)!=state[k] for k in (
            'epoch','version','source_hash','policy_hash','baseline_hash')):
            return state,{'ok':False,'reason':'stale_or_revoked_authority'}
        if t['nonce'] in state['nonces']:
            return state,{'ok':False,'reason':'replayed_authorization'}
        if digest(template)!=t['template_hash']:
            return state,{'ok':False,'reason':'candidate_artifact_digest_mismatch'}
        try:check_promotion(state['baseline'],template,state['policy'])
        except (EffectViolation,ValueError,KeyError,TypeError) as exc:
            return state,{'ok':False,'reason':'independent_effect_verifier_denied',
                          'detail':str(exc)[:200]}
        new=dict(state)
        new['nonces']=[*state['nonces'],t['nonce']]
        new['committed']={'template':template,'ticket':t,
                         'template_hash':digest(template),'authority_epoch':state['epoch']}
        return new,{'ok':True,'reason':'committed_by_trusted_service',
                    'commit_sha256':digest(new['committed'])}
    if operation=='advance':
        kind=body.get('kind')
        new=dict(state)
        if state['revoked']:
            return state,{'ok':False,'reason':'revoked_authority_cannot_advance'}
        if kind=='policy':
            policy=body.get('policy')
            if not isinstance(policy,dict):return state,{'ok':False,'reason':'invalid_policy'}
            new.update(policy=policy,policy_hash=digest(policy))
        elif kind=='source':
            src=body.get('source_hash')
            version=body.get('version')
            if not isinstance(src,str) or len(src)!=64 or not isinstance(version,str):
                return state,{'ok':False,'reason':'invalid_source_version'}
            new.update(source_hash=src,version=version)
        else:return state,{'ok':False,'reason':'invalid_update_type'}
        new['epoch']=state['epoch']+1
        return new,{'ok':True,'epoch':new['epoch'],'reason':'trusted_version_advanced'}
    if operation=='revoke':
        new=dict(state,revoked=True,epoch=state['epoch']+1)
        return new,{'ok':True,'epoch':new['epoch'],'reason':'trusted_authority_revoked'}
    return state,{'ok':False,'reason':'unsupported_operation'}

def serve(trust,sockpath,authorized_uid):
    trust=pathlib.Path(trust)
    statefile=trust/'authority.json'
    key=(trust/'shared_key').read_bytes()
    assert len(key)>=32
    sockpath=pathlib.Path(sockpath)
    if sockpath.exists():sockpath.unlink()
    with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as server:
        server.bind(str(sockpath))
        os.chmod(sockpath,0o666) # deliberately broad; peer credentials MUST deny unknown principals
        server.listen(8);server.settimeout(60)
        print('READY',flush=True)
        while True:
            try:conn,_=server.accept()
            except socket.timeout:continue
            with conn:
                try:
                    pid,uid,gid=struct.unpack('3i',conn.getsockopt(
                        socket.SOL_SOCKET,socket.SO_PEERCRED,struct.calcsize('3i')))
                    # Absolute deadline: neither a silent client nor a slow
                    # dripper can own this single-threaded service indefinitely.
                    deadline=time.monotonic()+CONNECTION_DEADLINE_SECONDS
                    buf=b''
                    while len(buf)<MAX_REQUEST:
                        remaining=deadline-time.monotonic()
                        if remaining<=0:raise TimeoutError('request deadline expired')
                        conn.settimeout(min(remaining,0.5))
                        try:data=conn.recv(min(65536,MAX_REQUEST-len(buf)))
                        except socket.timeout:continue
                        if not data:break
                        buf+=data
                        if b'\n' in buf:break
                    if len(buf)>=MAX_REQUEST:raise ValueError('request too large')
                    req=json.loads(buf.partition(b'\n')[0]);req['__peer_uid__']=uid
                    state=json.loads(statefile.read_text())
                    new,response=process(state,req,authorized_uid,key)
                    if new is not state:atomic(statefile,new)
                except Exception as exc:
                    response={'ok':False,'reason':'invalid_request','type':type(exc).__name__}
                conn.sendall(canon(response))

def request(socket_path,body,key,override_signature=None):
    with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as client:
        client.settimeout(6);client.connect(str(socket_path))
        message={'body':body,'signature':override_signature or sign(key,body)}
        client.sendall(canon(message));client.shutdown(socket.SHUT_WR)
        data=b''
        while not data.endswith(b'\n'):
            buf=client.recv(65536)
            if not buf:break
            data+=buf
        return json.loads(data)

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('command',choices=['init','serve'])
    p.add_argument('--trust',required=True)
    p.add_argument('--sock')
    p.add_argument('--uid',type=int)
    p.add_argument('--record')
    p.add_argument('--baseline')
    p.add_argument('--policy')
    a=p.parse_args()
    if a.command=='serve':serve(a.trust,a.sock,a.uid)
    else:initialize(a.trust,json.loads(pathlib.Path(a.record).read_text()),
                    json.loads(pathlib.Path(a.baseline).read_text()),
                    json.loads(pathlib.Path(a.policy).read_text()))
