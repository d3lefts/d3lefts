# NIGHTFALL — Dated global-priority reconciliation for fixed-degree Simon affine transfer

**Search date:** 2026-11-22. **Version:** 1.0. **Scope:** public/indexed literature and available academic discovery systems, with first-party paper/venue records cross-checked where accessible. **Outcome:** priority NOT CLEARED. This is a broad reproducible scan, not a proof that no unpublished, unindexed, differently named, or very recent result exists.

## 1. Exact priority question and exclusion conditions

Target: Is the following already published or directly implied with explicit dimension-free constants?

For N=2^m, iid uniform labels Q_N, and any μ invariant under affine permutations of F_2^m input addresses **and** arbitrary common permutations of N output labels, does every bounded pure-k Efron–Stein polynomial obey Γ_k(μ,Q_N)≤B_k δ_k(μ,Q_N) with B_k independent of N at each fixed k? In particular does the standard random-injective-label Simon distribution obey Γ_k≤C_k/N for all fixed k?

This is **not** the classical theorem that k-wise marginal equality implies exact transfer of degree-k expectations, nor a statement about the global L² low-degree likelihood-ratio norm, nor a query-complexity lower bound or global theorem about all affine-exchangeable measures.

Novelty thresholds: a dated paper with the same norm comparison or its immediate corollary defeats priority. Qualitative affine-exchangeability/limit statements are strong related prior art and may subsume a nonquantitative version, but do not *by their abstract alone* establish the stated uniform O(δ_k) inequality. Only a demonstrated mathematical reduction can resolve that.

## 2. Reproducible search strategy

Academic search: SciSpace literature index queries on affine-exchangeability, affine-pattern limits, constant-size affine testers, Simon bounded-low-degree distinguishing, permutation-invariant U-statistics and Efron–Stein total-variation stability. Public web queries across arXiv, publisher/venue pages, ECCC, the Electronic Journal of Combinatorics, CMU publication records, and quantum query reference sites. Terms included 'affine-exchangeable', 'F2 omega', 'linear forms densities', 'random affine subspaces', 'bounded degree Simon', 'low degree likelihood ratio Simon', 'homomorphism density independence', 'k-wise uniformity' and 'symmetric quantum speedups'. Searches were repeated with conceptually different phrasings, not just exact-title matches.

Search cannot access paywalled full texts, non-indexed manuscripts, restricted preprints, private notes, unpublished proofs or the entire world's mathematical literature. Journal abstracts and selected publisher HTML were inspected; the closest mathematical work should receive full-text specialist review before a novel-contribution claim.

## 3. Relevant published sources and overlap

**Critical direct neighbor — Candela, González-Sánchez, Szegedy, 'On F_2^ω-affine-exchangeable probability measures', Studia Mathematica 279 (2024), 1–69, DOI 10.4064/sm230505-27-8, online 2024-11-05.** https://www.impan.pl/en/publishing-house/journals-and-series/studia-mathematica/all/279/1/115674/on-mathbb-f-2-omega-affine-exchangeable-probability-measures . Characterizes extreme affine-exchangeable measures and supplies a *complete limit theory for densities of linear forms of arbitrary complexity*. This directly owns the affine-exchangeable representation / finite-pattern limit territory. Distinction: this search did not locate the specific output-permutation-invariant Efron–Stein Γ_k≤B_k δ_k bound or its Simon specialization in the abstract and accessible descriptive text. A full theorem-by-theorem comparison is required; structural novelty on affine exchangeability itself is **not** available.

**Hatami, Hatami, Hirst, 'Limits of Boolean Functions on F_p^n', Electronic Journal of Combinatorics 21 (2014), arXiv:1308.4108.** https://arxiv.org/abs/1308.4108 . Preexisting random-affine-restriction and finite-field function-limit representation. Strong overlap with finite affine-template probing; the idea of determining fixed-pattern statistics from bounded-dimensional affine restrictions cannot be claimed new.

**Bhattacharyya, Fischer, Lovett, 'Testing Low Complexity Affine-Invariant Properties', SODA 2013, arXiv:1201.0330.** https://arxiv.org/abs/1201.0330 . Constant-query tests for affine-invariant properties. A clear predecessor for finite random-affine local tests, though not by itself the signed bounded-degree dual norm comparison.

**Bhattacharyya, Fischer, Hamed Hatami, Pooya Hatami, Lovett, 'Every locally characterized affine-invariant property is testable', STOC 2013, arXiv:1212.3849.** https://arxiv.org/abs/1212.3849 . General constant-query testability from local affine patterns. Similar machinery; investigate whether their density-reduction arguments imply the finite witness / norm equivalence.

**Ben-David, Childs, Gilyén, Kretschmer, Podder, Wang, 'Symmetries, Graph Properties, and Quantum Speedups', SIAM Journal on Computing, DOI 10.1137/23M1573975.** https://epubs.siam.org/doi/full/10.1137/23M1573975 . Directly discusses how permutation symmetries constrain quantum-vs-classical query advantage, but operates at a different task (group shuffling and query complexity) rather than this norm under Simon versus an iid reference distribution.

**O'Donnell, Zhao, 'On Closeness to k-Wise Uniformity', APPROX/RANDOM 2018, arXiv:1806.03569.** https://arxiv.org/abs/1806.03569 . Quantifies dimension-dependent losses in approximate k-wise uniformity. It is prior art for the local-versus-global obstruction from #990 and shows why the extra symmetry assumptions matter. Does not settle this particular symmetry-based constant.

**'Pseudo-Deterministic Quantum Algorithms', ICALP 2026, Lemma 33.** https://drops.dagstuhl.de/storage/00lipics/lipics-vol374-icalp2026/html/LIPIcs.ICALP.2026.3/LIPIcs.ICALP.2026.3.html . Contains a collision-based Simon hidden-shift lower bound and symmetry of collision-free decision-tree transcripts. This independently establishes much of the *classical* Simon collision-hazard mechanism. Does not assert the stronger dual bound against arbitrary bounded pure-k functions.

**Bandeira, El Alaoui, Hopkins, Schramm, Wein, Zadik, 'The Franz-Parisi Criterion and Computational Tradeoffs in High Dimensional Statistics', NeurIPS 2022 (low-degree method).** Relevant low-degree likelihood-ratio and L² statistical detection methods; also compare own PR #992, whose Simon degree-three likelihood-ratio norm is already large. The additive Γ_k certificate is genuinely a *different norm*. https://proceedings.neurips.cc/paper_files/paper/2022/file/daff682411a64632e083b9d6665b1d30-Paper-Conference.pdf

**Lovász graph homomorphism densities and exchangeability (classical body of work).** Linear independence of finite motif/pattern density statistics and separating finite probes is a recognized proof strategy (see Lovász, *Large Networks and Graph Limits*, 2012). Do not claim finite-probe interpolation as an entirely new conceptual invention.

**2026 caution — 'The Polynomial-Time Low-Degree Conjecture is False', arXiv:2607.20318.** https://arxiv.org/abs/2607.20318 . Demonstrates pitfalls in promoting symmetry/low-degree similarity to algorithmic hardness. Not a counterexample to this theorem because hypotheses and norms differ, but rules out expansive claims about simulation complexity without explicit query-cost proof.

## 4. Priority matrix

| Candidate contribution | Best current assessment | Reason |
|---|---|---|
| Affine-exchangeable structure / affine-template sampling | **Substantial prior art** | Candela et al. 2024; Hatami et al. 2014; affine-testability literature |
| Finite invariant partition-kernel basis and rank filtration | **Possibly classical; NOT cleared** | Standard permutation representation, Möbius/partition algebra and finite linear-pattern density separation |
| Dimension-free transfer Γ_k≤B_k δ_k under joint affine/output symmetry | **No exact match found in this targeted scan; NOT cleared** | Explicit sharp norm comparison is narrower than known qualitative results; full 2024/2013 papers may imply it |
| Simon_N Γ_k≤C_k/N for each fixed k | **No exact match found in this targeted scan; NOT cleared** | Existing Simon query lower bounds do not automatically establish a uniform dual bounded-degree norm bound |
| Explicit exact Γ_2,Γ_3 and Γ_4=Θ(1/N) | **No exact match found; NOT cleared** | Simple collision combinatorics may be folklore or an unpublished consequence |
| Stable invariant level-six dimension D_6=24 | **New finite in-repo calculation, priority unknown** | Exact independent checker, no comparison to existing orbit tables |

## 5. Decision and next required checks

**Global priority status: UNRESOLVED.** The listed sources are bona fide strong predecessors. Neither targeted searching nor author-side proof establishes worldwide first discovery. Avoid the phrases 'first theorem', 'novel mathematical law', 'world-first' and 'independently certified breakthrough' until the original theorem statements have been checked and knowledgeable external reviewers have signed off.

**Cheapest decisive priority test:** ask a specialist in affine exchangeability/finite-field pattern limits to read Candela–González-Sánchez–Szegedy 2024 and Hatami–Hatami–Hirst 2014 specifically for this quantitative finite-orbit norm comparison; return exact theorem numbers or a counterexample. If a direct proof already appears, credit it and reduce NIGHTFALL's contribution to the Simon specialization/certificates.

**Mathematical gate:** non-author independent proof review of the rank-triangular interpolation and the k=6 noninjective-map boundary; a Lean exact representation/interpolation theorem with kernel replay, plus a separate bridge from its statement to Simon_N. No programmatically generated or GitHub-passing test can substitute for these.

**Action:** keep proposed Theorem A/S at PAPER-PROOF-UNDER-AUDIT in the source record; do not promote the claim to Theorem, Novel Contribution or competitive record at this checkpoint. Preserve all finite exact witnesses and continue independent review in #1014.
