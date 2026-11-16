#!/usr/bin/env python3
"""Independent exact-integer checker for NIGHTFALL dynamic checkpoint bridge.
Does not establish Lean proof, genuine privacy, or physical effect mediation.
"""
from itertools import product
from hashlib import sha256
from json import dumps

capacity_cases=0
for R, total, spent, c, d, raw, predicate in product(
    range(0,5), range(0,10), range(0,10),
    range(0,3), range(0,5), range(0,3), range(0,3)):
    if spent>total or d+predicate < 2*(c+raw):
        continue
    cap=total-spent
    prices=[]
    for paired in range(R+1):
        direct=R-paired
        if 2*paired+direct<=cap:
            prices.append(2*(c+raw)*paired+(d+predicate)*direct)
    expected=(2*(c+raw)*R
              +(d+predicate-2*(c+raw))*max(0,2*R-cap))
    assert (cap>=R)==bool(prices), ('FEASIBILITY',R,total,spent)
    if prices:
        assert min(prices)==expected, ('PRICE',R,total,spent,prices,expected)
    capacity_cases+=1

# Correlated source W_old={(0,0),(1,1)}, W_new=all 4 pairs.
worlds=list(product((0,1),repeat=2))
read={
  'left':lambda w:w[0],
  'right':lambda w:w[1],
  'predicate_only':lambda w:int(w[0]==w[1])
}
nominal=(0,0)
def certifies(support,selected):
    return all(w[0]==w[1] or any(read[s](w)!=read[s](nominal)
                     for s in selected) for w in support)
assert certifies([w for w in worlds if w[0]==w[1]],())
assert not certifies(worlds,())
assert certifies(worlds,('predicate_only',))
assert not certifies(worlds,('left',))
assert not certifies(worlds,('right',))
coverage_checks=0
for mask in range(16):
    support=[w for i,w in enumerate(worlds) if mask & (1<<i)]
    for allowed_bits in range(8):
        allowed={s for i,s in enumerate(read) if allowed_bits & (1<<i)}
        for subset_bits in range(8):
            selected=tuple(s for i,s in enumerate(read) if subset_bits & (1<<i))
            feasible=set(selected).issubset(allowed)
            # Algorithm A: evaluate safety of all states with same transcript.
            actual=all(w[0]==w[1] for w in support if
                       all(read[s](w)==read[s](nominal) for s in selected))
            # Independent algorithm B: hit each unsafe state by a sensor that
            # changes its value between nominal and counterexample.
            cover=all(any(read[s](w)!=read[s](nominal) for s in selected)
                      for w in support if w[0]!=w[1])
            assert not feasible or actual==cover, ('COVER',mask,subset_bits,allowed_bits)
            coverage_checks+=1
receipt={
    'capacity_cases':capacity_cases,
    'correlation_privacy_cases':coverage_checks,
    'failures':0,
    'checkpoint_model':'one change followed by stable suffix',
    'privacy_scope':'allowlisted predicate disclosure, not differential privacy',
    'counterexample':'zero-read certificate valid on correlated support, invalid on enlarged support'
}
payload=dumps(receipt,sort_keys=True,separators=(',',':')).encode()
receipt['sha256']=sha256(payload).hexdigest()
print(dumps(receipt,sort_keys=True,indent=2))
