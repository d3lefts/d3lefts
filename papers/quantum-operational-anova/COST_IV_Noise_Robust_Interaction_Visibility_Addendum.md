# COST IV — Noise-Robust Interaction–Visibility, a Source-Pinned Addendum

**Research program:** NIGHTFALL / Wright · **Date:** 2026-11-11 (New York) / 2026-11-12 UTC · **Status:** analytical corollary, conditional on independent audit of the source interaction–visibility theorem; exact counterexample/witness for noise exponent; no new Lean certification and no claim of novelty.

## Canonical sources examined

1. Revised, 15-page manuscript: `Wright_Interaction_Visibility_Law 2(1).pdf` (SHA-256 `c254365d0c0b9070195a6fccdd2036fafe82cd4e7827426d34ce1fcb7e522324`), matching the PDF in `Wright_Interaction_Visibility_Submission_Bundle(1).zip`. This is the preferred analytic statement, featuring Theorems 1.1, 2.1, 7.1 and 7.2, and additional full derivations.
2. Earlier, 13-page draft: `Wright_Interaction_Visibility_Law(2).pdf` (SHA-256 `c900ea53100116762525a78015336e591dd7e207e615599460f0ca24b856cd63`), matching the referee bundle. Keep for historical provenance, not as the source of the revised rank-linear proof.
3. Scoped formal results: `Wright_Kernel_Certified_Theorems(1).pdf` (SHA-256 `d508c48203ccdca06089514ef6cc3cb9669effa05f87b0692c9f17df1269ce57`), matching its manuscript ZIP. GitHub PR #404, draft/open as checked this session, describes 37 scoped Lean declarations with a strict Actions receipt. Not an end-to-end formal proof of the main interaction–visibility result.
4. Background: 64-page `NIGHTFALL_Research_Monograph_v1(2).pdf`, used for the historical source/status hierarchy, not an independent certificate.
5. COST III operational positive-hypergraph spectrum: `/mnt/data/COST_III_package/COST_III_Observability_Recovery_Complexity.md` as generated in this conversation; unrefereed analytic result and finite exact checker, not a Lean theorem.

## Theorem — noisy quadratic interaction–visibility

Let independent finite-alphabet variables `X=(X_1,…,X_n)` have an arbitrary product law. Let `f(X)` be real, `|f|≤B_0`, of Hoeffding interaction degree at most 2, and variance `V>0`. At each site let `x_i↦ρ_{i,x_i}` be a finite-dimensional quantum preparation with faithful average state `b_i=E[ρ_{i,X_i}]`. Assume the minimum eigenvalue of the local *SLD* contrast-Gram operator (on the centered local input space of each nontrivial active coordinate) is at least `a>0`. For `0≤t≤1` apply the local replacement-noise channel

    ρ_{i,x_i}(t) = t ρ_{i,x_i} + (1-t)b_i.

Let `G_t(Q)` denote the maximum reduction in squared-error Bayes risk for `f` using arbitrary joint POVMs on the selected registers `Q` of the resulting one-copy experiment; put `Δ_i(t)=G_t([n])-G_t([n]\{i})`. Let `C_2=(10+2√2)^2(1+√3)^2 <1229`.

**Conditional corollary of the revised Wright manuscript and COST's exact noise decomposition:**

    max_i Δ_i(t) ≥ t^4 a^2 V^2 / (2 C_2 B_0^2).

If every nontrivial local input alphabet is binary, the factor `2` in the denominator can be omitted.

**Proof.** The target has no interactions of order >2. By the operational quantum-ANOVA identity for a local product preparation with product average `B=⊗_i b_i`, there are nonnegative interaction gains `γ_S` with `γ_S=0` for `|S|>2` such that

    Δ_i(t) = t^2 γ_{\{i\}} + t^4 ∑_{j≠i}γ_{\{i,j\}} ≥ t^4Δ_i(1),

since `t^2≥t^4` for `t∈[0,1]`. Theorem 1.1 of the revised Wright manuscript supplies `max_iΔ_i(1)≥a²V²/(2 C_2 B_0²)` and its binary improvement. Combine. □

**Independent alternate short derivation:** The noisy local contrast signal scales by `t` while local average `b_i` is fixed, so the local SLD contrast-Gram operator scales by `t²`. Applying the original quadratic theorem to the new preparation gives the same bound. This is an independent algebraic *route*, not independent proof review of the imported theorem.

## Exact sharpness of the noise exponent

Let `n=2`, with independent fair signs `X_1,X_2∈{±1}` and `f(X)=X_1X_2`, hence `|f|=B_0=1`, `V=1`, pure interaction degree two. Use the same two noncommuting full-rank qubit states at both sites:

    ρ_± = [[2/3, ±1/6], [±1/6, 1/3]],   b=diag(2/3,1/3).

The centered one-site signal has only two entries `1/6`, and its SLD gain is `1/9`. For parity, the two-site score signal has off-diagonal entries `1/36` joining the eigenvector pairs `(00,11)` and `(01,10)`; the respective optimized gain contributions are `1/180` and `1/144`, hence

    G_t({1,2}) = t^4(1/180+1/144)=t^4/80,
    G_t({1})=G_t({2})=0,
    Δ_1(t)=Δ_2(t)=t^4/80.

Consequently no lower bound of the same general positive-prefactor type with `t^p` for a fixed `p<4` can hold for all such systems as `t→0`. This proves **sharpness of the exponent**, not of the numerical influence constant `C_2`.

## Connections and limits

- **COST positive hypergraph realization:** every positive-support degree-two gain table is physically realizable with these fixed noncommuting qubit encodings. The classical target's uniform bound `B_0` scales with the hypergraph weights and is indispensable to the influence lower bound.
- **Computational selection:** maximizing `G_t(Q)` over `|Q|≤k` remains NP-hard at degree 2 by the physical clique gadget, at each fixed rational `t>0` (all pair weights scale by `t⁴`); singleton-only degree-1 selection reduces to sorting. This is fixed-subset *selection* complexity, not adaptive quantum query complexity or efficient construction of the POVM.
- **Complex targets:** the scalar real theorem cannot be transferred unaltered to simultaneous real/imaginary estimation; incompatible measurements introduce a distinct operational issue.
- **Formal status:** the source manuscript's full law-uniform quadratic influence and sharp SLD operator statements are not shown end-to-end Lean-certified by the uploaded proof suite; all larger claims inherit those missing proof gates. No manuscript-version label or green CI alone implies referee approval or novelty.
- **Submission wording discrepancy:** the revised manuscript's title page says 'submitted for peer review', while the earlier referee-bundle README says no external submission occurred. Those are source-version statements, not independent evidence of an actual submission event; obtain confirmation from the author or submission system before reporting external review status.

## Decisive next certification

Formalize the finite-dimensional SLD gain/noise decomposition and the two-qubit parity equality in Lean, then compose it with a *precisely certified* quadratic influence theorem. Preserve a dependency passport distinguishing which imported premises are merely author-side analytic proofs. Independently compare with quantum-conditional-expectation and statistical-experiment deficiency / sensor-selection literature before asserting novelty.
