# Priority audit — distribution-uniform quantum-query simulation
Date: 2026-11-18 (Eastern). Status: AUTHOR-SIDE PREPRINT PRIORITY CHECK, NOT INDEPENDENT REVIEW.

## Exact headline under review

At commit [771d11af21896aa83f481b332d21d7d706b56927](https://github.com/d3lefts/d3lefts/commit/771d11af21896aa83f481b332d21d7d706b56927), the source theorem Nightfall.ProductSpace.Simulation.simulation_degree states that any [0,1]-bounded degree-d real function (d>=1) on any finite coordinate product, with an arbitrary finite product law (zeros allowed), has a deterministic query tree of depth <= n with probability of error > epsilon at most delta whenever

    n * epsilon^3 * delta^2 * sqrt(delta) >= 6 sqrt(2) pi^6 d^6.

The paper-level quantum corollary substitutes d=2T to give ceil(384 sqrt(2) pi^6 T^6 epsilon^-3 delta^-5/2) queries for a T-query acceptance-probability function. There is NO Lean theorem about quantum unitary circuits yet. The degree <= 2T argument and heterogeneous-alphabet padding are paper proofs, not part of simulation_degree. This is query, not time, complexity; the classical deterministic tree may depend on the full function and law.

## External priority sources reviewed on 2026-11-18

1. Girish, Mittal, Nehoran, Raz, Distributional Variants of the Aaronson-Ambainis Conjecture, arXiv:2609.35327 (2026-09-28), https://arxiv.org/abs/2609.35327. Theorem 3.3 and Theorem 4.14 cover fixed-bias binary products and slices. Remark 3.4 says overhead polynomial in reciprocal bias; Remark 3.5 covers differing coordinate biases only when bounded below by a common a>0. Does not explicitly establish law-uniform overhead for vanishing heterogeneous biases or nonbinary symbols.

2. Huffstutler, Miloschewsky, Podder, A short proof ... via the completion framework, arXiv:2611.12795 (2026-11-09), https://arxiv.org/abs/2611.12795. Theorem 2 gives O(Q(f)^6/(epsilon delta)^2) for partial Boolean functions on uniform Boolean cube, a DIFFERENT output task. Lemma 3's swap symmetry can plausibly be replaced by exchangeable heat-bath resampling. Lemma 4 counts vertices, flips, subcubes and opposite pairs via a determinant identity; replacing counts by product masses is nontrivial. Whether a weighted extension gives the proposed law-uniform corollary, perhaps with better exponents, remains HIGH PRIORITY RISK. The text does not state this extension, but absence from its text does not establish novelty.

3. Escudero Gutierrez, Saucedo, Palazuelos, Optimal inequalities for completely bounded polynomials and the limitations of quantum query algorithms, arXiv:2609.05201 (2026-09-04), https://arxiv.org/abs/2609.05201. Corollary 1.8 is a randomized nonadaptive simulation for a special class of nonadaptive quantum algorithms with r accepted measurement outcomes; not a result for all adaptive T-query algorithms over all product laws.

4. Liu and Mutreja, Parallel Quantum Advantage with Limited Adaptivity Requires Structure, arXiv:2608.20297v2 (2026-10-20), https://arxiv.org/abs/2608.20297. The stated simulation is restricted to parallel/constant-round queries and uses uniform-oracle/dense-distribution coupling.

5. Turturean, A proof of the Aaronson-Ambainis conjecture, arXiv:2611.09773 (2026-11-06), https://arxiv.org/abs/2611.09773. Original credited foundation for row and influence arguments on uniform Boolean inputs. NIGHTFALL's product-space proof reuses vendored Turturean lemmas; do not present as independent AA proof.

6. Blanc, Docter, Strassle and Tan, Proof of the Aaronson-Ambainis Conjecture: An Exposition, arXiv:2611.11626 (November 2026), https://arxiv.org/abs/2611.11626. Secondary exposition of the Boolean result, not found to state a general product-law theorem.

Searches included papers citing GMNR since September, weighted products, sparse biases and nonbinary quantum-query simulation. No explicit already-published statement with the same scope was found in this scan. This is NOT proof of novelty; unpublished and recently indexed references may be missed. Novelty verdict: provisionally plausible; not cleared.

## Author-side structural and arithmetic audit

Source-exact declarations and provenance:
- product_space/ProductRowBound.lean: RowBound.Pv, RowBound.Gsel, RowBound.product_block_inequality, RowBound.product_row_bound (pointwise row cost pi^2 d^2 for [-1,1]-bounded function); selector handles competing symbol proposals.
- product_space/ProductInfluence.lean: Influence.mean_increment gives Var(g)^3 <= 144 K^4 (max_j L_j(g))^2, where L_j is mean absolute one-coordinate resampling increment.
- product_space/ProductSimulation.lean: Simulation.hasRows_of_degree sets K=pi^2 d^2/2 for [0,1]-valued f; Simulation.hasRows_sect; Simulation.sum_mul_Ltot_sect establishes expected total-increment decrement exactly L_j; Simulation.expected_queries proves eta E[queries] <= K; Simulation.leaf_error and Simulation.simulation_rows give error <= K/(eta*n)+tau/epsilon^2; Simulation.simulation_degree chooses tau=epsilon^2 delta/2 and eta=tau^(3/2)/(12K^2).
- Independently re-expanded the prefactor: K/(eta*n)=3 sqrt(2) pi^6 d^6/(n epsilon^3 delta^(3/2)), which is <= delta/2 under the stated inequality. This is an author-side symbolic check, not an independent kernel proof.
- universal/InfinitePiAAProductTerminal.lean: InfinitePiAAProductTerminal.infinitePi_aa_product is an arbitrary-index L2 influence bound, NOT a simulation theorem on an infinite input product.
- product_space/CubePrintedAA.lean: CubeAA.printedConjecture specializes the product result to the fair cube; it reuses credited upstream analytic dependencies.

## Freeze / certificates

Review target HEAD: 771d11af21896aa83f481b332d21d7d706b56927.
ProductSimulation.lean blob SHA-1: 20bd62a563266bebd59e84440567cf1a9090020e.
Closure: 178 modules in research/nightfall/formalization/aa_product/CLOSURE.txt.
Pin: Lean 4.36.0-rc2, Mathlib 9d581dfff2e41de989072ea63abf3daf69311520.
Exact-head workflow: https://github.com/d3lefts/d3lefts/actions/runs/44433153026 — RUNNING at time of audit, NO claim of passing the source theorem until strict named-declaration audit and receipt upload complete.
Earlier 203-module integrated Lake run 44413969643 passed on 0dbffc9, WITHOUT the new ProductSimulation module. It is not a substitute for the new simulator certificate.

## Cheapest decisive experiments and posting gate

A. Have an expert independently test a product-weighted analogue of HMP Lemma 4, first binary with wildly differing biases, then k-ary. Require an explicit proof or a counterexample to a precisely formulated weighted candidate. Failure to find a proof is not nonexistence.
B. Have a separate expert audit competing-symbol selector (positivity, normalization, degree, endpoint), row duality, mean-increment lemma, section invariance, worst-case depth and zero masses. Independent expert review has NOT been obtained.
C. Independently check the quantum amplitude-to-indicator-monomial degree <=2T bridge for heterogeneous alphabets and its padding argument.
D. Obtain source-hashed passing exact-head Lean receipts and author/contributor permission for preprint posting.

Stop rule: If an earlier paper subsumes the law-uniform claim, demote originality and reposition around the product selector and kernel-verified formalization. DO NOT POST until all gates and human publication approval. No unreviewed author-side audit should be represented as referee verification.
