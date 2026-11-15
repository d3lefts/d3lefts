"""Independently composed exhaustive finite checks of finite_model.py.

This is a source-different auditor, not an independent human security review.
No database races, legal correctness, cryptographic protocols, or ballot privacy.
"""
from fractions import Fraction
from itertools import combinations, product
from finite_model import (
    Observation, minimum_nominal_certificate, robustly_authorized,
    Epoch, Passport, CurrentState, Effect, AtomicSink, permit,
)


def audit_information_certificates() -> tuple[int, int]:
    # For each Boolean world with 1..4 bits, every nonempty authorized-world set
    # containing the all-zero nominal, every positive integer cost vector in {1,2}^n,
    # compare target certificate to an independent dynamic program over bad-world masks.
    checked = 0
    impossible = 0
    for n in range(1, 5):
        worlds = [dict(zip((f'b{i}' for i in range(n)), bits)) for bits in product((0, 1), repeat=n)]
        nominal = worlds[0]
        for safe_mask in (range(1, 1 << len(worlds), 2) if n < 4 else
                          (1 | ((k * 0x9E37) & 0xFFFE) for k in range(128))):
            safe_set = {i for i in range(len(worlds)) if (safe_mask >> i) & 1}
            authorize = lambda w, ss=safe_set, ws=worlds: ws.index(w) in ss
            bad = [w for i, w in enumerate(worlds) if i not in safe_set]
            for prices in product((1, 2), repeat=n):
                qs = [Observation(f'b{i}', prices[i], lambda w, i=i: w[f'b{i}']) for i in range(n)]
                answer = minimum_nominal_certificate(worlds, nominal, qs, authorize)
                # DIFFERENT algorithm: iterate each unsafe alternative as a bit and
                # build minimal cost DP by covered-unsafe bitmask, rather than enumerate
                # selected query subsets as the implementation does.
                full = (1 << len(bad)) - 1
                dp = {0: Fraction(0)}
                for q in qs:
                    coverage = sum(1 << j for j, w in enumerate(bad) if q.read(w) != q.read(nominal))
                    nxt = dict(dp)
                    for mask, cost in dp.items():
                        nm = mask | coverage
                        nc = cost + q.cost
                        if nm not in nxt or nc < nxt[nm]:
                            nxt[nm] = nc
                    dp = nxt
                expected = dp.get(full)
                if expected is None:
                    impossible += 1
                    assert answer is None
                else:
                    assert answer is not None and answer[0] == expected, (n, safe_mask, prices, answer, expected)
                    answers = {k: nominal[k] for k in answer[1]}
                    assert robustly_authorized(worlds, answers, qs, authorize)
                    # Direct semantic replay: every unsafe world differs on a named observation.
                    assert all(any(w[k] != nominal[k] for k in answer[1]) for w in bad)
                checked += 1
    # Indistinguishability: authorization status is hidden from all observations.
    worlds = [{'ballot': 1, 'legal': 1}, {'ballot': 1, 'legal': 0}]
    qs = [Observation('ballot', 1, lambda w: w['ballot'])]
    assert minimum_nominal_certificate(worlds, worlds[0], qs, lambda w: w['legal'] == 1) is None
    assert not robustly_authorized(worlds, {'ballot': 1}, qs, lambda w: w['legal'] == 1)
    # Empty consistency class must not give vacuous permission.
    assert not robustly_authorized(worlds, {'ballot': 0}, qs, lambda w: w['legal'] == 1)
    return checked, impossible


def audit_guard() -> int:
    epoch = Epoch(1, 2, 3, 4, 5)
    p = Passport('UAH-DEMO', 'decision1', 'hash-p', 'hash-r', epoch, 'record', 10, 20,
                 True, True, True, True, True)
    s = CurrentState('UAH-DEMO', 'decision1', 'hash-p', 'hash-r', epoch, 10,
                     True, True, True, False, False)
    x = Effect('effect0', 'UAH-DEMO', 'decision1', 'record', 5)
    assert permit(p, s, x)
    sink = AtomicSink()
    assert sink.try_commit(p, s, x)
    assert not sink.try_commit(p, s, x)  # replay
    assert sink.invariant()
    # Cartesian toggle audit against an independent, feature-based oracle.
    checks = 0
    for flags in product((False, True), repeat=9):
        authenticated, ballot_ok, procedure_ok, legal_ok, rights_ok, authority_now, rights_now, budget_now, stayed = flags
        pp = Passport('UAH-DEMO', 'decision1', 'hash-p', 'hash-r', epoch, 'record', 10, 20,
                      authenticated, ballot_ok, procedure_ok, legal_ok, rights_ok)
        ss = CurrentState('UAH-DEMO', 'decision1', 'hash-p', 'hash-r', epoch, 10,
                          authority_now, rights_now, budget_now, stayed, False)
        expected = all(flags[:8]) and not stayed
        assert permit(pp, ss, x) == expected
        checks += 1
    # Attack each binding and current-world fact separately from a valid baseline.
    from dataclasses import replace
    bad_cases = [
        (p, replace(s, tenant='HOA'), x),
        (p, s, replace(x, tenant='HOA')),
        (p, replace(s, decision_id='other'), x),
        (p, s, replace(x, decision_id='other')),
        (p, replace(s, proposal_digest='other'), x),
        (p, replace(s, rule_digest='other'), x),
        (p, replace(s, epoch=replace(epoch, rule=9)), x),
        (p, replace(s, epoch=replace(epoch, electorate=9)), x),
        (p, replace(s, epoch=replace(epoch, legal=9)), x),
        (p, replace(s, epoch=replace(epoch, budget=9)), x),
        (p, replace(s, epoch=replace(epoch, appeals=9)), x),
        (p, replace(s, revoked=True), x),
        (p, replace(s, stayed=True), x),
        (p, replace(s, now=21), x),
        (p, s, replace(x, kind='spend')),
        (p, s, replace(x, amount=-1)),
        (p, s, replace(x, amount=11)),
    ]
    for pp, ss, xx in bad_cases:
        assert not permit(pp, ss, xx)
        old_count = len(sink.commits)
        assert not sink.try_commit(pp, ss, replace(xx, effect_id=f'attack-{checks}'))
        assert len(sink.commits) == old_count and sink.invariant()
        checks += 1
    # Time-of-check/time-of-use attack: old snapshot permits, new snapshot revoked.
    # In reality a stale check followed by an unguarded effect would be unsafe;
    # the model prohibits that by requiring the new, linearization-time snapshot.
    revoked = replace(s, revoked=True, epoch=replace(epoch, appeals=6))
    assert permit(p, s, x) and not permit(p, revoked, x)
    assert not sink.try_commit(p, revoked, Effect('after-revoke', x.tenant, x.decision_id, x.kind, x.amount))
    return checks


if __name__ == '__main__':
    certs, impossible = audit_information_certificates()
    guards = audit_guard()
    print(f'PASS: {certs} finite information instances, {impossible} impossible certificates; {guards} guard perturbations')
    print('Scope: finite, deterministic, coherent snapshots; no independent human, Lean, cryptographic or legal verification')
