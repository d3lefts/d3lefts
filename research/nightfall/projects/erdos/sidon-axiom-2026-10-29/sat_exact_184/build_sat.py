#!/usr/bin/env python3
"""Exact SAT encoding of k-element inclusion-maximal integer Sidon subsets of [1,N].
No external SAT library. DIMACS output; auxiliary truth-value witness for any candidate.
"""
import argparse, collections, json, hashlib

class CNF:
    def __init__(self):
        self.keys = {}; self.names=[None]; self.clauses=[]; self.labels=[]; self.N=None; self.pair_lists={}
    def var(self,key):
        if key not in self.keys:
            self.keys[key]=len(self.names); self.names.append(key)
        return self.keys[key]
    def add(self,*lits):
        self.clauses.append(tuple(int(x) for x in lits))
    def and2(self,p,q,key):
        z=self.var(key)
        self.add(-z,p);self.add(-z,q);self.add(z,-p,-q)
        return z
    def or2(self,p,q,key):
        z=self.var(key)
        self.add(-p,z);self.add(-q,z);self.add(-z,p,q)
        return z
    def atleast_seq(self, xs, K):
        # DP threshold nodes; exact equivalence to prefix cardinality.
        # s(i,j) <=> first i inputs contain >=j true.
        prev={0:None}; vals={}
        for i,x in enumerate(xs,1):
            cur={0:None}
            for j in range(1,min(i,K+1)+1):
                if j==i:
                    if j==1: cur[j]=x
                    else: cur[j]=self.and2(x,prev[j-1],('card_and',i,j))
                elif j==1:
                    cur[j]=self.or2(prev[j],x,('card_or',i,j))
                else:
                    z=self.and2(x,prev[j-1],('card_and',i,j))
                    cur[j]=self.or2(prev[j],z,('card_or',i,j))
            prev=cur
        self.add(prev[K]);
        if K+1 in prev:self.add(-prev[K+1])

    def build(self,N,K):
        self.N=N
        X={i:self.var(('x',i)) for i in range(1,N+1)}
        self.atleast_seq([X[i] for i in range(1,N+1)],K)
        pairs=collections.defaultdict(list)
        P={}
        for i in range(1,N+1):
            for j in range(i,N+1):
                p=X[i] if i==j else self.and2(X[i],X[j],('pair',i,j))
                P[(i,j)]=p; pairs[i+j].append(p)
        self.pair_lists={s:[(i,j) for i in range(1,N+1) for j in range(i,N+1) if i+j==s] for s in pairs}
        S={}
        for sumval,lits in pairs.items():
            a=self.var(('occupied',sumval));S[sumval]=a
            for p in lits:self.add(-p,a)
            self.add(-a,*lits)
            if len(lits)>1:
                seq=[self.var(('amo',sumval,t)) for t in range(len(lits)-1)]
                for t,p in enumerate(lits):
                    if t<len(seq): self.add(-p,seq[t])
                    if t>0:self.add(-p,-seq[t-1])
                    if 0<t<len(seq):self.add(-seq[t-1],seq[t])
        for x in range(1,N+1):
            blockers=[X[x],S[2*x]]
            for a in range(1,N+1):
                if a==x:continue
                # c_(x,a) can be true only if mark a chosen and sum x+a occupied.
                b=self.var(('block',x,a));self.add(-b,X[a]);self.add(-b,S[x+a]);blockers.append(b)
            self.add(*blockers)
        return X,P,S
    def values(self, marks):
        sel=set(marks); val={}
        for i,key in enumerate(self.names[1:],1):
            typ=key[0]
            if typ=='x': val[i]=key[1] in sel
            elif typ=='pair':val[i]=key[1] in sel and key[2] in sel
            elif typ=='occupied':val[i]=any(a+b==key[1] for j,a in enumerate(marks) for b in marks[j:])
            elif typ=='block':val[i]=(key[2] in sel and any(a+b==key[1]+key[2] for j,a in enumerate(marks) for b in marks[j:]))
        # Recover exact cardinal DP nodes by pure prefix counts; 'and' auxiliary is x_i & previous threshold.
        for i,key in enumerate(self.names[1:],1):
            typ=key[0]
            if typ in ('card_and','card_or'):
                prefix=sum(a<=key[1] for a in sel)
                if typ=='card_or':val[i]=prefix>=key[2]
                else:
                    val[i]=(key[1] in sel and prefix-1 >= key[2]-1)
            elif typ=='amo':
                _,s,t=key
                # ordered pair literals in same order as pairs generated
                ss=self.pair_lists[s]
                val[i]=any(a in sel and b in sel for a,b in ss[:t+1])
        return val
    def verify(self,marks):
        val=self.values(sorted(marks))
        failed=[]
        for idx,c in enumerate(self.clauses):
            if not any((lit>0)==val[abs(lit)] for lit in c):
                failed.append(idx)
        return failed
    def write(self,path):
        with open(path,'w') as f:
            f.write(f'p cnf {len(self.names)-1} {len(self.clauses)}\n')
            for c in self.clauses:f.write(' '.join(map(str,c))+' 0\n')
        return hashlib.sha256(open(path,'rb').read()).hexdigest()

def main():
    p=argparse.ArgumentParser();p.add_argument('--N',type=int,default=184);p.add_argument('--k',type=int,default=9);p.add_argument('--output',default=None);a=p.parse_args()
    cnf=CNF();cnf.build(a.N,a.k)
    path=a.output or f'sidon_N{a.N}_k{a.k}.cnf'
    digest=cnf.write(path)
    output={'N':a.N,'k':a.k,'number_variables':len(cnf.names)-1,'number_clauses':len(cnf.clauses),'cnf_sha256':digest,'cnf':path}
    print(json.dumps(output,sort_keys=True))
if __name__=='__main__':main()

