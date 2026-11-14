# Asymmetric-product c/5 audit — 2026-11-14

## Objective / falsification threshold

Certify the true finite-original-source **pure-degree-two** c/5 terminal
for all heterogeneous, asymmetric, nonnegative normalized marginals,
including zero-probability atoms, without accidentally asserting the still-open
shifted c/5 lemma or unconditional unrestricted 99.262985 coefficient.

## Claim actually proved by the imported source theorem (pending strict CI receipt)

For arbitrary finite coordinate set ι, finite nonempty alphabet α, laws
p : ι → α → ℝ with (∀i a, 0 ≤ p i a) and (∀i, Σₐ p i a=1),
|f| ≤ B, Efron–Stein degree ≤2, and
(∀i, originalSingletonNorm p f i = 0), the declaration

  ActualSourcePureQ2Fifth.actual_source_pure_q2_239_unconditional

asserts

  (sourceVariance p f)^2 ≤ (8√3 + 8/5)^2 B² M

for all M ≥0 bounding each true sourceInfluence p f i.

The premises **do not** include p_i=p_j, equal-symbol weights, symmetry
of individual increments, positive atom floors, or the absence of zero atoms.
This is a nontrivial law-uniform statement for the pure-Q2 subclass,
not a universal all-degree-two theorem.

Additional proved *conditional* pure-Q2 endpoints are
(5√3+8/5)^2 assuming the separately established source 5B section
budget and [2√3(1+√2)+8/5]^2 assuming the still-open sharp
2(1+√2)B source section budget.

## Asymmetry and the fourth moment: exact mechanism

For independent, **centered** real-Hilbert increments Y_j, with
||Y_j||≤c and s=Σ E||Y_j||², no symmetry assumption is needed for

  E||ΣY_j||⁴ ≤ 3s² + c² s.

Every cross term involving an odd number of an index vanishes by
independence and mean-zero of that index. It is **not** an assumption
that E[||Y_j||² Y_j]=0: the third-moment vector may be nonzero.
With a deterministic shift h, the additional term

  4⟨h, Σ_j E[||Y_j||² Y_j]⟩

survives. That term is exactly why the pure-Q2 proof cannot be
relabeled as a proof for arbitrary singleton sectors.

As a skew example, take probabilities [0,3/4,1/4] on values
[0,-1/3,1], respectively. The random variable is centered,
|Y|≤1 and E[Y³]=2/9 >0. Neither equality of probabilities
nor symmetric signs is assumed by the pure theorem.

## Independent exact finite falsification

Command:

  python3 research/nightfall/2026-11-quadratic-law-free-audit/check_asymmetric_c5_exact.py

For n=1,2,3, enumerate all 36^n asymmetric two-atom centered
coordinate laws with a,b in {1/6,1/4,1/3,1/2,3/4,1},
nine deterministic shifts, and examine the proposed *general* c/5
inequality at 431,892 rational instances. Probability and L1
moments are exact Fractions. The irrational comparison is made
entirely in rational arithmetic by two justified squarings.

**Interpretation:** finding a failing instance would disprove the
universal shifted statement; passing finitely many instances does
not establish it. The check also admits a third zero-weight symbol.

## Strict certification gate

Run the dedicated workflow
`.github/workflows/nightfall-q2-asymmetric-source-c5.yml`.

It compiles **all transitive Lean dependencies** of
`ActualSourcePureQ2Fifth.lean` using pinned Lean 4.36.0-rc2,
Mathlib 9d581dfff2e41de989072ea63abf3daf69311520, and checks
exact named declarations with only Classical.choice, Quot.sound and
propext. It writes source hashes, compiler result, and receipts.

Do not mark compiler-certified until exact-head GitHub Actions
and axiom receipts pass. Do not promote unrestricted (C_{99});
that additionally needs a c/5 result *with arbitrary nonzero h*
and the sharp original-source section budget.
