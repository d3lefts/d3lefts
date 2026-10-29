#!/usr/bin/env python3
"""Exhaustive independent oracle↔canonical CNF-model equivalence on small N.
This tests a *specific* auxiliary extension of all selections. The universal
SAT projection equivalence is proved separately in the research note.
"""
from build_sat import CNF
from independent_oracle import status
from itertools import combinations
import json

counts={}
for N in range(5,12):
 for k in range(2,min(5,N+1)):
  cnf=CNF();cnf.build(N,k)
  sat=0; total=0
  for A in combinations(range(1,N+1),k):
   expected=status(A,N)['saturated']
   actual=not cnf.verify(A)
   assert expected==actual, (N,k,A,expected,actual,cnf.verify(A)[:10])
   sat+=actual;total+=1
  counts[f'{N},{k}']={'tested':total,'valid':sat}
print(json.dumps({'status':'PASS','complete_subset_scan':counts},sort_keys=True))

