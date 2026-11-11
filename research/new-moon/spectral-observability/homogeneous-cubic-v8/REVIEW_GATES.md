# Adversarial review gates (independent reviewer, not executed by one model)

1. **Finite-product algebra:** derive `N_t f = sum_k t^k f^[k]` directly from coordinate conditional expectation operators; verify `||f^[3]||∞ ≤32||f||∞` and the general coefficient bound with correct product-measure quantifiers.
2. **Hilbert lift:** re-prove unit-direction argument; check covariance-rank projection, centered mean, and all scaling factors `a_r`, `B`, `η`.
3. **Cubic top-linearity:** independently check v5's matching/amplitude lemma and fourth-moment interpolation. Confirm the inherited theorem applies to a *pure cubic layer* even if the original function's pair supports intersect it in two vertices.
4. **Posterior closure:** prove that conditioning cannot create cubic supports absent from the original set, including versions and zero-probability transcripts; independently test the counterexample to combined *cross-degree* layerwise closure.
5. **Soft cover:** verify that the posterior top-degree term equals the sum of cubic components disjoint from the observed set, and that its `L∞` bound holds on a common full-measure set of transcripts. Check the exact risk inequality via `L²` Minkowski, not by unjustified tail orthogonality.
6. **Greedy hypergraph coverage:** prove the weighted one-step recurrence with the optimum `t`-cover; test every sign and inequality orientation, including `t=1`, `t=n` and zero cubic energy.
7. **Infinitary bridge:** check finite-rectangular approximation and essential countable-coordinate support, measurable posterior coordinate selection, null sections, and kernel measurability; finite exact checks cannot certify these.
8. **Prior art:** dated review of low-degree Efron–Stein slices, Chebyshev/noise projection, homogeneous Fourier level bounds, Hilbert decision trees, hypergraph structural influence, and relevant 2026 Turturean work. No originality promotion until completed by an independent reviewer.

## Falsifiable next experiment

Optimize over **bounded homogeneous cubic observables** on biased small product alphabets, using exact certificates for input functions and numerical candidate searches only to locate potential counterexamples. Score `V/(B sqrt M)` under direct Efron–Stein influences. Test dense repeated-pair interaction designs with no small energy cover and no linearization deletion set. A diverging family refutes universal exponent-two; bounded finite samples do not prove it.

## Status

- New deductions: analytic proof text, finite exact falsification checks in `checks/exact_bridge.py`.
- Imported: Q2/Lk in v5, PR #335; no new formal proof of those sources here.
- Open: unrestricted homogeneous cubic bound, full infinitary review, independent expert proof review, originality.