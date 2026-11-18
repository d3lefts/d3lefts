"""EXPERIMENTAL SCOPED MODE: identical local authority service except effect verifier.
This module is deliberately NOT a full mission guard and must never be
used for production authorization. See SCOPED_PERMISSION_GUARD_PROTOCOL.md.
"""
#!/usr/bin/env python3
"""Trusted Linux-peer-authenticated, HMAC-authenticated local promotion service.

One protected JSON database contains authoritative source/policy epoch,
used nonces, and locally committed deployment template. Atomic local rename
is the ONLY protected effect in this experiment; no AWS deployment.
"""
from __future__ import annotations
import argparse, hashlib, hmac, json, os, pathlib, select, signal, socket, struct, tempfile, time
from independent_effect_verifier import check_baseline, EffectViolation
from scoped_permission_guard import check_promotion
MAX_REQUEST=900_000
CONNECTION_DEADLINE_SECONDS=2.0
MAX_ACCEPTED_NONCES_PER_EPOCH=256

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
           'baseline_source_hash':record['source_hash'],
           'baseline_source_version':record['version'],
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
                      'version':state['version'],
                      'baseline_certified':(
                          state.get('baseline_source_hash')==state['source_hash'] and
                          state.get('baseline_source_version')==state['version']),
                      'committed_digest':(
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
        # A fresh ticket must never repair stale source-to-baseline custody.
        # Source advances require an explicit authenticated baseline refresh.
        if (state.get('baseline_source_hash') != state['source_hash'] or
                state.get('baseline_source_version') != state['version']):
            return state,{'ok':False,'reason':'baseline_requires_recertification'}
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
        # Bounded replay ledger: automatic epoch rotation invalidates every
        # outstanding old ticket before forgetting any used nonce.
        if len(new['nonces']) >= MAX_ACCEPTED_NONCES_PER_EPOCH:
            new['epoch']=state['epoch']+1
            new['nonces']=[]
        new['committed']={'template':template,'ticket':t,
                         'template_hash':digest(template),'authority_epoch':state['epoch']}
        return new,{'ok':True,'reason':'committed_by_trusted_service',
                    'commit_sha256':digest(new['committed'])}
    if operation=='rebaseline':
        # Only the authenticated issuer may attest a source-matched baseline.
        # check_baseline validates the template semantics, NOT the external
        # source-to-template correspondence. That remains a trusted premise.
        if state['revoked']:
            return state,{'ok':False,'reason':'revoked_authority_cannot_rebaseline'}
        baseline=body.get('baseline')
        if (body.get('source_hash') != state['source_hash'] or
                body.get('version') != state['version'] or
                not isinstance(baseline,dict)):
            return state,{'ok':False,'reason':'invalid_baseline_attestation'}
        try:check_baseline(baseline)
        except (EffectViolation,ValueError,KeyError,TypeError) as exc:
            return state,{'ok':False,'reason':'baseline_verification_denied',
                          'detail':str(exc)[:200]}
        new=dict(state,baseline=baseline,baseline_hash=digest(baseline),
                 baseline_source_hash=state['source_hash'],
                 baseline_source_version=state['version'],
                 epoch=state['epoch']+1,nonces=[])
        return new,{'ok':True,'epoch':new['epoch'],
                    'baseline_hash':new['baseline_hash'],
                    'reason':'baseline_recertified_for_current_source'}
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
            # Any new source epoch invalidates the old baseline's provenance.
            new.update(source_hash=src,version=version,
                       baseline_source_hash=None,baseline_source_version=None)
        else:return state,{'ok':False,'reason':'invalid_update_type'}
        new['epoch']=state['epoch']+1
        return new,{'ok':True,'epoch':new['epoch'],'reason':'trusted_version_advanced'}
    if operation=='revoke':
        new=dict(state,revoked=True,epoch=state['epoch']+1)
        return new,{'ok':True,'epoch':new['epoch'],'reason':'trusted_authority_revoked'}
    return state,{'ok':False,'reason':'unsupported_operation'}

def _serve_response(conn, response, deadline):
    """Bound socket writes; errors cannot stall the serial accept loop."""
    try:
        conn.settimeout(max(0.001, min(0.2, deadline-time.monotonic())))
        conn.sendall(canon(response))
    except (OSError, TimeoutError):
        pass

def _parse_framed_request(conn, deadline):
    """Read at most MAX_REQUEST bytes; no user-controlled idle timeout resets."""
    buf=bytearray()
    while len(buf)<MAX_REQUEST:
        remaining=deadline-time.monotonic()
        if remaining<=0:raise TimeoutError('request deadline expired')
        conn.settimeout(min(remaining,0.25))
        try:chunk=conn.recv(min(65536,MAX_REQUEST-len(buf)))
        except socket.timeout:continue
        if not chunk:break
        buf.extend(chunk)
        if b'\n' in chunk:break
    if len(buf)>=MAX_REQUEST:raise ValueError('request too large')
    if not buf:raise ValueError('empty request')
    return bytes(buf).partition(b'\n')[0]

def _reap_finished_workers():
    """Avoid zombie accumulation without an unbounded waitpid."""
    while True:
        try:child,_=os.waitpid(-1,os.WNOHANG)
        except ChildProcessError:break
        if child==0:break

def _evaluate_bounded(raw, statefile, authorized_uid, key, peer_uid,
                      deadline, server, conn):
    """Fork a disposable, same-UID worker so verifier/JSON/fsync hangs
    cannot indefinitely monopolize the parent's socket accept loop.

    Effect atomicity is a single-file rename, not a distributed transaction.
    An expired request can have committed just before the timeout: clients
    must reconcile via status/epoch and must not treat a timeout as rollback.
    """
    readfd,writefd=os.pipe()
    pid=os.fork()
    if pid==0:
        try:
            os.close(readfd)
            server.close()
            conn.close()
            try:
                message=json.loads(raw)
                if not isinstance(message,dict):raise ValueError('request must be object')
                message['__peer_uid__']=peer_uid
                state=json.loads(statefile.read_text())
                updated,response=process(state,message,authorized_uid,key)
                if updated is not state:atomic(statefile,updated)
            except BaseException as exc:
                response={'ok':False,'reason':'invalid_request',
                          'type':type(exc).__name__}
            payload=canon(response)
            # Only a bounded status response crosses this one-way pipe.
            os.write(writefd,payload[:4096])
        except BaseException:
            pass
        finally:
            os.close(writefd)
            os._exit(0)
    os.close(writefd)
    timed_out=False
    payload=b''
    try:
        remaining=deadline-time.monotonic()
        if remaining>0 and select.select([readfd],[],[],remaining)[0]:
            payload=os.read(readfd,4096)
        else:
            timed_out=True
    finally:
        os.close(readfd)
        if timed_out:
            try:os.kill(pid,signal.SIGKILL)
            except ProcessLookupError:pass
        # NEVER block waiting for an uninterruptible kernel-state worker.
        # On SIGKILL, reap opportunistically during subsequent iterations.
        done,_=os.waitpid(pid,os.WNOHANG)
        if done==0:
            try:os.kill(pid,signal.SIGKILL)
            except ProcessLookupError:pass
    if timed_out:return {'ok':False,'reason':'deadline_exceeded'}
    try:return json.loads(payload) if payload else {
        'ok':False,'reason':'worker_failed'}
    except (ValueError,UnicodeDecodeError):
        return {'ok':False,'reason':'invalid_worker_response'}

def serve(trust,sockpath,authorized_uid):
    trust=pathlib.Path(trust)
    statefile=trust/'authority.json'
    key=(trust/'shared_key').read_bytes()
    assert len(key)>=32
    sockpath=pathlib.Path(sockpath)
    if sockpath.exists():sockpath.unlink()
    with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as server:
        server.bind(str(sockpath))
        os.chmod(sockpath,0o666)  # untrusted clients may connect, not authorize
        server.listen(8);server.settimeout(60)
        print('READY',flush=True)
        while True:
            try:conn,_=server.accept()
            except socket.timeout:continue
            with conn:
                deadline=time.monotonic()+CONNECTION_DEADLINE_SECONDS
                try:
                    _pid,uid,_gid=struct.unpack('3i',conn.getsockopt(
                        socket.SOL_SOCKET,socket.SO_PEERCRED,struct.calcsize('3i')))
                    # Kernel-authenticate BEFORE reading attacker-controlled
                    # bytes: a silent unauthorized client consumes no deadline.
                    if uid!=authorized_uid:
                        response={'ok':False,'reason':'unauthorized_os_principal'}
                    else:
                        raw=_parse_framed_request(conn,deadline)
                        response=_evaluate_bounded(raw,statefile,authorized_uid,
                                                   key,uid,deadline,server,conn)
                except TimeoutError:
                    response={'ok':False,'reason':'deadline_exceeded'}
                except BaseException as exc:
                    response={'ok':False,'reason':'invalid_request',
                              'type':type(exc).__name__}
                _serve_response(conn,response,deadline)
            _reap_finished_workers()

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
