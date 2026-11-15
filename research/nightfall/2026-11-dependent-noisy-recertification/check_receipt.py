#!/usr/bin/env python3
"""Standalone exact certificate checker; does NOT import the Bellman solver.

Reconstructs the full joint world and checks Bellman lower bounds, attaining
policy action, all branch masses, terminal admissibility and source likelihoods.
"""
from fractions import Fraction as F
from itertools import product
from collections import defaultdict
import json,pathlib,sys,hashlib

def obs(w,act):
 b,u,a,n,z=w
 if act=='noisy_a':return a^n
 if act=='noisy_b':return b^n
 if act=='read_b':return b
 if act=='read_u':return u
 if act=='read_a':return a
 if act=='gold':return int(a==u)
 if act=='z':return z
 raise ValueError(act)

def build_world(source):
 b1=F(source['prior_b1']); psu=(F(source['pu1_b0']),F(source['pu1_b1']))
 psa=(F(source['pa1_b0']),F(source['pa1_b1']))
 err=F(source['shared_noise_error']);zc=F(source['cache_error'])
 r={}
 for b,u,a,n,z in product((0,1),repeat=5):
  pb=b1 if b else 1-b1
  pu=psu[b] if u else 1-psu[b]
  pa=psa[b] if a else 1-psa[b]
  pn=err if n else 1-err
  pz=(1-zc) if z==u else zc
  r[(b,u,a,n,z)]=pb*pu*pa*pn*pz
 assert sum(r.values())==1
 return r

def verify(path):
 blob=pathlib.Path(path).read_bytes()
 doc=json.loads(blob)
 assert doc['schema']=='nightfall.bellman-certificate.v1'
 m=build_world(doc['source'])
 known=doc['source']['cache']
 delta=F(doc['risk']['authorization_posterior'])
 eta=F(doc['risk']['denial_posterior'])
 costs={k:F(v) for k,v in doc['tests'].items()}
 table={tuple((str(k),int(v)) for k,v in row['history']):row for row in doc['states']}
 assert len(table)==len(doc['states'])
 assert tuple(sorted(known.items())) in table
 masses={};probs={}
 for h in table:
    matching={w:p for w,p in m.items() if all(obs(w,k)==v for k,v in h)}
    z=sum(matching.values());assert z>0
    masses[h]=z
    probs[h]=sum((p for w,p in matching.items() if w[1]!=w[2]),F(0))/z

 for h,row in table.items():
    assert probs[h]==F(row['posterior_unsafe'])
    p=probs[h];allowed=set()
    if p<=delta:allowed.add('authorize')
    if 1-p<=eta:allowed.add('deny')
    assert set(row['allowed_terminals'])==allowed
    candidate={a:F(0) for a in allowed}
    assert set(row['tests'])==set(costs)-{a for a,v in h}
    for t, entry in row['tests'].items():
        assert F(entry['cost'])==costs[t]
        children=[]
        for o in (0,1):
            ch=tuple(sorted(h+((t,o),)))
            if ch in table:
                pchild=masses[ch]/masses[h]
                children.append([o,str(pchild),[list(z) for z in ch]])
        assert entry['outcomes']==children
        cost=costs[t]+sum((masses[tuple((k,int(v)) for k,v in child[2])]/masses[h]*
                    F(table[tuple((k,int(v)) for k,v in child[2])]['value'])
                  for child in children),F(0))
        assert cost==F(entry['total'])
        candidate[t]=cost
    assert candidate
    best=min(candidate.values())
    assert best==F(row['value'])
    assert row['choice'] in candidate and candidate[row['choice']]==best

 # Independently replay every complete world against the selected policy.
 root=tuple(sorted(known.items()))
 total=masses[root];expected=F(0);allow_error=F(0);deny_error=F(0)
 for w,weight in m.items():
    if any(obs(w,k)!=v for k,v in root):continue
    weight/=total;h=root;price=F(0)
    while True:
      action=table[h]['choice']
      if action=='authorize':
        if w[1]!=w[2]:allow_error+=weight
        break
      if action=='deny':
        if w[1]==w[2]:deny_error+=weight
        break
      price+=costs[action]
      h=tuple(sorted(h+((action,obs(w,action)),)))
    expected+=weight*price
 assert expected==F(doc['root_value'])
 assert table[root]['choice']==doc['root_action']
 return {'status':'PASS','states':len(table),'root_value':str(expected),
         'joint_unsafe_authorization':str(allow_error),
         'joint_false_denial':str(deny_error),
         'certificate_sha256':hashlib.sha256(blob).hexdigest()}

if __name__=='__main__':
 p=sys.argv[1] if len(sys.argv)>1 else pathlib.Path(__file__).parent/'bellman_receipt.json'
 print(json.dumps(verify(p),sort_keys=True))
