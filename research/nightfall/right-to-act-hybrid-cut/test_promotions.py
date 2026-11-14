import json
from fractions import Fraction
from pathlib import Path
from hybrid_cut import Network,Edge,solve
from promotion_kernel import LocalPromotionKernel

HERE=Path(__file__).parent
D=json.loads((HERE/'example_network.json').read_text())
NET=Network.from_dict(D)


def initial_gate():
    g=LocalPromotionKernel(NET)
    plan=solve(NET,'joint')
    t=g.ticket(plan['cut_source_side'])
    for edge in plan['selected_cut']:
        if edge['action']=='guard':
            g.set_guard(edge['id'])
        elif edge['action']=='recheck':
            assert g.install_certificate(edge['id'],edge['source_digest'],True)
        elif edge['action']=='reuse':
            assert edge['id'] in g.certificates
    return g,t,plan


def test_current_promotion():
    g,t,p=initial_gate()
    assert g.promote(t,'rehearsal')
    assert len(g.promotions)==1


def test_change_between_evidence_and_promotion_rejected():
    g,t,p=initial_gate()
    g.update_source('a','new-digest-a')
    assert not g.promote(t,'stale')
    assert not g.promotions


def test_policy_change_invalidates_cached_evidence():
    g,t,p=initial_gate()
    g.update_policy('mission-access-v2')
    assert not g.promote(t,'wrong-policy')
    assert not g.promotions


def test_revocation_prevents_new_promotion():
    g,t,p=initial_gate()
    g.revoke()
    assert not g.promote(t,'post-revocation')


def test_new_effect_path_not_covered_by_old_ticket():
    g,t,p=initial_gate()
    g.add_effect_path(Edge('bypass','agent','protected',Fraction(10),Fraction(10),Fraction(10),'x'))
    assert not g.promote(t,'path_added')
    assert g.reachable_unsafe()


def test_false_verification_never_installs_certificate():
    g=LocalPromotionKernel(NET)
    assert not g.install_certificate('b','b2',False)
    assert 'b' not in g.certificates


def test_digest_mismatch_never_installs_certificate():
    g=LocalPromotionKernel(NET)
    assert not g.install_certificate('b','incorrect',True)
    assert 'b' not in g.certificates


def test_receipt_cannot_rename_cut():
    from promotion_kernel import Ticket
    g,t,p=initial_gate()
    forged=Ticket(t.epoch,t.policy,t.side,())
    assert not g.promote(forged,'forged')


def test_guard_is_not_independently_proved_protected():
    # A test fixture can declare a guard without installing a real system guard.
    # Consequently kernel success proves only the modeled safety contract.
    g,t,p=initial_gate()
    assert g.promote(t,'abstract-only')
    actual_hidden_path=[('agent','protected')]
    assert actual_hidden_path # Disproves any assertion of full actual-system mediation.


def test_new_ticket_still_needs_current_certification():
    g,t,p=initial_gate()
    g.update_source('a','changed')
    refreshed=g.ticket(p['cut_source_side'])
    assert not g.promote(refreshed,'not-yet-recertified')
    assert g.install_certificate('a','changed',True)
    assert g.promote(refreshed,'recertified')
