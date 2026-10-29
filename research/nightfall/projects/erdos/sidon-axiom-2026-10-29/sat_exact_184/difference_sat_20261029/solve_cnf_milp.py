#!/usr/bin/env python3
"""Solver comparison: MILP translation of signed CNF clauses, no custom satisfiability inference.
Returns a candidate if HiGHS has one; independent oracle must check all candidates.
A time limit is NEVER treated as UNSAT.
"""
import argparse,json,time
import numpy as np
from scipy.optimize import milp, Bounds, LinearConstraint
from scipy.sparse import coo_matrix
from build_difference_sat import CNF
from independent_oracle import classify

def run(N,k,limit):
    start=time.monotonic();model=CNF().build(N,k)
    I=[];J=[];V=[];lb=[]
    for row,c in enumerate(model.clauses):
        neg=0
        for lit in c:
            I.append(row);J.append(abs(lit)-1);V.append(1 if lit>0 else -1)
            if lit<0:neg+=1
        lb.append(1-neg)
    sparse=coo_matrix((np.array(V,dtype=np.float64),(np.array(I),np.array(J))),shape=(len(model.clauses),len(model.keys)-1)).tocsr()
    res=milp(c=np.zeros(len(model.keys)-1),integrality=np.ones(len(model.keys)-1),bounds=Bounds(0,1),constraints=LinearConstraint(sparse,np.array(lb,dtype=float),np.inf),options={'time_limit':limit,'disp':False,'mip_rel_gap':0.0})
    out={'N':N,'k':k,'vars':len(model.keys)-1,'clauses':len(model.clauses),'status':int(res.status),'message':res.message,'elapsed_total_s':round(time.monotonic()-start,3),'has_candidate':res.x is not None}
    if res.x is not None:
        A=[i for i in range(1,N+1) if res.x[model.X[i]-1]>0.5]
        truth=classify(A,N)
        out['candidate']=A;out['independent_sidon']=truth['sidon'];out['independent_saturated']=truth['saturated'];out['holes']=truth['holes']
        assert truth['saturated'] and len(A)==k
    return out
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--N',type=int,default=184);p.add_argument('--k',type=int,default=9);p.add_argument('--seconds',type=float,default=8.0);x=p.parse_args()
    print(json.dumps(run(x.N,x.k,x.seconds),sort_keys=True))
