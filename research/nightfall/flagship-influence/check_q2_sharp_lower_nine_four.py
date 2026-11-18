#!/usr/bin/env python3
"""NIGHTFALL: exact rational lower-bound witness for sharp arbitrary-product Q2.

Claim: any proposed universal degree-2 coefficient C in
    Var(f)^2 <= C B(f)^2 max_i Inf_i(f)
must have C >= 9/4, already on a five-bit uniform Boolean cube.
No upper-bound theorem or originality assertion is provided.

Separately exhausts ALL 0,±1 bipartite 2x2, 2x3 and 3x3 matrices.
Direct physical input-table flip/resampling influence validates witness
independently of its Walsh/ANOVA coefficient representation.

Run: python3 -I research/nightfall/flagship-influence/check_q2_sharp_lower_nine_four.py
"""
from collections import Counter
from fractions import Fraction as Q
from itertools import combinations, product

# Each tuple is (support, Walsh coefficient).
WITNESS = (
    ((0,), 1), ((2,), 1), ((3,), 1), ((4,), 1),
    ((0, 1), 1), ((0, 2), -1), ((0, 3), 1),
    ((1, 2), -1), ((1, 3), -1), ((1, 4), 1),
    ((2, 4), 1), ((3, 4), -1),
)
CHSH = (
    ((0, 2), Q(1, 2)), ((0, 3), Q(1, 2)),
    ((1, 2), Q(1, 2)), ((1, 3), Q(-1, 2)),
)
# Homogenize every singleton by adjoining the new fair sign x5.
# The resulting six-bit polynomial is PURE quadratic and non-bipartite.
HOMOGENEOUS_WITNESS = tuple(
    (S + (5,), c) if len(S) == 1 else (S, c) for S, c in WITNESS
)


def sign_poly(terms, x):
    return sum((Q(c) * product_of(x[i] for i in S) for S, c in terms), Q(0))


def product_of(values):
    out = Q(1)
    for z in values:
        out *= z
    return out


def physical_uniform_stats(n, terms):
    """Independent values and original coordinate-resampling variances."""
    states = list(product((-1, 1), repeat=n))
    table = {x: sign_poly(terms, x) for x in states}
    density = Q(1, len(states))
    mean = sum(table.values(), Q(0)) * density
    V = sum(((v - mean)**2 for v in table.values()), Q(0)) * density
    B = (max(table.values()) - min(table.values())) / 2
    I = []
    for i in range(n):
        # E [(f(X)-f(X_i<-X'_i))^2 / 2] where X'_i is fresh fair law.
        # For each x, half the fresh draws agree and half flip:
        # conditional mean square = (f(x)-f(flip_i x))^2 / 4.
        direct = sum(((table[x] -
                    table[x[:i] + (-x[i],) + x[i+1:]])**2 / 4
                    for x in states), Q(0)) * density
        I.append(direct)
    # Second checker: purely formal Walsh orthogonality. Independent of
    # the source-weighted input-table resampling calculation above.
    WalshV = sum((Q(c)**2 for S, c in terms), Q(0))
    WalshI = [sum((Q(c)**2 for S, c in terms if i in S), Q(0))
              for i in range(n)]
    assert V == WalshV, ("Walsh vs physical variance", V, WalshV)
    assert I == WalshI, ("Walsh vs physical influence", I, WalshI)
    return V, B, max(I), I, Counter(table.values())


def bell_matrix_sweep(m, n):
    """Exhaustive 3^(m*n) INTEGER matrices, no floating point.

    For f(x,y) = x^T W y, conditional resampling I_i is the squared
    Euclidean length of the corresponding row/column. The entire range
    is symmetric; B = max_x sum_j |sum_i x_i W_ij|.
    """
    best = Q(0)
    best_w = None
    count = 0
    above_four = 0
    signs = list(product((-1, 1), repeat=m))
    for vals in product((-1, 0, 1), repeat=m*n):
        if not any(vals):
            continue
        count += 1
        V = sum(w*w for w in vals)
        M = max(
            [sum(vals[i*n + j]**2 for j in range(n)) for i in range(m)] +
            [sum(vals[i*n + j]**2 for i in range(m)) for j in range(n)]
        )
        B = max(
            sum(abs(sum(x[i] * vals[i*n + j] for i in range(m)))
                for j in range(n))
            for x in signs
        )
        ratio = Q(V*V, B*B*M)
        if ratio > best:
            best, best_w = ratio, vals
        if ratio > 4:
            above_four += 1
    assert count == 3**(m*n) - 1
    assert best == 2, ("Bipartite exhaustive max unexpected", m, n, best)
    assert above_four == 0
    return count, best, best_w




def homogeneous_signed_graph_sweep(n):
    """Exhaustive homogeneous signed graphs on n<=5 sites.

    This enumerates ALL edge coefficients in {-1,0,1} on K_n; it does
    not enumerate real-valued coefficients or graphs on six-plus sites.
    """
    edges = list(combinations(range(n), 2))
    states = list(product((-1, 1), repeat=n))
    chars = [tuple(x[i]*x[j] for i,j in edges) for x in states]
    best = Q(0)
    checked = 0
    for coeff in product((-1, 0, 1), repeat=len(edges)):
        if not any(coeff):
            continue
        checked += 1
        V = sum(c*c for c in coeff)
        M = max(sum(c*c for c,(i,j) in zip(coeff,edges) if k in (i,j))
                for k in range(n))
        outputs = [sum(c*v for c,v in zip(coeff,row)) for row in chars]
        width = max(outputs)-min(outputs)
        ratio = Q(4*V*V,width*width*M)
        if ratio > best:
            best = ratio
    expected = {3:Q(9,8),4:Q(2),5:Q(2)}[n]
    assert checked == 3**len(edges)-1
    assert best == expected, ("homogeneous signed graph",n,best,expected)
    return checked, best

def main():
    V, B, M, I, hist = physical_uniform_stats(5, WITNESS)
    assert (V, B, M) == (Q(12), Q(4), Q(4))
    assert I == [Q(4)] * 5
    assert hist == Counter({Q(-4): 12, Q(0): 8, Q(4): 12})
    assert V**2 / (B*B*M) == Q(9, 4)
    print("PASS 5-bit fair Q2 lower-bound witness:",
          "V=12, B=4, M=4, ratio=9/4")
    assert all(len(S) == 2 for S, _ in HOMOGENEOUS_WITNESS)
    V6, B6, M6, I6, hist6 = physical_uniform_stats(6, HOMOGENEOUS_WITNESS)
    assert (V6, B6, M6) == (Q(12), Q(4), Q(4))
    assert I6 == [Q(4)] * 6
    assert hist6 == Counter({Q(-4): 24, Q(0): 16, Q(4): 24})
    assert V6**2 / (B6*B6*M6) == Q(9, 4)
    for x in product((-1, 1), repeat=6):
        assert sign_poly(HOMOGENEOUS_WITNESS, x) == sign_poly(
            WITNESS, tuple(x[5] * x[i] for i in range(5)))
    print("PASS 6-bit PURE homogeneous non-bipartite quadratic:",
          "V=12, B=4, I_i=4 for all six, ratio=9/4")
    V0, B0, M0, I0, h0 = physical_uniform_stats(4, CHSH)
    assert (V0, B0, M0) == (Q(1), Q(1), Q(1, 2))
    assert I0 == [Q(1, 2)]*4
    assert V0**2 / (B0*B0*M0) == 2
    # Falsifies a proposed stronger total-influence detour.
    total_I = sum(I0, Q(0))
    assert total_I**2 > (2*B0)**2 * M0
    print("PASS CHSH normalization and invalid total-influence shortcut")
    tested = 0
    for m, n in ((2, 2), (2, 3), (3, 3)):
        count, best, matrix = bell_matrix_sweep(m, n)
        tested += count
        print("PASS exhaustive signed bipartite", m, "x", n,
              "nonzero", count, "best", best, "no ratio >4")
    assert tested == 80+728+19682
    print("PASS exact signed Bell sweep:", tested, "nonzero matrices")
    graph_count = 0
    for n in (3,4,5):
        count,best = homogeneous_signed_graph_sweep(n)
        graph_count += count
        print("PASS exhaustive homogeneous signed K", n,
              "nonzero", count, "best", best)
    assert graph_count == 26+728+59048
    print("PASS exact quadratic sweep:", tested+graph_count,
          "nonzero matrices/graphs; no Q2 C=4 refutation. "
          "C>=9/4 lower bound certified by finite witness ONLY.")


if __name__ == "__main__":
    main()
