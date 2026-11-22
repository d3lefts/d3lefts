# NIGHTFALL | Global discovery and priority audit, v1.0
**Checkpoint:** 2026-11-22 (America/Chicago)  
**Scope:** original repository #1–#1133, with detailed PR-based reconstruction of the October phase/observability origins; November original-source Q2; quantum sensing/POVM; unrestricted product influence; Route 1; modern physical/oracle transfer.  
**Status:** dated author-side synthesis; does NOT establish world priority or promote a theorem without an exact-head kernel receipt.

## Precise research objective

Find the strongest **model-matched, externally distinguishable** mathematical contribution supported by immutable code and proof history. Favor source-independent quantitative laws, operator-level mechanisms, and exact original-oracle charging over benchmark-specific constants, a proposed physical implementation, or a misleading declaration of general quantum-classical equivalence.

**Principal candidate (broad significance):** an *information-parameterized, representation-sensitive barrier to distributional quantum-query advantage*: bounded low-degree scalar acceptance functions over finite-alphabet sources have bounded classical query complexity whenever the source has a cheap query-accessible representation of bounded Wyner common information. In the native coordinate representation the existing merged theorem is unconditional for every finite PMF, with explicit common-information cost. Additional representation change requires a proven, fully priced decoder. The claimed *sufficiency* is a theorem; a general task-relative necessity/characterization is not.

**Independent candidate (strongest inequality / variance exponent):** the dimension- and atom-independent **degree-two variance–influence bound** on arbitrary independent product spaces, with exponent two and explicit C≈105.41624, kernel-integrated at #776. This stands on its own and is not subsumed by the Route 1 / general-degree exponent-5/2 result.

**Tie-break:** represent the above as two distinct theorem families joined by a reusable structural mechanism. Do not invent a mathematically nonexistent single theorem containing arbitrary correlated laws, high-degree sharp exponent two, and arbitrary original physical oracle access.

## Formal mathematical claims and certifications

### A. Original-source quadratic observability — independently significant

For bounded real `f` of Efron–Stein degree at most two on an arbitrary product law, `B` an essential amplitude bound, `V=Var(f)`, and `M=max_i Inf_i(f)` (true source-law heat-bath/resampling influence), merged source #776 supports

```
V^2 <= C_2 B^2 M,
C_2 = (2(1+sqrt(2))*sqrt(3) + 11901/6250)^2
    ≈ 105.41623981998771.
```

See #587 (source coefficient mechanism), #740 (zero-mass/native finite bridge), #753–#776 (original-source L² and finite-label to arbitrary-index limit). Exact certification is restricted to the imported Lean definition of source degree (`TripleResidualZero`), not all informal presentations of quantum ANOVA. The bound is stronger in variance exponent than the all-degree theorem at d=2, but constants and output scaling must be compared consistently.

The exponent **2 is optimal** in a universal variance/influence inequality: `f_n=(1/n)Σ_i X_i` on independent fair signs has `B=1, V=1/n, M=1/n²`. For any exponent below 2 the ratio diverges; the degree-one example is mathematically sufficient. #521 additionally gives an author-analytic lower-bound family with limiting constant 4, not an exact determination of the universal optimal constant. These are different claims.

### B. Unrestricted-degree product law

Merged #858 certifies, for all degrees d and arbitrary (including infinite/heterogeneous) independent product sources,

```
3 V^5 <= 12500 * (pi^2 d^2)^6 * B^6 * M^2 .
```

It extends Turturean's 2026-11-06 Boolean-cube Aaronson–Ambainis proof to arbitrary product sources, with a competing-symbol selector and finite-cell/heat-bath transfer. The cube theorem is **prior art** and the NIGHTFALL proof explicitly reuses credited Turturean modules. The earlier product-law work #379–#419 and #500–#847 supplies the mature original-source machinery. General variance exponent **2** remains a conjecture beyond the degree-two scope; notably the cubic case is open (#805).

### C. Wyner-information classical simulation — candidate broad priority

Merged #970 and #976 establish for arbitrary finite PMF ν on product alphabet inputs, `0<=f<=1`, interaction degree `<=d`, `0<τ<=1`, `ε>0`, any `n>=1`, and every `s > C_W(ν)` (general-latent Wyner information in **nats**) a deterministic symbol-coordinate tree with

```
Pr_ν(|f(X)-tree(X)| > ε) <= [A(d,τ) + s/B(d,τ)]/n + τ/ε²,
K=π²d²/2,
γ=sqrt(3 τ^5 / [12500(π²(d+1)²)^6]),
A=K/(2γ),
η=γ/(512d²), w0=γ/(16K), B=η²w0 .
```

This is **distributional acceptance-value approximation**. `C_W` refers to the exact source coordinate representation; if the oracle coordinates are re-encoded, decoding costs must be charged.

Merged #987 additionally kernel-certifies the exact converse under the explicit and **stronger** hypothesis that every n-depth classical deterministic tree approximating the very same `f` has error strictly >δ:

```
C_W(ν) >= B(d,τ) * [ n(δ - τ/ε²) - A(d,τ) ] .
```

This can be negative/vacuous. It is not directly a promise-problem lower bound, and there is no iff theorem. The numerical converse is logically dependent on the forward theorem, not an independent lower-bound proof.

### D. Full finite complex quantum circuit — NEW SOURCE COMPOSITION IN THIS PR

`QuantumInformationBarrier.lean` imports the **original** source-level `QuantumCircuitSimulation.acceptance_degree` and `QuantumCircuitNormalization.probability_in_unit_interval`, then directly instantiates merged `route1_wyner_general` and `wyner_converse_from_approximation_hardness`:

1. `normalized_circuit_wyner_simulation`: for *well-formed norm-preserving* finite matrix-oracle circuits with T≥1, degree is **derived** as 2T and Born acceptance is **proved** in [0,1]; the resulting original-symbol tree satisfies the exact A(2T,τ), B(2T,τ), n, ε, s error certificate.
2. `normalized_circuit_wyner_necessity`: under every-depth-n-tree **acceptance-approximation hardness** for that precise circuit and ν, the exact positive/possibly-vacuous lower bound on `C_W(ν)` is derived without assuming degree or Born bounds.

**Certification gate:** new exact-head pinned workflow with standard axioms only (`propext`, `Classical.choice`, `Quot.sound`) and mandatory `leanchecker` replay. Until green on the exact PR head, these are **Lean candidates**, not compiled certificates. The code makes no claim to new proof methodology: it is a semantic composition of #858, #866/#873, #970/#976, and #987. Historical similar, *unmerged* source #974 already contains a narrower finite-component circuit-to-Wyner composition; full credit retained.

### E. Implementable representations, robustness, and counterexamples

* Early October #16/#31/#37/#51/#77/#92 established exact finite-field adaptive phase-decoding constructions and phase-orbit information, initially paper/finite checker scope. #241 introduced the portable Lean bridge. Specific October projective lower bounds in #244 were explicitly demoted after Héger–Patkós–Takáts prior art.
* #690 rigorously source-connects an F9 all-length **same-oracle adaptive/fixed design separation**; #695 certifies infinite-field exact causal n+1 vs nonadaptive 2n−1 squared-linear phase retrieval; #699 finds a separate continuity obstruction. These are **independent mathematical discoveries**, not consequences of Wyner simulation, and global novelty is not yet cleared.
* #647/#649–#658 gives an **independent** exact physical POVM/SLD optimal-gain source chain with a normalized terminal under its specific ternary ensemble. #673/#677 are scoped SLD scalar envelope and quantum ANOVA structural certificates; neither proves a universal commuting/noncommuting adaptive quantum observability theorem.
* #883 proves an exact diagonal-source exponential product-mixture-rank obstruction while cheap quotient decoding remains possible. Thus raw mixture rank or Wyner information is not a necessary indicator of classical task difficulty.
* #987 Simon tests show exact static source Wyner information can be large while task-aware classical shift discovery costs Θ(√N): a fixed full-block score is **not** a complexity characterization. A general task-relative posterior/early-stopping theorem remains open.
* #1087/#1118/#1133 certify finite three-reading decoding, degree grouping and tree-substitution lemmas. #1128's terminal for physical raw-intensity addresses is supported by a **reported local receipt**, while independent exact-head GitHub CI and source merge are distinct gates. Its at-most-3n physical query cost and B-independent query bound are *scoped*, and no polynomial classical runtime follows.
* #1095 general affine-code/graph-cut Wyner identities and #1026 access-local corruption theorem extend the representation picture; verify their own current-source kernel receipts before promotion. The robust transfer error in #1026 has a stated additive bound `nominal + n*η + (π²d²/2)*η/u` under the exact coupling; the broader quantum hybrid remains paper-level.

### F. Orthogonal October/November lines that must not be erased

* Exact Werner/Qutrit thresholds and limited rank-two sharp transfers (#17, #20, #35, #38 and later #397/#399/#658): separate finite-dimensional quantum decision theory; cannot be silently folded into scalar query simulation.
* Erdős overlap, Sidon/cube graph and finite-field phase records (#18, #45, #73, #84, #123, #279): combinatorial and numerical or specific algebraic results, with distinct records and eligibility scopes.
* Agent safety and permission cost (#467–#600, #602/#603/#644): model-specific information/freshness/capacity theorems and ControlArena experiments, not consequences of quantum Wyner. #602's KL chain rule has published bandit-method antecedents; #603's matching zero-error cost floor has explicit frozen-source/guard assumptions.
* Scientific provenance (#147/#241/#495/#697 and proof custody): necessary enabling infrastructure, not an original mathematical theorem.

The unifying research direction **Source-relative observability with priced oracle access** is an *organizational synthesis* linking these branches; it is **not** a proved theorem subsuming them.

## Mechanism graph (proof-carrying, no false arrows)

```
October finite-field sensing / phase orbit models --------> physical decoding costs
                                                        |            |
November original-source L2 & finite-cell Q2 ---------> all-degree product influence (#858)
                                                        |
Turturean credited cube proof + new selector ---------+
                                                        |
                                              Route 1 Wyner tree (#970/#976)
                                                        |
    actual circuit paths + WellFormed (#866/#873) -----+--> circuit-Wyner (this PR, CI GATE)
                                                        |
    original acceptance-hardness (#987) ---------------+--> exact numeric necessary C_W
                                                        |
    #1087/#1118/#1133 sensor decoder ------------------+--> #1128 physical-intensity terminal
                                                        |
    #883/#987 counterexamples -------------------------> rejects naive necessity/iff
```

Separate branches: #776 exponent-two Q2 sharpness; #690/#695 causal sensing separation; #658 physical POVM optimum; #600/#603 evidence permissions. **No implication arrow from these separate theorems to the generic Wyner resource barrier has been proved.**

## External-reference and global-priority gate (2026-11-22)

1. Aaronson–Ambainis, original conjecture (2014); David Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773 (posted **2026-11-06**) — earlier priority for the cube's general influence mechanism.
2. Girish–Mittal–Nehoran–Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*, arXiv:2609.35327 (submitted **2026-09-28**) — biased product and slice extensions, with explicit density assumptions in its quantitative reductions.
3. Huffstutler–Miloschewsky–Podder, arXiv:2611.12795 (**2026-11-09**) — alternate completion argument and potential product-weighted subsumption risk.
4. Bruno–Vaccaro arXiv:2610.15402 (**October 2026**) — established support rectangle mechanism for Wyner common information.
5. Héger–Patkós–Takáts, arXiv:1309.6731 (2013/14) — finite-projective search that already subsumed a NIGHTFALL October claim (#244).
6. **Outstanding:** #749 reports a **2026-11-08 Bhattacharjee Zenodo deposit** of an atom-independent general-product influence bound. Its complete source and exact theorem statement have **not been independently reconciled in this audit**; NO priority claim is permitted for the broad product-measure exponent-5/2 extension until checked.
7. The Wyner tree bound, arbitrary-latent reduction, Q2 exponent-two, and original-costed representation compiler require theorem-by-theorem searches for possible earlier implicit consequences, not mere title/abstract matching.

**Novelty status:** manuscript-level candidate only. No worldwide first-discovery, independent non-author refereeing, preprint submission, or competitive theorem record is asserted. Dated GitHub PR chronology preserves internal provenance only.

## Audit and next decisive experiments

**Independent engine B, specified before outcome:** (i) reconstruct #776 with one expert proof attack of the source conditional expectation/L² limit and `B` normalization; (ii) reconstruct #970's information-potential decrease and arbitrary-latent finite reduction, attacking zero atoms and hidden source-conditioning; (iii) check the exact original-symbol matrix-oracle syntax in #866/#873 and the new Lean terminal's absence of degree/normality premises; (iv) demonstrate a prior published theorem that implies (or explicitly does not imply) the Wyner bound at comparable constants, with dated source and precise theorem hypotheses; (v) test Simon/diagonal counterexamples against any necessity claim.

**Cheapest decisive experiment:** run the new current-head `QuantumInformationBarrier.lean` Lean 4.36.0-rc2 workflow. If red, retain only the already-merged separate certificates; no promotion. If green, label it a **source-connected Lean composition**, not a new globally original standalone proof.

**Stop rule:** do not optimize local constants or assert grand unified theorems until exact source closure and literature subsumption are resolved. Any new claim needs a distinct statement, comparable earlier baseline, and independent exact or analytic certificate. Human authorization is required before publication or external submission.

**Contribution and credit:** NIGHTFALL research lead Devin J. Wright and named collaborators; credits David Turturean, Aaronson–Ambainis, Wyner, Girish–Mittal–Nehoran–Raz, prior finite-field literature, and the original Route 1 Claude-led proof. No independent referee is invented.
