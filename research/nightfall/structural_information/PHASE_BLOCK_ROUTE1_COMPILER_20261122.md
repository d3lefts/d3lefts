# Recover-then-simulate: real phase retrieval as a Route 1 information compiler

**NIGHTFALL research checkpoint · 2026-11-22 · v1.0**

**Status:** finite decoder and its sharp 3-read query cost verified by two exact finite methods; exact Wyner support theorem proved on paper; general scalar quantum acceptance / Route 1 composition has a complete paper derivation *conditional on the explicitly specified block-local oracle*, not a named Lean end-to-end certificate. The mechanism is useful but global novelty is **OPEN**. Do not claim a quantum *runtime* bound, all-oracle theorem, or signs/relative phases inferred from intensities.

**Repository dependencies:** merged Lean-certified Route 1 [#970](https://github.com/d3lefts/d3lefts/pull/970), arbitrary Wyner latent bridge [#976](https://github.com/d3lefts/d3lefts/pull/976), and separated scalar risk conservation [#1065](https://github.com/d3lefts/d3lefts/pull/1065). Not a continuation or claimed proof of the universal continuous causal phase-retrieval topology obstruction [#995](https://github.com/d3lefts/d3lefts/pull/995).

## 1. Abstract exact information and query theorem

Let \(S_1,\ldots,S_B\) be i.i.d. uniform symbols in an alphabet \(\mathcal S\) of size \(M\). An injective local code \(e:\mathcal S\to\prod_{j=1}^m\mathcal Y_j\) gives *separately queryable* raw coordinates \(Y_{b,j}=e_j(S_b)\). Suppose:

1. The distinct codewords have Hamming distance at least **2** (no two differ in exactly one sensor coordinate).
2. There is a chosen set of \(r\) sensors (or a depth-\(r\) deterministic local decoder) which recovers \(S_b\) exactly from its \(r\) intensity queries.
3. A target oracle uses **only** these raw symbols and is block-local: in a fixed computational basis each entry of its address-controlled oracle query unitary is a function of at most one \(S_b\); inter-query unitaries and the final measurement effect are input independent.

**Theorem (source encoding / bounded-degree query transfer).**

(a) With the **individual sensor readings** as the original coordinates, any Wyner latent W making all \(mB\) raw coordinates conditionally independent satisfies \(I(W;Y) = H(Y) = B\log_2M\) bits. Therefore \(C_W(Y)= B\log_2M\) bits (or \(B\ln M\) nats). With the **decoded block variables** as coordinates, \(C_W(S_1,\ldots,S_B)=0\).

(b) For any fixed \(T\)-query finite-dimensional quantum circuit in the oracle model of (3), its scalar acceptance probability \(f:\mathcal S^B\to[0,1]\) has *interaction degree* at most \(2T\) with respect to the block variables (if \(T=0\), use degree bound 1). Thus merged Route 1 on the independent source produces a **deterministic adaptive classical tree** using \(q=\operatorname{poly}(T,\varepsilon^{-1},\delta^{-1})\) *decoded-block* queries, independent of B, that approximates the circuit's acceptance probability to \(\varepsilon\) outside a \(\delta\) fraction of i.i.d. draws. Compiling each block read back to physical sensors costs at most \(r q\) original intensity queries. The polynomial and constants are exactly those of Route 1; no new constant is invented here. Classical offline construction/computation may depend severely on B.

**Proof (a).** Let \(C=e(\mathcal S)^B\) be the valid full raw-table support. The no-Hamming-edge property survives Cartesian products of independent blocks. Let \(R\subseteq C\) be the support of any conditional product distribution \(\bigotimes_{b,j}p_{b,j}\). If \(u\ne v\) lie in R, choose a coordinate where they differ. Rectangularity of product support forces the one-coordinate hybrid to lie in R, but this hybrid differs from u in **exactly one** coordinate, contradicting the code distance. Hence R is a singleton. For arbitrary W, the product conditional law is therefore a point mass almost everywhere: \(H(Y\mid W)=0\) and \(I(Y;W)=H(Y)\). The identity latent W=Y attains this cost. The map \(S\mapsto Y\) is injective, hence uniform entropy \(B\log_2M\). The decoded S coordinates are independent, so a constant W makes them conditionally independent and has I=0. QED.

**Proof (b).** Initially every amplitude of a fixed input-independent state has block interaction degree 0. Every entry of one block-local oracle query has degree at most 1; multiplication of finite sums of local functions adds degree budgets, and finite summation preserves the maximum degree. Input-independent unitaries preserve degree. Therefore after T oracle calls every final amplitude has interaction degree at most T. The acceptance probability \(\langle\psi(S),E\psi(S)\rangle\), for a fixed effect \(0\le E\le I\), is a finite sum of products of a degree-T amplitude and its complex conjugate, so its real-valued interaction degree is at most 2T. It is bounded in [0,1]. Apply the *actual* finite-product Route 1 theorem to the independent block alphabet. Implement the resulting **classical** block reads by local exact decoding, paying r sensor queries each. QED.

This polynomial-method lemma is classical: see Beals–Buhrman–Cleve–Mosca–de Wolf (1998/2001), [arXiv:quant-ph/9802049](https://arxiv.org/abs/quant-ph/9802049), and the Boolean-function literature. The product-support rectangle obstruction is elementary; compare the 2026 study of Wyner common information and finite support rectangles, [arXiv:2610.15402](https://arxiv.org/abs/2610.15402). No priority is claimed for those ingredients.

## 2. Concrete sharp eight-state **real 2D** block

Four sensing vectors
\[
a_0=(1,0),\quad a_1=(0,1),\quad a_2=(1,1),\quad a_3=(1,-1).
\]
Eight sign-inequivalent real signals, each uniformly likely:

| s | representative x_s | (|a0·x|², |a1·x|², |a2·x|², |a3·x|²) |
|:--:|:--:|:--:|
| 0 | (0,1) | (0,1,1,1) |
| 1 | (1,-2) | (1,4,1,9) |
| 2 | (1,0) | (1,0,1,1) |
| 3 | (1,2) | (1,4,9,1) |
| 4 | (3,-2) | (9,4,1,25) |
| 5 | (3,2) | (9,4,25,1) |
| 6 | (2,1) | (4,1,9,1) |
| 7 | (2,3) | (4,9,25,1) |

**Three readings are universally sufficient, not only on the eight states.** In the quadratic-feature coordinates \((x_1^2, 2x_1x_2,x_2^2)\), the sensing rows are \((a_{j1}^2,a_{j1}a_{j2},a_{j2}^2)\). Their four 3-by-3 minors for omitted sensors j=3,2,1,0 respectively are \(-1,1,2,-2\), all nonzero. Thus any three readings recover \(xx^\top\), which uniquely determines \(x\) up to sign.

**No adaptive two-reading exact decoder can succeed on all eight states.** For each possible first sensor \(j\), the following is a *possible first outcome* for which each subsequent sensor leaves at least two distinct candidate states indistinguishable. Values and first-branch states are exact:

| first sensor j | first output | states surviving | one ambiguous pair for second sensors 0,1,2,3 |
|:--:|:--:|:--|:--|
| 0 | 1 | 1,2,3 | (1,2); (1,3); (1,2); (2,3) |
| 1 | 4 | 1,3,4,5 | (1,3); (1,3); (1,4); (3,5) |
| 2 | 1 | 0,1,2,4 | (1,2); (1,4); (0,1); (0,2) |
| 3 | 1 | 0,2,3,5,6,7 | (2,3); (0,6); (0,2); (0,2) |

In particular, the obstruction survives adaptivity of the second query to the first reading, and the first six signals already force a 3-read worst-case cost. The appended signals 6 and 7 yield exactly 8 uniform codewords and 3 bits of entropy. Every three-subset decodes, so the optimal zero-error worst-case sensor depth is **exactly 3**.

**Finite bounded noise corollary.** All 32 displayed intensity entries are integers. If each of three selected reading values is perturbed by additive error with magnitude strictly less than \(1/2\), integer rounding followed by the same exact decoder recovers the state. This does *not* address stochastic or adversarial errors of arbitrary size and does not extend to the full continuous signal class.

**Independent checker:** `scripts/check_phase_block_route1_exact.py` (stdlib only) calculates all readings from integer inner products, independently verifies all four quadratic-feature determinants, checks every three-read projection, proves each adaptive-two decision-tree first-branch obstruction, replays the minimum-depth Bellman recursion, and checks Hamming separation in B=1 and B=2 tables. This is an exact **finite** mathematical certificate; it does not machine-check the abstract quantum theorem or optimize over alternate sensing vectors.

## 3. What this proves and what it does **not**

- The raw four-intensity coordinates of this very simple phase-retrieval example have maximum possible \(C_W(Y)=H(Y)=3B\) bits. This is a mathematical consequence of a no-one-coordinate-neighbor support; it is **not** a general claim about arbitrary phase-retrieval distributions.
- After paying exactly 3 physical reads per *queried block*, the independent source can be accessed, so the Route 1 Wyner charge becomes **zero**, eliminating the B-linear information term from the upper bound for this model. This is **not** a universal lower bound showing a B-factor speedup against every algorithm using the original table.
- The oracle must be sign-invariant at the block level (equivalently: its matrix entries factor through the recorded intensities). A sign-sensitive oracle or cross-block relative-phase observable is not a function of the available raw data and cannot be simulated without an extra source of sign information or a separate model. For a raw **intensity** oracle this factorization is automatic; for an underlying amplitude oracle it is not.
- If oracle query entries jointly depend on r0 distinct blocks, replace degree \(2T\) by at most \(2r_0T\) if the dependency sets are known; one query with arbitrary global dependence cannot be treated as block-local.
- Fixed T, epsilon, delta are essential for B-independent **query bound**, not proof of polynomial-in-B classical preprocessing/runtime, coherent quantum-oracle emulation or approximate entire quantum state.
- Original Route 1 and the phase-retrieval 3-reading fact derive from existing theories; their **combination** as an explicit compiler is a paper-level contribution candidate awaiting independent mathematical and worldwide prior-art review.
- Neither Lean formalization of the quantum matrix-entry locality polynomial theorem nor a named kernel replay of the complete Route 1 composition has yet occurred. The checker is not promoted to a Lean proof.

## 4. Independent audit / decisive next formalization

1. **Finite proof kernel:** Lean-check the eight integer representatives, 4×4 exact sensor table, four 3-subset injections, the per-first-sensor adaptive-two witnesses, and the rectangle-support rigidity lemma.
2. **Quantum bridge kernel:** formalize a finite matrix of functions on blocks and prove the degree budget under matrix products and conjugate acceptance quadratic forms; explicitly instantiate the source as 8^B independent blocks.
3. **Route 1 terminal:** specialize #970's actual theorem to the product block law and compose a deterministic leaf query with a three-sensor exact decoder. Pin the final query budget to the source theorem's constants, do not guess numbers.
4. **Criticism:** test gauge-dependent oracle symbols and nonlocal query matrices as deliberate negative controls; review whether conditioning on all raw coordinates genuinely forces a product latent to be deterministic, including arbitrary latent spaces and zero-atom product components.
5. **Priority:** compare frame/complement-property literature, Beals et al. query-polynomial theory, and Wyner/Gács–Körner/support-rectangle prior art before any external "novel breakthrough" declaration.

**Stop rule:** promote finite decoder arithmetic only on exact replay; general theorem only with scoped paper proof; end-to-end Lean / novel flags only after named kernel terminal, independent analytic audit, and dated specialist priority review.
