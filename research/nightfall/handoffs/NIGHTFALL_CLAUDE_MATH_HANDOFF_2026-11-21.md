# NIGHTFALL → Claude: Mathematical Handoff and Breakthrough Gates

**Version:** 1.1 · **Date:** 21 November 2026 · **Repository:** [`d3lefts/d3lefts`](https://github.com/d3lefts/d3lefts) (`main`)

**Mission.** Turn the strongest existing mathematical results into a genuinely new, precisely scoped, independently checkable, citable theorem. Do not confuse a merged PR, a Lean source file, a successful historical CI receipt, a numerical checker, originality, and independent peer review. Reproduce the exact named theorem and its assumptions before promoting any claim. Preserve Claude's primary authorship on Route 1 and the original tensor-subcube one-query work; credit other contributors by their actual proof contributions.

## Executive assessment

The three strongest **connected mathematical contributions with repository proof evidence** are:

1. **Information-budgeted classical simulation over mixtures of product laws (Route 1 / Wyner).** Largest conceptual result: replaces linear dependence on mixture size with logarithmic dependence, then with a latent-information budget.
2. **Original-law quadratic influence / observability (Q2).** Strong analytic and formal foundation: variance exponent 2 for degree-2 observables on unrestricted independent products, with an explicit dimension-, alphabet-, and bias-free constant.
3. **Sharp tensor-subcube subspace-evasiveness.** Standalone exact finite-field theorem: optimal exponent `log₂3` for every tensor depth and every binary linear subspace; relevant to adaptive quotient geometry beyond product mixtures.

These are **author/repository contributions, not yet three externally cleared original publications**. A fourth, mathematically independent program—the fully formalized infinite-field phase-retrieval adaptivity gap and its continuity obstruction—is documented below. It is not a corollary of the three connected results. Named Lean source and historical exact-head CI exist for the identified theorems. A fresh independent compilation, proof-dependency audit, historical-priority assessment, and non-author mathematical review remain separate requirements.

### Theorem 1 — Route 1: logarithmic mixture cost and Wyner-information simulation

**Model.** Let `ν = Σ_{θ=1}^M w_θ P_θ` be a probability law on a finite product of finite alphabets, where the `P_θ` are product distributions with arbitrary masses, including zeros. Let `f : X → [0,1]` have product/indicator interaction degree at most `d≥1`. For any approximation tolerance `ε>0` and failure probability `δ>0`, a deterministic, adaptive classical decision tree can approximate `f(X)` with `Pr_ν(|f(X)−t(X)|>ε)≤δ` using

`depth ≤ poly(d, 1/ε, 1/δ) · (1 + ln M)`.

The proved Lean theorem is more explicit: `route1_polylog_simulation` gives an additive error bound `(A(d,τ) + B(d,τ) ln M)/n + τ/ε²`; its `γ`, `η`, and `w₀` are defined in the source. `route1_wyner_CI` and `route1_wyner_general` replace `ln M` by any `s>C_W(ν)`, where `C_W` is the infimum of `I(X;W)` over conditional-product latent decompositions. The exact arbitrary-measurable-latent **pushforward** is formalized when a measurable conditional-product kernel `W→LawSpace` is supplied. Deriving that kernel from a bare joint law is a separate disintegration interface; it is not proved by the pushforward module.

**Proof mechanism.** A product-space low-degree row/influence argument controls posterior variation; a finite product-star/Key Lemma and an adaptive two-potential stopping argument charge queries either to a bounded incremental potential or to an entropy / KL / total-variation information drop. This is not FUR(d), nor a general bound on computational runtime or on simulating all quantum output distributions. A `T`-query quantum algorithm has an acceptance polynomial of degree at most `2T` in the specified oracle model; verify the physically typed circuit composition and exact CI status separately before asserting the full quantum corollary.

**Evidence.** [Route1PolylogSimulation.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/Route1PolylogSimulation.lean); [Route1WynerSimulation.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/Route1WynerSimulation.lean); [Route1WynerGeneral.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/Route1WynerGeneral.lean); [Route1AbstractLatentPushforward.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/Route1AbstractLatentPushforward.lean). [Merged PR #970](https://github.com/d3lefts/d3lefts/pull/970), [merge `aa232597`](https://github.com/d3lefts/d3lefts/commit/aa2325979d681450a46c2063026d9db09d14730c), reported CI [run 44732951300](https://github.com/d3lefts/d3lefts/actions/runs/44732951300); arbitrary-latent follow-up [merge `27e4407`](https://github.com/d3lefts/d3lefts/commit/27e4407bb871429e48018018838ae76257b71f3e), reported CI [run 44755583762](https://github.com/d3lefts/d3lefts/actions/runs/44755583762). **Authorship:** Claude was credited as the primary Route 1 proof author. Recheck the exact quantitative theorem against earlier distributional complexity, information complexity, common-information and approximation literature; a limited web search did not establish novelty.

### Theorem 2 — Q2: original-product variance exponent two

**Model and theorem.** Under an arbitrary independent product measure `μ` (heterogeneous coordinate spaces and biases, zero-mass atoms allowed), let `f` be essentially bounded and Hoeffding/Efron–Stein degree at most two. Set `B = inf_c ||f−c||∞`, `V=Var_μ(f)`, and `M=sup_i E[Var(f|X_{−i})]`, using the genuine original-law heat-bath influence. Then, after centering `f`, the source theorem proves

`V² ≤ C₂ B² M`, where `C₂ = [2(1+√2)√3 + 11901/6250]² ≈ 105.416`.

This is a variance-exponent-two theorem, **not** a polynomial-in-`d` result for arbitrary degree. Its strength is independence from dimension, atom floors, alphabets, and bias. The original-law hypothesis matters; earlier biased-to-uniform reductions can lose control of source influence. The finite result uses a source-specific matching/fourth-moment mechanism, and the arbitrary-index `L²` extension uses finite-label conditional expectation, original-source influence contraction and a precise degree-two bridge.

**Evidence.** [InfinitePiQ2HoeffdingDegree.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/universal/InfinitePiQ2HoeffdingDegree.lean) names `infinitePi_q2_105416_hoeffding` and states its assumptions and full coefficient; [InfinitePiQ2NativeHeterogeneousTerminal.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/universal/InfinitePiQ2NativeHeterogeneousTerminal.lean) covers native finite alphabets. [PR #776](https://github.com/d3lefts/d3lefts/pull/776) and [PR #801](https://github.com/d3lefts/d3lefts/pull/801) document successive finite/infinite closure and the Hoeffding-degree bridge. [Author-side infinite-product derivation](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-infinite-product-q2/PROOF.md) includes older, now superseded certification status: use the current Lean declarations and receipts, not stale narrative. No independent referee and no priority clearance against Grothendieck/decoupling/Boolean-analysis literature.

### Theorem 3 — Sharp tensor-subcube geometry

Let `E_L=(F₂²)^{⊗L}` (dimension `2^L`) and `R_L={u₁⊗⋯⊗u_L : u_j∈F₂²\{0}}` (cardinality `3^L`). For **every** `q`-dimensional linear subspace `W≤E_L`, with `α=log₂3`,

`|R_L ∩ W| ≤ q^α`.

For every affine coset `a+W`, `|R_L∩(a+W)|≤(q+1)^α`. The exponent is optimal: `W=E_L` gives equality `3^L=(2^L)^α`, and tensor-factor subspaces give further equalities at `q=2^k`. The proof uses the three-slice recursion `(r,0),(0,r),(r,r)`, the pairwise rank constraints `q_i+q_j≤q`, and the sharp scalar inequality `q₀^α+q₁^α+q_*^α≤q^α`.

**Evidence.** [SubcubeSharpAllLevels.lean](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/structural_information/SubcubeSharpAllLevels.lean) (`all_levels_sharp`, `all_levels_affine_sharp`); [source and limitations](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/structural_information/SUBCUBE_SUBSPACE_EVASION_20261119.md); [PR #977](https://github.com/d3lefts/d3lefts/pull/977), CI [run 44739986591](https://github.com/d3lefts/d3lefts/actions/runs/44739986591); [PR #978](https://github.com/d3lefts/d3lefts/pull/978), CI [run 44741027976](https://github.com/d3lefts/d3lefts/actions/runs/44741027976). The independent exact-RREF checker `scripts/check_subcube_subspace_evasion.py` enumerates all subspaces through `L=3`, including 200,787 four-dimensional subspaces at `L=3`. The all-`L` *recursive tensor* theorem has formal source; equivalence with the separate original integer-bitmask generator is formally identified only through `L≤3`. **Credits:** Claude's prior one-query subcube mechanism is separate; do not claim this theorem proves simulation for coherent `T≥2` quantum queries. Priority against Segre-variety, coding-theory and finite-geometry bounds remains open.

## How the three fit together — and what they do NOT imply

- **Common mechanism:** bound what a low-degree observable can learn when only a small amount of coordinate information or representation complexity is available. The native language is product ANOVA / influence, latent mixture information, and low-rank quotient geometry.
- **Q2 → Route 1:** Q2 is a strong degree-two special-case influence result; Route 1 instead uses the **general-degree product AA 5/2 exponent bound** derived from Turturean's mechanism. Q2 is **not presently a logical dependency** of the Route 1 proof. It may improve constants for a specialized low-degree simulator, but that requires a new proof, not substitution by analogy.
- **Route 1 → quantum structure:** `C_W(ν)` is a sufficient upper-bound resource for low-degree classical prediction, not a necessary measure for quantum advantage. E.g. duplicated independent bits can have a large latent-description cost but remain trivially query-reducible. Do not advertise a one-number if-and-only-if theory.
- **Subcube → a different obstruction:** even when no cheap product-mixture certificate exists, geometry of linear query rows may permit efficient classical observation. Single row cosets are bounded by S1/S2, but conditioning can create collisions among **pairs** of rows; that missing secant information blocks the proposed `T≥2` transfer. Coherent quantum cross terms require their own proof.

This suggests a qualified program: **observability cost depends jointly on distributional information and task-relative representation geometry**, rather than on mutual information alone. This is a research hypothesis, not a unified theorem.

## PRIMARY TARGET: prove a polynomial secant-fiber theorem (shortest route to a new standalone result)

**Exact statement to prove or falsify.** For `A_L=R_L∪{0}`, a binary subspace `W≤E_L` with `q=dim W`, and every affine coset `a+W`, control

`E₂(L,q) = max_a |(A_L+A_L) ∩ (a+W)|`

by a fixed polynomial in `L` and `q`, independent of ambient dimension `2^L`. The current [PR #980](https://github.com/d3lefts/d3lefts/pull/980) proposes the concrete candidate

`E₂(L,q) ≤ 1 + 12 L (q+1)^4`.

**Status of that proposal:** author-side / conditional, NOT an all-`L` certified theorem. PR #980 reports locally passing finite checks and a formal six-family cover only. It explicitly lacks the general mixed-product row-fiber inequality, the quartic triple inequality and the end-to-end induction/Lean composition. Check `L=0`, `q=0`, zero- and nonzero-coset conventions before importing any formula. A false polynomial bound is as scientifically valuable as a valid correction if a minimal exact counterexample and its mechanism are produced.

**Why it matters.** The proved quotient-pair reduction is `μ(π(A_L))≤(L+1)E₂(W)` for nonzero quotient sums (where `μ` counts unordered distinct pairs, `π` is quotient by `W`). The trivial bound `E₂(W)≤2^q` is exponential. A valid polynomial secant theorem would make adaptive quotient pair multiplicity polynomial — a genuine finite-geometry result, independently interesting even **without** a quantum simulator. The extra coherent `T≥2` theorem remains a distinct gate.

**Cheapest decisive plan (Claude construction + independent adversary):**

1. Recover PR #980 branch, source file, proof and checker at exact commit. Freeze SHA and definition of the six slice families. Distinguish intersection with `A_L+A_L` (a set) from number of pair representations (a multiset).
2. Before inspecting its proposed proof, independently compute secant sets and all binary `q`-flats for `L≤3`; use a separate GF(2) representation, exact integer arithmetic and deliberate worst-case mixed-product subspaces. Cross-check zero coset, affine shifts, duplicates and parity conventions.
3. Attempt the three open general lemmas **on paper** in this order: mixed-product subspace row bound; quartic/three-slice scalar inequality; inductive six-family cover and recurrence. If any fails, search for the smallest counterexample and replace the operator, rather than optimizing a false constant.
4. Once the entire paper proof is closed, implement a named all-`L` theorem in pinned Lean `4.36.0-rc2` / Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`, with no hidden bound hypotheses, `sorry`, `admit`, introduced axioms, or unproved reduction. Re-run the exact finite checker as a separate falsifier.
5. Only then attempt an explicit adaptive **classical one-query / pair-energy** corollary. Treat `T=2` nonorthogonality as a mandatory negative control. Never infer all-`T` simulation from pair counting alone.

**Novelty threshold.** A verified all-`L` polynomial secant bound not already implied by published Segre/secant/coding results, with explicit constants and independently reproducible proof, is a plausible citable standalone contribution. A **stronger** breakthrough needs a valid, model-exact quantum/query theorem with matching lower bound or a demonstrably new sharp invariant. Neither is established now.

## HIGHER-UPSIDE TARGET: variance exponent 2 with polynomial degree dependence

Prove, first on the uniform Boolean cube and then (if feasible) for original-law arbitrary products,

`Var(f)^2 ≤ C d^p B(f)^2 max_i Inf_i(f)`

for **one fixed finite exponent `p` and an absolute constant `C`**, for every bounded degree-`d` function. The best publicly checked relevant general-degree result here is Turturean (Nov 2026), which gives `max Inf ≥ c Var(f)^(5/2)/d^6`. Defant–Mastyło–Pérez (2019) already give **variance exponent 2 at each fixed degree** with a degree factor exponential in `d` (their displayed `d^4 e^{4d}` bound on the fair cube). Thus *merely showing exponent two for each fixed `d` is not the landmark.* The live mathematical question is **polynomial dependence on `d` together with exponent two**. Degree exponent `p=2` is the proposed sharp frontier; any verified fixed polynomial `p` would materially advance the known general result.

**Urgent candidate audit.** A parallel instance reported `BIASED_BINARY_FIXED_DEGREE_EXPONENT_TWO.md`: for independent arbitrarily biased ±1 inputs and fixed `d`, `Σ_i sqrt(Inf_i)≤K_d B`, with a large `K_3≈1.8×10^6`, using a mean-point mixed-derivative expansion and vertex Markov bounds. **That file was not located on `main` in this review**, and its proof was not independently reconstructed or Lean-certified here. Ask Claude to locate its exact branch/commit and audit the directional inequality, all square-root/expectation interchanges, bias endpoints, degree/normalization conventions, and `K_d` growth. Compare line by line with DMP and existing polarisation/Bohnenblust–Hille arguments. If `K_d` is exponential/superpolynomial, it may improve the arbitrary-bias fixed-degree toolkit, but it does **not** settle the polynomial-degree landmark. If a polynomial bound can be extracted and survives adversarial review, reprioritize immediately.

**Stop rule.** Do not spend a long campaign polishing `K_3`, Q2 constants, or source packaging until a proof mechanism changes the *asymptotic dependence on `d`*. Test strongest candidate inequalities first on degree 1–3, highly biased sparse products, random-sign degree-`d` tensors, addressing functions, tribes, and Chebyshev-type extremizers.

## Independent prior art to compare before claiming novelty

- David Turturean, [*A proof of the Aaronson–Ambainis conjecture*](https://arxiv.org/abs/2611.09773), 6 Nov 2026: uniform Boolean `Var^{5/2}/d^6`, source of the general-degree product transfer mechanism.
- Uma Girish, Kunal Mittal, Barak Nehoran, Ran Raz, [*Distributional Variants of the Aaronson–Ambainis Conjecture*](https://arxiv.org/abs/2609.35327), Sep 2026: fixed common bias / slice comparison. Distinguish their assumptions from independent heterogeneous product laws and from a quantitative coefficient.
- Andreas Defant, Mieczysław Mastyło, Antonio Pérez, [*On the Fourier spectrum of functions on Boolean cubes*](https://arxiv.org/abs/1706.03670), *Math. Ann.* **374** (2019), 653–680: fixed-degree `Var²` / exponential-in-degree prior art.
- Wyner, *The common information of two dependent random variables*, *IEEE Trans. Inform. Theory* **21** (1975): latent common-information definition; distinguish two-variable original definition and any multivariate extension/conditional-product formulation.
- Finite-geometric Segre linear-section and secant results, generalized Hamming weights/simplex-tensor code literature; search full theorem statements and dates, not just matching terminology. The exact `q^{log₂3}` estimate and the proposed polynomial secant estimate are **not cleared** by the limited search conducted here.
- Repository [PR #947](https://github.com/d3lefts/d3lefts/pull/947) for the prior correction: high Wyner information **without** quantum advantage defeats a *sufficiency* inference, not a *necessity* inference; be meticulous about logical directions.

## INDEPENDENT FLAGSHIP: sharp adaptive phase retrieval and the price of regularity

**Classification:** NIGHTFALL's strongest *non-connected*, self-contained formal mathematical theorem package; a potential standalone paper, **not** a cleared historical novelty claim. Do not present this as a fourth dependency of Route 1/Q2/tensor subcubes. It is about exact algebraic sensing, not Boolean influence, mixture Wyner information, or quantum-query simulation.

### I1 — Exact adaptive versus fixed measurement complexity

Fix any **infinite field** `K` with `2≠0` and a signal dimension `n≥2`. A legal observation of an unknown `x∈K^n` is a squared *K-linear* form `y=(a·x)^2`. The goal is to identify `x` exactly **modulo one global sign** (`x~−x`), for **every** signal, including zero and arbitrary support. Queries can be either predetermined (nonadaptive) or selected as a function solely of earlier *observed* outputs (causal adaptive). No noise, continuity, finite-field, efficient-computability, or quantum-physical assumptions are part of this theorem.

The **formally certified exact minima in the source model** are

```
D_adaptive(n)    = n + 1
D_nonadaptive(n) = 2n − 1
savings          = n − 2
```

The adaptive design uses `n` coordinate-square observations followed by one history-selected sign-separating row. The lower bound proves no arbitrary causal protocol of depth `≤n` can work; it is **not merely** a lower bound for coordinate-first strategies. A fixed Vandermonde construction attains `2n−1`, with a matching lower bound for all fixed designs. At `n=2`, counts tie; for growing `n`, the ratio of fixed/adaptive minima approaches two.

**Named Lean terminal:** `Nightfall.InfiniteFieldPhase.Terminal.infinite_field_phase_retrieval_causal_terminal` in [PR #695](https://github.com/d3lefts/d3lefts/pull/695); pinned [CI run 44025319533](https://github.com/d3lefts/d3lefts/actions/runs/44025319533) at head `029661030cc1056ee16ea1ce77e2d8387298a7b9`. The PR records compilation of the six-source dependency closure and `#print axioms` limited to `propext`, `Classical.choice`, `Quot.sound`. In particular `InfiniteFieldLegalUpper.lean` identifies the construction with the **same causal history-oracle interface** used for the lower bound. Recheck this full declaration and current branch independently; the receipt establishes formal validity for its exact hypotheses, not priority.

### I2 — Continuity obstruction for a coordinate-first optimal architecture

The [PR #699](https://github.com/d3lefts/d3lefts/pull/699) theorem `Nightfall.ContinuousPhaseObstruction.no_continuous_final_row_all_dimensions` establishes a **specific sharp regularity obstruction over the real numbers**: for every `n≥3`, after `n` coordinate-square measurements, a single final history-dependent squared-linear row cannot identify *all* real signals modulo sign if its **first two row coefficients are continuous along the physically reachable history path**

```
h(t) = (t², (1−t)², 1, 0, ..., 0),     0 ≤ t ≤ 1.
```

The argument forces nonzero signed contributions at opposite endpoints and uses the intermediate value theorem to create a collision with an unchanged third-coordinate anchor. This is a constructive crossing mechanism, not simply a general topological embedding appeal. [Pinned CI run 44029903697](https://github.com/d3lefts/d3lefts/actions/runs/44029903697), head `10839ff172ae2ca5a03349d12fbb49c996e8d640`, reports strict compilation/kernel checks with only standard axioms. The companion `independent_checker.py` supplies additional finite numerical/rational adversarial tests; it does not prove the universal theorem.

**Do not overclaim:** I2 concerns a **coordinate-first `n+1`-query architecture** and continuity of **two coefficients on one specific history path**. It does *not* prove that every possible continuously adaptive `n+1`-query protocol fails, that every optimal policy is globally discontinuous, or that exact discontinuity automatically yields noise sensitivity with a quantified rate. I1 applies to arbitrary infinite fields of characteristic not two; I2 is real and explicitly topological. Never import real continuity language into arbitrary fields without defining a topology.

### The actual mechanism and significance

Taken together, I1 and I2 expose a precise tension:

> Under exact noiseless squared-linear measurements, causal adaptivity reduces worst-case measurement count from `2n−1` to `n+1`; in the optimal *coordinate-first* design, universally successful selection of the final sensing row cannot satisfy even a weak pathwise continuity requirement.

This is **not a universal law for all sensing protocols** yet. The useful distinction is *information economy versus regularity*, with a clear logical gap to robustness, stable recovery, or unrestricted continuous adaptive strategies. This is independent of the product-space program; any analogous influence/information narrative is currently an analogy without a theorem.

### Highest-value new theorem targets for Claude

1. **General continuous-policy gate (first priority).** Under an explicit topology and a single uniform sensing model over `ℝ^n`, determine whether any continuous causal `n+1`-query policy can universally recover `x` up to sign. Either construct a counterexample strategy to generalize I2, or prove an impossibility encompassing non-coordinate-first policies. Do not assume the coordinate-first proof survives arbitrary first-stage rows.
2. **Quantitative regularity–accuracy–measurement tradeoff.** Normalize signals (for example `||x||₂=1` modulo sign), specify a bounded sensing-row norm, measurement noise model, a uniform reconstruction-error metric, and a Lipschitz/continuity modulus on policy maps. Seek a theorem that either (a) lower-bounds the extra queries required for a given stability guarantee, or (b) lower-bounds policy regularity or reconstruction condition number at fixed `n+1` queries. First try `n=3`, using I2's explicit crossing path. Distinguish exact identifiability, stable inverse, finite precision, and runtime. A discontinuity alone does not furnish a numerical instability bound.
3. **Scope-and-priority audit before paper submission.** Compare same-oracle exact adaptive query complexity with work on the complement property and phase retrieval, adaptive measurement design (including Charikar–Wu–Ye), real/complex algebraic signal models, continuous versus Borel decision trees, and robust phase retrieval. Search for the actual *two-dimensional query-complexity functions* and the same causal scope, not just the phrase “phase retrieval.” Source-to-source priority clearance and independent human review remain open.

**Minimal decisive experiment:** characterize `n=3` policies abstractly enough to avoid the coordinate-first restriction. Independently reproduce I2's IVT collision; then test whether a non-coordinate-first *continuous* first-stage strategy evades the witness or whether a general topological obstruction survives. Write down failure modes before attempting a broad theorem. Formalize only a surviving statement, with a standalone Lean declaration importing the exact legal oracle semantics and an independently replayed certificate.

**Paper threshold:** a novel all-policy continuity impossibility **or** a sharp, quantitative, model-exact stability/query tradeoff (with proof and matching examples) would be a stronger, genuinely citable contribution than simply restating the already certified query minima. Preserve I1/I2 as the foundation; do not claim that their priority is settled or that I2 already establishes the general tradeoff.

**Research operator and transfer:** `exact model → adaptive/fixed minimax query counts → pathwise regularity obstruction → candidate global regularity or stability frontier`. Transfer to finite-field powered phase retrieval requires a new field-specific statement; discrete finite fields do not inherit the real IVT argument.

## Acceptance criteria and reporting contract

For each proposed theorem, deliver one immutable packet: **(i)** exact statement/normalizations/domain, **(ii)** shortest independent paper proof with dependency DAG, **(iii)** Lean theorem name + compiler/Mathlib lock + no-new-axioms `leanchecker` receipt, **(iv)** independent exact counterexample search/checker with source hash and negative controls, **(v)** dated theorem-by-theorem prior-art comparison, **(vi)** named independent mathematical reviewer and outstanding objections, **(vii)** credit and author approval before submission. Classify separately: analytic candidate → reproducible numerical evidence → kernel-certified theorem → independently reviewed theorem → priority-cleared novel contribution → external preprint/journal citation.

**Next action for Claude:** Start with PR #980, attack its unproved mixed-product and quartic inequalities *before* accepting its conclusion. In parallel, inspect the missing biased fixed-degree proof and determine whether its `K_d` can be polynomial. **Independent program:** recover PRs #695 and #699, and test whether the pathwise regularity obstruction extends beyond coordinate-first policies or yields a quantitative stability-versus-query lower bound. Report a decisive counterexample or a complete paper theorem and precise remaining certificate gate, not a broad claim of a unified theory.