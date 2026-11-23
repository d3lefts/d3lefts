# Operational information–cost synthesis: expected-query dequantization and coherent graph compilation

**2026-11-23; candidate v0.1; paper derivation, NOT a Lean certificate or priority-cleared theorem.**
Dependencies: NIGHTFALL source-checked `Nightfall.Route1Polylog.route1_wyner_general`; paper query-local transfer `ROUTE1_QUERY_LOCAL_WYNER_TRANSFER_20261122.md`; graph-cut code/Wyner identity `GRAPH_CUT_PHASE_WYNER_IDENTITY_20261122.md`. External inspiration: Google DeepMind/Google Quantum AI, *Discovering formally verified quantum programs with AI*, arXiv:2611.09822v3 (expected-cost semantics, externally frozen comparison). Do not attribute the present theorem to Google.

## Exact theorem candidate

Fix finite input alphabet and coordinate sets I,J, distribution μ on latent Z∈A^J, deterministic encoding Φ:A^J→A^I, and observed law ν with TV(ν,Φ_*μ)≤ζ. Each Φ_i depends on at most b latent coordinates; each latent Z_j is recoverable on supp μ by an original-observed-coordinate deterministic tree of worst depth r. All costs below are counts of **one original coordinate oracle invocation**; r≥1 and b≥1.

Let a finite-description quantum instrument with classical control and potentially unbounded measurement-driven looping act on the *standard coherent original-coordinate XOR/phase oracle*, with finite output acceptance probability p(x)∈[0,1]. Its execution terminates almost surely for each input in supp ν. Let N(x,ω) be its number of sequential oracle invocations. Assume E_{X∼ν,ω}N≤q<∞. Non-oracle gates, computation and tree-construction time are NOT charged. Postselection with conditioning on a rare success event, variable uncharged batch queries, arbitrary real intensity detectors, and a quantum oracle that returns the full correlated table are excluded.

For ε>0, δ>ζ, choose K≥max(1,ceil(4q/[ε(δ−ζ)])). Truncate after K calls, assigning rejection to truncated runs, and let p_K(x) denote the truncated acceptance probability. Markov's inequality gives
E_ν |p-p_K| ≤ q/K ≤ ε(δ−ζ)/4,
hence ν{|p-p_K|>ε/2} ≤ (δ−ζ)/2.
For the bounded-query program, the standard polynomial method gives degree(p_K)≤2K in input-coordinate indicators. Under Φ, g=p_K∘Φ has degree D≤max(1,2bK). Its range is [0,1].

Choose τ∈(0,1] with τ/(ε/2)^2 < (δ−ζ)/2, and choose s>C_W(μ). Let A_D(τ),B_D(τ) denote the **exact** constants in `route1_wyner_general`. For integer m≥1 satisfying
  [A_D(τ)+s B_D(τ)]/m + τ/(ε/2)^2 ≤ (δ−ζ)/2,
the Route 1 theorem produces a latent tree t of worst depth m whose error against g exceeds ε/2 with μ-probability at most (δ−ζ)/2. Replace each latent request by its exact original-oracle recovery tree. On the latent support the resulting original-coordinate tree T has depth ≤rm and agrees with t after encoding. Total-variation transfer adds ζ to the failure bound. Union bound yields

  Pr_{X∼ν}(|p(X)−T(X)|>ε) ≤ δ,    depth(T)≤rm.

**Important qualification:** For the polynomial method with measurement-based unbounded loops, a bounded-K truncation must be a genuine *input-independent quantum-instrument description with K coherent oracle slots*; the classical control may branch, but no x-dependent free oracle access or postselection is permitted. The exact expected-cost premise is averaged over ν; no per-input expected cost is required. A finite-alphabet tagged encoding may be used for heterogeneous coordinates, subject to a separately checked type-level bridge.

## Graph phase / coherent query compiler

For connected graph G=(V,E), n=|V|, choose root 0 and hidden vertex bits z∈{0,1}^{n−1}, z_0=0. Edge parity is t_{uv}=z_u XOR z_v. A standard edge oracle acts by
  O_E |u,v,y⟩ = |u,v,y XOR t_{uv}⟩.
A root-star oracle acts by
  O_S |v,y⟩ = |v,y XOR z_v⟩, with z_0=0.

Two root-star invocations implement O_E **coherently** by controlled-XORing z_u and z_v into the same target y. Since the operation is an exact basis permutation with the same action on each basis state, it agrees as a unitary on all superpositions, including entanglement with arbitrary reference systems. One root-star invocation is an allowed edge invocation on {0,v}; therefore Q_E≤Q_S≤2Q_E for any task with identical free gates and compatible coherent query access. For the phase-oracle convention the two root phases multiply to the edge phase.

For the actual real sign signals x_v=(-1)^{z_v}, the physical intensity is |x_u+x_v|²=4(1−t_{uv}). This equality transfers *classical reading values*, NOT coherent quantum oracle access. The latter requires a separate physical construction, reversible encoding, measurement-noise and query-cost proof. For independent blocks, the original raw-edge Wyner information is B(n−1−bridges(G)) bits, whereas the independent root-bit representation has zero Wyner common information. In a complete graph, it is B(n−1) vs zero while coherent query translation costs at most 2. This is a **representation separation**, not a quantum speedup or an unconditional dequantization theorem for physical intensities.

## Adversarial audit designed before promotion

1. **Quantum polynomial truncation:** derive the 2K-degree statement for a finite classical-control instrument with intermediate measurement, looping, and early stopping; challenge any x-dependent postselection normalization. Construct a counterexample if arbitrary free classical advice is allowed.
2. **Distribution and constants:** independently check Markov on ν, the TV transfer, choice of τ and m, the epsilon/2 union, and the q=0 edge case. Check the source theorem's exact degree definition and all finite-alphabet hypotheses.
3. **Oracle semantics:** prove a typed unitary equality O_E = O_S(u) O_S(v), with root handling and query-register coherency. Separately prove whether an actual squared-intensity device can realize the required coherent oracle, or mark it **not established**.
4. **Lower-bound ambition:** seek an adaptive coherent quantum analogue of the group-information-cover KL dual. Classical transcript KL and Bayes posterior factorization DO NOT automatically extend to coherent quantum queries; avoid asserting a matching lower bound.
5. **Priority:** compare exact-scope theorem to Aaronson–Ambainis influence/simulation, Turturean 2026, query compression, quantum expected-query complexity, and distributional polynomial method. Novelty remains **unverified**.

## Cheapest decisive experiment and stopping rule

Compile a finite quantum instrument with one measurement-conditioned loop and a coherent edge oracle. Prove exact output and expected/worst cost semantics under pinned Lean; formalize the finite polynomial bound and exact star-oracle unitary equivalence; then instantiate the already-compiled Route 1 theorem. Reject the general theorem if any oracle call is silently omitted, if the truncated instrument is not a degree-≤2K polynomial, or if the latent pullback fails to preserve degree. No publication or status promotion before independent adversarial review and dated prior-art audit.

## Reproducible finite check

`python3 research/nightfall/operational_information_cost/check_graph_coherent_oracle.py` exhaustively checks the edge XOR oracle against two star XOR operations on basis states for n=2,…,9, and includes planted one-star-query failures. This is **finite evidence only**, not a Lean kernel certificate.
