"""Independent exact-enumeration checker for separator reweighting certificates.
Does not import robust_separator; implements finite posterior directly.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256
from random import Random
import json
from robust_separator import robust_unbounded_risk,robust_threshold_margin,robust_interval_risk,uniform_change_radius

def corners(aa,bb,ll,uu):
    return [(
        sum(x*scale for x,scale in zip(aa,picks))/sum((x+y)*scale for x,y,scale in zip(aa,bb,picks)),
        tuple(picks)
    ) for picks in product(*[(l,u) for l,u in zip(ll,uu)])]

def run():
    rand=Random(202611150848); cnt=0; dig=sha256(); tight=0
    for n in range(1,7):
        for k in range(350):
            aa=[Q(rand.randrange(1,11),rand.randrange(11,30)) for _ in range(n)]
            ss=[Q(rand.randrange(1,11),rand.randrange(11,30)) for _ in range(n)]
            ll=[Q(rand.randrange(1,6),rand.randrange(8,15)) for _ in range(n)]
            uu=[l+Q(rand.randrange(1,12),rand.randrange(2,8)) for l in ll]
            delta=Q(rand.randrange(0,20),20)
            direct=max(corners(aa,ss,ll,uu), key=lambda x:x[0])
            value,wit=robust_interval_risk(aa,ss,ll,uu)
            assert value==direct[0]
            signed=max(sum(lam*(a-delta*(a+s)) for lam,a,s in zip(pick,aa,ss)) for _,pick in corners(aa,ss,ll,uu))
            cert=robust_threshold_margin(aa,ss,ll,uu,delta)
            assert cert==signed
            assert (cert<=0)==(direct[0]<=delta)
            ub=max(a/(a+s) for a,s in zip(aa,ss))
            assert robust_unbounded_risk(aa,ss)==ub
            assert value<=ub
            rho=[Q(rand.randrange(0,5),5) for _ in range(n)]
            crit,limit=uniform_change_radius(aa,ss,rho,delta)
            if sum(aa)<=delta*sum(a+s for a,s in zip(aa,ss)):
                checks=[Q(0),Q(1,8),Q(1,2),Q(3,4)]
                if crit is not None and crit>0 and (limit is None or crit<limit):checks += [crit, (crit+limit)/2 if limit is not None else crit+1]
                for strength in checks:
                    if limit is not None and strength>=limit:continue
                    lb=[1-strength*r for r in rho];up=[1+strength*r for r in rho]
                    assert all(l>0 for l in lb)
                    test=max(sum(lam*(a-delta*(a+s)) for lam,a,s in zip(pick,aa,ss)) for pick in product(*[(l,u) for l,u in zip(lb,up)]))
                    linear=(sum(a-delta*(a+s) for a,s in zip(aa,ss)) + strength*sum(r*abs(a-delta*(a+s)) for r,a,s in zip(rho,aa,ss)))
                    assert linear==test
                    if crit is not None:assert (strength<=crit)==(test<=0)
                    tight += 1
            dig.update((str(n)+'|'+str(k)+'|'+str(value)+'|'+str(cert)+'|'+str(ub)+'\n').encode())
            cnt+=1
    # Same old scalar unsafe risk, different legitimate decisions after a context shift.
    A=([Q(0),Q(1,10)],[Q(1,2),Q(2,5)])
    B=([Q(1,20),Q(1,20)],[Q(9,20),Q(9,20)])
    def risk(x,y,lam):return sum(t*a for t,a in zip(lam,x))/sum(t*(a+b) for t,a,b in zip(lam,x,y))
    assert risk(*A,[1,1])==risk(*B,[1,1])==Q(1,10)
    assert risk(*A,[1,9])==Q(9,50)
    assert risk(*B,[1,9])==Q(1,10)
    assert robust_unbounded_risk(*A)==Q(1,5)
    assert robust_unbounded_risk(*B)==Q(1,10)
    crit,_=uniform_change_radius(*A,[1,1],Q(3,20))
    assert crit==Q(1,2)
    print(json.dumps({'cases':cnt,'radius_checks':tight,'sha256':dig.hexdigest(),'same_old_risk':'1/10','new_unsafe_A':'9/50','new_unsafe_B':'1/10','exact_change_margin':'1/2','status':'PASS'},sort_keys=True))

if __name__=='__main__':run()
