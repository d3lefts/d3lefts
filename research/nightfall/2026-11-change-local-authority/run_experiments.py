"""Run preregistered exact source examples; independent audit in audit_independent.py."""
from fractions import Fraction as F
from hashlib import sha256
from pathlib import Path
import json
from mincost import exact_risk_optimum,risk_k

def enc(x):
    if isinstance(x,F):return str(x)
    if isinstance(x,(tuple,list)):return [enc(t) for t in x]
    if isinstance(x,dict):return {k:enc(v) for k,v in x.items()}
    return x

def row(label,n,edges,w,cache=(),r=2,delta=F(0)):
    optimum=exact_risk_optimum(n,edges,w,cache,r,delta)
    return {'experiment':label,'vertex_count':n,'edge_count':len(edges),
      'edges':enc(edges),'vertex_costs':enc(w),'cached_vertices':list(cache),
      'alphabet':r,'posterior_risk_limit':str(delta),
      'optimum_cost':str(optimum['cost']),
      'selected_node_reads':list(optimum['vertices']),
      'direct_gate_reads':list(optimum['direct']),
      'unverified_gates':list(optimum['uncovered']),
      'posterior_risk':str(optimum['risk']),
      'baseline_direct_only_cost':str(sum(e[2] for e in edges)),
      'baseline_all_nodes_cost':str(sum(w[v] for v in range(n) if v not in cache)),
      'minimum_cut_dual':str(optimum['maxflow_dual']),
      'enumerated_risk_exempt_edges':list(optimum['enumerated_skips'])}

examples=[]
examples.append(row('mixed evidence across two subsystems',4,[(0,1,F(5)),(2,3,F(3))],[F(1),F(1),F(5),F(5)]))
examples.append(row('mixed evidence with cache reused',4,[(0,1,F(5)),(2,3,F(3))],[F(1),F(1),F(5),F(5)],cache=(0,)))
all_edges=[(i,j,F(3)) for i in range(5) for j in range(i+1,5)]
examples.append(row('five-agent full mission',5,all_edges,[F(2)]*5))
examples.append(row('single changed constraint, only recertify local impact',5,[(0,1,F(3))],[F(2)]*5))
for delta in (F(0),F(1,2),F(3,4)):
    examples.append(row(f'risk-bounded two-gate instance delta={delta}',4,[(0,1,F(5)),(2,3,F(3))],[F(1),F(1),F(5),F(5)],delta=delta))
    examples.append(row(f'risk-bounded full five-agent instance delta={delta}',5,all_edges,[F(2)]*5,delta=delta))
output={'model_version':'nightfall-change-local-authority-v0.1','scope':'independent uniform edge halves, exact deterministic node/direct observations; safe-path cost','examples':examples,'certification':{'analytic_theorem':'proved in THEORY.md','unrestricted_autonomous_systems':'not claimed','Lean':'not performed','global_novelty':'not established','exhaustive_cross_check':'audit_independent.py'}}
path=Path(__file__).with_name('experiment_receipt.json');path.write_text(json.dumps(output,indent=2,sort_keys=True)+'\n')
print('wrote',path,'sha256',sha256(path.read_bytes()).hexdigest())
for x in examples:
 print(x['experiment'],'optimum',x['optimum_cost'],'direct baseline',x['baseline_direct_only_cost'],'all-nodes baseline',x['baseline_all_nodes_cost'],'risk',x['posterior_risk'])
