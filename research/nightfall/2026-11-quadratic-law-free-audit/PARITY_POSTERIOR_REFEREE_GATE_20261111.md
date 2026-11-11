# Quadratic arbitrary-law theorem: parity, genuine posterior, and dated priority gate

**NIGHTFALL / Devin J. Wright · 2026-11-11 · independent adversarial dependency audit v2**  
**Claim under review:** for bounded real Hoeffding-degree ≤ 2 observables on arbitrary independent heterogeneous products,
`Var(f) ≤ 15(1+√3) ||f||∞ sqrt(sup_i I_i(f))`; ensuing rank-r Hilbert adaptive hard budget `ceil(20172 r B²/η)`. The statements are in merged #362 and #368, with previously scoped Lean support #359, #364.

## A. Matching parity: what is proved and what is not

The analytic proof in #362 selects one rectangle for each edge in a *matching*. Global even and odd measures independently choose the two corners within each matching block. The contribution of a selected edge is half its alternating mixed difference. Any off-matching pair uses at most one endpoint of each block, so the joint marginal under either parity is identical. Thus `sum_P ||h_ij||∞≤4B` for all matchings. Greedy weighted edge-cover then gives endpoint costs `sum_i c_i≤8B`.

New `ParityBlockCancellation.lean` supplies an actual full-`ι→Bool`-selector involution and independent expectation reindexing. It covers both orientations of each cross-block pair, including right-right (two flips), without any distributional fairness premise. **It does not yet construct the full product-valued even/odd measures from an actual arbitrary-degree-two function** or formalize the greedy weighted edge-cover and the finite rectangle-selection lower bound. The new theorem is a *supporting* lemma, not the main matching theorem.

The existing #362 exact Fraction checker separately exhausts 546 matching/parity identities across 33 heterogeneous degree-two products, including skewed atom masses. This is falsification evidence only.

## B. Actual posterior drift: recovered existing Lean first

**Avoid redundant work:** the original repository already has concrete finite-product posterior arithmetic, not merely an abstract conjecture:
- `research/nightfall/formalization/product_space/ProductSpaceTwoSidedBridge.lean`, namespace `Nightfall.ProductSpace.Posterior`, `finite_observation_partition`, `posterior_edge_mean`, `posterior_total_mean`, `conditional_mass_one` (source from #303/#307).
- `research/nightfall/formalization/product_space/VariancePosteriorOneStep.lean`, `Nightfall.ProductSpace.Observation.posterior_total_at_coordinate` and `exact_certificate_posterior_decrement`, instantiating a *concrete* product `pairMass` and `edgeCross`, from #312. This is a **Boolean directed crossing potential** under strictly positive laws, not automatically the real-valued ANOVA squared-resampling influence or the new rank-r quadratic adaptive theorem.

New `PosteriorEnergyDrift.lean` proves a complementary interaction-support identity, for every finite index type and energy map (no hidden probability or variance assumption):
`T(Q∪{i}) + I_i(Q)=T(Q)`, where `T(Q)=Σ_S |S\Q| w_S`.
Analytically, this is exactly the *expected* total of the actual squared influences after observing `i`, because degree-two Hoeffding components obey martingale orthogonality. The map from actual conditional ANOVA component energies, including null cells and output target, to `w_S` remains an explicit Lean composition step.

**Critical adversarial counterexample:** the same identity is **false** with posterior variance replacing total influence. For `f(X,Y)=XY` with independent fair signs, `Var(f)=I_X=1`, yet `E Var(f | X)=1` (not zero). A distinct exhaustive exact posterior checker runs 12 products, 5,360 valid transcript/next-coordinate combinations, and records 3,851 false variance-drift controls. All 5,360 true total-influence identities pass.

## C. End-to-end Lean dependency checklist

* **Closed scoped only:** n-increment arbitrary-weight finite Hilbert fourth moment (pinned #364); quadratic three-point interpolation and conditional coefficient closure (#359); finite Efron--Stein decomposition (#325); finite selector-involution cancellation and ANOVA support deletion (this PR, **only after strict CI PASS**); pre-existing Boolean finite posterior partition/expectation (#303/#312).
* **Still required for the exact target:** direct global matching product coupling from actual `h_ij` + selected rectangles; weighted maximal-matching/edge-owner construction; global degree-two Markov switching to actual `ΣE||U_i||≤8B`; additive projection-to-ANOVA `7B` norm budget; actual Hilbert-valued assigned increments and bounds; final substitution of concrete finite-product squared resampling energies into the existing algebra; then posteriors of real/rank-r functions and measurable/infinite product transfer.
* **Not an end-to-end Lean theorem:** do not confuse a declared generic `T(Q)` or Boolean crossing potential with `max_i E|f-E_i f|²` without the missing identification.

## D. Direct current prior art checked (2026-11-11)

1. David Turturean, *A proof of the Aaronson-Ambainis conjecture*, arXiv:2611.09773v1, submitted **2026-11-06**: bounded uniform Boolean-cube degree-d exponent-5/2 variance lower bound `Inf_max ≥ c Var^(5/2)/d^6`. Not the exact all-alphabet degree-two squared-variance theorem. Read abstract and available formalization guide. https://arxiv.org/abs/2611.09773
2. Francisco Escudero Gutiérrez, *Influences of Fourier Completely Bounded Polynomials and Classical Simulation of Quantum Algorithms*, arXiv:2304.06713v2 **2023-06-28**, **Theorem 1.6**: `Inf_max ≥ Var²` for homogeneous Fourier-*completely bounded* Boolean polynomials with `||p||_{fcb,d}≤1`. **The exponent two is NOT new in itself.** Theorem 1.8 also proves `(Var/d)²` in the block-multilinear completely bounded class. Neither theorem assumes only bounded `||f||∞` under arbitrary independent categorical laws. https://arxiv.org/html/2304.06713v2
3. Uma Girish, Kunal Mittal, Barak Nehoran, Ran Raz, *Distributional Variants of the Aaronson-Ambainis Conjecture*, arXiv:2609.35327v1 **2026-09-28**, **Theorem 4.3**, **Remarks 4.4–4.5**: AA-equivalence for fixed Bernoulli biases and slices. Transferred lower-bound overhead depends polynomially on distance of biases from 0 and 1; product-family generalization explicitly keeps biases bounded away from endpoints. Thus no atom-floor-free all-alphabet coefficient as in #362 is asserted. https://arxiv.org/html/2609.35327v1
4. Classical bilinear Littlewood/Bohnenblust–Hille and Grothendieck inequalities, ANOVA/Hoeffding, Markov derivative inequality, and OSSS decision-tree inequality are predecessor mechanisms. **A source-to-source expert reduction showing that a known categorical bilinear norm theorem does not already imply the matching theorem has not been completed.**
5. Parallel program PR #375 supplies another analytic rank-linear formulation, but it is not an e2e Lean certificate and its appearance is **not evidence of priority**.

**Novelty verdict:** No identical joint input/output/query statement identified among the checked sources; global originality **not established**. Require a human specialist to attack reduction from general categorical degree-two bilinear bounds, and to review the exact final source.

## E. Reproduction and status

- Source: this PR branch, original analytic manuscript #362 and #368 (do not rewrite frozen source).
- CI: `.github/workflows/nightfall-quadratic-posterior-energy.yml` pins Lean 4.35.0 / Mathlib v4.35.0 and audits only `propext`, `Classical.choice`, `Quot.sound`; runs the new Fraction posterior checker and original matching checker.
- **New independent theorem status must be taken from the *latest* matching head CI receipt, not from this text.**
- No site promotion, external publication, or claim of complete kernel verification is authorized by this scoped audit.
