# Linear-code Wyner identity and graph-cut phase-retrieval compiler

**NIGHTFALL exploratory theorem candidate, 2026-11-22, v1.0.** This is a new *derivation in this research session*, not a verified worldwide-novel theorem. A symbolic all-dimensional paper proof is below. Independent exact finite checks and a source-locked CI exist separately. No all-n Lean terminal, external mathematical referee or same-scope priority clearance. This generalizes the merged #1087 and parallel #1084 eight-state 3-versus-4 example. Its principal ingredients (rectangular supports, elementary finite-field linear algebra, graph cut/cycle spaces, and quantum polynomial method) have established prior art.

## 1. Precise linear/affine-code information theorem

Let q be a prime power, \(\mathbb F_q\) its finite field, \(L\le\mathbb F_q^m\) a linear subspace of dimension d, and \(a\in\mathbb F_q^m\). Let \(Y\) be **uniform** on the affine code \(a+L\). We take the **m individual scalar coordinates** \(Y_1,\ldots,Y_m\) as the product coordinates for multivariate Wyner information
\[
C_W(Y)=\inf_{W:\,Y_1,\ldots,Y_m\text{ independent}\mid W} I(Y;W).
\]
For the unit coordinate vectors \(e_j\), define the set of *free axes*
\[
J=\{j\in[m]:e_j\in L\},\qquad r=|J|.
\]

**Theorem A (exact affine-code multivariate Wyner identity, proved on paper):**
\[
\boxed{C_W(Y)=(d-r)\log_2 q\ \text{bits}=(d-r)\ln q\ \text{nats}.}
\]
This also holds for an arbitrary measurable latent W **provided the conditional-product kernels exist**; the proof does not assume W finite.

**Proof — lower bound.** Fix any candidate latent W. Since the unconditional distribution is supported on a+L, almost every conditional law is supported on a+L. For such w, let its conditional law be \(\bigotimes_j p_{j,w}\). If for a coordinate i∉J there were two different values with positive mass in the i-th conditional marginal, the Cartesian support would contain two points of a+L differing only at i. Their difference is nonzero \(\lambda e_i\in L\), hence \(e_i\in L\), contradiction. Thus every i∉J is a deterministic function of W, and
\[
I(Y;W)\ge I(Y_{J^c};W)=H(Y_{J^c}).
\]
The projection of L to J^c has kernel exactly the span of \(\{e_j:j\in J\}\), dimension r. So \(Y_{J^c}\) is uniform on an affine space of dimension d−r, with entropy \((d-r)\log_2q\).

**Proof — matching upper bound.** Set W=Y_{J^c}. For each W value, the fiber \(\{y\in a+L:y_{J^c}=W\}\) is an affine coset of \(\operatorname{span}\{e_j:j\in J\}\). Since Y is uniform, the conditional distribution consists of independent **uniform** coordinates \(Y_j\) for j∈J, together with fixed coordinates for j∉J. It is a coordinate-product distribution, and \(I(Y;W)=H(W)=(d-r)\log_2q\). QED.

**General consequence:** For a uniform linear code with minimum Hamming distance at least 2, r=0, so \(C_W(Y)=H(Y)=d\log_2q\). However the theorem also handles arbitrary single-coordinate freedoms and quantifies the exact decrease: each freely variable code coordinate contributes one full q-ary symbol of independent entropy and removes \(\log_2q\) bits from the Wyner budget. This is an *exact invariant*, not a merely upper or lower bound.

### A model-sharp discontinuity

For a connected tree on n vertices, its n−1 edge-parity readings are independent, \(C_W=0\). Add one new edge joining the endpoints of a path that includes every tree edge, creating the cycle C_n. Now the n readings have exactly one XOR constraint, **and \(C_W=n-1\) bits**. The zero-error reconstruction cost stays n−1 queries. One redundant parity/intensity coordinate causes a \(\Theta(n)\) jump in *raw-coordinate* common information without increasing the optimal decoding cost.

This is **not** a contradiction to Wyner's definition or a new lower bound on computation: adding coordinates changes the product partition. It is a structural warning against treating raw C_W as an invariant operational query-complexity parameter.

## 2. A real phase-retrieval realization with graph sensors

Let \(G=(V,E)\) be a finite *connected* simple undirected graph on n≥3 vertices, with m edges, and let b denote its number of bridges. Fix an anchor vertex \(v_0\) and choose independent uniform signs \(x_v\in\{\pm1\}\) for \(v\ne v_0\), setting \(x_{v_0}=1\). Equivalently, choose a uniformly random signal class \(x\sim-x\) in \(\{\pm1\}^n/\{\pm1\}\).

For each edge \(e=\{u,v\}\), the **actual physical squared-linear sensor** is
\[
a_e=e_u+e_v,\quad Y_e=|\langle a_e,x\rangle|^2=(x_u+x_v)^2\in\{0,4\}.
\]
Writing \(t_e=1_{\{x_u\ne x_v\}}\in\mathbb F_2\), the intensity is \(Y_e=4(1-t_e)\). The edge-bit vector \(t\) is the graph's binary cut/coboundary code \(L_G=\operatorname{im}(\partial^\top:\mathbb F_2^V\to\mathbb F_2^E)\). Because G is connected, \(\dim L_G=n-1\), so the m raw readings have entropy n−1 bits.

**Theorem B (graph-bridge common-information identity, exact paper proof):**
\[
\boxed{C_W((Y_e)_{e\in E})=(n-1-b)\ \text{bits}.}
\]
More generally for a possibly disconnected graph with c connected components, \(C_W=(n-c-b)\) bits under independent vertex signs/gauge classes in each component.

**Proof.** The coordinate unit vector \(1_{\{e\}}\in\mathbb F_2^E\) belongs to the cut code precisely when deleting edge e disconnects its component: a cut consisting of a single edge is exactly a bridge. Thus the free axes of L_G are the b bridge-edge coordinates. Apply Theorem A with q=2, d=n−1 (or n−c) and r=b. QED.

**Special cases:**
- Tree: m=n−1, b=n−1, so C_W=0.
- Cycle C_n: m=n, b=0, so C_W=n−1 bits.
- Complete graph K_n, n≥3: m=n(n−1)/2, b=0, so C_W=n−1 bits.
- A triangle and a leaf attached by one bridge: n=4, m=4, b=1, so C_W=2 bits.

**Theorem C (exact allowed-query decoding cost):** An arbitrary fixed spanning tree \(T\subseteq E\) of a connected graph lets us reconstruct the entire sign class x from exactly n−1 available edge-intensity queries. Starting at anchor \(x_{v_0}=1\), traverse tree edges and recover each adjacent sign from \(t_{uv}\). No deterministic zero-error **adaptive** algorithm querying only the listed binary edge intensities can have worst-case depth <n−1: there are 2^(n−1) possible equally likely classes and each sensor answer has at most 2 possibilities, so a depth-q decision tree has at most 2^q answer leaves. Thus the optimal cost is n−1. This lower bound does not hold if arbitrary newly selected real sensing vectors are allowed: a generic row can separate any fixed finite codebook in one query.

**Genuine growing fetch-cost separation:** On K_n, a trivial full-tuple fetch reads m=n(n−1)/2 distinct sensors, but the exact spanning-tree decoder needs only n−1, a factor of n/2. Unlike padding a code with exact duplicate sensors, all K_n sensors are distinct nonzero quadratic measurements; the comparison is still a *compiler-cost comparison*, **not** a lower bound that any algorithm needs all m sensors.

## 3. Route 1 application with B independent graph-phase blocks

Let \(x^{(1)},\ldots,x^{(B)}\) be independent copies of the above uniform sign class, each represented as one virtual alphabet symbol in a set of size \(2^{n-1}\). Each of the B physical blocks has m independently addressable *within-block* graph-intensity sensors.

Across **all mB separately addressable raw sensors**, the distribution has
\[
C_W(Y_{\mathrm{raw}})=B(n-1-b)\text{ bits},
\]
because the direct product of B affine binary codes is an affine code with dimension B(n−1) and exactly Bb free axes.

Across **B independent virtual hidden blocks**,
\[
C_W(x^{(1)},\ldots,x^{(B)})=0.
\]

For a real-valued bounded \(f\) with block interaction degree at most d, the existing kernel-checked Route 1 #970 product-source simulator gives a decision tree reading at most \(N(d,\varepsilon,\delta)=\operatorname{poly}(d,\varepsilon^{-1},\delta^{-1})\) block symbols, independently of B and their alphabet size. Compose each requested block-symbol access with the n−1-edge spanning-tree decoder:
\[
\boxed{Q_{\mathrm{raw}}\le(n-1)\,N(d,\varepsilon,\delta),}
\]
where every actual intensity query is counted. For a well-formed finite T-query circuit whose *each* oracle call depends on only **one block sign class** and is invariant under its global sign, the acceptance probability has block degree ≤2T by the standard polynomial method. Hence use d=max(1,2T), yielding O(n·poly(T,1/ε,1/δ)) **classical intensity queries, independent of B**. These are distributional acceptance-value estimates, not quantum state sampling, coherent quantum oracle substitution or efficient classical runtime.

This full phase/quantum/Route1 composition is still **paper-level**; the new general all-n affine-code and graph Wyner identities are not Lean certified. The exact finite eight-state decoder is already kernel checked in merged #1087; #1084 independently works on its own finite model.

## 4. Independent checker, prior art, and decisive continuation

Separate executable check: \`scripts/check_graph_phase_wyner_exact.py\`. It independently enumerates all 1,098 simple undirected graphs on n=2,3,4,5 vertices, uses actual signed-intensity readings, counts cut-space dimension and one-edge directions, and separately uses graph connectivity after deleting each edge. It checks exact r=b and d=n−c in all cases. It also exhausts every binary linear subspace of \(\mathbb F_2^m\) for m≤4, checking dimension, projection fibers and the free-axis factorization. **Finite checks do not prove all-n Wyner or the Route 1 compiler.**

Closest sources to compare further: Wyner (1975); multivariate common information literature; support-rectangle criterion of Bruno–Vaccaro (arXiv:2610.15402, October 2026); classic cut/cycle codes; Beals–Buhrman–Cleve–Mosca–de Wolf on quantum query polynomials; and merged NIGHTFALL #970/#976 and #1087. The elementary *no-one-coordinate support edge* mechanism is already present in NIGHTFALL #987; this note derives its exact **linear-code free-axis formula** and **physical graph bridge specialization**. No exact worldwide antecedent to this entire packaged statement was identified in a narrow search, **not** sufficient to claim novelty.

**Independent audit assignment (before author proof):** formalize the exact coordinate-product conditionality claim for an arbitrary latent kernel, seek a counterexample with an affine coset and free axes or nonuniform weights, prove bridge/one-edge equivalence without citing this note, and independently verify the costed spanning-tree decoder on disconnected/zero-bridge edge cases. Run an independent same-scope prior-art search before categorizing a contribution. A perfect checker or short proof is not automatic priority.

**Most valuable transfer question:** can the same free-axis identity be extended to nonuniform distributions on linear codes, to noisy graph-intensity sources, or to correlated blocks with an **operationally costed** representation complexity? The uniform linear identity does not automatically survive nonuniform source weights; begin with explicit two-cycle counterexamples or proofs. Any claim of an improvement over classical optimal query depth requires a *matching lower bound for the same target and oracle*, not just comparison to the original raw Wyner upper bound.

**Status / certification:** Theorems A–C have explicit algebraic paper proofs; finite independent exact checks are regressions; B-independent Route 1 composition is a paper consequence with an existing certified black box; complete Lean and historical priority are open. Preserve all competing claims and failure receipts. Do not merge or submit without further review.
