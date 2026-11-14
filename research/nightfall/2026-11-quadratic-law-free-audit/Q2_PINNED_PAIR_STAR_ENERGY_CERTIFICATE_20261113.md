# Pinned genuine-source Q2 pair-star and squared-energy certificate

**NIGHTFALL / 2026-11-13 follow-on checkpoint (runs executed 2026-11-14 UTC).** **Status: 11 additional strictly pinned Lean declarations passed. Terminal source-level Q2 variance–influence theorem is NOT certified.**

Research led by Devin J. Wright; AI-assisted theorem formulation and Lean construction. Sources are committed to [stacked draft PR #462](https://github.com/d3lefts/d3lefts/pull/462), based on the original-law soft-refresh operator [draft #460](https://github.com/d3lefts/d3lefts/pull/460). These are **author-side mathematical steps**; no specialist independent human proof review, international priority certification, or real-system assurance claim.

## Objective and exact source model

Finite original coordinates \(\iota\), arbitrary finite alphabet \(\alpha\), normalized product source \(p_i(a)\) (with **no positive-atom floor**). The original mass is exactly \(M_p(x)=\prod_i p_i(x_i)\), and the source-preserving refresh \(Q_r\) is a mixture of coordinate-keep/marginal-refresh masks. The proofs use **actual distinct coordinates** and the original source product; there is no synthetic repeated-neighbor stream. The two-coordinate proof itself requires only normalized coordinate weights; physical probability interpretation separately requires nonnegative \(p\).

The new results apply to any \(H:\alpha\times\alpha\to\mathbb R\) that is separately source-centered:
\[
\sum_a p_j(a)H(a,b)=0\quad(\forall b),\qquad
\sum_b p_k(b)H(a,b)=0\quad(\forall a).
\]

**Exact contract:** Every Lean declaration is accepted in Lean 4.36.0-rc2 (compiler commit \`b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a\`), pinned Mathlib \`9d581dfff2e41de989072ea63abf3daf69311520\`, with allowed axioms **only** \`Classical.choice\`, \`Quot.sound\`, \`propext\`. Strict \`scripts/lean_bridge.py\` emits individual scope/axiom receipts and \`check_receipts.py\` enforces the contract; module compilation is explicit from source-identical original-product dependencies.

## Four strict passed pinned runs

| Run (all SUCCESS) | Source module | Certified *named* declarations | Exact mathematical scope |
| --- | --- | --- | --- |
| [43546760922](https://github.com/d3lefts/d3lefts/actions/runs/43546760922) | [ActualProductPairSector.lean](../formalization/observability/ActualProductPairSector.lean) | \`actual_product_two_site_event\`; \`actual_product_two_site_marginal\`; \`actual_centered_pair_source_projection\`; \`actual_mask_two_site_probability\`; \`actual_soft_noise_centered_pair_eigen\` | True two-site joint law, marginal, centered pair source projection and exact \(Q_r H(X_j,X_k)=r_jr_kH(X_j,X_k)\) |
| [43547204578](https://github.com/d3lefts/d3lefts/actions/runs/43547204578) | [ActualProductSoftStar.lean](../formalization/observability/ActualProductSoftStar.lean) | \`actual_soft_noise_add\`; \`actual_soft_noise_sum\`; \`actual_soft_noise_centered_star_eigen\` | Finite linearity and exact centered star section \(Q_r(g(X_i)+\sum_{j\ne i}H_j(X_i,X_j))=r_i g(X_i)+\sum_{j\ne i}r_ir_jH_j(X_i,X_j)\) |
| [43547483580](https://github.com/d3lefts/d3lefts/actions/runs/43547483580) | [ActualProductSoftStarEnergy.lean](../formalization/observability/ActualProductSoftStarEnergy.lean) | \`actual_source_distinct_pair_neighbors_orthogonal\` | \(\mathbb E_\mu H(X_i,X_j)J(X_i,X_k)=0\) for \(j\ne k\), derived by conditioning and source stationarity, with the first kernel centered in \(X_j\) |
| [43547645505](https://github.com/d3lefts/d3lefts/actions/runs/43547645505) | [ActualProductSoftStarParseval.lean](../formalization/observability/ActualProductSoftStarParseval.lean) | \`actual_source_pairwise_orthogonal_energy\`; \`actual_source_weighted_centered_star_energy\` | True-source weighted star \(L^2\) energy equals the squared-weight sum of the actual pair-marginal energies, not assumed as a synthetic sampling law |

**Reproduction:** The [pinned CI workflow](https://github.com/d3lefts/d3lefts/blob/nightfall-q2-pair-sector-v436-20261113/.github/workflows/nightfall-q2-pair-source-v436.yml) compiles literal current branch files, prints individual axioms, runs receipt validation, and archives a \`SHA256SUMS.txt\` of all new and prerequisite source modules, repo commit, compiler pin and Mathlib commit. Use the artifacts linked from the four passing runs to inspect the actual hashes; this note does not invent their values.

## Mechanism and precise transfer achieved

1. **Original two-site law, not an independence axiom:** Joint point-event mass and arbitrary pair expectation are reconstructed from the explicit product mass by \`Fintype.prod_sum\`. Zero coordinate masses are permitted.
2. **Pair projection:** A separately centered source pair vanishes under genuine conditional refresh unless *both* sites are retained, in which case the pair survives unchanged. Exact mask probabilities give the \(r_jr_k\) eigenvalue.
3. **Exact soft-star D1:** Linearity transports the singleton/pair spectral action to the actual finite collection of distinct original neighboring sites, without a duplicated-neighbor array. Setting \(r_i=1\) realizes the scalar form of the proposed soft-ownership \(\mathcal Q_iU_i=h_i+H_i\) **when the stated separately centered star representation is supplied**.
4. **Source-energy C1 local piece:** For any weights \(w_j\), \(\mathbb E_\mu(\sum_{j\ne i}w_jH_j(X_i,X_j))^2=\sum_{j\ne i}w_j^2 \mathbb E_\mu H_j(X_i,X_j)^2\). This is proved under the true original product, via independently compiled source stationarity and orthogonality. No global influence inequality follows without relating the \(H_j\) to the original \(f\) and charging matching weights.

These are exact **operator and local energy bridges**. They are neither a novel world-priority claim nor a universal Q2 theorem merely because the compiler accepted them.

## Open source-to-terminal proof obligations

- **[OPEN] Original source function:** starting only from a bounded \(f\) of source Efron–Stein degree \(\le2\), derive its genuine canonical centered singleton/pair components and identify each supplied \(H_j\) with the actual \(\operatorname{esComp}_{\{i,j\}} f\) on the active pin. The current result has a *centered-star representation as hypotheses*, not as a consequence of an arbitrary \(f\).
- **[OPEN] Genuine source matching/weights:** derive source-supported pair maxima \(w_{ij}\), the \(4B\) disjoint matching theorem, the \(8B\) cover, and \(\lambda_{ij}\) from those costs; prove exact global pair energy partition over both endpoints and \(s_i\le I_i(f)\) with no supplied energy cap.
- **[OPEN] Quantitative endpoint:** recompile or reconstruct the original-source switching/section \(8B\) budget, additive \(\alpha B\) budget, true-source Hilbert fourth-moment estimate, its \(L^1\)-\(L^2\)-\(L^4\) interpolation and scalar closure under one identical pinned compiler.
- **[OPEN] Terminal declaration:** a single named \`source_Q2\` whose only mathematical hypotheses are normalized nonnegative \(p_i\), original-source \(|f|\le B\) (with clearly specified support and zero-atom semantics), and source degree \(\le2\); it must print standard axiom dependencies, source hashes and a full strict passing receipt.
- **[OPEN] Scope beyond finite homogeneous alphabet:** arbitrary heterogeneous alphabets and measurable-space passage require their own exact representation bridge, and non-author proof review/novelty are separate.

Proposed final coefficient is the **author-analytic** \((10+2\sqrt2)^2(1+\sqrt3)^2 \approx 1228.356\) from the original program. The new strict Lean declarations **do not state that inequality or imply it without the open obligations**.

## Independent attack plan and stop rule

- Rebuild the two-site marginal proof without reading its original code, test unequal j/k, singleton coordinate sets, zero-mass atoms, deterministic retention \(r_i\in\{0,1\}\), and arbitrary (not just Boolean) alphabets.
- Recompute true source energy by exact Fractions on small skewed/zero-atom systems, including overlapping stars. Distinguish independence **across neighbors for one fixed center** from the generally false independence across different owner centers.
- Inspect each \`#print axioms\` and compare source SHA and Mathlib pin against the run artifacts. No theorem-promotion based only on green headline status.
- Cheapest decisive next Lean experiment: define *source-derived* canonical pair kernels of an arbitrary \(f\) using original-law conditional refreshes; prove their separate centering and identify the stars above without supplying centered pair components externally. If this forces unproved source-energy identities as premises, stop and expose the missing bridge rather than assume it.

**Status gate:** Numerically checked examples, author-side algebra and 22 total related pinned declarations (11 in #460 + 11 additional in this PR) remain distinct from the single terminal source-level Q2 proof. No manuscript submission or publication is authorized by this certificate passport.
