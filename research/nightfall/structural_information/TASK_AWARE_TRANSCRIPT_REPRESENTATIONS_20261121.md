# Priority shift: task-aware, transcript-adaptive structural representation

**Status:** OPEN flagship research question, not a theorem. **Checkpoint:** 2026-11-21 (US Central). **Primary research PR:** [#987](https://github.com/d3lefts/d3lefts/pull/987), kept draft. **Superseded emphasis:** optimizing the author-chosen Simon static score `κR(1+ln M)` and its numerical limit `1/2`. **Separate completed campaign:** [v8 archived passport](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/closed_campaigns/V8_UNCONDITIONAL_FOUR_CERTIFICATE_20261121.md), no further constants polishing.

## Problem statement and audit gates

Given a finite-alphabet oracle distribution ν, a specified *task* F or a bounded low-degree acceptance polynomial f, and a tolerance/failure pair (ε,δ), seek a **non-tautological, source-defined, transcript-adaptive** representation quantity `S_task(ν,f;ε,δ)` satisfying:

1. **Rigorous sufficiency:** a depth bounded by an explicit function of this quantity and d,ε,δ gives a deterministic classical simulator approximating f with ν-failure at most δ; implement the correct original-coordinate oracle query interface and charge all exploratory queries.
2. **Conditional flexibility:** an adaptive query transcript h may change the posterior ν|h, the source/product-mixture reference Q_h, domination factor R_h and relevant coordinate partition; the reference and the partition may be chosen **only from the observed transcript**, never from unobserved oracle values or the hidden shift.
3. **Early stopping:** the certificate may stop on a transcript once the **task** is determined or approximated to accuracy ε with posterior failure budget, even when most oracle coordinates remain unknown. This differs from requiring reconstruction of the entire target block.
4. **Noncircularity:** the definition must not simply be the optimal classical decision-tree depth under a new name, nor permit arbitrary posteriors, task-dependent oracle lookups, invisible hidden shift, or free computation of unobserved f. It must use independently checkable structural operators (conditional product decomposition, bounded source discrepancy, low-degree moments, observable symmetries, or explicit stopping witnesses), with honest query and certificate costs.
5. **Calibration:** on Simon's **hidden-shift task**, target `O(√N)` original *table-entry* queries (N=2^n), not the Θ(N) static full-block score; retain correctness on duplicated bits, even parity, and the Forrelation-vs-uniform mixture. This is a *target*, not a theorem already established.
6. **Certification:** paper proof → independent adversarial audit → pinned Lean source/axiom check → independent `leanchecker` → dated prior-art review. Do not announce a characterization or necessity theorem before both directions are genuinely proved.

## Verified baselines and strong counterexamples

- **V8 stop:** unconditional factor `π²/[4(4−2√3)]≈4.60` finite-product influence coefficient improvement certified on exact Lean/Mathlib pins; no relationship to this new representation result should be invented.
- **Existing Route 1:** merged PR #970 certifies source-level classical simulation over any finite PMF with general Wyner common information and its exact high-probability error estimate. The direct *ungrouped* change-of-measure composition and parametric contrapositive are kernel checked in [run 44985218833](https://github.com/d3lefts/d3lefts/actions/runs/44985218833). Heterogeneous block decoding/composition is **not** Lean-formalized.
- **Duplicate bits:** repeated coordinates are an oracle-access artifact: regroup identical pairs so one original query recovers one product block. An online scheme should cost O(1) per relevant block, not charge a latent description of m bits.
- **Even parity:** a static product reference U dominates the even-parity law with factor R=2, independent of dimension; the scheme should not charge Θ(n) Wyner information merely for one global parity constraint.
- **Forrelation:** for the 50/50 forrelated/uniform mixture, PR #987's direct classical Pinsker/Bessel+arcsine argument proves `C_W≥N/(2π²)` nats. This does not itself prove a lower bound on the **optimized online measure**. A matching simulation/hardness comparison must preserve the same mixture and error/gap conditions; standard lower bounds are Ω(√N/log N).
- **Simon:** standard injective-label oracle with N=2^n input addresses and N output symbols. Static block reconstruction score is Θ(N), despite `Θ(√N)` classical hidden-shift complexity. The explicit score-free matching/Finner trade-off and stronger adaptive decoder lemma are preserved in PR #987, with author-side exact checks but **no general Lean or independent human proof**.

## Concrete online stopping certificate for the Simon benchmark

Use the deterministic XOR difference cover on n=a+b address bits, where a=ceil(n/2), b=floor(n/2). Query
`A={(u,0^b):u∈F₂^a}` and `B={(0^a,v):v∈F₂^b}`, in total at most
`q_0=2^a+2^b−1=O(√N)` **distinct table entries**.

For every hidden shift s≠0, some pair of queried addresses differ by s. Since the promised labels are injective across shift cosets, two observed equal output symbols prove their addresses differ by precisely s. Such a collision is an **observable transcript certificate** for the full hidden shift. **Stop here** for tasks computing a function of s; do not query an unobserved representative of every remaining shift-pair. The source law conditional on the observed collision has a known s but still many unobserved labels; demanding full-table block reconstruction would waste Ω(N) queries.

This is a classical construction/baseline, **not** a new quantum/classical theorem. Important interface: the task `F(x)=s(x)` or a bit `s_j(x)` need not itself be a bounded degree-O(n) real acceptance polynomial on the table-entry indicator basis. For the full Route 1 transfer, distinguish computing the promise task from approximating a *particular normalized quantum circuit's acceptance probability*, which may depend on the unseen injective labels even when s is fixed.

## Cheapest decisive experiment (pre-registered)

**Prediction A (desired):** a restricted online representation operator based on posterior product-mixture envelopes and *observable task stopping certificates* yields a finite, auditable cost O(√N) for Simon while upper-bounding the classical approximation of every bounded degree-d acceptance polynomial in its declared scope.

**Alternative B:** replacing full-block reconstruction with task stopping only reproduces the classical decision-tree definition in disguise and has no general explanatory theorem. **Alternative C:** post-collision determination of s does not control the particular quantum-acceptance polynomial's variance, so the source-to-acceptance bridge fails. **Alternative D:** allowing online arbitrary Q_h hides an uncharged oracle computation or invalidates domination under conditioning.

**Discriminating tests:**
- Enumerate all standard Simon tables for N=2,4,8 and verify an observable duplicate in the fixed difference-cover transcript; construct a certificate that uses **only queried addresses/answers** and proves the shift uniquely, with worst-case `q_0`.
- Conditional on each possible observed collision, enumerate supported table completions and test whether the chosen task `F=s_j` is constant. Separately test a normalized quantum-circuit acceptance polynomial `f` once an exact pinned source representation is available; do **not** assume its constancy.
- For duplicate/parity, show the same **single structural definition** reproduces prior cheap certificates with no hidden coordinates.
- For Forrelation, attack the proposed online quantity via a low-cost hypothetical certificate; if it would contradict the source-matched classical hardness theorem, locate the invalid assumption before promoting the representation.

**Budget/stop rule:** prefer one finite exact checker and one clean general lemma over large numerical optimization; halt on a counterexample or an uncharged observation. No renewed effort on the arbitrary static `1/2` score.

## Proof dependency / transfer graph

`Route1WynerGeneral [merged Lean]` + `pointwise density transfer [Lean]` → `heterogeneous blocked/grouped source simulation [paper, formalization gap]` → `transcript-conditioned domination & budget accounting [new open theorem]` → `task-relative stopping certificate [new open theorem]` → `Simon Θ(√N) calibration [test]` → `distribution- and task-relative necessary/sufficient characterization [speculative, no claim]`.

**Review request:** a non-author collaborator should independently attempt to refute the source-to-posterior transition, the stopping rule, and the quantum-acceptance bridge; credit contributors and publish no priority claims without a dated prior-art comparison.
