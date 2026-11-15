#!/usr/bin/env python3
"""Emit portable exact Bellman lower-bound + policy witness for a source model."""
from recert import Solver,joint,TESTS
from fractions import Fraction as Q
import hashlib,json,pathlib

def build():
    source=joint()
    planner=Solver(source, cache={'z':1},delta=Q(1,10),eta=Q(1,10))
    planner.solve();planner.check_certificate()
    rows=[]
    for history, r in sorted(planner.record.items(), key=lambda x:(len(x[0]),x[0])):
      choices={}
      for t in planner.names:
        if t in dict(history):continue
        choices[t]={'cost':str(planner.tests[t].cost),
                    'outcomes':[[v,str(p),list(h2)] for v,p,h2 in planner.outcomes(history,t)],
                    'total':str(r['alternatives'][t])}
      rows.append({'history':list(history),'posterior_unsafe':str(r['unsafe']),
                   'value':str(r['value']),'choice':r['choice'],
                   'allowed_terminals':sorted(r['available_terminal']),
                   'tests':choices})
    doc={
      'schema':'nightfall.bellman-certificate.v1',
      'source':{'prior_b1':'1/3','pu1_b0':'1/4','pu1_b1':'3/4',
                'pa1_b0':'3/4','pa1_b1':'1/4','shared_noise_error':'1/4',
                'cache_error':'1/4','cache':{'z':1}},
      'tests':{t.name:str(t.cost) for t in TESTS},
      'risk':{'authorization_posterior':'1/10','denial_posterior':'1/10'},
      'root_value':str(planner.solve()),'root_action':planner.record[planner.root]['choice'],
      'states':rows,
    }
    return doc

def main():
    p=pathlib.Path(__file__).parent/'bellman_receipt.json'
    raw=(json.dumps(build(),sort_keys=True,separators=(',',':'))+'\n').encode()
    p.write_bytes(raw)
    print(json.dumps({'status':'PASS','file':str(p),'bytes':len(raw),
                      'sha256':hashlib.sha256(raw).hexdigest(),'states':len(build()['states'])},sort_keys=True))
if __name__=='__main__':main()
