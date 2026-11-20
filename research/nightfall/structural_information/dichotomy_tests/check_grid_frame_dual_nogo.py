#!/usr/bin/env python3
"""Exact independent grid chain-map and dual-flow falsifier (not a proof)."""
from collections import Counter
from random import Random
C=Counter()
def ck(label,ok):
    C[label]+=1
    if not ok:raise AssertionError((label,C[label]))
def xor(xs):
    v=0
    for x in xs:v^=x
    return v
def lattice(L):
    E=[];index={}
    for i in range(L):
        for j in range(L):
            u=i*L+j
            if j+1<L:index[(u,u+1)]=len(E);E.append((u,u+1))
            if i+1<L:index[(u,u+L)]=len(E);E.append((u,u+L))
    rows=[(1<<u)|(1<<v) for u,v in E]
    faces=[]
    for i in range(L-1):
        for j in range(L-1):
            a=i*L+j;b=a+1;c=a+L;d=c+1
            faces.append(xor(1<<index[(u,v)] for u,v in
                             ((a,b),(a,c),(b,d),(c,d))))
    return E,index,rows,faces
def basis_pivots(B):
    piv={}
    for j,b in enumerate(B):
        word=1<<j
        while b:
            k=b.bit_length()-1
            if k not in piv:piv[k]=(b,word);break
            t,w=piv[k];b^=t;word^=w
        else:raise AssertionError('not a basis')
    return piv
def coordinates(v,piv):
    word=0
    while v:
        k=v.bit_length()-1;t,w=piv[k]
        v^=t;word^=w
    return word
def one_case(L,trial,rng):
    E,ids,R,faces=lattice(L)
    edge_count=len(E); face_count=(L-1)**2
    # Independent random spanning-tree basis: no enumerating huge subsets.
    shuffled=list(range(edge_count));rng.shuffle(shuffled)
    tree=[];piv={}
    for eid in shuffled:
        v=R[eid]
        while v:
            k=v.bit_length()-1
            if k not in piv:piv[k]=v;tree.append(eid);break
            v^=piv[k]
    ck('tree_rank',len(tree)==L*L-1)
    # Sparse invertible changes ensure c'=1 or 2, with independent A implementation.
    D=[1<<eid for eid in tree]
    for j in range(0,len(D)-1,2):
        if (trial+j)%3:D[j]^=D[j+1]
    B=[xor(R[eid] for eid in range(edge_count) if w>>eid&1) for w in D]
    pivot=basis_pivots(B)
    A=[coordinates(r,pivot) for r in R]
    c=max(w.bit_count() for w in A)
    cp=max(w.bit_count() for w in D)
    q=c*cp
    P=[xor(D[j] for j in range(len(D)) if a>>j&1) for a in A]
    for eid in range(edge_count):
        ck('boundary_preserving',
           xor(R[e] for e in range(edge_count) if P[eid]>>e&1)==R[eid])
        ck('sparse_columns',P[eid].bit_count()<=q)
    for f in faces:
        ck('A_annihilates_face',
           xor(A[e] for e in range(edge_count) if f>>e&1)==0)
        ck('P_annihilates_face',
           xor(P[e] for e in range(edge_count) if f>>e&1)==0)
    def lift(v):
        mask=0
        # Invert boundary2 by peeling horizontal edges from top to bottom.
        for i in range(L-1):
            for j in range(L-1):
                u=i*L+j
                bit=(v>>ids[(u,u+1)])&1
                prev=((mask>>((i-1)*(L-1)+j))&1) if i else 0
                if bit^prev:mask|=1<<(i*(L-1)+j)
        return mask
    S=[]
    for eid in range(edge_count):
        boundary=P[eid]^(1<<eid)
        f=lift(boundary)
        ck('exact_face_lift',
           xor(faces[j] for j in range(face_count) if f>>j&1)==boundary)
        S.append(f)
        ck('edge_isoperimetry',16*f.bit_count()<=boundary.bit_count()**2)
        ck('bounded_face_column',16*f.bit_count()<=(q+1)**2)
    for j,face in enumerate(faces):
        ck('S_boundary2_identity',
           xor(S[e] for e in range(edge_count) if face>>e&1)==1<<j)
    depth=0
    for f in range(face_count):
        i,j=divmod(f,L-1)
        dist=1+min(i,j,L-2-i,L-2-j)
        count=sum((S[e]>>f)&1 for e in range(edge_count))
        ck('dual_path_lower_bound',count>=dist)
        depth+=dist
    N=L-1
    Dsum=sum((N-2*t)**2 for t in range((N+1)//2))
    ck('dual_depth_sum',depth==Dsum)
    ck('global_bound',edge_count*(q+1)**2>=16*Dsum)
    ck('coarse_bound',3*L*(q+1)**2>=4*(L-1)**2)
    return c,cp,q
def run():
    rng=Random(20261119);n=0
    for L,trials in ((2,15),(3,30),(4,30),(5,30),(6,30),(8,15),(12,10)):
        for i in range(trials):
            c,cp,q=one_case(L,i,rng);n+=1
        print('GRID',L,'TRIALS',trials,'LAST_C_CP_Q',c,cp,q)
    print('PASS grid dual-chain no-go',n,'cases')
    print('COUNTS',dict(sorted(C.items())))
if __name__=='__main__':run()
