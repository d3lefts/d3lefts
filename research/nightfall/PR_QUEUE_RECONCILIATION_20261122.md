# NIGHTFALL pull-request reconciliation — 22 November 2026

## Purpose and invariant

The user expressly requested that outstanding pull requests be merged or closed and that the public website be updated. This is a **repository workflow receipt**, not a mathematical validation or novelty certification. The inventory initially had **47 open PRs**; additional parallel PRs appeared during reconciliation. The final `GET /pulls?state=open&per_page=100` returned **0 open PRs**. Branch head identities below are preserved for independent reinspection; this reconciliation did not delete source branches.

**Website:** [public research dispatch](https://d3lefts.github.io/d3lefts/recent-research.html), [website change #1019](https://github.com/d3lefts/d3lefts/pull/1019), with 25 dated source-scoped ledger entries. The frozen 40-record historical catalogue, original approval whitelist, and distinction between finite replay / named Lean / paper candidate remain intact. The homepage editorial-budget error was repaired at `4ace00cee906469755d39541f54274899b262719` (13,987 editorial characters and 46 links). GitHub Pages deployment has separately succeeded.

**Outstanding blocker:** The strict website/source-check workflow remains red due to many unregistered Lean source modules, including historical files; [issue #1025](https://github.com/d3lefts/d3lefts/issues/1025) preserves fail-closed reconciliation. **Do not disable source verification or blanket-certify unregistered sources.**

**Most consequential unmerged frontier:** [#1016](https://github.com/d3lefts/d3lefts/pull/1016), the O(L³) rank-free two-query tensor simulator, is an author-side proof candidate. It was **closed without merge**, not refuted; [independent review issue #1021](https://github.com/d3lefts/d3lefts/issues/1021) retains its Lovitz–Petrov tensor-circuit and quantum-path audit obligations.

**Stacked merge conflicts resolved by exact source preservation:**
- [#1011](https://github.com/d3lefts/d3lefts/pull/1011): the unique all-dimensional phase-noise note was copied to main at `58cabdb3777dc2ff1b7c59867471ec5fdc4d1211`, then PR closed.
- [#1015](https://github.com/d3lefts/d3lefts/pull/1015): source `CausalPhaseConditional.lean` and its workflow were copied to main; the old `GenuinePrefixPhase.lean` blob already matched merged #1008. ProductSphereZero is still a hypothesis, not a certified topological theorem.
- [#1017](https://github.com/d3lefts/d3lefts/pull/1017): four unique source files / named Lean conditional composition were copied to main with original head hashes; duplicated `GenuinePrefixPhase.lean` was omitted. ProductSphereZero remains an explicit premise.

### Exact PR disposition ledger

| PR | Reconciled state | Head SHA | Historical title |
|---|---|---|---|
| [#1024](https://github.com/d3lefts/d3lefts/pull/1024) | merged to main (this pass) | `5fe0a6ff4646` | [DRAFT] ProductSphereZero parity-cobordism proof route and Lean reference orbit |
| [#1023](https://github.com/d3lefts/d3lefts/pull/1023) | merged to main (this pass) | `aff7566366a5` | Simon fixed-degree transfer: reconstructed all-k proof, k=6 audit, dated priority assessment |
| [#1019](https://github.com/d3lefts/d3lefts/pull/1019) | merged to main (this pass) | `dbfbff82053d` | Website: Nov 22 source-scoped research dispatch and proof-status reconciliation |
| [#1018](https://github.com/d3lefts/d3lefts/pull/1018) | merged by parallel instance | `aceb579ffb68` | Exact mixed-character obstruction criterion and rank-only negative control (topology open) |
| [#1017](https://github.com/d3lefts/d3lefts/pull/1017) | closed; unique source copied to main | `2620bd55656b` | [Lean PASS · CONDITIONAL] Reachable-prefix phase retrieval obstruction from ProductSphereZero |
| [#1016](https://github.com/d3lefts/d3lefts/pull/1016) | closed; preserved as research draft | `537411f2b1ba` | Rank-free two-query simulation on the uniform tensor-subcube oracle |
| [#1015](https://github.com/d3lefts/d3lefts/pull/1015) | closed; unique source copied to main | `8d802573fdeb` | Lean: conditional all-policy phase-retrieval obstruction |
| [#1013](https://github.com/d3lefts/d3lefts/pull/1013) | merged by parallel instance | `3955160ff11a` | NIGHTFALL: archive exact Simon k≤5 orbit certificates and corrected all-k proof candidate |
| [#1012](https://github.com/d3lefts/d3lefts/pull/1012) | merged by parallel instance | `b439dc83bade` | Lean: verified known-sphere collision geometry and mixed-topology obligation (topology open) |
| [#1011](https://github.com/d3lefts/d3lefts/pull/1011) | closed; unique source copied to main | `98d83482d6a6` | Extend the sharp linear phase-retrieval noise exponent to every dimension |
| [#1008](https://github.com/d3lefts/d3lefts/pull/1008) | merged to main (this pass) | `73b473d8fc9c` | Check the genuine-prefix phase-retrieval causal algebra in Lean |
| [#1002](https://github.com/d3lefts/d3lefts/pull/1002) | merged to main (this pass) | `75e7cba9907b` | [DRAFT] Tensor T2: centered, spectral-tail and task-aware measurement-effect simulation certificates |
| [#1001](https://github.com/d3lefts/d3lefts/pull/1001) | merged to main (this pass) | `399de76b2a05` | [DRAFT] Robustness frontier for causal phase retrieval — coordinated with audit #1000 |
| [#1000](https://github.com/d3lefts/d3lefts/pull/1000) | merged to main (this pass) | `07673f1914c8` | [AUDIT #995] Independent audit: continuous causal phase retrieval argument correct; Theorem B and embedding separation |
| [#999](https://github.com/d3lefts/d3lefts/pull/999) | merged to main (this pass) | `e67536fd8c9b` | Sharp minimax phase retrieval and a strict adaptive attainment separation |
| [#998](https://github.com/d3lefts/d3lefts/pull/998) | closed; preserved as research draft | `1f9022ad6499` | [DRAFT] RH gamma-window transfer and pinned Q2 exact-type challenge |
| [#995](https://github.com/d3lefts/d3lefts/pull/995) | merged to main (this pass) | `03602051af41` | [DRAFT] Universal continuous-causal phase retrieval via product Borsuk–Ulam (audit needed) |
| [#994](https://github.com/d3lefts/d3lefts/pull/994) | merged to main (this pass) | `620a9a86c456` | [DRAFT] Archive exact frangible-wheel counts and select phase-retrieval flagship |
| [#992](https://github.com/d3lefts/d3lefts/pull/992) | merged to main (this pass) | `4ff45aa4feb7` | [DRAFT] Spectral MSE stability and exact Simon degree-2/3 obstruction |
| [#991](https://github.com/d3lefts/d3lefts/pull/991) | merged to main (this pass) | `c40369a8d6ec` | [DRAFT] Stronger moment-matched Route1 tail envelopes: Chernoff and Jackson |
| [#990](https://github.com/d3lefts/d3lefts/pull/990) | merged to main (this pass) | `45219bee7a34` | NIGHTFALL: dimension-controlled risk transfer — degree-1/degree-2 dichotomy and the level-wise certificate |
| [#989](https://github.com/d3lefts/d3lefts/pull/989) | merged to main (this pass) | `75688afd69b5` | [EVIDENCE] Reconcile Cairn C-10 objections with the public 131,072-cell witness |
| [#988](https://github.com/d3lefts/d3lefts/pull/988) | merged to main (this pass) | `15531f37dac4` | NIGHTFALL: sharp local-moment conservation of adaptive low-degree query risk (exact audit) |
| [#987](https://github.com/d3lefts/d3lefts/pull/987) | merged to main (this pass) | `4e131e204945` | [DRAFT research] Task-aware transcript representations — Route 1 density bridge & Simon audits |
| [#985](https://github.com/d3lefts/d3lefts/pull/985) | closed; preserved as research draft | `83fad3c7cd2c` | [AUDIT] Full Turturean pinned Lean replay and v8 interface contract |
| [#982](https://github.com/d3lefts/d3lefts/pull/982) | merged to main (this pass) | `bc554e1d71f4` | NIGHTFALL: exact Paley(5591) triple-neighborhood audit (717 / 716), no exponent claim |
| [#981](https://github.com/d3lefts/d3lefts/pull/981) | merged to main (this pass) | `45fed9915a1a` | Adopt 4CT-style staged independent differential formalization gates |
| [#980](https://github.com/d3lefts/d3lefts/pull/980) | merged to main (this pass) | `76a5602d22e8` | Six-way tensor secant recursion and polynomial quotient-fiber candidate |
| [#974](https://github.com/d3lefts/d3lefts/pull/974) | closed; preserved as research draft | `7896030e5801` | Quantum-circuit Wyner theorem: compose physical 2T-degree bridge with Route 1 terminal |
| [#972](https://github.com/d3lefts/d3lefts/pull/972) | closed; preserved as research draft | `ed5c1cd4970d` | Audit hardening for #970: require kernel replay, never fall back to axiom-only CI |
| [#971](https://github.com/d3lefts/d3lefts/pull/971) | closed; preserved as research draft | `ebad3c339380` | Lean: source-connected Wyner one-step information charge beyond log M |
| [#969](https://github.com/d3lefts/d3lefts/pull/969) | closed; preserved as research draft | `dfdac047cc50` | Lean: finite Shannon information chain rule for Route 1 / Wyner (scoped) |
| [#967](https://github.com/d3lefts/d3lefts/pull/967) | closed; preserved as research draft | `6d556cd5f27f` | Lean all-W L3: formalize three-slice rank bridge and import exhaustive certificate |
| [#966](https://github.com/d3lefts/d3lefts/pull/966) | closed; preserved as research draft | `905f1f3d7bf8` | NIGHTFALL: pinned Lean Route 1 large-set charge and unconditional FUR2 pair-degree bridge |
| [#965](https://github.com/d3lefts/d3lefts/pull/965) | closed; preserved as research draft | `93a7e6006b81` | Lean PASS (scoped L≤3 algebra): tensor rows, slice caps, quotient witnesses, dual code |
| [#964](https://github.com/d3lefts/d3lefts/pull/964) | closed; preserved as research draft | `dd0582c21a53` | Lean: Route 1 finite two-potential stopping budget (scoped, full terminal open) |
| [#963](https://github.com/d3lefts/d3lefts/pull/963) | closed; preserved as research draft | `26d323ac7544` | Sharp tensor-subcube subspace-evasiveness and adaptive row-quotient certificate |
| [#961](https://github.com/d3lefts/d3lefts/pull/961) | closed; preserved as research draft | `9779c65691e8` | Extend Claude's one-query theorem: row influence, quotient collisions, grids and tensors |
| [#959](https://github.com/d3lefts/d3lefts/pull/959) | closed; preserved as research draft | `d560d79ae995` | [DRAFT] Amplify Theorem H via tensor simplex codes; repair at-most-r counting |
| [#958](https://github.com/d3lefts/d3lefts/pull/958) | closed; preserved as research draft | `2f148ad0813c` | Conjecture E refuted: near-linear tensor frame lower bound; K-free circuit subcase |
| [#957](https://github.com/d3lefts/d3lefts/pull/957) | closed; preserved as research draft | `cc771670c519` | Subcube tensor family falsifies Conjecture E's high-girth frame dichotomy (author-side proof) |
| [#956](https://github.com/d3lefts/d3lefts/pull/956) | closed; preserved as research draft | `4485ed7bc3ab` | Subcube tensor counterexample to Conjecture E's high-girth frame converse |
| [#955](https://github.com/d3lefts/d3lefts/pull/955) | closed; preserved as research draft | `58929fb8278a` | [DRAFT] Independent cactus block corollary and Theorem F error-budget correction |
| [#954](https://github.com/d3lefts/d3lefts/pull/954) | closed; preserved as research draft | `63a5ed319afb` | Proposed counterexample to Conjecture E: grid rows defeat all high-girth local frames |
| [#953](https://github.com/d3lefts/d3lefts/pull/953) | closed; preserved as research draft | `7fe63d02e86b` | Draft: short-sum bent lower bound, costly-frame rigidity and bounded-doubling subcase |
| [#951](https://github.com/d3lefts/d3lefts/pull/951) | closed; preserved as research draft | `1f3a5ca962c6` | Conjecture E partial theorem: PFR+dense Bogolyubov yields polynomial-doubling frames |
| [#950](https://github.com/d3lefts/d3lefts/pull/950) | closed; preserved as research draft | `86060bc5abff` | Theorem F: small-doubling Conjecture E subcase via PFR, Bogolyubov, exact frame |
| [#949](https://github.com/d3lefts/d3lefts/pull/949) | closed; preserved as research draft | `9cd0b3d82df0` | Linear Conjecture E: derive a small-doubling frame bound Λ_T ≤ N₄ + O(K) |
| [#948](https://github.com/d3lefts/d3lefts/pull/948) | closed; preserved as research draft | `51cd2bddb230` | Structural information: Wyner simulation, representation transfer, linear-distribution dichotomy (paper) |
| [#947](https://github.com/d3lefts/d3lefts/pull/947) | closed; preserved as research draft | `9b5a0c0fb4eb` | Audit: correct structural-information necessity claim and add low-degree Fourier transfer |
| [#946](https://github.com/d3lefts/d3lefts/pull/946) | closed; preserved as research draft | `df3c18ee900f` | Draft: oracle-relative query structure—bounded-cost parity separation and Wyner obstruction |
| [#945](https://github.com/d3lefts/d3lefts/pull/945) | closed; preserved as research draft | `3a4a5f1bcab2` | Evaluate rolling database migrations with mixed-version retail workers |
| [#944](https://github.com/d3lefts/d3lefts/pull/944) | closed; preserved as research draft | `d28271b90413` | Compare paired contract histories on DispatchQ and ArtifactGraph starters |

## Scientific gates preserved

- **Named Lean:** only the named declarations, source pins and explicit hypotheses are certified. A dependent classical product-sphere zero theorem is not discharged merely by a conditional causal terminal.
- **Exact finite:** reproducing fixed-depth tensors, Simon affine orbits, Paley counts, or a source-hashed quantum circuit test does not prove a universal theorem.
- **Analytic research:** #999, #1002, #1011, #1024 and other proof candidates remain paper-level until non-author mathematical review, same-model prior-art search and appropriate kernel/interval certification.
- **External systems:** repository evidence changes are not an external Cairn attachment, an Einstein Arena submission, an external refereeing decision, or a website deployment by themselves.
- **Future work:** use issues and fresh focused PRs for independently reviewed next steps, rather than silently reopening or replacing historical research results. Closing research drafts neither falsifies them nor grants novelty.
