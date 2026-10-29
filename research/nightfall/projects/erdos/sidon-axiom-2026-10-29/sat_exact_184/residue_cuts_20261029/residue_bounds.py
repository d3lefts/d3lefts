#!/usr/bin/env python3
"""Exact residue-sector capacity necessary for saturated Sidon sets; no external dependencies."""
from math import comb
from itertools import product

def residue_capacity(counts,N):
    m=len(counts);k=sum(counts)
    # T: ordered triples u+v-w; trivial terms account for 2k-1 per old point.
    T=[0]*m
    for a,na in enumerate(counts):
      for b,nb in enumerate(counts):
        if not na*nb:continue
        for c,nc in enumerate(counts):
          T[(a+b-c)%m]+=na*nb*nc
    diag=[0]*m
    for a,na in enumerate(counts):
      for c,nc in enumerate(counts):
        diag[(2*a-c)%m]+=na*(nc-(a==c))
    pair=[0]*m
    for a in range(m):
      for b in range(a,m):
        count=(comb(counts[a],2) if a==b else counts[a]*counts[b])
        if count:
          for x in range(m):
            if (a+b-2*x)%m==0:pair[x]+=count
    triple=[]
    for x in range(m):
      numerator=T[x]-(2*k-1)*counts[x]+diag[x]
      assert numerator>=0 and numerator%2==0,(counts,x,numerator)
      triple.append(numerator//2)
    slots=[N//m+(1 if 1<=x<=N%m else 0) for x in range(m)]
    needs=[slots[x]-counts[x] for x in range(m)]
    return {"slots":slots,"needs":needs,"mixed":triple,"midpoint_upper":pair,
            "capacity":[triple[i]+pair[i] for i in range(m)]}

def histograms(k,m):
    if m==1:
        yield (k,);return
    for i in range(k+1):
        for tail in histograms(k-i,m-1):yield (i,)+tail

def census(N,k,m):
    total=valid=0; maxcounts=[-1]*m;bad_examples=[]
    for count in histograms(k,m):
        total+=1
        b=residue_capacity(count,N)
        if all(a<=c for a,c in zip(b['needs'],b['capacity'])):
            valid+=1
            for t in range(m):maxcounts[t]=max(maxcounts[t],count[t])
        elif len(bad_examples)<6:bad_examples.append(count)
    return {'N':N,'k':k,'m':m,'total_profiles':total,'profile_capacity_pass':valid,
            'profile_capacity_rejected':total-valid,'per_residue_max_allowed':maxcounts,
            'sample_exclusions':bad_examples}

if __name__=='__main__':
 import json
 for m in (2,3,4,5,6,7,8,9,10):
  print(json.dumps(census(184,9,m),sort_keys=True),flush=True)
