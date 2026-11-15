"""Adversarial independent exact check of graph recertification model.
Brute oracle uses direct vertex-set enumeration; checker recomputes max-flow
feasibility and cut capacity without invoking flow solver logic. Finite worlds
are directly checked on small cases. No claim of universal proof from tests.
"""
from fractions import Fraction as Q
from itertools import combinations,product
from hashlib import sha256
import random,json
from mincost import maximum_closure_mincut,exact_risk_optimum,risk_k

def brute(n,edges,w,cached,k):
    """Separate integer-bitmask enumeration with explicit omitted edge subsets."""
    best=None
    for Vbits in range(1<<n):
        if any(not (Vbits>>v&1) for v in cached):continue
        for Dbits in range(1<<len(edges)):
            uncovered=sum(1 for i,(u,v,d) in enumerate(edges)
                          if not ((Dbits>>i&1) or ((Vbits>>u&1) and (Vbits>>v&1))))
            if uncovered>k:continue
            c=sum(w[v] for v in range(n) if v not in cached and (Vbits>>v&1))
            c+=sum(d for i,(_,_,d) in enumerate(edges) if Dbits>>i&1)
            if best is None or c<best:best=c
    return best

def audit_cut(n,edges,w,cached,certificate):
    """Independent proof-object checker: source/sink cut, capacity and flow conservation."""
    arc=certificate['flow_arcs'];source=certificate['source'];sink=certificate['sink']
    reach=set(certificate['residual_reachable'])
    assert source in reach and sink not in reach
    balance=[Q(0)]*(sink+1)
    cut=Q(0)
    for u,v,cap,f in arc:
        assert 0<=f<=cap
        balance[u]-=f;balance[v]+=f
        if u in reach and v not in reach:cut+=cap
    assert all(balance[v]==0 for v in range(sink+1) if v not in (source,sink))
    assert -balance[source]==balance[sink]==certificate['maxflow']==cut
    S=set(certificate['vertices'])
    objective=sum(w[v] for v in S-set(cached))+sum(d for u,v,d in edges if not(u in S and v in S))
    assert objective==cut

def world_audit(n,edges,r,cached,sol):
    """Enumerate *all* assignments of independent endpoint halves for tiny cases."""
    m=len(edges);S=set(sol['vertices']);D=set(sol['direct']);U=set(sol['uncovered'])
    assert set(cached)<=S
    transcript_counts={}
    for halves in product(range(r),repeat=2*m):
        checks=[(halves[2*i]+halves[2*i+1])%r for i in range(m)]
        resolved=[i for i,(u,v,d) in enumerate(edges) if i in D or (u in S and v in S)]
        accepted=all(checks[i]==0 for i in resolved)
        # All-safe worlds must be accepted, no exceptions.
        if all(k==0 for k in checks):assert accepted
        if not accepted:continue
        # Exact posterior risk audit: enumerate every world with the same
        # *complete observed transcript*, including cached node halves.
        transcript=[]
        for i,(a,b,d) in enumerate(edges):
            if a in S:transcript.append((i,'left',halves[2*i]))
            if b in S:transcript.append((i,'right',halves[2*i+1]))
            if i in D:transcript.append((i,'direct',checks[i]))
        key=tuple(transcript)
        counts=transcript_counts.setdefault(key,[0,0])
        counts[0]+=1
        counts[1]+=int(any(x!=0 for x in checks))
        for i in U:
            assert i not in resolved
            # Change one unobserved endpoint half => same sensor transcript,
            # and flips just that edge's mission verdict.
            a,b=edges[i][:2]
            index=2*i if a not in S else 2*i+1
            assert (a not in S) or (b not in S)
            new=list(halves);new[index]=(new[index]+1)%r
            assert all((new[2*j]+new[2*j+1])%r==checks[j] for j in resolved)
            assert (new[2*i]+new[2*i+1])%r != checks[i]
    expected=Q(1)-Q(1,r**len(U))
    assert transcript_counts
    for total,unsafe in transcript_counts.values():
        assert Q(unsafe,total)==expected,(total,unsafe,expected)

def main():
    rnd=random.Random(20261115);digest=sha256();count=0
    exemplar=None;worlds=0
    for n in range(2,7):
        for trial in range(200):
            possible=list(combinations(range(n),2))
            rnd.shuffle(possible);m=rnd.randrange(1,min(9,len(possible))+1)
            edges=tuple((u,v,Q(rnd.randint(1,6),rnd.choice([1,2]))) for u,v in possible[:m])
            w=tuple(Q(rnd.randint(1,7),rnd.choice([1,2])) for _ in range(n))
            cached=tuple(i for i in range(n) if rnd.randrange(5)==0)
            for r,delta in ((2,Q(0)),(2,Q(1,2)),(3,Q(2,3))):
                k=risk_k(r,delta,m)
                sol=exact_risk_optimum(n,edges,w,cached,r,delta)
                gold=brute(n,edges,w,cached,k)
                assert sol['cost']==gold,(n,edges,w,cached,sol,gold)
                assert sol['risk']<=delta
                kept=tuple(e for i,e in enumerate(edges) if i not in sol['enumerated_skips'])
                # Certificate in solver was created for possibly larger leave set;
                # if some omitted edge became covered anyway, dual is still valid for original leave set.
                cert=sol['closure_certificate']
                # Independent dual verification is done for every zero-risk source graph,
                # and for mincut results whose omitted-edge sets are exactly U.
                audit_cut(n,kept,w,cached,cert)
                if m<=4 and n<=4:
                    world_audit(n,edges,r,cached,sol)
                    worlds+=r**(2*m)
                entry={'n':n,'edges':[(u,v,str(d)) for u,v,d in edges],
                       'w':list(map(str,w)),'cached':cached,'r':r,'delta':str(delta),
                       'k':k,'optimum':str(gold),'vertices':sol['vertices'],
                       'direct':sol['direct'],'uncovered':sol['uncovered'],'risk':str(sol['risk'])}
                digest.update((json.dumps(entry,sort_keys=True,separators=(',',':'))+'\n').encode());count+=1
    print(json.dumps({'cases':count,'finite_world_assignments_checked':worlds,
                      'sha256':digest.hexdigest(),'status':'PASS'},indent=2))
if __name__=='__main__':main()
