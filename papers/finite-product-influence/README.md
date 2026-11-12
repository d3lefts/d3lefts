# Product-Space Influence: Analytic Manuscript and Formal Source

**Status:** Scoped Lean kernel-compiled theorem **at a pinned commit**, not an end-to-end universal-product or quantum theorem. Non-author human mathematical review and originality audit are unrecorded.

**Canonical proof source:** [ProductInfluence.lean](../../research/nightfall/formalization/product_space/ProductInfluence.lean)  
**Full named proof passport:** [FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md](../../research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md).


## Consolidated analytic manuscript (v8; original v7 preserved)

The **current specialist-review manuscript** is [Bias-Free Aaronson--Ambainis v8](Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex), with source-exact [rank theorem](Rank_Optimal_Observation_Introduction_v8.tex), [Hilbert/posterior proof](Rank_Optimal_Observation_Section_v8.tex), [review passport](V8_PROOF_PASSPORT.md), [source manifest](SOURCE_SHA256SUMS_v8), and [exact-rational checker](check_v8_exact.py). Its [referee guide](V8_REFEREE_README.md) spells out prior art, exact formulas and open proof gates. The previous [v7 source](Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v7.tex) and v6/v5 historical branches are preserved unchanged.

**Quantitative improvement over v7:** In arbitrary independent products and arbitrary finite or nonatomic alphabets, the analytic quadratic proof gives `Var(f)^2 <= K B^2 max_i I_i` with exact `K=(10+2sqrt(2))^2(1+sqrt(3))^2=1228.356323837...` versus v7's `225(1+sqrt(3))^2≈1679.42`. The mechanism is a stronger additive Hoeffding-projection range estimate, followed by v7's existing matching and independent fourth-moment proof. Hilbert rank-r influence has coefficient `3Kr`; finite-product adaptive observation has a hard cap `ceil(12 K r B^2 / eta)`, with matching rank/error order. Neither improvement is end-to-end Lean certified or externally refereed.

**Binary comparator, not claimed new:** A classical real Grothendieck deduction gives `Var(f)^2 <=16(K_G^R)^2 B^2 M` for globally bounded binary quadratics under product laws; signed rank compression gives adaptive cost `ceil(192(K_G^R)^2 r B^2 / eta)`. These binary coefficients are stronger than the arbitrary-alphabet result. Under an arbitrary joint binary law the root-influence bound requires a full-cube norm assumption, and an influence lower bound additionally requires a heat-bath Poincare gap. These are known-method comparisons, not an independent binary breakthrough.

**Fixed observation scope:** The manuscript adds a nonadaptive scalar guarantee only if target risk `eta` exceeds total quadratic energy `delta_2`: `ceil((3+2sqrt(2))B^2/(eta-delta_2))`. It does not assert an alphabet-uniform fixed-query bound below that floor.

**All-degree theorem unchanged:** The scalar law-free `Var(f)^(5/2)/d^6` product extension is retained from v7 and credits Turturean's original Boolean-cube construction. The only Lean kernel theorem named below remains a weaker **finite** result. No full analytic measurable/rank/quantum chain is formalized.

**Reproduce:** `sha256sum -c papers/finite-product-influence/SOURCE_SHA256SUMS_v8`, `python3 papers/finite-product-influence/check_v8_exact.py`, `python3 papers/finite-product-influence/check_rank_posterior_exact.py`, then `cd papers/finite-product-influence && latexmk -pdf -interaction=nonstopmode -halt-on-error Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex`. The new GitHub workflow verifies exact hashes, model tests, claim archive and compilation. These checks **do not** supply a mathematical proof or novelty certificate.

**Promotion stop rule:** independent specialist review of the all-degree transfer, quadratic matching/section fourth-moment proof and actual posterior policy; dated categorical Grothendieck prior-art comparison; explicit author sign-off for any external submission. Draft staging is not arXiv or journal publication.

**Related restricted work:** PR #335 already established cubic top-degree-core transfer; PR #381 shares that backdoor mechanism and separately provides the sharp top-layer projection norm. PR #380 invalidates naive independent-increment fourth-moment transfer to unrestricted cubic overlap. No unrestricted cubic theorem is promoted.


## Quantum ANOVA connection — separate, scoped analytic addendum

[Quantum ANOVA / classical quadratic bridge (11 Nov 2026)](QUANTUM_ANOVA_BRIDGE_20261111.md) records the shared Hilbert-projection mechanism, the finite-dimensional **product-average iff universal supermodularity** characterization, and a new conditional terminal-gain inequality for local quantum encoders:
\[
\max_i\{G^*([n])-G^*([n]\setminus\{i\})\}\ \ge\
\frac{\delta_2\operatorname{Var}(f)^2}{K_8 B^2},\qquad
K_8=(10+2\sqrt2)^2(1+\sqrt3)^2.
\]
Here \(\delta_2>0\) is an explicit local Gram/condition-number visibility floor; independence of the classical inputs, local product preparations, faithful local averages, and degree at most two are all required **for this quantitative transfer**. The product-average quantum ANOVA theorem itself allows arbitrary joint conditional states, but the transfer does not. This **terminal leave-one-register-out** result is *not* a single-register-start gain bound or an adaptive quantum measurement/query theorem.

Run \`python3 papers/finite-product-influence/check_quantum_anova_bridge_exact.py\` for two dependency-free exact rational examples (joint parity gain \(1/9\) and correlated-average supermodularity violation \(1/16\)). These spot-checks do not certify the general noncommuting theorem, v8's analytic proof, or originality. The quantum v3 source and full audit package have not yet been imported into this repository; preserve the frozen v8 TeX and checksum manifest, and do not promote the synthesis to a refereed or Lean-certified result.

---

## Exact scope

Finite coordinates `iota`, common finite alphabet *type* `alpha`, heterogeneous nonnegative normalized marginal tables allowing zero-mass atoms, `|f|<=1`, and indicator-monomial product degree `<=d`. The named declaration

```lean
Nightfall.ProductSpace.Influence.product_influence
```

establishes an existential resampling-coordinate bound

```text
3 Var(f)^5 <= 12500 (pi^2 d^2)^6 I_j(f)^2
```

or coefficient `sqrt(3/12500)/pi^6`, **not** the stronger earlier manuscript coefficient. The imported level and antipodal proof infrastructure comes from David Turturean's independently authored Boolean-cube Aaronson–Ambainis work.

## Provenance

- Pinned NIGHTFALL checked source: `e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb`.
- Pinned upstream Turturean source: `2a6ceaef872ae993708950f951989134084b851a`.
- Lean `4.33.0` with the upstream pinned project.
- [Successful named theorem and axioms receipt](https://github.com/d3lefts/d3lefts/actions/runs/42929857470); `product_influence` reports only standard Lean axioms as documented.
- The previous failed attempt is preserved in the primary proof passport; do not substitute a later edited file for the checked SHA.

## Not proved by this source

- Arbitrary nonatomic or infinite products, including measurable-selection/null-set handling.
- The sharper `V^2` degree-two formula.
- Hilbert-rank adaptive observability, categorical minimax laws, or unrestricted cubic exponent two.
- Historical global originality, journal acceptance or external referee endorsement.

**First extension gate:** formal proof of Hoeffding-support degree ↔ indicator-product degree and independently reviewed finite-partition lift, then compose actual posterior rather than adding more abstract stopping inequalities.
