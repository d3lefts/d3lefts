#!/usr/bin/env python3
"""Independent propositional test of one-way sequential counter, no use of Sidon modules."""
from itertools import product

def cnf_for_atmost(n,k):
    x=list(range(1,n+1));nxt=n+1;aux={};clauses=[]
    for i in range(1,n):
        for j in range(1,min(i,k)+1):
            aux[i,j]=nxt;nxt+=1
    for i in range(1,n):
        clauses.append((-x[i-1],aux[i,1]))
        if i>1:
            for j in range(1,min(i-1,k)+1):clauses.append((-aux[i-1,j],aux[i,j]))
            for j in range(2,min(i,k)+1):clauses.append((-x[i-1],-aux[i-1,j-1],aux[i,j]))
    for i in range(k+1,n+1):
        clauses.append((-x[i-1],-aux[i-1,k]))
    return clauses,aux

def unit_unsat(clauses,fixed):
    vals=dict(fixed)
    while True:
        added=False
        for clause in clauses:
            if any(vals.get(abs(v)) == (v>0) for v in clause):continue
            remaining=[v for v in clause if abs(v) not in vals]
            if not remaining:return True
            if len(remaining)==1:
                lit=remaining[0];v=abs(lit);val=lit>0
                if v in vals and vals[v]!=val:return True
                if v not in vals:vals[v]=val;added=True
        if not added:return False

def run():
    count=0
    for n in range(2,12):
        for k in range(1,n):
            clauses,aux=cnf_for_atmost(n,k)
            for mask in range(1<<n):
                fixed={i+1:bool(mask&(1<<i)) for i in range(n)}
                status=unit_unsat(clauses,fixed)
                assert status==(mask.bit_count()>k),(n,k,mask,status)
                count+=1
    print('PASS Sinz one-way at-most equivalence: unit propagation decides',count,'total patterns n=2..11')
if __name__=='__main__':run()
