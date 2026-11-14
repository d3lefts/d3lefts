"""Independent original-spin enumeration tests for source ANOVA compilation.

Never imports an ANOVA formula into the direct oracle. Uses the actual
physical state law and conditioned spin configurations as the reference.
"""
from itertools import product
from fractions import Fraction as F
from random import Random
from innovation_observer import Observer,path_signs
R=Random(2026111317)
counts={"finite_source_models":0,"original_spin_posterior_checks":0,
        "original_spin_influence_checks":0}

def direct(p,a,root,laws,terms):
    rows={}
    for x in product(range(a),repeat=len(p)):
        weight=root[x[0]]
        for e in range(1,len(p)):
            weight*=laws[e-1][(x[e]-x[p[e]])%a]
        if weight==0:continue
        value=sum((h[(x[v]-x[u])%a] for u,v,h in terms),F(0))
        rows[x]=(weight,value)
    assert sum((w for w,f in rows.values()),F(0))==1
    return rows

def posterior(rows,p,a,observed):
    selected={x:(w,f) for x,(w,f) in rows.items() if all(
        (x[e]-x[p[e]])%a==v for e,v in observed.items())}
    Z=sum((w for w,f in selected.values()),F(0))
    if not Z:return None
    m=sum((w*f for w,f in selected.values()),F(0))/Z
    v=sum((w*(f-m)**2 for w,f in selected.values()),F(0))/Z
    return m,v

def inf_spin(rows,p,a,observed,j):
    groups={}
    for x,(w,f) in rows.items():
        if not all((x[e]-x[p[e]])%a==v for e,v in observed.items()):
            continue
        key=tuple((x[e]-x[p[e]])%a for e in range(1,len(p))
                  if e!=j and e not in observed)
        groups.setdefault(key,[]).append((w,f))
    mass=sum((w for rows2 in groups.values() for w,f in rows2),F(0))
    val=F(0)
    for group in groups.values():
        Z=sum((w for w,f in group),F(0))
        m=sum((w*f for w,f in group),F(0))/Z
        val+=sum((w*(f-m)**2 for w,f in group),F(0))
    return val/mass

for trial in range(100):
    n=R.randint(2,6)
    a=R.choice([2,3])
    parent=[-1]+[R.randrange(i) for i in range(1,n)]
    def law():
        w=[R.randint(0,5) for _ in range(a)]
        if not sum(w):w[0]=1
        return [F(v,sum(w)) for v in w]
    root=law();laws=[law() for _ in range(1,n)]
    D=R.randint(1,min(3,n-1))
    terms=[]
    for _ in range(9):
        u,v=R.sample(range(n),2)
        if len(path_signs(parent,u,v))<=D:
            terms.append((u,v,[F(R.randint(-4,4),R.choice([1,2,3]))
                              for z in range(a)]))
    if not terms:terms=[(0,1,[F(z) for z in range(a)])]
    rows=direct(parent,a,root,laws,terms)
    observer=Observer(parent,a,laws,terms)
    assert (observer.prediction(),observer.risk())==posterior(rows,parent,a,{})
    for step in range(n-1):
        scores=observer.scores()
        if not scores:break
        for j,expected in scores.items():
            assert inf_spin(rows,parent,a,observer.read,j)==expected
            counts["original_spin_influence_checks"]+=1
        e=observer.choose()
        outcomes=[z for z,pz in enumerate(laws[e-1]) if pz]
        chosen=R.choice(outcomes)
        observer.reveal(e,chosen)
        assert (observer.prediction(),observer.risk())==posterior(
            rows,parent,a,observer.read)
        counts["original_spin_posterior_checks"]+=1
    counts["finite_source_models"]+=1
print({**counts,"result":"passed"})
