# NIGHTFALL universal law transfer — audit contract v0.1

**Date:** 11 November 2026. **Scope:** deterministic bounded-loss transport out of an existing product-reference adaptive observer. No new full-chain influence proof.

## Prediction pre-registered before exact checks

For every pair of finite strictly positive rational probability vectors p and q, every t in [0,1], the exact Fraction value of the max target loss over 0 <= L_i <= 1 with Σp_iL_i<=t equals both:
1. fractional knapsack sorted by descending q_i/p_i;
2. dual minimum over a in {0,q_i/p_i}: a t + Σ max(q_i-a p_i,0).

A third **independent** algorithm enumerates every feasible vertex of the bounded-loss polytope; an extreme point has at most one fractional component because only one coupling budget inequality exists. If the three disagree, FAIL. The theorem's general infinite-measure validity is not established by finite agreement.

## Exact replay

From repository root:
\`\`\`sh
python3 research/nightfall/2026-11-universal-law-transfer/check_sharp_transport.py
\`\`\`
Expected:
\`\`\`
status=PASS exact_cases=2760 adversarial_family=28 seed=261111
receipt_sha256 ca5282b3b74ba4ad2bfb676cd7d00fee2220b2a8613ff07358288324a516422a
\`\`\`

The adversarial family concentrates target mass on one source atom of probability 1/n. Each target measure is dominated by its source but the family demonstrates that no uniform-in-target risk modulus follows from domination alone.

## Lean scope

\`FiniteLawTransfer.lean\` has three named theorems, independent of any observer algorithm:
- \`Nightfall.UniversalLawTransfer.loss_dual_pointwise\`: an elementary bounded-loss likelihood-ratio upper certificate.
- \`Nightfall.UniversalLawTransfer.finite_loss_dual\`: finite-sum upper certificate for arbitrary finite real masses and any budget.
- \`Nightfall.UniversalLawTransfer.exact_support_transfer\`: zero-error transfer under support dominance.

**Not compiled or claimed:** Radon–Nikodym theorem, Lebesgue decomposition, Neyman–Pearson sharp dual equality, uniform integrability, product-space influence, completion, infinite adaptive sections, or Hilbert conditional expectation. The \`THEOREM.md\` full-law transfer remains an analytic theorem *conditional on the source Paper A/B observer claims*.

## Audit B independence

- The exact checker uses three different algorithms (greedy, vertex enumeration, dual breakpoints), all with exact fractions; this is *internal independent-code arithmetic*, **not** a non-author proof review.
- An external reviewer should independently check that the same source observer and its default extension are measurable under each target law; one must assume the output remains pointwise bounded on the singular component for squared-loss transfer.
- Verify that the (T4) modulus is sharp for **all bounded losses**, not automatically for the much smaller set of observability residuals.
- Challenge necessity/sufficiency of uniform integrability only for the **universal loss-transfer property**, not for one fixed function.
- Search Neyman–Pearson, distribution shift and active observation literature; do not award priority for the classical dual or UI lemma.

## Stop rule and status

This construction **expands law scope** (independent product reference -> arbitrary correlated and singular target with explicit sharp penalty) but is an elementary measure-transport composition of classical mechanisms. A completed CI job can promote only the finite exact inequality from uncompiled -> kernel-checked-scoped. Global originality cannot be certified without source-to-source prior-art review and independent mathematical criticism. Do not feature it as an Original Finding until it offers a genuinely new nontrivial mathematical component.
