#!/usr/bin/env python3
"""AXIOM finite-field fourth-power decoder, F_25 = F_5[z]/(z^2-2).
Independent implementation of Frobenius linearization. No third-party deps.
"""
import random, json

def add(a,b): return ((a%5+b%5)%5)+5*((a//5+b//5)%5)
def neg(a): return ((-a%5)%5)+5*((-(a//5))%5)
def mul(a,b):
    u,v=a%5,a//5; w,t=b%5,b//5
    return ((u*w+2*v*t)%5)+5*((u*t+v*w)%5)
def power(a,n):
    out=1
    while n:
        if n&1: out=mul(out,a)
        a=mul(a,a);n//=2
    return out

def dot(a,b):
    t=0
    for p,q in zip(a,b):t=add(t,mul(p,q))
    return t

def row(a,y):return [power(t,5) for t in a]+[neg(mul(y,t)) for t in a]

def rref(A,cols):
    rows=[v[:] for v in A]
    pivots=[]; idx=0
    for j in range(cols):
        q=next((r for r in range(idx,len(rows)) if rows[r][j]),None)
        if q is None:continue
        rows[q],rows[idx]=rows[idx],rows[q]
        inv=power(rows[idx][j],23)
        rows[idx]=[mul(x,inv) for x in rows[idx]]
        for r in range(len(rows)):
            if r!=idx and rows[r][j]:
                c=rows[r][j]
                rows[r]=[add(x,neg(mul(c,y))) for x,y in zip(rows[r],rows[idx])]
        pivots.append(j);idx+=1
        if idx==len(rows):break
    return rows[:idx],pivots

def kernel_generator(A,cols):
    rows,pivots=rref(A,cols)
    free=[j for j in range(cols) if j not in pivots]
    if len(free)!=1:return None,cols-len(pivots)
    v=[0]*cols;v[free[0]]=1
    for i,j in enumerate(pivots):v[j]=neg(rows[i][free[0]])
    return v,1

def recover(A,ys):
    k=len(A[0]); assert len(A)==len(ys)
    if all(y==0 for y in ys):
        _,pivots=rref(A,k)
        return [(0,)*k] if len(pivots)==k else None
    M=[row(a,y) for a,y in zip(A,ys)]
    w,d=kernel_generator(M,2*k)
    if d!=1:return None
    u,v=w[:k],w[k:]
    j=next((i for i,t in enumerate(v) if t),None)
    if j is None:return None
    c=mul(u[j],power(power(v[j],5),23))
    roots=[t for t in range(1,25) if power(t,4)==c]
    solutions=[]
    for t in roots:
        x=tuple(mul(t,z) for z in v)
        if all(power(dot(a,x),4)==y for a,y in zip(A,ys)):
            solutions.append(x)
    return solutions

def main():
    rng=random.Random(20261028)
    results={}
    for k,m,trials in [(1,10,30),(2,16,30),(3,24,30),(4,30,30)]:
        successes=0
        for t in range(trials):
            A=[[rng.randrange(25) for _ in range(k)] for __ in range(m)]
            x=[rng.randrange(25) for _ in range(k)]
            if not any(x):x[0]=1
            y=[power(dot(a,x),4) for a in A]
            out=recover(A,y)
            if out is None:continue
            phases=[l for l in range(1,25) if power(l,4)==1]
            expected={tuple(mul(l,v) for v in x) for l in phases}
            assert set(out)==expected,{'k':k,'trial':t,'x':x,'out':out}
            successes+=1
        results[f'k={k},m={m}']={'trials':trials,'certified_unique_orbit':successes}
    # Exhaustive possible measurement rows: test rank for EVERY nonzero signal in k=2,
    # modulo fourth-root phase, with the complete set of 625 rows.
    A=[[i,j] for i in range(25) for j in range(25)]
    full_rank_count=0
    for p in range(25):
        for q in range(25):
            if p==q==0:continue
            x=[p,q]
            M=[row(a,power(dot(a,x),4)) for a in A]
            _,pivots=rref(M,4)
            assert len(pivots)==3,(p,q,pivots)
            full_rank_count+=1
    results['exhaustive_rank_k2']={'nonzero_signals':full_rank_count,'full_span_rank':3,'total_sensing_rows':625}
    results['zero_case'] = 'rank(A)=k gives zero as sole all-zero-reading signal'
    print(json.dumps({'status':'PASS','field':'F25(z^2=2)','results':results},indent=2))
if __name__=='__main__':main()
