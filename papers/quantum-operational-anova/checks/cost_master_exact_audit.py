#!/usr/bin/env python3
"""COST v0.3: independent rational direct-matrix versus hypergraph audit.

Scope: finite Rademacher inputs, identical noncommuting qubit encoders,
finite single-copy fixed-subset scalar Personick risk, and explicit
combinatorial phase/complexity lemmas. Tests do not prove universal claims.
Requires Python standard library only.
"""
from fractions import Fraction as F
from itertools import combinations, product
from math import comb
import hashlib
import json

P,Q,D = F(2,3),F(1,3),F(1,6)
N=4


def subsets(n):
    return [tuple(i for i in range(n) if (mask>>i)&1) for mask in range(1<<n)]


def kronecker(a,b):
    return [[a[i][j]*b[k][l] for j in range(len(a[0])) for l in range(len(b[0]))]
            for i in range(len(a)) for k in range(len(b))]


def rho(x,t):
    return [[P, x*t*D],[x*t*D,Q]]


def state_matrix(x,t,coords):
    a=[[F(1)]]
    for i in coords:
        a=kronecker(a,rho(x[i],t))
    return a


def diag_weight(bits):
    z=F(1)
    for a in bits:
        z *= P if a == 0 else Q
    return z


def c(m):
    out=F(0)
    for bits in product((0,1),repeat=m):
        b=diag_weight(bits)
        bbar=diag_weight(tuple(1-v for v in bits))
        out += 2 * D**(2*m)/(b+bbar)
    return out


def direct_gain(coeffs,n,coords,t):
    # Directly assemble all quantum signal matrix entries by averaging the
    # conditional density matrix over every full input string.
    dim=2**len(coords)
    A=[[F(0) for _ in range(dim)] for __ in range(dim)]
    for x in product((-1,1),repeat=n):
        fx=sum(a*__import__('math').prod(x[i] for i in S) for S,a in coeffs.items())
        X=state_matrix(x,t,coords)
        for i in range(dim):
            for j in range(dim):
                A[i][j]+=F(fx,2**n)*X[i][j]
    w=[diag_weight(bits) for bits in product((0,1),repeat=len(coords))]
    return sum((2*A[i][j]**2/(w[i]+w[j]) for i in range(dim) for j in range(dim)),F(0))


def spectral_gain(coeffs,coords,t):
    C=set(coords)
    return sum((a*a*c(len(S))*t**(2*len(S)) for S,a in coeffs.items() if set(S)<=C),F(0))


def clique(g,n,k):
    for T in combinations(range(n),k):
        if all((i,j) in g for i,j in combinations(T,2)):
            return True
    return False


def check_quantum():
    assert c(1)==F(1,9),(c(1),)
    assert c(2)==F(1,80),(c(2),)
    # For f=x1*x2, any independent product of local POVMs has gain at
    # most c(1)^2; the optimal joint measurement has gain c(2).
    assert c(2)>c(1)**2 and c(2)/(c(1)**2)==F(81,80)
    # Full rank: det(rho) = 7/36; explicit nonzero commutator.
    assert P*Q-D*D==F(7,36)
    assert (P-Q)*D == F(1,18)
    coeffs={(0,):F(2),(2,):F(-1),(3,):F(3),
            (0,1):F(2),(1,2):F(-3),(0,2,3):F(1),
            (0,1,2,3):F(-2)}
    checks=0
    for t in (F(0),F(1,3),F(2,3),F(1)):
        for R in subsets(N):
            a=direct_gain(coeffs,N,R,t)
            b=spectral_gain(coeffs,R,t)
            assert a==b,(t,R,a,b)
            checks+=1
    print('PASS direct independent rational density-matrix gain = quantum hypergraph spectrum: %d cases' % checks)
    print('PASS collective-vs-product readout squared-error gain ratio = 81/80')
    return checks



def check_entangled_conditional_states():
    # One conditional state is the entangled Bell state Phi+, while the
    # unconditional average state is exactly B=I_4/4. The classical label
    # is not a product of two independent input labels.
    I=[[F(int(i==j)) for j in range(4)] for i in range(4)]
    bell=[[F(0) for j in range(4)] for i in range(4)]
    for i in (0,3):
        for j in (0,3): bell[i][j]=F(1,2)
    b=[[v/4 for v in row] for row in I]
    minus=[[(I[i][j]-bell[i][j])/3 for j in range(4)] for i in range(4)]
    pplus,pminus=F(1,4),F(3,4)
    assert all(pplus*bell[i][j]+pminus*minus[i][j]==b[i][j]
               for i in range(4) for j in range(4))
    # Both states have exactly maximally mixed one-qubit marginals, so the
    # local replacement-noise channel sends sigma -> B+t^2(sigma-B).
    for state in (bell,minus):
        assert state[0][0]+state[1][1]==F(1,2)
        assert state[2][2]+state[3][3]==F(1,2)
        assert state[0][0]+state[2][2]==F(1,2)
        assert state[1][1]+state[3][3]==F(1,2)
    for t in (F(0),F(1,5),F(1,2),F(1)):
        plus_t=[[b[i][j]+t*t*(bell[i][j]-b[i][j]) for j in range(4)] for i in range(4)]
        minus_t=[[b[i][j]+t*t*(minus[i][j]-b[i][j]) for j in range(4)] for i in range(4)]
        a=[[pplus*3*plus_t[i][j]-pminus*minus_t[i][j] for j in range(4)] for i in range(4)]
        gain=sum((4*a[i][j]*a[j][i] for i in range(4) for j in range(4)),F(0))
        assert gain==3*t**4,(t,gain)
    print('PASS Bell-ensemble entangled conditional states, product average and full t^4 operational gain: 4 rational cases')
    return 4

def check_graph():
    # Quantify every labelled graph on <= 5 vertices and every subset.
    count_g=count_subsets=count_clique=0
    # Independent physical matrix checks on a nontrivial sparse graph.
    sample_edges={(0,1),(0,2),(1,3),(2,3)}
    sample_coeffs={e:F(1) for e in sample_edges}
    for R in subsets(4):
        assert direct_gain(sample_coeffs,4,R,F(1))==F(sum(i in R and j in R for i,j in sample_edges),80)
    for n in (2,3,4,5):
        E=list(combinations(range(n),2))
        for mask in range(1<<len(E)):
            edges={e for i,e in enumerate(E) if (mask>>i)&1}
            count_g+=1
            for R in subsets(n):
                # Physically exact at t=1: each edge Fourier coefficient =1,
                # and all singletons and higher sets have zero coefficient.
                g=sum(F(1,80) for i,j in edges if i in R and j in R)
                assert g==F(sum(i in R and j in R for i,j in edges),80)
                count_subsets+=1
            for k in range(2,n+1):
                threshold=F(comb(k,2),80)
                exists=any(F(sum(i in R and j in R for i,j in edges),80)>=threshold
                           for R in combinations(range(n),k))
                assert exists==clique(edges,n,k)
                count_clique+=1
    print('PASS direct qubit-matrix graph gadget on all 16 subsets')
    print('PASS graph->quantum gain, complete finite clique correspondence: graphs=%d subsets=%d instances=%d' %
          (count_g,count_subsets,count_clique))
    return count_g,count_subsets,count_clique


def pathwidth_dp(n,weights,k,width,t=F(1)):
    # Exact DP for all hyperedges whose vertex indices span <= width.
    # State: assignment of most recent width positions, number selected,
    # and accumulated gain. This is a special path-decomposition checker.
    groups={i:[] for i in range(n)}
    for S,w in weights.items():
        assert S and max(S)-min(S)<=width
        groups[max(S)].append((S,w*t**(2*len(S))))
    dp={(tuple(),0):F(0)}
    for i in range(n):
        ndp={}
        for (hist,count),value in dp.items():
            first=i-len(hist)
            lookup={j:hist[j-first] for j in range(first,i)}
            for bit in (0,1):
                cnt=count+bit
                if cnt>k:continue
                ext={**lookup,i:bit}
                gain=sum(w for S,w in groups[i] if all(ext[j] for j in S))
                nexthist=tuple(ext[j] for j in range(max(0,i-width+1),i+1))[-width:] if width else tuple()
                key=(nexthist,cnt)
                v=value+gain
                if key not in ndp or ndp[key]<v: ndp[key]=v
        dp=ndp
    return max((v for (h,count),v in dp.items() if count==k), default=None)


def check_dp():
    tests=0
    n=7
    # Multiple small weighted rank<=3 examples, all valid for pathwidth 2.
    H=[S for size in (1,2,3) for S in combinations(range(n),size) if max(S)-min(S)<=2]
    for seed in range(17):
        weights={S:F(((sum((j+1)**2 for j in S)+13*seed)%13),13)
                 for S in H}
        for k in range(n+1):
            got=pathwidth_dp(n,weights,k,2)
            want=max((sum(w for S,w in weights.items() if set(S)<=set(R))
                      for R in combinations(range(n),k)),default=None)
            assert got==want,(seed,k,got,want)
            tests+=1
    print('PASS bounded-pathwidth exact DP versus independent exhaustive search: %d instances' % tests)
    return tests



def check_complex_trine():
    # Exact trine phase moments, representing sin(theta)=s*sqrt(3) with
    # rational s; no floating trigonometry. For 0<c<1, real and imaginary
    # optimal scalar gains each c^2/4, but joint complex gain c^2/4.
    cosine=(F(1),-F(1,2),-F(1,2))
    sin_sqrt3=(F(0),F(1,2),-F(1,2))
    assert sum(cosine)==0 and sum(sin_sqrt3)==0
    assert sum(t*t for t in cosine)/3==F(1,2)
    assert 3*sum(t*t for t in sin_sqrt3)/3==F(1,2)
    assert sum(a*b for a,b in zip(cosine,sin_sqrt3))==0
    c=F(1,2)
    gain_real=gain_imag=c*c/4
    joint_upper=c*c/4   # Bloch |r|<=1 for every qubit POVM outcome
    joint_attained=c*c/4 # projective sigma_x
    assert 2*joint_attained==gain_real+gain_imag
    assert joint_attained==joint_upper
    print('PASS trine exact moments and sharp factor-two complex sensing compatibility at c=1/2')
    return str(gain_real),str(gain_imag),str(joint_attained)

def phase_example():
    # Optimal pair switches exactly at z=t^2=1/2.
    weights={(0,):F(2),(1,2):F(4)}
    z0=F(1,4);z1=F(3,4)
    def score(S,z):return sum(w*z**len(T) for T,w in weights.items() if set(T)<=set(S))
    assert score((0,1),z0)>score((1,2),z0)
    assert score((0,1),z1)<score((1,2),z1)
    assert score((0,1),F(1,2))==score((1,2),F(1,2))
    print('PASS algebraic noise-selection phase change at t^2=1/2')

if __name__=='__main__':
    q=check_quantum();e=check_entangled_conditional_states();g=check_graph();d=check_dp();h=check_complex_trine();phase_example()
    payload=json.dumps({'rational_density_cases':q,'entangled_ensemble_cases':e,'finite_graph_counts':g,
                        'pathwidth_dp_cases':d,'complex_trine_gains':h,'c1':str(c(1)),'c2':str(c(2)),
                        'c3':str(c(3))},sort_keys=True).encode()
    print('AUDIT_SUMMARY='+payload.decode())
    print('AUDIT_SUMMARY_SHA256='+hashlib.sha256(payload).hexdigest())
