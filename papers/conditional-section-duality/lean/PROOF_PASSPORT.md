# Proof Passport — conditional-section fixed-query selector (12 November 2026)

**Research owner:** NIGHTFALL / Devin J. Wright (AI-assisted formalization and audits).
**Claim identity:** finite fixed-selector and beta-budget transfer; a specific step in the [conditional-section duality programme](../../../research/nightfall/2026-11-conditional-section-duality/README.md).
**Status:** Five named Lean 4.35.0 declarations **kernel compiled**; full bounded-source observation theorem **not** compiled; worldwide originality, external mathematical review and submission **not** established.

## Reproducible kernel evidence

- Exact source: [FixedObservationSelector.lean](FixedObservationSelector.lean)
- Source SHA-256: `d3ddb18999cdc0e87e2ef5c131eac821c74a4141cc9a722b10581de5858cdb35`
- GitHub Actions: [run 43284555054](https://github.com/d3lefts/d3lefts/actions/runs/43284555054), successful strict kernel/axiom job.
- Pin: `leanprover/lean4:v4.35.0`, binary commit `eb6cafb7290e8bd5f2937522d8d804f58f02bafc`; Mathlib `v4.35.0` commit `56a005855ea17e0b0958f73ec801ae140b0a1679`.
- Compiler receipt: [nightfall-conditional-section-selector-lean-receipts](https://github.com/d3lefts/d3lefts/actions/runs/43284555054/artifacts/13974282940), JSON protocol `nightfall-lean-bridge/v2`, strict.
- Audit: all five have `COMPILED` and `allowlisted_dependencies`; only `propext`, `Classical.choice`, `Quot.sound`, no `sorryAx`, no unapproved axiom.
- Independent finite falsification: existing [check_conditional_sections.py](../../../research/nightfall/2026-11-conditional-section-duality/check_conditional_sections.py) reran with 180 product models and 352 address-query subsets, passed. This test cannot certify universality.

## Five exact named declaration scopes

All of these are actual Lean source statements and assumptions, not vaguely inferred consequences:

1. `Nightfall.ConditionalSection.scalar_fixed_observation_selector`. For real `q>0`, `t,tail>=0`, `q*t<=head`, `head+tail<=total`, and `risk<=t*tail`, conclude `4*q*risk<=total^2`. It proves the sharp selector arithmetic.
2. `Nightfall.ConditionalSection.beta_conditioned_fixed_observation`. Add `beta>0`, `d,B>=0` and the **separate premise** `beta*total<=2*d^2*B`; conclude `beta^2*q*risk<=d^4*B^2`.
3. `Nightfall.ConditionalSection.finite_selector_tail_energy`. For disjoint finite blocks `S,T` and `a_i>=0` on the omitted block, if `S` nonempty, `t>=0`, `a_i>=t` on `S`, `a_i<=t` on `T`, then
   `4*|S|*sum_(i in T) a_i^2 <= (sum_(i in S union T) a_i)^2`.
   Unlike (1), this explicitly obtains the tail-energy bound from the actual selected magnitudes, not as a hypothesis.
4. `Nightfall.ConditionalSection.finite_beta_fixed_observation`. Add `beta*sum_(S union T) a_i <= 2*d^2*B` to (3) and conclude
   `beta^2*|S|*sum_(i in T) a_i^2<=d^4*B^2`.
   No risk-identity of an underlying function is asserted.
5. `Nightfall.ConditionalSection.selector_factor_four_sharp`. Exact identity
   `4*q*(q*t^2)=(q*t+q*t)^2`, so the coefficient four is sharp in the scalar selector budget. This does **not** prove optimality of the full observation constant for bounded degree-d functions.

## Unclosed arrow

The proposed substantive theorem in the linked research note is: for a bounded real function on an independent finite product of Hoeffding degree at most `d`, and source-defined `beta(f)>0`, there exists a fixed coordinate set `S` with `|S|<=q` and
`E[(f-E[f|X_S])^2] <= d^4 B^2/(beta(f)^2 q)`.

That full statement requires **in one source-function formalization**:
- the Markov/Popoviciu conditional section budget `sum_i E[s_i] <= 2d^2B`;
- that `beta(f)` implies `sum_i sqrt(I_i)<=2d^2B/beta(f)`;
- existence/selection of the largest `q` coordinate root influences;
- the exact Hoeffding risk identity plus omission-to-tail influence inequality;
- measurable finite-product extensions, and treatment of `q>=n` and constant-function cases.

**None of these source-to-budget edges is certified here.** The formalization is one meaningful theorem dependency, not a formalization of the full manuscript.

## Credit, prior art and review

The argument uses classical weighted tail arithmetic and the imported `L_1` influence/Markov method of Filmus–Hatami–Keller–Lifshitz (2016), Hoeffding ANOVA and Popoviciu. Compare Escudero Gutiérrez–Saucedo–Palazuelos (2026) before asserting originality. The beta-conditioned theorem is still a *research programme candidate*; **novelty has not been certified**. This paper-local Lean source sits **outside** the existing 67-module formalization-source registry. Do not silently change that registry's count or claim it has incorporated this proof until an exact-blob provenance update is performed.

**Next falsifier:** construct a bounded arbitrary-alphabet degree-two function for which the analytic section budget or claimed `beta(f)` lower bound breaks; or independently certify the missing source-level ANOVA and largest-q selection in the same pinned environment.
