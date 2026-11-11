# Universal Product-Space Observability

**Status:** Analytic theorem manuscript; **not end-to-end Lean checked, not externally refereed, not priority-certified**.

**Primary mathematical source:** [PRINCIPAL_THEOREM.md](../../research/nightfall/2026-11-principal-observability/PRINCIPAL_THEOREM.md). Its exact quantified theorem statement, constants, proof steps, and boundaries govern this entry. Do not cite this page as an independent theorem.

## Mathematical question

Can a bounded, strongly measurable Hilbert observable of fixed Hoeffding interaction degree be predicted, to spectral-truncation error plus `eta`, by a dimension-independent number of adaptively selected **whole input-coordinate** observations over an arbitrary independent product law? The manuscript proposes a bound of the form `N=ceil((40/3) U log(1+4U))`, with `U=d^7 B^3 r^(3/2)/(c_* eta^(3/2))` and `c_*=sqrt(3/12500)/pi^6`.

The laws and observable are assumed known. The statement is about an existential measurable policy, **not** computational runtime or the unrestricted cubic exponent-two influence conjecture.

## Dependency chain and evidence boundary

1. [Finite product scalar theorem](../finite-product-influence/README.md): kernel-checked at the weaker `(5/2,6)` exponent and precisely stated coefficient; finite common alphabet type and indicator-monomial degree.
2. **Finite-to-arbitrary measurable product:** the manuscript supplies an analytic approximation argument; its countable active coordinate support, posterior null sets and degree-preservation details need independent review.
3. **Scalar-to-Hilbert compression:** covariance projection, random-sign scalarizations, PSD exponential moments and logarithmic influence bound require independent review; support Lean lemmas are **not the composed theorem**.
4. **Adaptive posterior:** conditioning, greedy measurable coordinate choice, ANOVA total-influence descent, and stopped potential are written analytic steps with partial abstract Lean support only.
5. **Output spectral tail:** `tau_r` is additive error; no cost bound for computing the policy is established.

**Primary evidence:** [formalization coverage](../../research/nightfall/formalization/observability/README.md) · [review gates and corrected obstruction](../../research/nightfall/2026-11-spectral-observability/REVIEW_GATES.md) · [principal formal scalar proof passport](../../research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md).

**External antecedents:** David Turturean (2026), Aaronson–Ambainis (2014), classical Hoeffding/Efron–Stein and PSD/Khintchine-style tools. See the bibliography and assumptions in the original source; a comprehensive historical novelty audit remains open.

## First referee tasks

Reconstruct the measure-theoretic lift from the full definition of finite indicator-product degree. Independently reproduce the PSD log-mgf implication and every constant. Then attack the per-transcript greedy posterior descent and the existence of a measurable maximum/approximate maximizing coordinate on a countably active product. See [referee desk](../../research/referee/README.md).

**Stop rule:** A successful finite Lean receipt cannot be transferred to the general Hilbert theorem without proofs of the intervening steps and a non-author source-to-source review.
