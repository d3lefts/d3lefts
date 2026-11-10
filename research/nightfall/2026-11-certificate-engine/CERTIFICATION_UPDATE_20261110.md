# Product-space Aaronson–Ambainis: formalization and publication reconciliation

**Research status:** 10 November 2026; reviewed against repository `main` at `4cb56d3386051f083e2bad69810c3e2996b22a58` and open draft PR heads listed below. **This is an evidence ledger, not a referee report or public priority claim.** The source and exact Lean theorem statements, rather than a prose title or a green badge, govern what is certified.

## What has actually changed

The published `main` branch retains the Certificate Engine v2 candidate manuscript and the earlier, merged orientation/conditional-removal modules. The *substantially stronger new proofs are still on unmerged draft branches*.

| Stage | Repository evidence | What the certificate establishes | What it does NOT establish |
|---|---|---|---|
| Orientation symmetry | merged [#289](https://github.com/d3lefts/d3lefts/pull/289); Lean 4.35.0 | finite two-draw mass identities, including heterogeneous nonnegative finite weights | all-pairs reciprocal theorem |
| Conditional weight removal | merged [#293](https://github.com/d3lefts/d3lefts/pull/293); [receipt](https://github.com/d3lefts/d3lefts/actions/runs/42868198742) | abstract localized inequality under explicit positive-denominator and all-pairs premises | those premises from the product law |
| Reciprocal transfer | draft [#295](https://github.com/d3lefts/d3lefts/pull/295); [receipt](https://github.com/d3lefts/d3lefts/actions/runs/42883858082) | 16 named Lean 4.33.0 declarations, including `weighted_product_reciprocal` and `cross_pair_cost_pos`, derived from Turturean's pinned antipodal theorem | a shared-toolchain localized consequence by itself |
| Finite product two-sided bridge | draft [#298](https://github.com/d3lefts/d3lefts/pull/298), head `24cd9fe4379c6fcfe18093797a6870333645bf71`; [successful receipt](https://github.com/d3lefts/d3lefts/actions/runs/42903333354) | **joint Lean 4.33.0 compile**, eight named declarations including `localized_two_sided_product`, `two_sided_product`; no leftover reciprocal hypothesis | degree-dependent influence, arbitrary measurable products |
| Finite level crossing | draft [#299](https://github.com/d3lefts/d3lefts/pull/299), head `8371a5d06360ad48e8b5e4e2c1c0b73313816b1e`; [successful receipt](https://github.com/d3lefts/d3lefts/actions/runs/42906796793) | five additional named Lean 4.33.0 declarations including `finite_level_crossing`, threshold rows and positive row norms, **only for thresholds outside the attained range** with nonempty opposite classes | all thresholds, the mean-crossing bound, Chebyshev row cost |
| Overlap-based observation | draft [#300](https://github.com/d3lefts/d3lefts/pull/300), head `ce1d7c14d668ba28744a36a9677ee141df94845d`; [successful receipt](https://github.com/d3lefts/d3lefts/actions/runs/42908869811) | finite generic algebra: `certificate_overlap_sampler`, `weighted_potential_descent`, `geometric_potential_decay`, `overlap_information_sharp` | an end-to-end Lean proof of posterior conditional expectation, the adaptive policy, or runtime-efficient sampler |

The named receipts on #298, #299 and #300 report only the standard axioms `Classical.choice`, `propext`, and `Quot.sound`, without `sorryAx`. The joint finite two-sided result is the decisive improvement over the old `main` documentation. **Do not add together declaration counts across stacked branches as if they were independent proofs or merged modules.** In particular, #299 and #300 have the same #298 parent and are *not* in a single merged line.

For these formalizations, the finite input coordinates share a common finite alphabet **type** with heterogeneous coordinate-dependent masses; different alphabet **types**, arbitrary measurable alphabets, and infinite index sets require separate bridges. #298 assumes strictly positive masses and does not state normalization in its `two_sided_product` theorem. The algebra accepts positive finite weights; the interpretation as a *probability* theorem additionally requires each marginal to sum to 1, or normalization/support reduction. Do not conflate these requirements.

## The principal claimed theorem and its remaining gates

For independent inputs `X_i`, a bounded real function `f` of ANOVA/Hoeffding degree at most `d≥1`, `V=Var(f)>0`, and resampling influences
`I_i(f)=E Var(f|X_{-i})=(1/2)E[(f(X)-f(X^(i)))²]`, the Candidate Principal Theorem states

```text
max_i I_i(f) >= c_prod * V^(5/2) / d^6
c_prod = (8/5)^(3/2) * sqrt(15) /
         [125*(4-2*sqrt(3))*pi^4]
       = 0.001201250694... .
```

The claimed constant does **not** involve a minimum atom mass, maximum alphabet size or number of coordinates. What now has a formal proof is the **finite-product Boolean certificate/two-sided core** of the proposed argument, not this entire theorem. The remaining proof obligations are:

1. Derive and independently review the competing-symbol Chebyshev fractional-certificate row bound `K ≤ π²d²/2` for bounded real functions on finite products. The selector must handle incompatible replacements of the *same coordinate* and verify polynomial degree, pointwise boundedness and the LP limiting argument.
2. Audit the threshold integration, third moment, median constants, projection/averaging and total `L_1` influence bound, then compose them with #298 in one source-coherent proof. #299 addresses one threshold only and excludes ties `f(x)=t`.
3. Prove the finite-partition/conditional-projection passage to arbitrary measurable coordinate spaces and arbitrary (including uncountable) index sets. Establish the maximum-influence attainment, and handle null sets and completed product sigma algebras.
4. Independently check source-to-source originality against Turturean (6 November), Girish–Mittal–Nehoran–Raz (28 September), Huffstutler–Miloschewsky–Podder (9 November), and the 10 November Blanc–Docter–Strassle–Tan exposition. A finite-product transfer is a promising scope difference, but the published priority question remains open.
5. Obtain **non-author** mathematical review of the two decisive new proofs (competing-symbol selector and median/averaging) before public submission. Lean's kernel acceptance is a different certification gate from this review.

## New consequence on draft #300: exact scope of adaptive observation

For a nonconstant *Boolean* `g` with positive fractional-certificate costs `≤K`, the localized theorem defines `V_1,V_0>0`, coordinate loads `P_j,Q_j ≥0`, and `S=Σ_j sqrt(P_j Q_j)>0`. With `π_j=sqrt(P_jQ_j)/S`, the abstract Lean sampler gives

```text
E_(j~π) I_j(g) >= (V_1 V_0)^2/S^2
              >= V_1 V_0
              >= Var(g)/K^2 .
```

The `S^{-2}` gain is sharp **only relative to the abstract localized inequality and arbitrary constant influence vectors**. The constant vectors in `overlap_information_sharp` need not be realizable as influences of Boolean functions, so it is not a global decision-tree optimality theorem.

The exact ANOVA identity
`E_(X_j)[T(g|X_j)]=T(g)-I_j(g)` for `T=Σ_i I_i(g)`, together with `T≤d Var(g)`, yields the *derived* conditional bound
`MSE_t ≤ d Var(g) exp(-t/(d K²))` for a certificate-overlap observer. This is an **analytic derivation**, not the currently Lean-certified end-to-end adaptive tree. It applies to *Boolean g with bounded row cost*, not automatically to arbitrary bounded real quantum acceptance probabilities. Every posterior state must preserve the degree and row-cost assumptions, and runtime complexity is unbounded unless the sampler itself can be computed efficiently.

A key counterexample to the tempting shortcut `E[Var(g|X_j)]=Var(g)-I_j(g)` is two-bit parity under fair bits: `I_j(g)>0`, yet observing only `j` leaves output variance unchanged. The correct potential is **total ANOVA influence**, not output variance.

## Quantum-query bound: reconcile two manuscript versions before release

The `Wright_Certificate_Engine_v2.tex` on `main` advertises a `T^7 ε^{-3} δ^{-3/2}` simulation corollary. That version is **not currently substantiated by the audited potential argument**, and must not be presented as verified. A separately prepared RC2 review derives the more conservative bound

```text
m <= ceil( (2T)^7 / [2^(3/2) c_prod ε^5 δ^(7/2)] )
```

for a known finite product input law and a `[0,1]`-valued degree-`d≤2T` acceptance probability, **conditional on the full principal influence theorem**. The conversion from the `[-1,1]` principal theorem is
`I_i(f) ≥ 8*c_prod*Var(f)^(5/2)/d^6` because `g=2f-1` has variance `4Var(f)` and influences `4I_i(f)`.

A proof audit of this precise bound uses `T_total(f)=Σ I_i(f) ≤ d Var(f)≤d/4`. At a posterior state with variance at least `v`, query a maximally influential coordinate and decrease `E[T_total]` by at least `8*c_prod*v^(5/2)/d^6`. **Stop querying as soon as the posterior variance is below `v`**. The fraction of paths still above `v` after `m` queries is then at most `d^7/[32*c_prod*m*v^(5/2)]`. Set `v=δε²/2` and `m=d^7/[2^(3/2)c_prod ε^5δ^(7/2)]`: the active-path probability is at most `δ/2`. On stopped paths, conditional Chebyshev makes the error probability at most `v/ε²=δ/2`, yielding total error at most `δ`. This argument counts *whole-symbol input queries*, not computation time or gate complexity.

**Audit boundary:** this scaling argument is conditional on the proposed law-independent real-function influence theorem; it has not been composed into a Lean theorem or separately peer reviewed. Do not silently replace the main-branch manuscript's exponents without an explicit manuscript revision and proof comparison.

## Novelty, significance, and release decision

- Strongest machine-certified claim checked this session: **finite-product localized and two-sided certificate inequalities, plus a finite off-range level-crossing theorem**. The proof architecture preserves arbitrary positive coordinate masses without a minimum-atom factor.
- Promising manuscript-level result: full arbitrary-product Aaronson–Ambainis influence bound with `c_prod≈0.00120125`; written proof is not yet a non-author-vetted theorem.
- Reusable secondary mechanism: certificate overlap → a concrete distribution over informative coordinates → total-influence Lyapunov descent. The generic sampler is formally certified; posterior-policy composition remains open.
- **No new scientific theorem is certified merely by this ledger**. No merge, arXiv posting, journal submission, priority assertion, or reviewer invitation is authorized by the existence of green CI.

### Source and replay pointers

- [Turturean's AA proof and pinned formalization](https://arxiv.org/abs/2611.09773), [source commit](https://github.com/physical-superintelligence/aaronson-ambainis/tree/2a6ceaef872ae993708950f951989134084b851a)
- [Girish–Mittal–Nehoran–Raz, distributional variants](https://arxiv.org/abs/2609.35327)
- [Huffstutler–Miloschewsky–Podder, completion framework](https://arxiv.org/abs/2611.12795)
- [Blanc–Docter–Strassle–Tan exposition](https://aiproofwatch.com/updates/a-proof-of-the-aaronson-ambainis-conjecture-1cd81793) (bibliographic announcement; verify the primary manuscript)
- Exact independent 522-case checker in #300: `research/nightfall/formalization/product_space/check_certificate_guided_descent.py` on that draft head.
- Dated certified source receipts: [#298](https://github.com/d3lefts/d3lefts/actions/runs/42903333354), [#299](https://github.com/d3lefts/d3lefts/actions/runs/42906796793), [#300](https://github.com/d3lefts/d3lefts/actions/runs/42908869811).

**Next cheapest decisive audit:** obtain a specialist's direct adversarial review of the finite competing-symbol selector and the threshold-integration/median argument, explicitly testing the arbitrary-alphabet case and `f(X)=E f` ties; then formalize those dependencies. Preserve a dated revision hash before public priority claims.
