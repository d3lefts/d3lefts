#!/usr/bin/env python3
"""Optional exact SAT feasibility experiment via SciPy/HiGHS MILP for small instances.
Numerical backend results are exploratory; exhaustive small subset check is independent certificate.
"""
import argparse
from scipy.optimize import milp, Bounds, LinearConstraint
from scipy.sparse import coo_array
import numpy as np
from build_sat import CNF
from independent_oracle import status

p=argparse.ArgumentParser();p.add_argument('--N',type=int,default=11);p.add_argument('--k',type=int,default=3);p.add_argument('--seconds',type=int,default=15);args=p.parse_args()
f=CNF();f.build(args.N,args.k)
rows=[];cols=[];vals=[];lower=[]
for idx,c in enumerate(f.clauses):
    neg=sum(t<0 for t in c)
    lower.append(1-neg)
    for t in c:rows.append(idx);cols.append(abs(t)-1);vals.append(1 if t>0 else -1)
A=coo_array((np.array(vals,dtype=float),(np.array(rows,dtype=np.int32),np.array(cols,dtype=np.int32))),shape=(len(f.clauses),len(f.names)-1)).tocsr()
res=milp(np.zeros(A.shape[1]),integrality=np.ones(A.shape[1],dtype=np.int32),bounds=Bounds(0,1),constraints=LinearConstraint(A,np.array(lower,dtype=float),np.inf),options={'time_limit':args.seconds,'mip_rel_gap':0})
print('N,k',args.N,args.k,'variables',A.shape[1],'clauses',A.shape[0],'status',res.status,'message',res.message)
if res.x is not None:
    marks=[i for i in range(1,args.N+1) if res.x[f.keys[('x',i)]-1]>.5]
    print('marks',marks,'oracle',status(marks,args.N))
    assert status(marks,args.N)['saturated']

