"""Exact source-ANOVA observer for finite cyclic-group tree innovations.

The source law consists of mutually independent edge increments. Terms are
h((X_v-X_u) mod a). The algorithm never enumerates all vertex states.
All computations use exact Fraction; model authenticity is an assumption.
"""
from collections import defaultdict
from fractions import Fraction as F
from itertools import combinations, product

def subsets(seq):
    seq=tuple(sorted(seq))
    for k in range(len(seq)+1):
        yield from combinations(seq,k)

def path_signs(parent,u,v):
    def ancestors(node):
        ans=[]
        while node:
            ans.append(node)
            node=parent[node]
        return set(ans)
    A=ancestors(u);B=ancestors(v)
    return {**{e:-1 for e in A-B},**{e:1 for e in B-A}}

def relative_term(parent,a,term):
    u,v,h=term
    signs=path_signs(parent,u,v)
    S=tuple(sorted(signs))
    table={x:F(h[sum(signs[e]*x[j] for j,e in enumerate(S))%a])
           for x in product(range(a),repeat=len(S))}
    return S,table

def compile_anova(parent,a,edge_laws,terms):
    assert len(edge_laws)==len(parent)-1
    assert all(sum(law,F(0))==1 for law in edge_laws)
    components=defaultdict(lambda:defaultdict(F))
    for term in terms:
        S,h=relative_term(parent,a,term)
        marginal={}
        for T in subsets(S):
            indices=[S.index(e) for e in T]
            marg={}
            for z in product(range(a),repeat=len(T)):
                total=F(0)
                for x,y in h.items():
                    if tuple(x[i] for i in indices)!=z:continue
                    w=F(1)
                    for i,e in enumerate(S):
                        if e not in T:w*=edge_laws[e-1][x[i]]
                    total+=w*y
                marg[z]=total
            marginal[T]=marg
        for U in subsets(S):
            for z in product(range(a),repeat=len(U)):
                val=F(0)
                for T in subsets(U):
                    t=tuple(z[U.index(e)] for e in T)
                    val+=(-1)**(len(U)-len(T))*marginal[T][t]
                components[U][z]+=val
    return {U:dict(table) for U,table in components.items()}

class Observer:
    def __init__(self,parent,a,edge_laws,terms):
        self.parent=tuple(parent)
        self.a=a
        self.laws={e:tuple(map(F,edge_laws[e-1]))
                   for e in range(1,len(parent))}
        self.tables=compile_anova(parent,a,edge_laws,terms)
        self.read={}

    def energies(self):
        energy={}
        for U,table in self.tables.items():
            total=F(0)
            for z,value in table.items():
                weight=F(1)
                for e,g in zip(U,z):weight*=self.laws[e][g]
                total+=weight*value*value
            energy[U]=total
        return energy

    def risk(self):
        return sum((val for U,val in self.energies().items() if U),F(0))

    def prediction(self):
        return self.tables.get((),{():F(0)}).get((),F(0))

    def scores(self):
        res={e:F(0) for e in range(1,len(self.parent)) if e not in self.read}
        for U,energy in self.energies().items():
            for e in U:res[e]+=energy
        return res

    def choose(self):
        inf=self.scores()
        return min(inf,key=lambda e:(-inf[e],e)) if inf else None

    def reveal(self,e,g):
        assert e not in self.read and 0<=g<self.a and self.laws[e][g]>0
        new={U:dict(t) for U,t in self.tables.items() if e not in U}
        for U,table in self.tables.items():
            if e not in U:continue
            idx=U.index(e)
            V=U[:idx]+U[idx+1:]
            out=new.setdefault(V,{})
            for z,val in table.items():
                if z[idx]==g:
                    z2=z[:idx]+z[idx+1:]
                    out[z2]=out.get(z2,F(0))+val
        self.tables=new
        self.read[e]=g
