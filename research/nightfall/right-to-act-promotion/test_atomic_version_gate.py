"""Exact local snapshot/version and interprocess linearization tests.

Synthesis/verification mocked in these unit tests; real ControlArena CDK
is independently exercised by run_atomic_version_experiment.py.
"""
import json
import multiprocessing as mp
import os
import pytest
import atomic_version_gate as m
from promotion_runner import POLICY,canon
from test_effect_verifier import sample

@pytest.fixture
def env(tmp_path,monkeypatch):
    b,legit=sample()
    source=tmp_path/'agent';source.mkdir()
    (source/'source.py').write_text('valid-v1')
    monkeypatch.setattr(m,'synth',lambda path:(legit,0.0))
    monkeypatch.setattr(m,'check_promotion',lambda *args:{'effect':'safe'})
    gate=m.VersionedGate(b,POLICY,tmp_path/'trusted')
    gate.admit(source)
    return gate,source,b

def test_unadmitted_external_edit_cannot_change_published_version(env):
    gate,source,_=env
    ticket,_,_=gate.prepare()
    (source/'source.py').write_text('untrusted later change')
    ok,_,_=gate.promote(ticket)
    assert ok
    record=json.loads(gate.published.read_text())
    assert record['source_hash']==ticket.source_hash
    assert record['policy_hash']==ticket.policy_hash
    assert record['version']==ticket.version

def test_trusted_new_source_invalidates_old_ticket(env):
    gate,source,_=env
    ticket,_,_=gate.prepare()
    (source/'source.py').write_text('new admitted version')
    gate.admit(source)
    ok,why,_=gate.promote(ticket)
    assert not ok and 'epoch' in why and not gate.published.exists()

def test_policy_epoch_invalidates_old_ticket(env):
    gate,source,_=env
    ticket,_,_=gate.prepare()
    gate.revise_policy(dict(POLICY,policy_version=2))
    ok,why,_=gate.promote(ticket)
    assert not ok and 'epoch' in why and not gate.published.exists()

def test_revocation_persists_across_gate_instances(env):
    gate,source,b=env
    ticket,_,_=gate.prepare()
    clone=m.VersionedGate(b,POLICY,gate.dir)
    clone.revoke()
    assert not gate.promote(ticket)[0]
    with pytest.raises(RuntimeError,match='revoked'):gate.prepare()

def test_corrupt_policy_hash_fails_closed(env):
    gate,source,_=env
    state=json.loads(gate.state_file.read_text())
    state['policy']['mission']='tampered'
    gate.state_file.write_bytes(canon(state))
    with pytest.raises(RuntimeError,match='corrupt'):gate.prepare()

def test_snapshot_tamper_fails_closed(env):
    gate,source,_=env
    ticket,_,_=gate.prepare()
    (gate.snapshots/ticket.version/'source.py').write_text('tampered')
    ok,why,_=gate.promote(ticket)
    assert not ok and 'verification failed' in why and not gate.published.exists()

def test_source_symlink_rejected(env):
    gate,source,_=env
    (source/'evil_link').symlink_to('/etc/passwd')
    with pytest.raises(ValueError):gate.admit(source)

def _hold_promote(gate,ticket,entered,release,q):
    original=os.replace
    def intercepted(src,dst):
        if str(dst)==str(gate.published):
            entered.set()
            assert release.wait(12)
        return original(src,dst)
    os.replace=intercepted
    result=gate.promote(ticket)
    q.put(('published',result[0]))

def _update(gate,source,kind,done,q):
    if kind=='source':
        result=gate.admit(source)
    else:
        result=gate.revise_policy(dict(POLICY,policy_version=2))
    q.put((kind,result))
    done.set()

@pytest.mark.parametrize('kind',['source','policy'])
def test_admission_and_policy_race_with_publication(env,kind):
    gate,source,_=env
    ticket,_,_=gate.prepare()
    if kind=='source':(source/'source.py').write_text('admitted v2')
    ctx=mp.get_context('fork')
    entered=ctx.Event();release=ctx.Event();done=ctx.Event();queue=ctx.Queue()
    publisher=ctx.Process(target=_hold_promote,args=(gate,ticket,entered,release,queue))
    updater=ctx.Process(target=_update,args=(gate,source,kind,done,queue))
    publisher.start()
    try:
        assert entered.wait(10)
        updater.start()
        assert not done.wait(0.25),'updated source/policy while publication had lock'
        release.set()
        publisher.join(12);updater.join(12)
        assert publisher.exitcode==0 and updater.exitcode==0
        first=queue.get(timeout=2);second=queue.get(timeout=2)
        assert first==('published',True) and second[0]==kind
        assert json.loads(gate.published.read_text())['epoch']==ticket.epoch
        assert not gate.promote(ticket)[0]
    finally:
        release.set()
        if publisher.is_alive():publisher.terminate();publisher.join()
        if updater.pid and updater.is_alive():updater.terminate();updater.join()
