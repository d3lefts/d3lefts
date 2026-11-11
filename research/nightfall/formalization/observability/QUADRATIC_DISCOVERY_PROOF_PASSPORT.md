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
