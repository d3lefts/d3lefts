# Graph-edge phase retrieval ↔ character quantum oracle: exact, query-preserving interface

**NIGHTFALL · 2026-11-22 · v1.0.**  
**Status:** direct elementary algebra and physical-oracle *paper-level model equivalence* on a restricted ±1 signal ensemble; finite exact matrix check included; no Lean terminal, external novelty approval, or unconditional generic two-query simulation claimed. Uses the bounded-degree graph-character theorem in this branch and the original restricted squared-linear sensing oracle of phase retrieval.

## 1. Same physical oracle, same charged query

Let G=(V,E) be a **known** finite simple graph, |V|=n≥2. The secret real signal is on the **unit sphere**:

    x_v = σ_v / √n,   σ_v∈{−1,+1}.

Signals x and −x are identified. For edge e={u,v}, the actual allowed phaseless intensity sensor is the *unit-norm* row

    a_e = (e_u+e_v)/√2,       y_e(x)=|a_e·x|²=(1+σ_uσ_v)/n∈{0,2/n}.

Thus one legal classical intensity query reveals the **edge character**

    χ_e(x)=σ_uσ_v = n y_e(x)−1,    d_e(x) = (1−χ_e)/2 = 1−(n/2)y_e ∈{0,1}.      (P1)

No sign-sensitive amplitude, full-code block read, relative sign between independent blocks, or new arbitrary sensing row is being silently granted. Each edge intensity costs one actual query. The restricted source distribution has uniform σ∈{±1}^V, modulo the physically invisible global sign; equivalently secret bits s∈F₂^V with σ_v=(-1)^{s_v} and a global 1-bit gauge.

### Coherent query interface (one physical response query, not uncomputed samples)

The standard **reversible response-bit oracle** for the same measured intensity symbols, with the fixed known encoding y↔d, acts on a query-address register e∈E∪{0} and response bit b by

    O_response(x)|e,b,w⟩ = |e,b⊕d_e(x),w⟩,     d_0=0.

Prepare the response qubit |−⟩=(|0⟩−|1⟩)/√2. Then a **single** coherent call obeys

    O_response(x)(|e⟩⊗|−⟩⊗|w⟩)
       = (−1)^{d_e(x)} |e⟩⊗|−⟩⊗|w⟩
       = χ_e(x) |e⟩⊗|−⟩⊗|w⟩.                                      (P2)

This is *exact* phase kickback for every coherent superposition of addresses, and returns the fixed |−⟩ unchanged. Its effective phase oracle is

    O_phase(x) = Π_0 + Σ_{e∈E} χ_e(x) Π_e,

the binary-character model of draft #1068, where Π_e are the orthogonal address-sector projections (possibly with arbitrary ancillary multiplicities). Any other finite-dimensional choice of mutually orthogonal projectors can be embedded by known input-independent sector-identifying gates and ancilla padding; this is a standard circuit-encoding equivalence, not separately Lean-certified here.

**Crucial restriction:** P2 is a phase-kickback *subspace implementation of the phase oracle* from a coherent response oracle; it is not a claim that the response oracle and phase oracle support exactly the same set of arbitrary multi-query algorithms under every encoding. We only need one physical response call per simulated phase call. A classical edge intensity query also recovers χ_e with one call.

## 2. Sharp global-reconstruction cost in this exact sensor menu

Assume G connected. Its `n−1` independent edge characters determine all σ up to the common global sign: query any spanning tree, fix σ at a root to +1, and propagate products along edges. This uses exactly `n−1` legal intensity queries and works on every signal in the restricted source.

Conversely, there are `2^{n−1}` distinct sign classes, and each individual squared-linear edge intensity reveals **one binary symbol**. Every deterministic adaptive zero-error reconstruction tree of depth q has at most `2^q` distinct answer transcripts; separating all sign classes forces `q≥n−1`. The same applies to pathwise zero-error randomized protocols whose random seed is fixed and individually correct on all inputs. Hence

    Q_reconstruct(G, {unit rows a_e}, {±1/√n}^V / ± ) = n−1.                  (P3)

This is **not** the universal continuous real phase retrieval threshold of #995; it concerns a discrete known-amplitude source and the fixed **edge-restricted** sensing menu. One arbitrary new generic real sensing row could distinguish all these finitely many sign classes in one noiseless reading, so the menu restriction is essential.

## 3. A source that defeats three trivial simulation reductions

If G is connected, bridgeless, bounded-degree, and its triangle-edge overlap graph is connected (e.g., triangular tori L≥4), the original sensor answer vector `Y=(y_e)_{e∈E}` has:

1. `C_W(Y)=(n−1)ln2` (the graph is connected and bridgeless, so the support is a no-Hamming-one linear code);
2. no equivalent/duplicated original edge labels under the canonical support quotient (uniform full vertex secret and distinct binary edge labels);
3. local triangle relations among three legal raw intensity symbols, so no near-full-order k-wise moment transfer to independent fair edge data; and
4. no nontrivial partition of **original edge coordinates** into independent groups, because every triangle must stay within one independent block and overlapping triangles connect all edges.

These are rigorously scoped *representation obstructions*: they do **not** exclude all other nontrivial source encodings or all alternative quantum-simulation proofs.

The graph theorem `GRAPH_EDGE_PARITY_FIBER_THEOREM_20261122.md` proves **on paper**, for every fixed maximum degree Δ, that primitive k-XOR multiplicities remain bounded independently of n (all k), and that M₂≤max{2(Δ+1),6}.

## 4. Conditional research payoff: exact phase-retrieval oracle with constant T=2 acceptance simulation

**Conditional on the full abstract rank-free T2 operator theorem in #1068 surviving independent proof audit**, these graph bounds plus P1/P2 give, for every two-query phase-kickback quantum circuit on the **actual indexed intensity-response oracle**, a deterministic, nonadaptive classical algorithm approximating its **acceptance probability** on all but a δ fraction of uniform restricted signals, using

    Q_intensity ≤ min{|E|,ceil[2(2√F_{4,Δ}+145√max{2(Δ+1),6})²/(ε²δ)]}.   (P4, CONDITIONAL)

This would be independent of n for fixed Δ, ε, δ, although **global phase-retrieval reconstruction needs exactly n−1 intensity readings** by P3 and raw Wyner information grows as n. The constant is astronomically loose; for finite n the bound may be just the trivial |E|-read fallback. This would be a genuine cross-workstream **conditional simulation/reconstruction structural separation**, not a quantum state simulator and not a standalone confirmed breakthrough.

P4 applies to quantum circuits whose secret dependence is obtained by the **phase kickback interface** P2. It does not assert arbitrary quantum intensity-response algorithms can be reduced to identical-count phase circuits, nor does it handle arbitrary real signals, unknown magnitudes, noisy intensities or arbitrary cross-block sensors.

## 5. Validity/robustness boundary and certification plan

**Exactness:** on unit signals y∈{0,2/n}; source-independent additive intensity errors of magnitude <1/n preserve the sign after nearest-level thresholding, but a fixed positive measurement noise independent of n does not. No dimension-uniform robustness is claimed. On unnormalized coordinates σ_v=±1, the intensity levels become {0,2} with unit rows but the signal radius grows √n. Do not mix these radius conventions.

**New proof obligations:** (a) Lean formalize (P1), the exact bit-response oracle and (P2) quantum phase kickback with actual finite indices and arbitrary ancilla; (b) certify spanning-tree reconstruction plus the optimal binary transcript count (P3) against the exact allowed sensor family; (c) independently prove or refute the complex Hilbert T2 energy/cancellation theorem in #1068 before importing (P4); (d) reconcile a standard coherent intensity response register with the matrix-oracle semantics in historical #974; (e) dated prior art comparing graph-related quantum queries and phase retrieval with precise oracle/measurement models. Publication or priority claims require human sign-off.

**Cheapest decisive experiment:** `scripts/check_graph_intensity_quantum_bridge_exact.py` tests n=3 and n=4 graph intensities using exact integer/rational arithmetic and explicitly constructs indexed response XOR matrices plus |−⟩, checks phase kickback for every assignment/superposition at one query, and a negative control with the wrong response-state |+⟩. Such finite tests do **not** prove P4 or an all-T physical compiler.

**Parallel-work reconciliation:** [PR #1095](https://github.com/d3lefts/d3lefts/pull/1095) has already independently constructed an unnormalized ±1 graph-intensity compiler and a stronger exact graph-bridge Wyner information theorem C_W=(n−1−b)ln2. This note is complementary: it uses **unit-sphere signals and unit sensing rows**, supplies the **one-coherent-response-call phase-kickback model**, and combines it with the *bounded-degree all-k primitive-fiber* theorem, conditional on the still-open general T2 operator bound. Neither note should claim first discovery of graph-intensity/parity arithmetic.\n\n**References/credit:** standard phase kickback, elementary graphic incidence and real frame intensity identities; NIGHTFALL #995 (different continuous model), #970/#976 (Route1 information), #974 (archived matrix oracle), #1016/#1059/#1068 (rank-free T2 source and audit). No novelty claim for phase kickback or graph spanning-tree inversion.
