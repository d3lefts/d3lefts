#!/usr/bin/env python3
"""Exact finite-instance query-and-restrict simulator and full event audit.
This checks whole tree executions on selected product instances. It is NOT
a general Lean theorem or independent referee certification.
"""
from fractions import Fraction as Q
from itertools import product

class ProductSimulator:
    def __init__(self, laws, fun, eta):
        self.laws, self.fun, self.eta = laws, fun, eta
        self.states = list(product(*[range(len(q)) for q in laws]))
        self.dim = len(laws)
        self.weights = {x: self.mass(x) for x in self.states}
        self.leaves = []
        self.drift_checks = 0

    def mass(self,x):
        p=Q(1)
        for i,a in enumerate(x): p*=self.laws[i][a]
        return p

    def conditional(self,observed):
        cells={x:w for x,w in self.weights.items()
               if w and all(x[i]==a for i,a in observed.items())}
        p=sum(cells.values(),Q(0))
        assert p>0
        return {x:w/p for x,w in cells.items()}

    def mean(self,dist):
        return sum((w*self.fun(x) for x,w in dist.items()),Q(0))

    def variance(self,dist):
        m=self.mean(dist)
        return sum((w*(self.fun(x)-m)**2 for x,w in dist.items()),Q(0))

    def influence(self,dist,i):
        return sum((w*self.laws[i][b]*(self.fun(x)-
                    self.fun(x[:i]+(b,)+x[i+1:]))**2/Q(2)
                    for x,w in dist.items()
                    for b in range(len(self.laws[i]))),Q(0))

    def build(self,observed=None,depth=0):
        if observed is None: observed={}
        law=self.conditional(observed)
        v=self.variance(law)
        mean=self.mean(law)
        active=[i for i in range(self.dim) if i not in observed]
        J=sum((self.influence(law,i) for i in active),Q(0))
        if v<=self.eta or not active:
            leaf={"mean":mean, "observed":dict(observed),
                  "depth":depth,"variance":v}
            self.leaves.append(leaf)
            return leaf
        influence={i:self.influence(law,i) for i in active}
        i=max(active,key=lambda j: (influence[j],-j))
        assert influence[i]>0
        child={}
        EchildJ=Q(0)
        for b,p in enumerate(self.laws[i]):
            if p==0: continue
            obs={**observed,i:b}
            subtree=self.build(obs,depth+1)
            child[b]=subtree
            newlaw=self.conditional(obs)
            Jb=sum((self.influence(newlaw,j) for j in active if j!=i),Q(0))
            EchildJ+=p*Jb
        assert J-EchildJ==influence[i], (observed,J,EchildJ,influence[i])
        self.drift_checks+=1
        return {"query":i,"children":child,"observed":dict(observed),
                "depth":depth,"J":J,"variance":v}

    def run(self,tree,x):
        queries=0
        while "query" in tree:
            queries+=1
            tree=tree["children"][x[tree["query"]]]
        return tree["mean"],queries

def audit(name,laws,fun,eps,delta):
    sim=ProductSimulator(laws,fun,eps*eps*delta/2)
    tree=sim.build()
    total_fail=Q(0)
    max_queries=0
    for x,w in sim.weights.items():
        if not w: continue
        est,k=sim.run(tree,x)
        max_queries=max(max_queries,k)
        if abs(est-fun(x))>=eps:
            total_fail+=w
    assert total_fail<=delta, (name,total_fail,delta)
    assert max_queries<=sim.dim
    assert sim.drift_checks>0
    print("PASS",name,"states",len(sim.states),"internal_nodes",sim.drift_checks,
          "max_queries",max_queries,"exact_failure",total_fail)

# Includes a ternary coordinate and zero mass label.
laws=[(Q(1,5),Q(4,5)),(Q(1,2),Q(1,3),Q(1,6)),
      (Q(0),Q(3,7),Q(4,7))]
f=lambda x: (Q(1,2)+Q(1,12)*(x[0]-1)+Q(1,15)*(x[1]-1)
              +Q(1,18)*(x[2]-1)+Q(1,20)*(x[0]-1)*(x[1]-1))
assert all(0<=f(x)<=1 for x in product(*[range(len(q)) for q in laws]))
audit("heterogeneous-quadratic-zeroatom",laws,f,Q(1,8),Q(1,4))

# Third-degree fair-cube instance, acceptance-style bounded polynomial.
laws2=[(Q(1,2),Q(1,2))]*4
g=lambda x: (Q(1,2)+Q(1,8)*((2*x[0]-1)*(2*x[1]-1)*(2*x[2]-1))
            +Q(1,10)*(2*x[3]-1))
audit("fair-cubic",laws2,g,Q(1,10),Q(1,5))
