#!/usr/bin/env python3
"""Axiom #91: exact positive-difference plus midpoint encoding for saturated integer Sidon sets.
Pure Python, deterministic output. Independent of the original sum-based CNF.
"""
from collections import defaultdict
from hashlib import sha256
from argparse import ArgumentParser
import json

class CNF:
    def __init__(self):
        self.literals={}; self.keys=[None]; self.clauses=[]
        self.pairs_by_d={}; self.card={}
    def v(self,key):
        if key not in self.literals:
            self.literals[key]=len(self.keys);self.keys.append(key)
        return self.literals[key]
    def c(self,*args): self.clauses.append(tuple(args))
    def AND(self,a,b,key):
        z=self.v(key);self.c(-z,a);self.c(-z,b);self.c(z,-a,-b);return z
    def OR(self,a,b,key):
        z=self.v(key);self.c(-a,z);self.c(-b,z);self.c(-z,a,b);return z
    def card_exact(self,x,k):
        prev={0:None}
        for i,t in enumerate(x,1):
            cur={0:None}
            for j in range(1,min(i,k+1)+1):
                if i==j:
                    cur[j]=t if j==1 else self.AND(t,prev[j-1],('card_and',i,j))
                elif j==1:cur[j]=self.OR(prev[1],t,('card_or',i,j))
                else:
                    u=self.AND(t,prev[j-1],('card_and',i,j))
                    cur[j]=self.OR(prev[j],u,('card_or',i,j))
            prev=cur
        self.c(prev[k]);
        if k+1 in prev:self.c(-prev[k+1])
    def atmostone(self,ls,d):
        if len(ls)<2:return
        prev=None
        for i,t in enumerate(ls[:-1]):
            z=self.v(('amo',d,i))
            self.c(-t,z)
            if prev is not None:
                self.c(-prev,z)
                self.c(-t,-prev)
            prev=z
        self.c(-ls[-1],-prev)
    def build(self,N,k):
        self.N=N;self.k=k
        X={i:self.v(('X',i)) for i in range(1,N+1)}
        self.card_exact(list(X.values()),k)
        P={};D={}
        for d in range(1,N):
            ls=[]
            for a in range(1,N+1-d):
                b=a+d;z=self.AND(X[a],X[b],('P',a,b));P[a,b]=z;ls.append(z)
            self.pairs_by_d[d]=[(a,a+d) for a in range(1,N+1-d)]
            dvar=self.v(('D',d));D[d]=dvar
            for z in ls:self.c(-z,dvar)
            self.c(-dvar,*ls)
            self.atmostone(ls,d)
        # W_(a,d) -> X_a and D_d; one W can block a+d and a-d.
        W={}
        for a in range(1,N+1):
            for d in range(1,max(a-1,N-a)+1):
                w=self.v(('W',a,d));W[a,d]=w
                self.c(-w,X[a]);self.c(-w,D[d])
        for x in range(1,N+1):
            terms=[X[x]]
            terms.extend(P[a,2*x-a] for a in range(1,x) if x < 2*x-a <=N)
            terms.extend(W[a,abs(x-a)] for a in range(1,N+1) if a!=x)
            self.c(*terms)
        self.X=X;self.P=P;self.D=D;self.W=W
        return self
    def assignment(self,marks):
        marks=set(marks)
        diffpairs=defaultdict(list)
        for a in sorted(marks):
            for b in sorted(marks):
                if a<b:diffpairs[b-a].append((a,b))
        v={}
        for i,key in enumerate(self.keys[1:],1):
            kind=key[0]
            if kind=='X':v[i]=key[1] in marks
            elif kind=='P':v[i]=key[1] in marks and key[2] in marks
            elif kind=='D':v[i]=key[1] in diffpairs
            elif kind=='W':v[i]=(key[1] in marks and key[2] in diffpairs)
            elif kind in ('card_and','card_or'):
                _,pos,j=key
                count=sum(a<=pos for a in marks)
                v[i]=(pos in marks and count>=j) if kind=='card_and' else count>=j
            elif kind=='amo':
                _,d,pos=key
                v[i]=any(a in marks and b in marks for a,b in self.pairs_by_d[d][:pos+1])
        assert len(v)==len(self.keys)-1
        return v
    def test(self,marks):
        assign=self.assignment(marks)
        return [i for i,c in enumerate(self.clauses) if not any((lit>0)==assign[abs(lit)] for lit in c)]
    def save(self,path):
        with open(path,'w') as f:
            f.write(f'p cnf {len(self.keys)-1} {len(self.clauses)}\n')
            for c in self.clauses:f.write(' '.join(map(str,c))+' 0\n')
        with open(path,'rb')as f:return sha256(f.read()).hexdigest()

if __name__=='__main__':
    p=ArgumentParser();p.add_argument('--N',type=int,default=184);p.add_argument('--k',type=int,default=9);p.add_argument('--output',default='difference_N184_k9.cnf');args=p.parse_args()
    m=CNF().build(args.N,args.k)
    digest=m.save(args.output)
    print(json.dumps({'N':args.N,'k':args.k,'variables':len(m.keys)-1,'clauses':len(m.clauses),'sha256':digest,'file':args.output},sort_keys=True))
