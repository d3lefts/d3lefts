# NIGHTFALL Q2: shifted Hilbert c/4 interpolation and C107.393 source route

**Status:** exact rational *scalar* polynomial certificate, not a Lean source theorem and not an independently reviewed unrestricted coefficient.

## Source obligation (kept explicit)

Assume nonnegative `a,s,c,u`, `e=a²+s`, `t=√e`, and a shifted-Hilbert fourth moment `q` satisfying

```
e³ ≤ u² q
q ≤ 3 e² - 2 a⁴ + 4 a c s + c² s.
```

The second is the stronger, *unrelaxed*, actual-source shifted Hilbert moment estimated in PR #551. Unlike the coarser `q ≤ 3e² + 2c e√e + c²e`, it retains the negative `-2a⁴` term and exact `s` factors.

## Exact new scalar inequality

```
sqrt(e) ≤ sqrt(3)*u + c/4.
```

For `e=0` or `4t≤c`, it follows immediately from nonnegativity. Otherwise set
`x=a/t` and `v=c/(4t)`, so `x,v∈[0,1]` and `s=t²(1-x²)`.

The moment upper envelope is `q ≤ t⁴ Q(x,v)`, with

```
Q(x,v) = 3 - 2x⁴ + 16xv(1-x²) + 16v²(1-x²).
```

The exact rational Bernstein certificate proves

```
F(x,v) = 3 - (1-v)² Q(x,v) ≥ 0
       for all x,v∈[0,1].
```

Indeed, the polynomial has a tensor Bernstein expansion of bidegree
`(31,24)` with **800 coefficients, all nonnegative**. Exactly four are
zero: `(i,j)=(0,0),(1,0),(2,0),(3,0)`; the least strictly positive is
`2/31465`. Each basis factor
`binom(31,i)x^i(1-x)^(31-i) * binom(24,j)v^j(1-v)^(24-j)`
is nonnegative on the unit square. The checker independently re-expands
the Bernstein representation into the *power* basis using integer binomial
arithmetic and verifies all coefficients agree exactly with `F`.

Combining `t^6 ≤ u²q ≤ u²t⁴ Q` and `(1-v)² Q ≤ 3` yields
`(t-c/4)² ≤3u²`, hence `t≤√3u+c/4`.

## Consequence conditional on source composition

Substitute the local shift `H=originalSingleton` and owned, source-centered
Hilbert increments from #551, the original-source section estimate
`Σu_i ≤ 2(1+√2)B` strictly passed in #549, the true owner cover
`Σc_i ≤8B`, and the original exact variance and influence cap.

This algebraically gives

```
Var(f)² ≤ (2(1+sqrt(2))*sqrt(3) + 2)² B² M
       = 107.3934498997707243... B² M.
```

All canonical singleton components remain unrestricted, and the finite
product laws may be heterogeneous, arbitrarily biased, and have zero atoms.

**DO NOT PROMOTE:** The Bernstein checker certifies an exact real
polynomial inequality, not the required Lean original-source Hilbert
moment theorem or the entire degree-two theorem. A separate pinned Lean
named-declaration audit and independent mathematical proof review are
required. No new `c/5` claim, optimum, global novelty, or publication claim.
Attribution: NIGHTFALL joint research; source shifted Hilbert work
#533/#538/#551 and source Bernoulli section #549.

Exact checker: `check_shifted_c4_bernstein.py`, using only standard
library `fractions.Fraction`, `math.comb`, and a reverse coefficient
transform with rational integer arithmetic.

## Lean-directed compact certificate

`research/nightfall/formalization/observability/ShiftedC4Bernstein.lean`
contains nine local polynomial identities over rational rectangles:
the x-axis split is `0,2/5,3/5,1`, and the v-axis split is
`0,1/3,2/3,1`. Every local polynomial has a tensor Bernstein
representation of bidegree `(4,4)` with **225 nonnegative exact rational
coefficients** in aggregate (221 strictly positive, four zero).
The local identities are discharged by real polynomial normalization and
nonnegativity; `shifted_c4_F_nonneg` assembles the nine cells.

This source is a **separate Lean proof attempt** from the independent
800-coefficient rational checker. It must not be called a Lean certificate
until its exact-head pinned compilation and named axiom audit succeed.
