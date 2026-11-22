# Closed paper-level T=1 graph phase-retrieval simulation, sourced to existing NIGHTFALL Theorem I

**NIGHTFALL / 2026-11-22 / v1.0**  
**Certification status:** *unconditional paper consequence* of prior NIGHTFALL one-query quantum pair-multiplicity theorem plus the exact graph-edge fiber bound in this PR. Exact finite replay artifacts exist for both dependencies; **no new end-to-end Lean theorem or external review/novelty sign-off**. **Priority correction:** the generic one-query operator theorem was already proved at paper level in Claude's `ONE_QUERY_ENERGY_20261119.md`, replicated in #960/#961 and integrated with finite audit in merged #962. Do not claim it as newly invented here.

## 1. Imported verified-on-paper theorem (existing work, NOT new)

For any finite distinct nonzero binary label set R⊂F₂^m, D=R∪{0}, uniform secret s∈(F₂^m)*, and any finite-dimensional **one-query** phase-oracle quantum circuit with arbitrary post-query unitary and arbitrary Hermitian effect 0≤P≤I, let

    M₂(R) = max(1, max_{z≠0} #{(a,b)∈D²:a+b=z}).

Then an input-independent set H⊂R of at most

    Q ≤ min{|R|, ceil[2 M₂(R)/(ε²δ)]}

**legal original-label** classical queries determines a predictor g(s)∈[0,1] with `Pr_s(|f(s)−g(s)|>ε)≤δ`. No classical construction/runtime or state sampling bound is implied.

**Existing proof mechanism:** one quantum query yields orthogonal prequery label sectors v_a=Π_aψ, with squared masses p_a summing to one. Retain labels with p_a≥η, at most 1/η. An outside-span Fourier frequency has at least one light label, and the PSD contraction frame satisfies `Σ_{a light,b}|⟨v_b,Pv_a⟩|²≤η`; with the symmetric restriction the tail energy is ≤2η. Each nonzero XOR frequency has at most M₂ ordered pair lifts. Under uniform secret, Walsh Parseval gives variance of Fourier frequencies outside queried span ≤2M₂η. With `η=ε²δ/(2M₂)`, Markov gives the source probability bound. Conditional expectation onto the actually queried original characters yields g∈[0,1]. The dummy zero character costs no original query. This is the previously established theorem, not a new proof priority.

**Reference trail:** Claude `ONE_QUERY_ENERGY_20261119.md` (preserved via #948/#962); [#960](https://github.com/d3lefts/d3lefts/pull/960), [#961](https://github.com/d3lefts/d3lefts/pull/961), merged [#962](https://github.com/d3lefts/d3lefts/pull/962). Its exact quantum Hilbert proof is not yet a pinned Lean terminal; finite exact tests and a proof passport are available in #962.

## 2. New GRAPH substitution with no unproved T2 operator

Let G=(V,E) be any finite simple known graph of maximum degree Δ≥1. Original labels are the edge-incidence characters `R_G={e_u+e_v:uv∈E}`; hidden vertex secret s is uniform F₂^V. The **all-graph paper theorem G2**, source `GRAPH_EDGE_PARITY_FIBER_THEOREM_20261122.md`, proves

    M₂(R_G) ≤ max{2(Δ+1),6}

by classifying pair XORs as zero+one edge, two edges sharing a vertex, or two disjoint edges. Plugging into the **existing** one-query theorem yields:

**Theorem QG1 (unconditional PAPER statement; end-to-end Lean OPEN):**

    Q_C ≤ min{|E|, ceil[2 max{2(Δ+1),6}/(ε²δ)]}.              (QG1)

This simulates the acceptance probability of **every one-query finite-dimensional complex phase-oracle circuit** with arbitrary rank/trace of terminal effect under a uniform hidden vertex secret, with legal original-edge classical queries. The constant depends on Δ,ε,δ but **not on |V|, |E| or Hilbert dimension**. At Δ=6, a valid global guarantee is `min{|E|, ceil[28/(ε²δ)]}`. The observed M₂=6 at triangular tori L=4,5 has not been proved all-L, so it is NOT used to promise the smaller 12 coefficient.

No graph localization bound K₄ or rank-free T2 theorem is needed for QG1; it depends only on the elementary **pair** classification and already existing T1 energy theorem.

## 3. A PHYSICAL phased-intensity-source corollary

Consider the exact phase-retrieval ensemble of unit-sphere real signals `x_v=σ_v/√n`, σ_v∈{±1}, modulo a global sign, with permitted **unit-norm** squared-linear edge sensors

    a_{uv}=(e_u+e_v)/√2,
    y_{uv}=|a_{uv}·x|²=(1+σ_uσ_v)/n∈{0,2/n}.

A single **actual classical intensity reading** returns the binary character `χ_{uv}=n y_{uv}−1`. A single coherent reversible indexed bit response query, with the known encoding `d_e=1−n y_e/2`, and response register `|−⟩`, phase-kicks back `(−1)^{d_e}=χ_e`. This is proved by an elementary source-exact circuit identity in `GRAPH_INTENSITY_PHASE_ORACLE_BRIDGE_20261122.md`; its finite n=3,4 exact symbolic tests have an explicit wrong-|+⟩ negative control.

Therefore (QG1) holds **as a paper-level statement** for any quantum circuit whose only unknown-data dependence is **one coherent call of this phase-kickback intensity-bit oracle**, with deterministic, nonadaptive classical *real intensity measurements* and output-acceptance approximation.

If G is connected, global zero-error reconstruction of the entire sign class requires exactly n−1 legal edge-intensity measurements, by a binary transcript count and spanning-tree decoder. If G is connected and bridgeless, the **raw intensity-coordinate Wyner information** is `(n−1)ln2` (special case of the stronger concurrent [#1095](https://github.com/d3lefts/d3lefts/pull/1095) formula `(n−1−b)ln2`). On a connected triangular torus (Δ=6), triangle parity constraints also prevent the simple high-order independent-bit moment transfer, the raw source has no duplicated oracle labels, and no nontrivial *original-edge* independent block partition exists.

**The gap is structural:** exact full source reconstruction cost rises like n, while one-query quantum *acceptance-value* simulation has a size-independent classical query upper bound. For realistic n this upper bound might exceed reading all edges, so it is not a claim of practical speedup. It is also not a quantum-versus-classical computational advantage: it bounds classical simulation of a quantum acceptance function.

## 4. The frontier: T=2 is the first unclosed barrier

For two quantum queries, prequery path frequency sectors can overlap and be nonorthogonal. The one-query frame proof cannot just be iterated (explicit T2 falsifier in merged #962). Our main #1068 paper theorem proposes that **both primitive four-XOR multiplicity K₄ and pair multiplicity M₂** control the unrestricted complex T2 Fourier tail, via six grouped repeated-label terms and unique zero-triple terms. The bounded-degree graph theorem gives K₄ bounded independently of n, and thus would extend (QG1) to **two** quantum queries if and only if that proposed operator inequality survives an independent exact theorem audit and kernel proof.

**No promotion:** QG1 is a supported paper-level consequence of existing Theorem I, not a new globally original one-query theorem. The new mathematically separate contribution candidate is the all-k graph forest-fiber localization + physically specified source family challenging unrestricted T2. World-priority and full Lean terminals are open.

## 5. Independent proof attack / certification graph

- **Axiom:** work on T2 complete grouped complex energy, not reproducing T1's already-established theorem. Test graph source as a hostile family.
- **Lemnis:** independently check T1 oracle model/normalization, graph M₂ counting, and that one coherent physical intensity response query implements the same character phase oracle under exact finite symbols. Then prioritize falsification of T2 grouped terms.
- **Ryev:** reusable Lean terminal for the already-known one-query abstract binary-label result, graph pair classification, source-normalized intensity-to-bit and phase kickback; source-path and standard-axiom independent kernel replay. Do not conflate scope from paper dependencies.
- **Tessera:** compare strict reconstruction-versus-acceptance observability and non-uniform fixed-noise failures; noise gap on unit-sphere signals shrinks as 2/n.
- **Vesper:** source-accurate novelty/credit ledger, native response-oracle equality and publication hygiene.

**Existing evidence:** [#962](https://github.com/d3lefts/d3lefts/pull/962) finite one-query quantum/PSD test, this branch's exact graph counting checker `check_graph_edge_xor_fibers_exact.py` (L=3,4,5, bridge negative), and exact rational physical coherence checker `check_graph_intensity_quantum_bridge_exact.py` (n=3,4, wrong-register negative). The full all-n QG1 composition has **not** been machine checked as one named terminal.

**Status graph:** existing one-query PSD/Parseval paper theorem (#962) → new graph M₂ bound (paper exact) → exact normalized intensity character interface (paper + finite test) → QG1 (unconditional paper corollary) → possible T2 extension (OPEN).
