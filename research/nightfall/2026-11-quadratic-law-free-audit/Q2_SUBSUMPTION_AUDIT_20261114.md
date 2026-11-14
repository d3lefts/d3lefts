# NIGHTFALL Q2: source-scope subsumption audit (2026-11-14)

## Gate / outcome

This is a **dated, bounded prior-art audit**, not a proof of priority.
The current source-only finite-product degree-two Lean theorem is valid in
its exact source scope (Q2 source: `ActualSourceQ2CoupledUnconditional.lean`,
draft PR #494, pinned compiler run 43627249467). Its exact coefficient is
407 + 138 sqrt(2) + 188 sqrt(3) + 56 sqrt(6) ≈ 1064.9584490.

**Negative novelty finding:** On the uniform Boolean cube, a much stronger
variance-squared/max-influence inequality follows *elementarily* from
Khintchine's inequality and the bilinear mixed-norm principle. Therefore
the bare exponent-two assertion for degree two on fair bits should NOT be
marketed as new. The 2026 optimal completely bounded root-influence paper
is an even more relevant external theorem to compare.

**Still not determined:** A source-to-source subsumption of the exact
finite product theorem across arbitrary alphabet sizes, coordinate-specific
nonuniform marginals, and zero-probability atoms. Neither failure of an
obvious reduction nor failure to find a paper establishes novelty.

## Strongest relevant external references checked

1. F. Escudero Gutiérrez, M. Saucedo, C. Palazuelos, *Optimal inequalities
   for completely bounded polynomials and the limitations of quantum query
   algorithms* (September 4, 2026), arXiv:2609.05201.
   The abstract states the sharp block-multilinear root-influence result
   `||P||_cb >= (sum_i sqrt(Inf_i(P)))/t` (with its block scope).
   **Gate:** check the paper's exact block definitions, which influences are
   summed, and the cb norm of the scalar quadratic lift before invoking it
   on categorical product sources.
2. S. Aaronson, A. Ambainis, J. Iraids, M. Kokainis, J. Smotrovs,
   *Polynomials, Quantum Query Complexity, and Grothendieck's Inequality*
   (CCC 2016): constant-factor correspondence between bounded quadratic
   Boolean polynomials and one-query quantum representations.
3. J. Briët, F. Escudero Gutiérrez, S. Gribling, *Grothendieck inequalities
   characterize converses to the polynomial method*, Quantum 8:1526
   (Nov 18, 2024), DOI 10.22331/q-2024-11-18-1526.
4. U. Girish, K. Mittal, B. Nehoran, R. Raz, *Distributional Variants of
   the Aaronson-Ambainis Conjecture*, arXiv:2609.35327 (Sept 28, 2026):
   fixed-biased-bit and slice equivalence; no uniform-in-bias,
   heterogeneous-alphabet constant specified in the abstract.
5. D. Turturean, *A proof of the Aaronson-Ambainis conjecture*,
   arXiv:2611.09773 (Nov 6, 2026): uniform cube bound with variance
   exponent 5/2 and degree exponent 6. The fair degree-two variance
   exponent-two phenomenon is not a consequence of this theorem alone.
6. Classical real Khintchine inequality, degree-one Rademacher sums;
   classical mixed Littlewood/Grothendieck bilinear bounds.

## Decisive fair-cube subsumption calculation (self-contained)

Let `f:{-1,1}^n -> [-B,B]` have Fourier degree <=2:
`f(x)=c+sum_i a_i x_i + sum_{i<j} b_ij x_i x_j`.
Use Efron–Stein (conditional-variance) normalization:
`V=Var(f)=sum_i a_i^2+sum_{i<j} b_ij^2`;
`I_i=a_i^2+sum_{j!=i}b_ij^2`; `M=max_i I_i`.

1. `(f(x)-f(-x))/2=sum_i a_i x_i`, so
   `sum_i |a_i| <= B`.
2. For any bipartition L,R,
   `G_LR(s,t)=sum_{i in L,j in R} b_ij s_i t_j`.
   The alternating four-evaluation projection of f onto its cross
   interactions shows `||G_LR||_infty <= B`.
   Fix t and maximize over s; hence
   `sum_{i in L} |sum_{j in R} b_ij t_j| <= B`.
   Average uniform t and use real Khintchine
   `E|sum c_j t_j| >= (sum c_j^2)^(1/2)/sqrt(2)`:
   `sum_{i in L} (sum_{j in R} b_ij^2)^(1/2) <= sqrt(2) B`.
3. Choose each vertex independently in L or R with probability 1/2.
   Put `R_i=(sum_{j!=i} b_ij^2)^(1/2)`.
   Conditional on i in L, let
   `T_i=sum_{j in R} b_ij^2`. Then
   `0<=T_i<=R_i^2`, `E[T_i]=R_i^2/2`, and
   `sqrt(T_i)>=T_i/R_i` if `R_i>0`. Therefore
   `E[1_{i in L} sqrt(T_i)] >= R_i/4`.
   Summing gives `sum_i R_i <= 4sqrt(2)B`.
4. Consequently
   `sum_i sqrt(I_i) <= (1+4sqrt(2))B`, and
   `V<=sum_i I_i<=sqrt(M)sum_i sqrt(I_i)`.
   Thus, rigorously on uniform fair bits,

       Var(f)^2 <= (1+4sqrt(2))^2 B^2 max_i I_i < 49 B^2 max_i I_i.

This is an independent *derivation from classical ingredients*, NOT a
new theorem in historical priority. It already strictly dominates the
coefficient 1064.958 on this **narrower fair-cube** domain. It does not
transport to arbitrary source laws by substitution.

## A categorical counterexample to a uniform root-influence sum

There is a stronger obstruction than the failure of conditional
two-draw influence comparison. For any n>=2, use n+1 independent
coordinates of a COMMON n-symbol alphabet `{0,...,n-1}`.
The first coordinate J is uniform on n labels. All other coordinates
are independent fair signs encoded in two symbols, with zero mass
on unused alphabet atoms. Define `s(0)=+1, s(1)=-1`, and `s(a)=-1`
for unsupported atoms, and set

    f(J,X_1,...,X_n) = s(X_J) = sum_{j=0}^{n-1} 1_{J=j} s(X_j).

The formula is pointwise a sum of terms depending on two source
coordinates, so its actual Efron–Stein degree is <=2 even on
zero-probability configurations. It is bounded by 1 everywhere;
its variance is 1. Under the true product law,

    I_J = 1 - 1/n,       I_{X_j} = 1/n  (for every j),

using the source conditional-variance normalization.
Consequently,

    sum_i sqrt(I_i) = sqrt(n) + sqrt(1-1/n) --> infinity

despite `||f||_infty=1`, `Var(f)=1`, and `max_i I_i<=1`.

**Implication:** a universal extension of the fair-cube root-influence
SUM inequality `sum_i sqrt(I_i)<=C B` to arbitrary finite common
alphabets is mathematically **FALSE**. Any prior-art subsumption
of our true-source Q2 max-influence bound must use a weaker norm,
additional structure, or a different reduction. This explicit
counterexample does not prove our max-influence inequality historically
novel: Grothendieck/decoupling methods might still yield it
without a root-sum bound.

The independent checker `check_q2_subsumption_boundary.py` verifies
this construction by direct Fraction summation for finite n, not by
assuming the derived influence formulas. This is a test, not a
formal Lean theorem. The symbolic formulas above give the general proof.

## Exact obstruction to a naive bias-free reduction

Let a single original source `X~Bernoulli(epsilon)` and `f(X)=X`.
Original conditional-variance influence is
`I_orig=epsilon(1-epsilon)`.

Draw `X,Y` independently and condition on the unordered pair being
`{0,1}`. The fair orientation variable has conditional influence
`I_cond=1/4`. Thus
`I_cond/I_orig=1/[4epsilon(1-epsilon)] -> infinity`
as epsilon->0.

**Implication:** No dimension- and bias-independent *pointwise*
comparison `I_cond<=C I_orig` can justify simply applying a
fair-cube theorem conditional on each unordered pair.
This does **not** refute an averaged two-draw transfer theorem, a
completely bounded operator extension, or a different reduction.

Checker: `check_q2_subsumption_boundary.py`; all arithmetic rational
where possible. Numerical falsification does not prove the analytic
fair-cube theorem, which is established by the displayed inequalities.

## Status and next decisive prior-art test

- Validity: narrow fair-cube bound mathematically derived from standard
  Khintchine; rare-event obstruction exact; source Q2 theorem independently
  recorded by current-head Lean receipts.
- Prior art: fair-cube exponent-two **subsumed by classical mechanism**.
  Arbitrary product/zero-atom statement **not subsumed by a verified
  source-preserving reduction this session**.
- Missing highest-value test: a categorical/nonuniform extension of the
  root-influence vs completely bounded norm inequality with a
  distribution-independent comparison of the actual source influence,
  no division by small probabilities, and explicit coefficient.
  If this succeeds with a universal constant, demote Q2's originality.
- Publication: no originality signoff; obtain full-text line-by-line
  comparison of the Sep 2026 completely bounded theorem and an
  independent functional-analysis referee.
