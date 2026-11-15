#!/usr/bin/env python3
"""Extra-shift C96 conjecture: independent exact-rational FINITE stress test, not proof.
Checks e+H² <= 2u²+u for scalar binary increment families with |Y_i|<=1.
Also checks a sharp all-n biased Bernoulli equality construction.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256
import json
from check_c96_first_second_exact import P_GRID, SHIFTS, law, convolution

EXPECTED = "ebf32717e180e587a9822a39286bbeffa38942a6c316757ec745b74b8e6be175"


def verify_sharp_equality(ts):
    H = sum(ts, Q())
    laws = [((t/(1+t), Q(1)), (1/(1+t), -t)) for t in ts]
    pmf = convolution(laws)
    u = sum((w*abs(H+z) for z,w in pmf.items()),Q())
    e = sum((w*(H+z)**2 for z,w in pmf.items()),Q())
    assert u == H and e == H**2+H
    assert 2*u*u+u-e-H*H == 0
    return {"ts":[str(t) for t in ts],"H":str(H),"u":str(u),"e":str(e)}


def main():
    checked=0
    mn=None
    digest=sha256()
    for n in range(5):
        for ps in product(P_GRID, repeat=n):
            for orientation in product((-1,1), repeat=n):
                pmf=convolution([law(p,s) for p,s in zip(ps,orientation)])
                s=sum((p/(1-p) for p in ps), Q())
                for H in SHIFTS:
                    u=sum((w*abs(H+y) for y,w in pmf.items()), Q())
                    e=H*H+s
                    margin=2*u*u+u-e-H*H
                    if mn is None or margin<mn: mn=margin
                    digest.update(f'{n};{ps};{orientation};{H};{u};{e};{margin}\n'.encode())
                    if margin<0:
                        raise AssertionError(f'STRONG SHIFT COUNTEREXAMPLE: n={n}, p={ps}, directions={orientation}, H={H}, gap={margin}')
                    checked+=1
    assert checked==746493
    assert digest.hexdigest()==EXPECTED, 'exact-case receipt drift'
    eq=[verify_sharp_equality(ts) for ts in
        [(Q(1,2),),(Q(1,3),Q(1,4)),(Q(1,8),Q(1,4),Q(3,8))]]
    print(json.dumps({
        "status":"NO_COUNTEREXAMPLE_ON_SCALAR_GRID_NOT_A_PROOF",
        "conjecture":"E||H+sum Yi||²+||H||² <= 2(E||H+sum Yi||)²+c E||H+sum Yi||",
        "cases":checked,
        "minimum_exact_margin":str(mn),
        "exact_case_digest":digest.hexdigest(),
        "all_n_analytic_equality_family_examples":eq,
    },indent=2))


if __name__=="__main__":
    main()
