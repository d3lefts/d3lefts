#!/usr/bin/env python3
"""Exact universal C4/C8/C16 certificate for abelian regular K4 covers.
No solver, no graph-library, no imported generator. Inputs are star-normalized chord voltages.
"""
from itertools import product

MAIN = '01201203102102130'    # generalized commutator with chord a=12, b=13
CASE = {
 (-2,-2):'01320',(-2,-1):'01230',(-2,0):'01201203102102130',(-2,1):'013203120',(-2,2):'012302130',
 (-1,-2):'012301320',(-1,-1):'01230',(-1,0):'012301320',(-1,1):'012301320',(-1,2):'012301320',
 (0,-2):'012031230',(0,-1):'01230',(0,0):'01320',(0,1):'013203120',(0,2):'01201203210210230',
 (1,-2):'02130',(1,-1):'01230',(1,0):'02130',(1,1):'01320',(1,2):'02130',
 (2,-2):'012302130',(2,-1):'01230',(2,0):'012031230',(2,1):'013203120',(2,2):'01320',
}
SMALL = {
 3:{(-2,0):'02130',(-2,1):'01320',(-2,2):'01230',(-1,2):'01230',(0,2):'01230'},
 4:{(-2,0):'012031230',(0,2):'012031230'},
}
assert len(CASE)==25

# Integer (or cyclic) voltage evolution, independent of state table claim.
def walk(word, a,b,c, modulus=None):
    labels={(1,2):a,(1,3):b,(2,3):c}
    deck=0; states=[]
    for prev,nxt in zip(word,word[1:]):
        u,v=int(prev),int(nxt)
        assert u!=v and 0<=u<4 and 0<=v<4
        states.append((u,deck if modulus is None else deck%modulus))
        if (u,v) in labels: deck += labels[(u,v)]
        elif (v,u) in labels: deck -= labels[(v,u)]
    assert word[0]==word[-1]=='0'
    assert len(word)-1 in {4,8,16}
    return (deck if modulus is None else deck%modulus), states

def audit_word(word,a,b,c,modulus=None):
    voltage, states=walk(word,a,b,c,modulus)
    assert voltage==0,(word,a,b,c,modulus,'voltage',voltage)
    assert len(set(states))==len(states),(word,a,b,c,modulus,'duplicate')
    return len(states)

# Conditional infinite-group lemma: a has order >=3, b not in {0,±a,2a}.
# Universal state differences at common base are all from this forbidden set.
from collections import defaultdict
zero,states=walk(MAIN,1,100,107)
assert zero==0
D=set()
for i in range(4):
 vals=[x for j,x in states if j==i]
 for q,x in enumerate(vals):
  for y in vals[q+1:]:
   # Each is f(a)+e*b with e in {-1,0}; we infer e by doing a second run.
   pass
z0,ss0=walk(MAIN,1,0,0)
z1,ss1=walk(MAIN,1,1,0)
assert z0==z1==0
factors=[]
for (node,x),(node1,y) in zip(ss0,ss1):
 assert node==node1
 factors.append((node,x,y-x))
assert all(coef in (0,-1) for _,_,coef in factors)
for i in range(4):
 ls=[(x,e) for j,x,e in factors if j==i]
 for q,(x,e) in enumerate(ls):
  for y,ee in ls[q+1:]:
   if e==ee:assert x!=y and abs(x-y)<=2
   else:
    # collision when b=(x-y)/(ee-e), integer coefficient
    D.add((x-y)//(ee-e))
assert D=={0,1,-1,2},D
print('PASS general 16-word collision set = {0,+a,-a,2a}; b outside forbids all repeats')

maxdiff=0
for (b,c),w in sorted(CASE.items()):
 audit_word(w,1,b,c)
 m=max((abs(u-v) for i,u in walk(w,1,b,c)[1]
        for j,v in walk(w,1,b,c)[1] if i==j),default=0)
 maxdiff=max(maxdiff,m)
 for k in range(3,5):
  selected=SMALL.get(k,{}).get((b,c),w)
  audit_word(selected,1,b,c,k)
 for k in range(5,8):
  audit_word(w,1,b,c,k)
assert maxdiff==4
assert len(SMALL[3])==5 and len(SMALL[4])==2
print('PASS all 25 residual coefficient pairs over Z, modulus 3..7 with 7 listed exceptions; max label separation 4')
# Falsifiers: unacceptable certificates rejected by the exact oracle.
for args in [('01230',1,0,2,7), ('01201203102102130',1,1,5,17),('01201203210210230',1,0,2,3)]:
 try: audit_word(*args)
 except AssertionError:pass
 else:raise AssertionError('mutation accepted '+repr(args))
print('PASS three negative controls rejected')
