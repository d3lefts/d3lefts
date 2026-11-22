# PR #1000 — Information–regularity–robustness frontier for causal phase retrieval

**Status (2026-11-22):** DRAFT RESEARCH CHARTER / PR RESERVATION ONLY. No new breakthrough, general noise theorem, Lean proof, independent specialist review, or priority claim is asserted. Do not merge to main based on this charter.

## Objective and source boundaries

Determine sharp quantitative tradeoffs between number of normalized squared-linear readings, causal selector regularity, reconstruction error, and adversarial observation noise. A genuine win is a previously unknown *uniform* theorem with optimal or provably sharp-order bounds, separating fixed from adaptive protocols where possible and identifying the operator responsible for the tradeoff.

Source dependencies are paper-level [#997](https://github.com/d3lefts/d3lefts/pull/997) and draft [#999](https://github.com/d3lefts/d3lefts/pull/999), plus the more general but *unreviewed* [#995](https://github.com/d3lefts/d3lefts/pull/995). The source-pinned baseline advertised in #999 is an *infimum* for noiseless annuli, not a noise-robust construction. Earlier [#695](https://github.com/d3lefts/d3lefts/pull/695) and [#699](https://github.com/d3lefts/d3lefts/pull/699) concern different adaptive models; do not silently transfer certificates.

## Exact working model (v0; alternatives must be separately identified)

Fix n >= 2, 0 <= r < R, R > 0, m >= 0, and sigma >= 0. Domain D = {x in R^n : r <= ||x|| <= R}. A deterministic length-m protocol has selectors a_j : R^(j-1) -> R^n continuous on **all possible noisy real observation prefixes**, with ||a_j|| <= 1. On input x and adversarial additive errors e_j in [-sigma,sigma] it observes

    z_j = <a_j(z_1,...,z_(j-1)), x>^2 + e_j.

The decoder Delta maps complete observed transcripts to R^n / {+1,-1}; no decoder continuity required. Use d_pm([x],[y]) = min(||x-y||,||x+y||). The robust minimax error is

    E_m(n,r,R;sigma) = inf_(continuous normalized causal a, arbitrary Delta)
      sup_(x in D, |e_j| <= sigma) d_pm(Delta(z(x,e)),[x]).

Keep *observation* noise separate from row perturbations and finite-precision row selection. The stronger global-prefix continuity is intentional and must not be conflated with the reachable-prefix-only continuity in #997/#999. At sigma=0, explicitly prove any transfer between these classes; do not assume it.

## Baselines, not novelty

- Trivial monotonicity: E_m(n,r,R;sigma) is nondecreasing in sigma; upper bounded by the radius of an admissible constant decoder.
- For r=0 and 0 < sigma <= R^2, the two inputs x=0 and y=sqrt(sigma) v (unit v) can be forced to share the zero observed transcript: choose noise e_j=-<a_j(0,...,0),y>^2 for y, and zero noise for x. Every |e_j| <= sigma. Thus E_m(n,0,R;sigma) >= sqrt(sigma)/2 for every m and every normalized causal policy. This is an elementary indistinguishability observation, **not** a novel contribution.
- #999 exhibits a fixed near-hyperplane family with near-optimal *noiseless* error but a conditioning obstruction for those specific frames. That obstruction does NOT prove impossibility for all causal policies.
- At sigma=0, #999's claim E_(2n-2)(n,r,R;0) = (R-r)/2 is for its reachable-prefix model. Treat its proof and the extension-to-global-prefix question as pending formal review, not as a Lean theorem.
- Do not conjecture a discontinuity at sigma -> 0 merely because a particular near-coplanar construction loses stability; quantify the best joint construction as its geometric parameter changes.

## Primary questions / success thresholds

1. **Sharp noise/accuracy law.** At m=2n-2 and 0<=r<R, determine E_m(n,r,R;sigma), or a two-sided uniform sharp-order bound in sigma, n, r, R, with explicit assumptions and constants. Find the Pareto frontier between excess error tau over the purported noiseless infimum and required noise precision sigma. Is an adaptive improvement over optimal fixed frames possible?
2. **Known-norm transition.** Repeat at m=2n-3 for D = sphere(R), for both unrestricted and sphere-valued decoders, *as a separate theorem/model*.
3. **Regularity operator.** If global continuity is too weak for a uniform rate, compare bounded selector Lipschitz constant L and/or bounded decoder stability; prove an obstruction or sharp constructive bound that charges this resource explicitly.
4. **Transfer theorem.** Identify a reusable, dimension-explicit indistinguishability/conditioning principle for continuous adaptive sensing, not merely a constant fitted to one frame.

A successful flagship needs at least one **new theorem** with explicit optimality/sharpness evidence; correct prior art; proof independently attacked; named Lean certificate for its formalizable core and external mathematical review before claiming a breakthrough. Numerical phenomena, replay logs, theorem schemas, or the round number #1000 alone do not pass.

## Preregistered cheapest decisive checks and counterexamples

- First analyze n=2, R=1, r=0, m=2, both (i) the adaptive #999 policy and (ii) normalized two-row fixed frames. Explore sigma as an exact rational square where possible.
- **Prediction to test, not claim:** the minimax excess-risk rate may depend on whether a bounded row-selector regularity modulus is imposed; compare L-bounded and unrestricted continuous policies.
- Adversarial alternatives: the noiseless exact infimum fails after auditing #999; global-prefix extension changes the model; decoder output restrictions alter constants; the near-hyperplane noise example is non-universal; a fixed frame achieves the same rate as adaptive protocols.
- Cheap falsifiers: axis inputs, near-zero vectors, antipodal quotient identification, transverse orthogonal pairs, vanishing first reading, negative corrupted measurements, sigma=0, r=0, r->R, zero row, m=0, selector behavior at unreachable prefixes.
- Distinguish finite counterexamples (which can refute universal hypotheses) from finite success samples (which cannot prove a sharp bound).
- **Stop rule:** after one scoped n=2 symbolic analysis and independent attack, if no nontrivial sharp inequality or separative example survives, narrow the claim or switch to the known-sphere case; do not optimize a bound at sub-verifier resolution.

## Formalization / independent coordination (assignments, not completed actions)

- **Axiom — mathematical construction:** derive n=2 candidate policies and a quantified upper bound with explicit sigma, normalized rows, total-domain continuous extensions, and output decoder. Provide a complete manuscript and minimal counterexample attempts.
- **Lemnis — independent adversarial proof audit:** independently reconstruct #997/#999 lower-bound dependencies and challenge the n=2 construction, the exact minimax quantifiers, and causal/noncausal confusion. Record smallest countermodel or dependency-complete argument. Do not review only the author's prose.
- **Tessera — structural transfer:** independently examine whether a uniform n-dimensional lifting exists; preserve dependence on m, n, L and radial parameters. No theorem transfer by analogy.
- **Ryev — reproducibility and formal verification plumbing:** write independent rational/numerical falsifiers and a separate Lean theorem-contract checker; enforce exact source SHA, compiler/mathlib pin, named theorem type, #print axioms, rejection of sorryAx/nonstandard axioms, and CI artifact retention.
- **Vesper — integration and prior-art/credit gate:** map connections to #695, #699, #995, #997, #999; commission same-model dated literature review and independent specialist criticism; reject unjustified novelty or end-to-end certificate claims. Coordinate separately scoped PRs rather than stacking overlapping proof changes.

**Operational note:** these are role-targeted open work packages recorded in GitHub. Merely naming a role does *not* dispatch or execute a parallel instance. Each must be accepted and evidenced by an actual linked issue, commit, review or reproducible artifact. The author of a proposed theorem cannot act as its independent reviewer.

## Lean theorem ladder (do not replace hard proof with theorem-shaped assumptions)

0. Specify real finite-dimensional quotient metric and causal transcript recursion with full-prefix selectors; establish type-correct theorem statements.
1. Establish exact zero-prefix indistinguishability for r=0: for sigma in [0,R^2], two lawful inputs and noise sequences have the same transcript; derive E >= sqrt(sigma)/2 using quotient triangle inequality. The universal bound should quantify arbitrary normalized selectors and decoders, not take indistinguishability as a premise.
2. Isolate the fixed frame algebra: Vandermonde full-spark, sign-partition lemma, near-coplanar kernel bound, and explicit finite-noise paired-transcript construction.
3. Isolate the topology as imported, explicitly source-audited sublemmas; formalize actual causal transcript equality and verify #997's exact count without creating a fake topology axiom.
4. Only then formalize a *new* robust sharp bound, with all dependencies compiled under the active pin, full transitive import closure, named theorem, ordinary axiom audit and checker receipts.

No assumption of a target inequality, an assumed collision or a hand-coded numerical witness is an acceptable terminal certification. A finite scan is not a proof. If the topological library theorem is absent, the gap must remain open.

## Claim/certificate registry

- PR #1000 at opening: **research charter / conjecture-and-falsification stage**.
- Known elementary indistinguishability bound in this charter: **paper derivation; not independent, not Lean-certified, not novelty-reviewed**.
- Claims in #997/#999: **inherited author-side paper-level statements**, NOT upgraded here.
- New sharp robustness theorem: **not yet discovered**.
- External submission, website breakthrough badge and merge: **not authorized by this charter**.

### Discovery graph

Problem -> global-prefix continuous causal noise model -> indistinguishable corrupted transcripts / constrained conditioning -> n=2 exact construction and adversarial paired inputs -> future sharp theorem -> Lean/independent certificate -> dimensional transfer or documented obstruction.
