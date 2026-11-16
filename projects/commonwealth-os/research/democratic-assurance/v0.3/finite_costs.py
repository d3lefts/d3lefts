"""Exact finite illustrative joint-cost frontier. Scores are synthetic design labels.
These are NOT empirical estimates of democratic outcomes or monetary costs.
"""
from itertools import combinations
from fractions import Fraction as F
import json
from pathlib import Path
# name, cost in arbitrary units, contribution to (A,E,L,S)
OPTIONS=[
 ('evidence-grounded-ai',F(5),(3,0,0,0)),
 ('adversarial-deliberation',F(3),(2,1,0,0)),
 ('non-digital-access',F(4),(0,3,0,0)),
 ('inclusion-and-equity-audit',F(3),(1,2,0,0)),
 ('legal-scope-review',F(4),(0,0,3,1)),
 ('verified-human-adoption',F(3),(0,0,2,1)),
 ('atomic-effect-guard',F(5),(0,0,1,4)),
 ('independent-red-team',F(4),(1,0,0,2)),
]
THRESH=(4,4,4,5)

def solve():
    feasible=[]
    all_data=[]
    for mask in range(1<<len(OPTIONS)):
        names=[]; cost=F(0); score=[0]*4
        for j,(name,c,contrib) in enumerate(OPTIONS):
            if (mask>>j)&1:
                names.append(name); cost+=c
                score=[x+y for x,y in zip(score,contrib)]
        all_data.append((cost,names,score))
        if all(x>=t for x,t in zip(score,THRESH)):
            feasible.append((cost,names,score))
    best=sorted(feasible,key=lambda v:(v[0],v[1]))[0]
    # independently check necessity of each chosen component for optimality is not assumed.
    result={'options':len(OPTIONS),'subsets_enumerated':len(all_data),'feasible_subsets':len(feasible),
            'thresholds':dict(zip('AELS',THRESH)),
            'optimal_synthetic_cost':str(best[0]),'selected':best[1],
            'scores':dict(zip('AELS',best[2])),
            'notice':'Arbitrary design scores and costs. Exact enumeration only; NOT real-world feasibility, comparison, or novelty.'}
    Path(__file__).with_name('cost_receipt.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(result,sort_keys=True))

if __name__=='__main__':solve()
