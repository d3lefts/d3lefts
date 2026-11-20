import sys, itertools, numpy as np
exec(open('sidon_extremals.py').read().split("for L,neg in")[0])
L=int(sys.argv[1]); specs,X=setup(L)
subsets=[frozenset(F) for k in range(L+1) for F in itertools.combinations(range(L),k)]
def Fof(s): return frozenset(i for i in range(L) if s[i]==2)
mode=sys.argv[2]
if mode=='all':   # every function of the free set with f(empty)=+
    pats=[dict(zip(subsets,(1,)+bits)) for bits in itertools.product((1,-1),repeat=len(subsets)-1)]
else:             # depends on (|F|, 0 in F)
    keys=sorted({(len(F),0 in F) for F in subsets if F})
    pats=[]
    for bits in itertools.product((1,-1),repeat=len(keys)):
        d=dict(zip(keys,bits)); pats.append({F:(1 if not F else d[(len(F),0 in F)]) for F in subsets})
best=(0,None)
for f in pats:
    sig=np.array([f[Fof(s)] for s in specs],float); v,_=solve(X,sig)
    if v>best[0]+1e-9: best=(v,f)
print("L=%d free-set patterns (%s, %d tried): best K=%.4f   3(L+1)/4=%.4f"%(L,mode,len(pats),best[0],0.75*(L+1)))
print("  minus free-sets:",sorted([tuple(sorted(F)) for F,v in best[1].items() if v<0],key=lambda t:(len(t),t)))
