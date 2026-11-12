# Proof Passport — Quadratic Discovery Lean Kernel Core (review branch)

Date: 2026-11-11. Mathematical source: NIGHTFALL, *Adaptive Compression and
Quadratic Observability on Product Spaces*, v4.0, sections on quadratic matching,
projection/interpolation, influence, and adaptive rank recovery.

## Target theorem (NOT YET kernel certified)

For every finite product of arbitrary independent alphabet laws, every
real-valued function f with |f| <= B and Hoeffding/ANOVA degree <=2 obeys

    Var(f) <= 15(1+sqrt(3)) B sqrt(max_i Inf_i(f))

where Inf_i(f) is the Efron–Stein resampling influence. The proposed
Hilbert-rank-r adaptive observation complexity Theta(r/eta), the
measurable/infinite product extension, and global novelty are separate gates.

## What QuadraticDiscoveryCore.lean actually proves

1. `additive_projection_identity`: the exact quadratic interpolation identity
   q(0)+q'(0)=-2q(0)+4q(1/2)-q(1).
2. `additive_projection_seven`: if the three values lie in [-B,B], the
   projected additive part is bounded by 7B. The separate
   `additive_projection_seven_sharp` has a genuine explicit sharp witness
   q(t)=8t²-8t+1.
3. `parity_coupling_difference` and `mixed_difference_four`: the two-point
   even/odd cancellation and the exact 4B mixed-difference estimate.
4. `matching_amplitude_from_coupled_expectations`: sum of matched amplitudes
   <=4B given an **explicitly assumed** equality between the signed mixed
   differences and the gap of the two global coupling expectations. This
   equality has NOT been proved from the product function in Lean.
5. `quadratic_certificate_closure`: proves the exact constant
   15(1+sqrt(3)) by finite-sum algebra under an **explicitly supplied**
   matching/fourth-moment certificate (section norm, cost, interpolation,
   energy-decomposition bounds). Its hypotheses are not established from f.
6. `squared_influence_of_quadratic_bound`: the elementary square-and-scale
   consequence of an explicitly assumed variance-versus-sqrt-influence bound.

All declarations use only Mathlib and standard Lean foundational axioms.
Only a successful GitHub CI receipt with matching SHA, toolchain, names and
#print axioms can establish that the checked statements compiled.

## Genuine arbitrary-law moment extension (separate file)

`ArbitraryLawFourthMoment.lean` formalizes an actual product of two arbitrary
finite weight tables, its factorization, and the centered real-valued
two-increment fourth-moment identity

    E[(Y+Z)^4] = E[Y^4] + 6 E[Y²]E[Z²] + E[Z^4].

It also proves the finite Hilbert self-moment estimate
`E||Y||^4 <= c² E||Y||²` under an explicit pointwise `||Y||²<=c²`
bound and arbitrary nonnegative state weights. Unlike the abstract
certificate closure, these statements quantify over the actual sample
tables without fairness or atom lower bounds.

They still do **not** establish the many-increment Hilbert fourth-moment
inequality used by the unrestricted quadratic theorem.

## Recovery audit and new verified bridges (2026-11-11)

**Hoeffding representation — finite-product gate CLOSED.**
Existing merged `EfronSteinDegree.lean` (PR #325) proves the actual
Möbius decomposition `es_decomp` and `prodDegree_iff_esDegree`.
New `QuadraticHoeffdingBridge.lean` imports it and kernel-proves
`quadratic_hoeffding_decomposition` and
`quadratic_hoeffding_filter`, with all higher-order terms removed
pointwise for a genuinely assumed `ESDegreeLE p f 2`. Pinned upstream:
Turturean commit `2a6ceaef872ae993708950f951989134084b851a`;
Lean 4.33.0. Reproducible success:
https://github.com/d3lefts/d3lefts/actions/runs/43057281341
(actual imported proof, strict accepted standard axioms).

**Global matching — analytic mechanism recovered, kernel gap OPEN.**
Merged PR #327's `CUBIC_OBSTRUCTION_NOTE.md` proves the general
disjoint top-support parity comparison
`sum_{S in matching} ||h_S||∞ <= 2^d B`; at `d=2`
this yields `<=4B`. Draft PR #356 `PROOF.md` supplies a separate
finite-graph proof with exact rational checks. The v4
`source/matching-core.tex` constructs the greedy endpoint assignment
`sum_i c_i<=8B` and `||h_ij||∞<=max(c_i,c_j)`. No Lean declaration
constructs the **global even/odd product distributions with cancellation
of all off-matching interactions**, or the greedy assignment from
actual graph weights. The checked `matching_amplitude_from_coupled_expectations`
still assumes the conservation equality.

**Fourth moments — actual two-Hilbert-increment gate CLOSED;
arbitrary-family gate OPEN.** New `HilbertTwoIncrementMoment.lean`
imports `ArbitraryLawFourthMoment.lean` and proves genuinely from
arbitrary independent finite categorical laws and coordinatewise
centering that

    E||U+V||⁴ <= E||U||⁴ + E||V||⁴
                   + 6 E||U||² E||V||².

No fair-sign or atom-floor assumptions and no dimension factor.
Pseudonorm is the exact Euclidean squared norm of a finitely indexed
real vector. Pinned Lean 4.35.0/Mathlib v4.35.0 succeeded with standard
axioms only:
https://github.com/d3lefts/d3lefts/actions/runs/43058085067
(source `HilbertTwoIncrementMoment.lean` SHA-256
`e8958e46baa6afa0be946f75848555177d12dcc23fc227e036f7f7238c1c36a7`).
The theorem is not yet an `n`-increment theorem and does not
identify actual assigned Hoeffding terms as independent increments.
The separate source-exact analytic finite-`n` proof is in the
v4 `source/matching-core.tex`: `E||ΣY||⁴<=c²s+3s²`.

**Independent numerical attack.** The deterministic
`check_hilbert_many_exact.py` executes 1,050 exact-rational
heterogeneous/categorical Hilbert examples, checking the independent
covariance-trace fourth-moment formula and the bound, with a second
brute-force tensor enumeration for up to four increments. This is
falsification testing only, not a theorem certificate.

**Overall target still NOT closed**: remaining finite-product links are
(A) actual ANOVA centering/orthogonality/energy decomposition and
resampling influence instantiation; (B) global parity-coupled matching
construction and greedy endpoint cover; (C) arbitrary finite-family
Hilbert fourth-moment induction and mapping assigned interactions
into its independent increment inputs. Then the checked
`quadratic_certificate_closure` can conclude
`Var(f) <= 15(1+sqrt(3)) B sqrt(M)` without *extra* hypotheses.
The Hilbert rank-r/adaptive posterior and measurable infinite-product
claims require separate full bridges after scalar finite closure.

## No hidden claims / missing load-bearing formal steps

- Define finite-product degree-two Hoeffding projections and actual scalar
  Efron–Stein influence, connecting to the existing `ProductInfluence.lean`
  definitions under the pinned toolchain.
- Prove the *global* multi-edge parity coupling construction, cancellation of
  all off-matching quadratic interactions, and sup-norm matching mass <=4B.
- Formalize the weighted greedy matching and its assignment costs.
- Formalize the sectionwise quadratic switching polynomial and its 8B
  derivative/oscillation budget, then derive the 7B additive projection norm
  from actual conditional product expectations.
- Prove independence and centeredness of the Hilbert `L²`-valued assigned
  increments; prove their fourth-moment estimate and interpolation.
- Compose these facts into the **unconditional** finite-product target
  theorem. Only after that should the finite-product influence result be
  promoted to kernel-checked.
- Separately formalize rank-r covariance projection, posterior ANOVA drift,
  a realized adaptive policy, and countable arbitrary-product measurability
  before claiming end-to-end spectral observability.
- Independent mathematical reviewer and dated priority review remain open.

## Historical source and novelty boundaries

- David Turturean (2026): Lean-checked Boolean-cube Aaronson–Ambainis
  method, imported for the already kernel-checked (5/2,6) product bound.
- Classical Markov–Chebyshev polynomial inequalities, Efron–Stein/ANOVA,
  matching theory, and bounded independent-sum fourth moments are antecedents.
- The proposed **new** conclusion is the no-atom, no-alphabet-cost squared-
  variance quadratic theorem and associated rank-r adaptive classification.
  The abstract projection/certificate lemmas are not individually claimed
  novel and do not certify the proposed main theorem by themselves.

## Fail-closed CI gate

GitHub Actions workflow `nightfall-quadratic-discovery-lean.yml` installs
Lean v4.35.0 + Mathlib v4.35.0, runs `scripts/lean_bridge.py --strict`,
checks all eight theorem declarations and their reported axioms with
`check_receipts.py`, and retains pinned source hashes and logs.
Do not merge/promote until the CI run passes; do not represent that
green status as a proof of the full arbitrary-law theorem.

## Addendum 2026-11-12 — actual source ES bridge through PR #408 (not terminal Q2)

The 11 November historical proof sections above describe their contemporaneous proof state. Merged PR #407 added an actual finite quadratic row/section bridge. PR [#408](https://github.com/d3lefts/d3lefts/pull/408) added genuine Efron–Stein pair-kernel centering and all-edge rectangle-orientation statements. **Eight named declarations** have strict compiled [Lean 4.33.0 receipt #43167542367](https://github.com/d3lefts/d3lefts/actions/runs/43167542367) under the pinned Turturean upstream and permitted standard axioms. Source SHA-256: 4d59e9bf872f89a3310b6c3a5203d9256e4b85bfab65cfc60c0a065bca0bffea; see the [actual matching ledger](../product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md).

**Now certified scoped:** source-derived pair components, conditional centering and arbitrary-graph oriented rectangles. **Still missing terminal Lean:** global even/odd parity-from-the-same-source-f with unmatched-coordinate padding proving matching mass ≤4B; composition with actual greedy ownership, genuine independent assigned increments, and resampling influences; unconditional scalar exponent-two theorem; Hilbert rank and posterior risk; arbitrary measurable-product lift. The independent many-increment Lean 4.35 [receipt #43062171542](https://github.com/d3lefts/d3lefts/actions/runs/43062171542) is a distinct theorem and cannot be treated as a same-pin merged proof.

**Current stronger analytic coefficient:** v8/v9.2 C₂=(10+2√2)²(1+√3)²≈1228.356, versus this historical v4/v7 value 225(1+√3)². The [v9.2 internal review](../../../../papers/finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md) flags a Corollary 6.2 citation/constant problem, unavailable exact v9.2 TeX, and pending non-author proof/priority review. This addendum cannot elevate the analytic bound to a kernel theorem.

**Next decisive compiler experiment:** formulate a declaration with only normalized finite laws, actual bounded source function f, actual degree-two Efron–Stein assumption, and disjoint matching; construct both global selector distributions and conclude the true 4B mass directly, with no assumed matching equality. Other proof gates remain open. See the [updated q2 passport](../../2026-11-active-passports/quadratic-rank-observability.md).
