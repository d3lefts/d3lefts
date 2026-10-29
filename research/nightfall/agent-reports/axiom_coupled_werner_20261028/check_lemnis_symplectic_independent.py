#!/usr/bin/env python3
"""AXIOM cross-audit of Lemnis diagonal all-k rigidity: anchored symplectic identity,
complete k2 subsets, all k4 65 outside words / 4160 negative triples,
independent 16-physical-partial-trace witness checks.
"""
from itertools import product,combinations
from fractions import Fraction as F
from collections import Counter
from hashlib import sha256
from pathlib import Path

def H(a,b):return sum(x!=y for x,y in zip(a,b))
def sigma(a,b):return (-1)**H(a,b)
def rainbow(a,b,c):return sum(len({x,y,z})==3 for x,y,z in zip(a,b,c))%2
def f(v):return tuple((x==1,x==2) for x in v)
def symp(a,b):
 A=f(a);B=f(b)
 return sum(x[0]*y[1]+x[1]*y[0] for x,y in zip(A,B))%2

def partial_trace_diag(terms):
    # independent of signed-graph Gram: literal 2^n partial traces.
    n=len(next(iter(terms))[0]);result=F(0)
    for mask in range(1<<n):
        keep=[j for j in range(n) if (mask>>j)&1==0]
        lost=n-len(keep)
        group=Counter()
        for (a,b),coef in terms.items():
            if all(a[j]==b[j] for j in range(n) if j not in keep):
                group[tuple(a[j] for j in keep),tuple(b[j] for j in keep)]+=coef
        result+=F(-1,2)**lost * sum(F(v*v) for v in group.values())
    return result

# Symplectic anchored equivalence: exhaustive triples at n<=3.
for n in (1,2,3):
 W=list(product(range(3),repeat=n))
 for a,b in product(W,repeat=2):
  # Translate the anchor to 0 under ternary arithmetic and use binary one-hot encoding.
  # A triangle (anchor,a,b) with anchor=0 has rainbow parity equal to symplectic product.
  assert rainbow((0,)*n,a,b)==symp(a,b)
 print('PASS anchored symplectic parity, n=',n,'pairs=',len(W)**2)

# All 512 subfamilies of F3²: verify triangle criterion and sharp 4-coordinate boxes.
W=list(product(range(3),repeat=2)); positives=[]
for mask in range(1<<len(W)):
 S=[W[j] for j in range(len(W)) if mask>>j&1]
 ok=all(rainbow(a,b,c)==0 for a,b,c in combinations(S,3))
 if ok:positives.append(tuple(S))
maxsize=max(map(len,positives))
maximal=[S for S in positives if len(S)==maxsize]
expected={tuple((x,y) for x in A for y in B) for A in combinations(range(3),2) for B in combinations(range(3),2)}
assert maxsize==4 and set(maximal)==expected and len(maximal)==9
print('PASS all 512 k2 supports: maximum size 4; exactly nine two-symbol coordinate boxes')

# Every outside word (65 of them) added to the canonical 16-word box at n=4.
B=list(product((0,1),repeat=4))
W=list(product(range(3),repeat=4))
outs=[y for y in W if y not in B]
assert len(outs)==65
witnesses=0
for y in outs:
 bad=[]
 for a,b in combinations(B,2):
  if rainbow(a,b,y)==1:
   bad.append((a,b))
   # Generate exact rank-three coefficients from an *independent* parity computation.
   coef=(1,-sigma(a,b),-sigma(a,y))
   M={(v,v):F(w) for v,w in zip((a,b,y),coef)}
   assert partial_trace_diag(M)==-F(3,16),(a,b,y)
   witnesses+=1
 assert len(bad)==64,(y,len(bad))
assert witnesses==4160
# Negative control: changing one triangle coefficient destroys its expected negativity.
a,b=next((a,b) for a,b in combinations(B,2) if rainbow(a,b,outs[0]))
y=outs[0]
coef=(1,-sigma(a,b),-sigma(a,y))
X={(v,v):F(w) for v,w in zip((a,b,y),coef)}
assert partial_trace_diag(X)==-F(3,16)
X[(y,y)]=-X[(y,y)]
assert partial_trace_diag(X)!=-F(3,16)
print('PASS all 65 outside words, 64 bad triples each; 4160 literal partial-trace negative witnesses')
print('PASS adversarial coefficient-flip control')
print('SOURCE_SHA256',sha256(Path(__file__).read_bytes()).hexdigest())
