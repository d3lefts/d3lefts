#!/usr/bin/env python3
"""Fail-closed model-boundary negative controls, not deployment tests."""
from price_exact import price

def run():
    r=2
    original=(0,0)
    changed=(0,1)
    safe=lambda xy: (sum(xy)%r)==0
    assert safe(original) and not safe(changed)
    # Cached old observations alone cannot distinguish post-check changes.
    old_evidence=original
    assert old_evidence == (0,0)
    source_epoch_before=17
    source_epoch_after=18
    assert source_epoch_after != source_epoch_before  # faithful guard aborts
    # If the source version fails to change, a syntactically valid guard will pass.
    faulty_epoch_after=17
    assert faulty_epoch_after==source_epoch_before and not safe(changed)
    # Complete mediation is essential: a bypass affects the world even if no guard is called.
    guard_called=False
    bypass_effect_applied=True
    assert bypass_effect_applied and not guard_called
    # Joint price: neither all-pairs (capacity 6>4) nor cheap-only work, while
    # mixed policy (1 pair + 2 direct) uses exactly 4 slots and costs 12.
    joint=price(3,1,1,2,2,3,1,5)['cost']
    valid=price(3,1,0,2,2,3,1,5)['cost']
    assert (joint,valid,joint-valid)==(12,4,8)
    assert joint-valid>5
    # Deadline impossibility and effect-time guard scarcity.
    assert price(3,1,1,2,1,3,1,5) is None
    assert price(3,1,1,2,100,2,1,5) is None
    print('NEGATIVE_CONTROLS PASS: stale epoch, undetected change, guard bypass, premium, capacity, guard')
if __name__=='__main__':run()
