"""Toy cross-layer evidence covering cost: brute force vs independent subset-DP.
This is a classical weighted set cover problem, not a new algorithm/theorem.
"""
from itertools import combinations
from pathlib import Path
import json

REQUIREMENTS = ('electorate','tally','legal','freshness','budget','effect')
OPERATIONS = (
    ('roster-audit',3,('electorate',)),
    ('tally-audit',4,('tally',)),
    ('legal-opinion',5,('legal',)),
    ('fresh-source-check',3,('freshness',)),
    ('budget-check',3,('budget',)),
    ('atomic-guard',4,('effect',)),
    ('combined-roster-tally',6,('electorate','tally')),
    ('joint-authority-evidence',8,('legal','freshness','budget')),
    ('guard-and-refresh',5,('freshness','effect')),
)

def enumerated_minimum():
    target=set(REQUIREMENTS); winners=[]; optimum=None
    for n in range(len(OPERATIONS)+1):
        for chosen in combinations(OPERATIONS,n):
            covered=set().union(*(set(o[2]) for o in chosen)) if chosen else set()
            if target<=covered:
                price=sum(x[1] for x in chosen)
                if optimum is None or price<optimum:
                    optimum=price; winners=[[x[0] for x in chosen]]
                elif price==optimum:
                    winners.append([x[0] for x in chosen])
    return optimum,winners

def dynamic_minimum():
    # Different algorithm: state over covered obligations, not subset enumeration.
    bits={r:1<<i for i,r in enumerate(REQUIREMENTS)}
    goal=(1<<len(REQUIREMENTS))-1
    states={0:(0,())}
    for label,cost,covers in OPERATIONS:
        mask=sum(bits[r] for r in covers)
        nxt=dict(states)
        for have,(price,items) in states.items():
            dest=have|mask; proposed=price+cost
            if dest not in nxt or proposed<nxt[dest][0]:
                nxt[dest]=(proposed,items+(label,))
        states=nxt
    return states[goal]

def main():
    price,winners=enumerated_minimum()
    alt,items=dynamic_minimum()
    assert price==alt
    assert price==18, (price,alt)
    separate=sum(next(x[1] for x in OPERATIONS if r in x[2] and len(x[2])==1) for r in REQUIREMENTS)
    assert separate==22
    record={'model':'toy-democratic-assurance-evidence-cover-v0.2',
            'status':'passed', 'requirements':list(REQUIREMENTS),
            'isolated_evidence_cost':separate,'joint_evidence_cost':price,
            'joint_witnesses':winners,'dp_witness':list(items),
            'saving_in_synthetic_units':separate-price,
            'methods':['full-subset-enumeration','bitmask-dynamic-programming'],
            'scope':'illustrative weighted set cover; toy operation prices and coverage; no empirical democratic cost estimate; not a novel algorithm'}
    Path(__file__).with_name('dap_cost_receipt.json').write_text(json.dumps(record,indent=2,sort_keys=True)+'\n')
    print(json.dumps(record,sort_keys=True))

if __name__=='__main__':main()
