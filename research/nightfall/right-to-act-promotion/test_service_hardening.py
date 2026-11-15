"""Adversarial tests for *entire* authority-request handler lifetime.

No production test-only bypass exists: monkeypatching occurs only inside an
isolated test server process, before the real service forks its workers.
All tests use real Unix sockets and service-owned on-disk authority state.
"""
import json
import multiprocessing as mp
import os
import pathlib
import socket
import tempfile
import time
import authority_service as a

def _server(root, sock, uid, mode):
    original_process=a.process
    original_atomic=a.atomic
    def stalled_process(state, message, authorized_uid, key):
        if message.get('body',{}).get('op') == 'simulated_expensive_verifier':
            time.sleep(10.0)
        return original_process(state,message,authorized_uid,key)
    def stalled_atomic(path, obj):
        if mode=='persistence' and obj.get('epoch')==2:
            time.sleep(10.0)
        return original_atomic(path,obj)
    if mode=='verification':
        a.process=stalled_process
    if mode=='persistence':
        a.atomic=stalled_atomic
    a.serve(root,sock,uid)

def _prepare(root):
    root=pathlib.Path(root)
    key=b'K'*32
    (root/'shared_key').write_bytes(key)
    baseline={'Resources':{}}
    policy={'policy_version':1}
    a.initialize(root,{'version':'v1','source_hash':'a'*64,
      'policy_hash':a.digest(policy),'baseline_hash':a.digest(baseline)},
      baseline,policy)
    return key

def _start(mode, path, authorized_uid=None):
    root=pathlib.Path(path)
    key=_prepare(root)
    sock=root/'authority.sock'
    ctx=mp.get_context('fork')
    server=ctx.Process(target=_server,
        args=(str(root),str(sock),os.getuid() if authorized_uid is None else authorized_uid,mode))
    server.start()
    for _ in range(100):
        if sock.exists():break
        if not server.is_alive():raise RuntimeError('server exited')
        time.sleep(.01)
    assert sock.exists()
    return server,sock,key

def _stop(server):
    server.terminate()
    server.join(3)
    if server.is_alive():
        server.kill()
        server.join(3)

def test_expensive_authenticated_verifier_cannot_starve_following_request():
    with tempfile.TemporaryDirectory() as tmp:
        server,sock,key=_start('verification',tmp)
        try:
            started=time.monotonic()
            reply=a.request(sock,{'op':'simulated_expensive_verifier'},key)
            elapsed=time.monotonic()-started
            assert reply['reason']=='deadline_exceeded', reply
            assert elapsed<3.2,elapsed
            started=time.monotonic()
            status=a.request(sock,{'op':'status'},key)
            assert status['ok'] and status['epoch']==1,status
            assert time.monotonic()-started<1.2
        finally:_stop(server)

def test_stalled_persistence_does_not_starve_or_commit():
    with tempfile.TemporaryDirectory() as tmp:
        server,sock,key=_start('persistence',tmp)
        try:
            reply=a.request(sock,{'op':'advance','kind':'policy',
                                  'policy':{'policy_version':2}},key)
            assert reply['reason']=='deadline_exceeded',reply
            started=time.monotonic()
            status=a.request(sock,{'op':'status'},key)
            assert status['ok'] and status['epoch']==1,status
            assert time.monotonic()-started<1.2
        finally:_stop(server)

def test_kernel_peer_check_precedes_reading_untrusted_bytes():
    with tempfile.TemporaryDirectory() as tmp:
        server,sock,key=_start('normal',tmp,os.getuid()+100000)
        try:
            client=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
            client.connect(str(sock))
            # Attack sends no bytes and does not close its write half.
            started=time.monotonic()
            raw=client.recv(1024)
            assert json.loads(raw)['reason']=='unauthorized_os_principal'
            assert time.monotonic()-started<1.0
            client.close()
        finally:_stop(server)

def test_bounded_nonce_history_rotates_epoch_and_rejects_old_ticket():
    with tempfile.TemporaryDirectory() as tmp:
        root=pathlib.Path(tmp)
        key=_prepare(root)
        a.MAX_ACCEPTED_NONCES_PER_EPOCH=2
        original=a.check_promotion
        a.check_promotion=lambda *_: {}
        try:
            state=json.loads((root/'authority.json').read_text())
            template={'Resources':{}}
            def body(nonce):
                return {'op':'promote','ticket':{
                    'epoch':1,'version':'v1','source_hash':'a'*64,
                    'policy_hash':state['policy_hash'],
                    'baseline_hash':state['baseline_hash'],
                    'template_hash':a.digest(template),'nonce':nonce},
                    'template':template}
            one=body('a'*16)
            two=body('b'*16)
            new,first=a.process(state,{'__peer_uid__':os.getuid(),
                'body':one,'signature':a.sign(key,one)},os.getuid(),key)
            assert first['ok'] and len(new['nonces'])==1
            final,second=a.process(new,{'__peer_uid__':os.getuid(),
                'body':two,'signature':a.sign(key,two)},os.getuid(),key)
            assert second['ok'] and final['epoch']==2 and final['nonces']==[]
            _same,deny=a.process(final,{'__peer_uid__':os.getuid(),
                'body':one,'signature':a.sign(key,one)},os.getuid(),key)
            assert not deny['ok'] and deny['reason']=='stale_or_revoked_authority'
        finally:
            a.check_promotion=original
            a.MAX_ACCEPTED_NONCES_PER_EPOCH=256
