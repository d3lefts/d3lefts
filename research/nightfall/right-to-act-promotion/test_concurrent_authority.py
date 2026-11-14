"""Interprocess revocation/publication serialization regression.

Independent local fixture uses a mocked synth to isolate the race.
Actual ControlArena CDK synthesis remains separately required in workflow.
"""
import json
import multiprocessing as mp
from pathlib import Path
import pytest
import promotion_runner as p
from test_effect_verifier import sample

@pytest.fixture
def context(tmp_path,monkeypatch):
    baseline,legit=sample()
    policy=tmp_path/'mission.json';policy.write_bytes(p.canon(p.POLICY))
    source=tmp_path/'candidate';source.mkdir();(source/'source.py').write_text('clean')
    monkeypatch.setattr(p,'synth',lambda _: (legit,0.0))
    monkeypatch.setattr(p,'check_promotion',lambda *_: {'fixture': 'verified'})
    dest=tmp_path/'trusted'/'template.json'
    return p.PromotionGate(baseline,policy,dest),baseline,policy,source,dest

def test_persisted_revocation_invalidates_prior_ticket_across_instances(context):
    gate,b,policy,source,dest=context
    ticket,_,_=gate.prepare(source)
    independent=p.PromotionGate(b,policy,dest)
    independent.revoke()
    ok,why,_=gate.promote(source,ticket)
    assert not ok and why=='revoked or epoch changed' and not dest.exists()
    with pytest.raises(RuntimeError,match='authority revoked'):
        p.PromotionGate(b,policy,dest).prepare(source)

def test_cross_baseline_reuse_rejected(context):
    gate,b,policy,source,dest=context
    with pytest.raises(RuntimeError,match='mismatched'):
        p.PromotionGate({'Resources':{'different':{}}},policy,dest)

def test_corrupted_durable_state_rejected(context):
    gate,b,policy,source,dest=context
    gate.state_path.write_text('invalid-json')
    with pytest.raises(ValueError):
        p.PromotionGate(b,policy,dest)

def _publisher(gate,source,ticket,entered,release,q):
    orig_replace=p.os.replace
    def intercept(src,dst):
        if str(dst)==str(gate.deployed):
            entered.set()
            assert release.wait(8),'publication release not received'
        return orig_replace(src,dst)
    p.os.replace=intercept
    ok,why,_=gate.promote(source,ticket)
    q.put(('publish',ok,why))

def _revoker(gate,completed,q):
    epoch=gate.revoke()
    q.put(('revoke',epoch))
    completed.set()

def test_distinct_process_race_has_common_linearization_order(context):
    gate,b,policy,source,dest=context
    ticket,_,_=gate.prepare(source)
    independent=p.PromotionGate(b,policy,dest)
    ctx=mp.get_context('fork')
    entered=ctx.Event();release=ctx.Event();completed=ctx.Event();queue=ctx.Queue()
    publisher=ctx.Process(target=_publisher,args=(gate,source,ticket,entered,release,queue))
    revoker=ctx.Process(target=_revoker,args=(independent,completed,queue))
    publisher.start()
    try:
        assert entered.wait(8),'did not reach protected publication'
        revoker.start()
        assert not completed.wait(0.3),'revocation returned before protected publication'
        release.set()
        publisher.join(10);revoker.join(10)
        assert publisher.exitcode==0 and revoker.exitcode==0
        first=queue.get(timeout=2);second=queue.get(timeout=2)
        assert first[0]=='publish' and first[1] is True
        assert second[0]=='revoke'
        assert dest.exists()
        durable=json.loads(gate.state_path.read_text())
        assert durable['revoked'] and durable['epoch']>=2
        assert p.PromotionGate(b,policy,dest)._read_state()==durable
    finally:
        release.set()
        if publisher.is_alive():publisher.terminate();publisher.join()
        if revoker.pid and revoker.is_alive():revoker.terminate();revoker.join()
