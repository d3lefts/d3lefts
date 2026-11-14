"""NIGHTFALL v0.4: candidate generator ONLY; no checker imports.
Exact rational cut-interface certificate for small externally stable systems.
"""
import json, random
from fractions import Fraction as Q
from pathlib import Path

OUT=Path(__file__).with_name('candidate_fixtures.json')

def solve(A,y):
    n=len(y); aug=[[Q(int(i==j))-A[i][j] for j in range(n)]+[y[i]] for i in range(n)]
    for k in range(n):
        p=next(i for i in range(k,n) if aug[i][k]); aug[k],aug[p]=aug[p],aug[k]
        d=aug[k][k]; aug[k]=[x/d for x in aug[k]]
        for i in range(n):
            if i==k: continue
            f=aug[i][k]; aug[i]=[aug[i][j]-f*aug[k][j] for j in range(n+1)]
    return [row[-1] for row in aug]

def fmt(x): return str(x)

def gen():
    rng=random.Random(20261113)
    cases=[]
    for n in range(1,9):
        for repeat in range(14):
            g=1+repeat%3
            B=[[Q(rng.randint(0,2), 24*n) for j in range(n)] for i in range(n)]
            C=[[Q(rng.randint(0,3), 13*g) for j in range(g)] for i in range(n)]
            z=[Q(rng.randint(1,6),9) for j in range(g)]
            y=[sum((C[i][j]*z[j] for j in range(g)),Q(0)) for i in range(n)]
            q=solve(B,y)
            cases.append(dict(n=n,g=g,B=[[fmt(v) for v in row] for row in B],C=[[fmt(v) for v in row] for row in C],z=list(map(fmt,z)),q=list(map(fmt,q))))
    OUT.write_text(json.dumps(dict(version='0.4',generator='exact rational Gauss Jordan',cases=cases),indent=1)+'\n')
    return len(cases)

if __name__=='__main__':print('generated',gen(),'cases')
