# NIGHTFALL Q2 subsumption audit v1 — 2026-11-14

**Problem:** determine whether the finite-product degree-two theorem
`Var_p(f)^2 <= C B^2 max_i sourceInfluence_p(f,i)`, with finite common
alphabet, arbitrary normalized per-coordinate masses including zeros,
and genuine source-derived `ESDegreeLE p f 2`, follows from pre-2026
Littlewood/Bohnenblust–Hille/Grothendieck estimates or the 2026 AA literature.

**Status:** counterexample to a *proposed proof transfer*, not proof of
novelty. Author-side exact checker; no external specialist review.
Current source-verified coefficients: 1228.356 on main (#491);
1064.958449 on draft #494 with a reported strict pinned Lean success.
The constants are not optimized here.

## The strongest preexisting theorem checked

M. Maia and J. Santos, *On the Mixed (ℓ1,ℓ2)-Littlewood Inequalities
and Interpolation*, Mathematical Inequalities & Applications 21 (2018),
721–727, DOI 10.7153/mia-2018-21-51, Section 1, Eq. (1):
for real bilinear forms U on c0 × c0, `sum_i sqrt(sum_j a_ij²)
<= sqrt(2) ||U||`. Verified from the first page of the original PDF:
https://files.ele-math.com/articles/mia-21-51.pdf

On the uniform fair Boolean cube this gives a short known route to the
quadratic benchmark `Var(f)^2 <= (9+4 sqrt(2)) B² M` (for B a uniform
absolute range bound and source influence with no extra factor of 2):
bipartition the quadratic coefficient graph randomly, extract its
cross-bilinear component by four sign flips (norm ≤B), apply the mixed
Littlewood row bound, and average the half-edge cross mass. The linear
sector has coefficient ℓ1 norm ≤B by odd/even sign splitting. This
is a special-case subsumption of NIGHTFALL's much weaker fair-bit
bound, not of the arbitrary-alphabet theorem.

Related: Defant et al., *The Bohnenblust–Hille inequality for
homogeneous polynomials is hypercontractive*, Annals of Mathematics 174
(2011), 485–497; the exponent-4/3 coefficient estimate by itself does
not imply the quadratic variance exponent 2 without additional
mixed-row control.
https://annals.math.princeton.edu/2011/174-1/p13

## Decisive negative test: naive categorical transfer fails by sqrt(n)

Take independent fair signs X_1,...,X_n and an independent uniformly
distributed n-valued symbol Y. Define a genuinely degree-two bounded
task
    f(X,Y) = X_Y - (1/n) sum_i X_i
           = sum_i X_i (1_{Y=i} - 1/n).

All interaction terms are separately centered. Exact symbolic values:
    E f = 0;
    Var(f) = 1 - 1/n;
    ||f||infty = 2(1-1/n);
    I_{X_i}(f) = (n-1)/n²;
    I_Y(f) = 1-1/n;
    sum_i sqrt(E[h_{iY}²]) = sqrt(n-1).

Therefore the false extension
    sum_i sqrt(E[h_{iY}²]) <= K ||f||infty
fails for every universal K: the left side grows as sqrt(n) while
the right side stays ≤ 2K. In particular, it contradicts a naive
`sqrt(2)` mixed-Littlewood extension for sufficiently large n.

**Important:** this does **not** refute the actual Q2 theorem: here the
categorical hub has influence `1-1/n`, and the source theorem remains
comfortably true. It shows that the ℓ∞-bilinear c0 row norm cannot be
transferred without accounting for categorical one-hot exclusivity
and hub influence. Arbitrary source factorization is the unresolved
obligation.

Reproducible exact checker:
`python3 research/nightfall/2026-11-quadratic-law-free-audit/check_littlewood_categorical_obstruction.py`.
The checker enumerates original worlds exactly for n=2,...,8 and
verifies the rational moment and influence identities, with further
symbolic inequalities for n=9,16,32,128,1024.

## Contemporary AA comparisons, theorem scope

1. David Turturean, *A proof of the Aaronson–Ambainis conjecture*
   (6 Nov 2026), arXiv:2611.09773. Uniform fair Boolean cube,
   general d, exponent 5/2 and d^{-6}. Does not by statement subsume
   a bias-independent, finite-alphabet exponent-2 theorem.
2. Uma Girish, Kunal Mittal, Barak Nehoran, Ran Raz, *Distributional
   Variants of the Aaronson–Ambainis Conjecture* (28 Sep 2026),
   arXiv:2609.35327. Fixed Bernoulli bias p in (0,1), uniform-over-slice
   counterparts and equivalence of qualitative AA variants. These
   statements do not supply an alphabet-size-free / min-atom-free
   degree-two coefficient for coordinate-dependent laws.
3. Nikhil Bansal, Makrand Sinha, Ronald de Wolf (CCC 2022),
   *Influence in completely bounded block-multilinear forms and
   classical simulation of quantum algorithms*.
   This imposes completely bounded block-form structure and is not
   the same as all bounded finite-alphabet quadratic observables.
   DOI:10.4230/LIPIcs.CCC.2022.28.

## Scope of the conclusion

**Confirmed:** classical Littlewood subsumes a fair-bit restricted
specialization and the naive transport to categorical sources is
mathematically false. **Not confirmed:** whether a different classical
operator-factorization, Grothendieck extension, decoupling inequality,
or an unlocated 2026 paper subsumes the entire original-source Q2
theorem. This is neither an exhaustive literature search nor a
non-author review.

Next decisive experiment: seek a form of the mixed Littlewood estimate
which explicitly charges the most influential categorical hub while
preserving the variance-squared exponent and zero-atom support. Demand
a literal theorem-type map or counterexample. Do not optimize scalar
coefficients before resolving subsumption.
