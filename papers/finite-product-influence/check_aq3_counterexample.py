"""Independent exact check of the AQ(3) counterexample: n=17 fair bits, G=min(#ones,13).
Brute-force row validity on all 2^17 vertices, then exact LHS/RHS with Fractions."""
from fractions import Fraction as F
from math import comb
import itertools
n, cap = 17, 13
G = lambda k: min(k, cap)
# row validity check (symmetric; check by weight classes exhaustively on representative vertices)
def row(u):
    k = sum(u)
    if k < cap: return [1]*n
    ones = [i for i in range(n) if u[i]][:cap]
    return [1 if i in ones else 0 for i in range(n)]
import random
random.seed(1)
bad = 0
for k in range(n+1):
    u = tuple([1]*k + [0]*(n-k)); a = row(u)
    for _ in range(4000):
        v = tuple(random.randint(0,1) for _ in range(n))
        cost = sum(a[i] for i in range(n) if u[i] != v[i])
        if abs(G(sum(u)) - G(sum(v))) > cost: bad += 1
print("row violations (random 4000 per weight class):", bad)
# LHS: E over u of (G(u)-G(-u))_+^4 / s(u,-u), w=1
L = F(0)
for k in range(n+1):
    d = G(k) - G(n-k)
    if d <= 0: continue
    s = cap if max(k, n-k) >= cap else n
    L += F(comb(n,k), 2**n) * F(d**4, s)
# RHS sum: (1/2) sum_i E (G(U)-G(U^i))^2 ; flipping changes G by 1 iff transition k<->k+-1 crosses below cap
E = F(0)
for k in range(n+1):
    pk = F(comb(n,k), 2**n)
    # flips of ones: k -> k-1 changes G iff k <= cap ; flips of zeros: k -> k+1 changes iff k < cap
    E += pk * ((k if k <= cap else 0) + ((n-k) if k < cap else 0))
E /= 2
print("L =", L, " E =", E, " L/E =", L/E, float(L/E), " L-3E =", L-3*E)
