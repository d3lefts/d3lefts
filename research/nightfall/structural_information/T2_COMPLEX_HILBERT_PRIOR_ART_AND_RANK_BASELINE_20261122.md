# T2 rank-free complex Hilbert simulation — dated priority and fair-baseline audit (v1)

**Audit date:** 2026-11-22. **Object:** analytic claim in [draft PR #1068](https://github.com/d3lefts/d3lefts/pull/1068) and tensor source [merged #1112](https://github.com/d3lefts/d3lefts/pull/1112)/[merged #1114](https://github.com/d3lefts/d3lefts/pull/1114). **Status:** a complete *author-side paper proof* of the unrestricted complex-Hilbert operator result is recorded on #1068, scoped algebraic Lean certificates have merged, the *end-to-end noncommutative quantum theorem is NOT yet Lean-certified*, independent outside review and worldwide novelty remain open. No external publication approval.

## Exact model that must be matched

Let `V` be an F2-vector space, `R ⊂ V\\{0}` finite and **distinct**, `D=R ∪ {0}`, `s` uniform on `V*`, and `χ_a(s)=(-1)^(s(a))`. A legal classical query requests one `χ_a` with `a∈R`. The two-query phase oracle `O_s=Σ_(a∈D) χ_a(s) Π_a` acts on an arbitrary complex Hilbert space through orthogonal sectors `Π_a` summing to the identity. `U` is unitary and `P` an arbitrary bounded, noncommuting effect `0≤P≤I`. The target is the **scalar acceptance** `f(s)=⟨O_s U O_s ψ,P O_s U O_s ψ⟩`. The proposed simulator fixes original-row queries before observing data and approximates this acceptance with probability at least `1-δ` over the hidden secret. This is not state simulation, runtime-efficient simulation, arbitrary source law, or all-depth simulation.

## Dated external antecedents independently cross-checked this session

| Prior work (source and date) | Proven/questioned scope | Same-model relevance and credit |
| --- | --- | --- |
| [Lovitz, *Toward a generalization of Kruskal's theorem*](https://arxiv.org/abs/1812.00264), 2018/2020 | Binary-local-factor product-tensor circuit active-mode control | Pre-existing source of at-most-`k−2` active factors; not an original NIGHTFALL structural theorem |
| [Bansal, Sinha, de Wolf, CCC 2022](https://doi.org/10.4230/LIPIcs.CCC.2022.28), 2022-07-11 | Completely bounded block-multilinear influence and almost-everywhere simulation of a restricted class of quantum circuits | Pre-existing quantum/classical Fourier influence mechanism; not inspected as a uniform thin-code original-label theorem |
| [Lovitz–Petrov, *A generalization of Kruskal's theorem*](https://doi.org/10.1017/fms.2023.20), 2023 | General product-tensor splitting/exchange structure | **Direct dependency** for tensor primitive-fiber counting; generic active-factor argument is inherited |
| [Blanc, Docter, Strassle, Tan, *Quantum Speedups Require Structure or Depth*](https://arxiv.org/abs/2608.19158), 2026-08-19, FOCS 2026 | Fixed-round near-everywhere classical simulation under **uniform full independent oracle inputs** | Strongest direct competitor for generic fixed-round slogans. Its source law is not the correlated linear-code oracle below |
| [Liu–Mutreja, *Parallel Quantum Advantage with Limited Adaptivity Requires Structure*](https://arxiv.org/abs/2608.20297), 2026-08-20; revised 2026-10-20 | Parallel/limited-adaptivity simulation; coupling to **dense** oracle distributions | Not a theorem for exponentially sparse codeword-conditioned sources by direct conditioning |
| [Escudero Gutiérrez–Saucedo–Palazuelos, *Optimal inequalities for completely bounded polynomials*](https://arxiv.org/abs/2609.05201), 2026-09-04 | Sharp root-influence inequality for disjoint-block CB forms; resulting **nonadaptive** classical simulation for that quantum class | Nonadaptivity is substantially prior art. Disjoint independent-block influence cannot be directly reused for correlated queried characters without a separate source theorem |
| [Girish–Mittal–Nehoran–Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*](https://arxiv.org/abs/2609.35327), 2026-09-28 | Equivalence of simulation conjectures across uniform, fixed-biased product and slice distributions | These are equivalences, not an unconditional thin-code / original-row simulation theorem |
| [Wang–Yuan, *Structure and Exact Certification of Nonnegative Tensor Decompositions*](https://arxiv.org/abs/2610.32787), 2026-10-23 | `p+q−2` effective-order exchange bound using Lovitz–Petrov | Bounded-active-mode exchange mechanism predates NIGHTFALL; nonnegative real decomposition is not the binary character-oracle target |
| [Yaqiao Li, *Two exact quantum queries use at most six variables*](https://arxiv.org/abs/2610.34079), 2026-10-25 (revision 2026-11-16) | Exact computation of **total Boolean output functions** | Strong adjacent T=2 path-interference theory, but not approximate acceptance on correlated secrets |

**Priority verdict:** In the indexed original-source statements inspected on 2026-11-22, no identical theorem was verified combining *arbitrary* complex sectors and effects, *uniform correlated binary character labels*, *T=2*, *nonadaptive actual original-row* acceptance estimation, and explicit `K4/M2` fiber charges. **This is a negative result of a bounded search, not a worldwide novelty certificate**. The FOCS fixed-round theorem, nonadaptive CB simulation and published tensor splitting must be credited prominently. Full-text specialist comparison, source-to-source reduction attempts and human review are still required before a novel-contribution label.

## Verified elementary original-row basis bound — fair comparison correction

Set `r = dim_F2 span(R)`. Choose a basis `b_1,…,b_r` **from R**. Query only these r original labels. Every `a∈R` has unique expression `a=Σ λ_i b_i`, hence exactly
`χ_a(s)=∏_(i:λ_i=1) χ_(b_i)(s)`.
The known quantum circuit's oracle and scalar acceptance can then be evaluated exactly with unrestricted classical preprocessing. This gives **unconditionally for any quantum query depth**
`Q_classical_exact ≤ r ≤ |R|`, zero failure, under the same oracle interface. No operator-energy or quantum simulation theorem is used. This is elementary linear algebra, **not claimed as new research**.

Consequently, **if** the #1068 operator theorem plus #1097 Möbius improvement holds with `K_A,M2`, the honest stronger displayed candidate is
`Q_T2 ≤ min(r, ceil[2(2√K_A+35√M2)^2/(ε²δ)])`
rather than just `min(|R|, …)`. The rank term is proved independently; the second term is **paper-level / Lean terminal open**. Do not present their conjunction as kernel-certified.

For the binary tensor family `R_L=(F2²\\{0})^{⊗L}`, `|R_L|=3^L` but the row span equals all `F2^{2^L}` because every standard basis tensor is included. Thus `r=2^L`. The vector of all `3^L` responses is uniform on a binary linear code of dimension `2^L`; its fraction of the independent full `3^L`-bit response cube is exactly
`α_L=2^(2^L−3^L)` (at `L=3`, `2^-19`; at `L=4`, `2^-65`).

**Failure-event conditioning barrier:** an arbitrary full-cube event `E` of measure `δ_full` satisfies only `Pr(E|C)≤min(1,δ_full/α_L)` under uniform conditioning on the code `C`. Taking `E=C` shows the possible amplification factor is sharp for event transfer. Therefore an independent-cube almost-everywhere guarantee cannot simply be asserted to survive conditioning on this code; a code-specific argument is needed. This **does not prove** existing fixed-round methods cannot be adapted, or furnish a lower bound.

## New exact comparison against the fair 2^L baseline

Specialize the **paper-level** cubic primitive Group A estimate from #1114 and the conditional 35 constant from #1097:
- `N=1+4·3^6=2917`,
- `M2=2L+2`,
- `S3(L)=Σ_(j=0)^min(3,L) binom(L,j)`,
- `K_A ≤ 52 N² min(N,M2) S3(L)`.

With `ε=δ=1/4`, the displayed conditional formula is
`Q_formula = ceil[128(2√K_A +35√M2)^2]`.
This is a formula comparison, **not measured simulator runtime or a verified end-to-end quantum theorem**.

The pure-Python independent [exact checker](../../../scripts/check_t2_rank_baseline_exact.py) computes lower/upper integer envelopes for `Q_formula` using `floor(√n)`/`ceil(√n)`, never floating-point or verifier tolerance, and checks the actual row span through `L=4`. For **every** `1≤L≤59`, the lower envelope is at least `2^L`. At **L=60** the upper envelope is strictly below `2^60`. Hence **L=60 is the first depth where the DISPLAYED conditional cubic/35 upper bound beats the sharper exact-basis `2^L` strategy**, correcting the previously reported `L=36` crossover against the weaker full-row `3^L` baseline.

At L=60 the exact checker obtains
`K_A_bound=1,946,047,105,358,616`,
`M2=122`,
`Q_formula∈[996,384,772,700,385,408, 996,385,608,400,259,072]`,
and `2^60=1,152,921,504,606,846,976`.
The interval here is a certified integer **enclosure of the formula**, not a probability interval or a quantum-complexity lower bound.

## Independent audit and claim gates

- **Checked this session:** source-dated original literature abstracts and where available HTML theorem context; current NIGHTFALL #1068 paper source, #1076/#1077 proof-audit checkpoints, scoped Lean source/CI, and exact binary tensor rank and integer envelope arithmetic. The paper result's complex operator lemmas were not re-proved from scratch here.
- **Lean status:** scoped cancellation/Möbius source dependencies have named kernels. The previously failed Möbius receipt was a **parser false-negative** despite successful compilation/checker; [PR #1115](https://github.com/d3lefts/d3lefts/pull/1115) fixed it and its exact-head [run 45065425057](https://github.com/d3lefts/d3lefts/actions/runs/45065425057) passed; merged SHA `16bfa598fdb0984af4c5e6736d5950198e4e5fee`. **No full Hilbert matrix-frame/Walsh/actual-query Lean terminal exists in inspected trees.**
- **Priority status:** external same-model global priority **OPEN**, no novelty assertion; this record avoids duplicating the candidate claim of #1068.
- **Falsification target:** attempt to derive the claimed `K4/M2` theorem from BDST/Liu–Mutreja/CB via a source-exact code-conditioned reduction. If it works, demote originality; if it cannot, exhibit the exact missing hypothesis rather than arguing from absence of a search hit.
- **Next formal proof obligation:** full complex noncommutative light path frames, crossed synthesis, zero triple energy, repeated coefficient partition, uniform Walsh projection and the final actual-label query count. Independent author-controlled proof attack #1076 is incomplete, outside reviewer not obtained. Do not close #1077 based on this prior-art and baseline audit.
