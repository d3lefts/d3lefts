# Working Proof Passport v1 — Conditional-section duality and nonadaptive observation

**Checkpoint:** 2026-11-12. **Evidence status:** self-contained finite-product analytic proof and finite falsification, not end-to-end Lean, not non-author reviewed, not priority cleared. **Supplementary working passport**, not a new active-registry claim.

Let f be real bounded |f|≤B, Hoeffding degree ≤d on a **finite number** of independent product coordinates. Let s_i(X_{−i})=||f−E_i f||_{L²(μ_i)} on the conditional fiber, I_i=E s_i², and

$$\beta(f)=\inf_{i:I_i>0}\frac{E s_i}{\sqrt{I_i}}\in(0,1].$$

The [analytic source](../2026-11-conditional-section-duality/README.md) derives ∑_i E s_i≤2d²B from polynomial endpoint Markov and the conditional oscillation budget. Therefore ∑_i√I_i≤2d²B/β. Sorting the √I_i and paying the energy of unobserved Hoeffding supports gives a *fixed* coordinate set S of at most q entries with squared Bayes risk

$$E(f−E[f|X_S])²\le\frac{d^4B^2}{\beta(f)^2q}.$$

This has no min-atom floor but requires a **function-specific positive β**. The constructed rare-address family has β=1/√k and needs Ω(β^{-2}/η) fixed queries for the prescribed risk level; reading address then selected leaf adaptively uses only two per block. Beta does **not** remain automatically bounded at every posterior, and this theorem does **not** imply alphabet-uniform nonadaptive cost, a Hilbert operator result, or arbitrary uncountable-index product scope.

**Independent finite checker evidence in the original source:** 180 generated models and 352 address-query subsets; the source [prior-art and audit ledger](../2026-11-conditional-section-duality/AUDIT_AND_PRIOR_ART.md) explicitly treats Filmus–Hatami–Keller–Lifshitz's L1-influence machinery, Escudero Gutiérrez–Saucedo–Palazuelos' completely bounded nonadaptive simulation, Turturean and classical Markov/Bonami–Beckner/ANOVA as antecedents. Source-origin ZIP custody is distinct from the edited Git Markdown/checker bytes.

**Falsifiers:** find a finite-product bounded degree-d f whose conditional section budget fails; a fixed subset violating the sorted-root-influence risk inequality; or a prior theorem with identical β/degree/whole-coordinate oracle scope. The cheapest decisive test is independent replay and a source-level review of the projection, degree preservation and β gate.

**Status gate:** no new certified theorem is created by writing this passport. Preserve historical source and report non-author referee verdict separately from CI.
