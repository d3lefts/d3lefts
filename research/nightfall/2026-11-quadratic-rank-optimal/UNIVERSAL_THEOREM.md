# Theorem D — Rank-optimal quadratic observability on arbitrary independent product laws

**NIGHTFALL Constellation / Devin J. Wright — analytic theorem and independent audit v1.0 — 11 November 2026**

**Evidence level: analytical manuscript + exact finite falsification. The source scalar matching proof and its many-increment fourth moment are not yet composed into an end-to-end Lean theorem. Worldwide priority and non-author refereeing are not certified.**

## Statement and significance

Let (Ω_i, μ_i) for i in I be arbitrary independent probability spaces, including nonatomic, heterogeneous or arbitrarily skewed laws; I can be uncountable. Let F be a strongly measurable, real-Hilbert-valued observable with ||F||≤B almost surely and Hoeffding–Efron–Stein interaction degree ≤2. Let τ_r be the covariance spectral variance beyond the largest r output directions. Define

    D = 15(1+sqrt(3)),
    a_r = Gamma(r/2)/(sqrt(pi)*Gamma((r+1)/2)).

**Theorem D1 (rank-sensitive quadratic influence).** For every H-valued degree-two output G taking values in a real r-dimensional Hilbert space, define

    V = E||G-E G||²,
    I_i = E||G-E_i G||²,
    M = sup_i I_i.

Then

    V ≤ (D B/a_r) sqrt(M),  or  M ≥ a_r² V²/(D² B²).

In particular, because D<41 and a_r²≥1/(3r), the purely rational certificate inequality

    V² ≤ 5043 r B² M

holds for every such output, independent of input dimension, atom masses, alphabet sizes, or density of quadratic interactions.

**Theorem D2 (rank-optimal adaptive spectral prediction).** Given r≥1 and η>0, there exists a deterministic measurable adaptive whole-input-coordinate observation policy of hard query budget

    N ≤ ceil(4D² B²/(a_r² η)) ≤ ceil(20172 r B²/η)

whose full Hilbert conditional-mean prediction has risk ≤τ_r+η. The function and source product law are known; this is an existential observation guarantee, NOT a computational runtime claim. The statement also applies to complex Hilbert targets by realification, with output real rank at most twice the complex rank; this is not a physical quantum measurement protocol.

**Theorem D3 (sharp order and an unlimited fixed-query gap).** For all r,k≥1, independent fair signs Z_{jt} with 1≤j≤r, 1≤t≤k and

    F_{r,k} = (sum_t Z_{1t}, ..., sum_t Z_{rt})/(k sqrt(r))

have pointwise norm ≤1, interaction degree one, variance 1/k, and exact best risk 1/k − min(q,rk)/(rk²) after q adaptive coordinate queries. Attaining η=1/(2k) therefore needs at least q=rk/2=r/(4η) queries. The rank/accuracy dependence is optimal up to constants.

For a separate rank-one degree-two family, let K be uniform on [m], independent of fair signs Z_1,...,Z_m, and f(K,Z)=Z_K. Two adaptive queries recover f exactly. A fixed set of q leaves has Bayes MSE 1−q/m when K is also read, and 1−q/m² when K is not read. Thus for each fixed η in (0,1/2), every sufficiently large m requires at least 1+(1−η)m nonadaptive coordinate queries, despite adaptive exact depth 2. **No alphabet-independent finite nonadaptive cost exists** for the full quadratic class.

Unlike Paper B's all-degree O(r^(3/2) η^(−3/2) log(r/η)) guarantee and its special disjoint-output rank-linear result, Theorem D2 has both r-linear and η^(−1) scaling for **arbitrarily overlapping output dependencies** (degree two only).

## Complete analytic proof of D1: spherical transfer of the scalar matching mechanism

First work on a finite categorical full-support product and H=R^r. The canonical Hoeffding decomposition is

    G = m + sum_i h_i(X_i) + sum_{i<j} h_{ij}(X_i,X_j),

where each pair kernel has zero conditional mean in each of its two inputs. Define H_i=L²(μ_i;H). Orthogonality gives

    V = sum_i ||h_i||² + sum_{i<j} ||h_{ij}||²,
    I_i = ||h_i||² + sum_{j≠i} ||h_{ij}||².

**Spherical reverse trace.** Let u be uniform on the unit sphere of R^r, and let K be PSD. Orthogonal invariance gives E_u|<u,v>|=a_r||v|| for every vector v. If K has eigenvalues λ_j and trace s>0, then concavity of the square root gives

    sqrt(sum_j (λ_j/s) u_j²) ≥ sum_j (λ_j/s)|u_j|.

Averaging yields

    E_u sqrt(u^T K u) ≥ a_r sqrt(tr K).           (1)

This is the correct reverse inequality for lifting standard deviations; interchanging maximum coordinate and direction expectation would be invalid.

**Three scalar budgets.** Every real bounded degree-two g has the following properties (with genuine proof in the NIGHTFALL scalar matching audit, PR #362):

(a) For every matching P in its quadratic interaction graph, sum_{(i,j) in P} ||g_{ij}||_infty ≤ 4B. To see this, choose rectangles for every matched edge; global even/odd products of two-point couplings preserve all off-matching marginal distributions and eliminate their contributions, while selected mixed differences survive. Two expectations of bounded g differ by at most 2B, and every selected edge contributes half its mixed difference.

(b) For the additive projection g_≤1=E g+sum_i g_i, the positive product interpolation q_x(t)=E g+t sum_i g_i(x_i)+t² sum_{i<j}g_{ij}(x_i,x_j) is bounded in absolute value by B for t∈[0,1]. The identity g_≤1=−2q_x(0)+4q_x(1/2)−q_x(1) implies ||g_≤1||_infty≤7B. Since the sum of the separate additive ranges is at most 14B, Popoviciu implies sum_i ||g_i||₂≤7B.

(c) For every fixed x, choose a maximizing replacement for each input i, and form the expected polynomial when each such input switches independently with probability t. Its degree is at most two, its absolute value at most B, and its derivative at zero is the sum of the nonnegative individual gains. Endpoint Markov bounds this sum by 8B. Repeating with minimizing replacements bounds all decreases by 8B. Thus the sum of coordinate oscillations is ≤16B at each x. The centered i-section U_i(·;X_-i)=g_i(·)+sum_{j≠i}g_{ij}(·,X_j) has scalar conditional standard deviation ≤half its oscillation. Therefore sum_i E||U_i||_{L²(μ_i)}≤8B.

**Vector lifting.** Put b_ij=sup ||h_ij||_H. Fix ANY matching P chosen using these vector weights. Apply scalar (a) to <u,G>, integrate over uniform u, and bound E_u sup|<u,h_ij>|≥a_r b_ij. This gives

    sum_{(i,j) in P} b_ij ≤ 4B/a_r.             (2)

For each vector additive component h_i, its covariance matrix has trace ||h_i||². The same holds for each conditional Hilbert section U_i, with squared trace equal to ||U_i||²_{H_i}. Apply (1) to scalarized (b) and (c) and average over u to obtain

    sum_i ||h_i||_{H_i} ≤ 7B/a_r,
    sum_i E||U_i||_{H_i} ≤ 8B/a_r.               (3)

These are valid for dense interaction graphs, all finite alphabets and arbitrary independent masses.

**Greedy matching and actual independent Hilbert increments.** Sort pair edges by decreasing b_ij and retain each edge disjoint from previously retained ones. Assign to each retained edge's endpoints cost c_i=b_ij, leaving other vertices zero. Each interaction edge has some endpoint with c_i≥b_ij. Assign each edge to such an endpoint. By (2), sum_i c_i≤8B/a_r. Let S_i denote neighbors assigned to i. The genuine H_i-valued increments Y_{ij}=h_{ij}(·,X_j), j∈S_i, are independent, centered, and pointwise bounded in norm by c_i. Put Z_i=sum_{j∈S_i}Y_{ij}, s_i=E||Z_i||². Then s_i≤I_i≤M and sum_i s_i equals all pair-interaction variance.

For any finite family of independent centered Hilbert Y_j with ||Y_j||≤c, write v_j=E||Y_j||² and s=sum_j v_j. Exact fourth-moment expansion yields

    E||sum_j Y_j||^4
      = sum_j E||Y_j||^4 + 2 sum_{j<k}v_j v_k
        + 4 sum_{j<k} E<Y_j,Y_k>²
      ≤ c²s + 3s².                                (4)

The finite arbitrary-law many-increment theorem has a separately pinned, scoped Lean certificate in PR #364; this is NOT the full matching proof. By Hölder interpolation,

    s_i^(3/2) ≤ E||Z_i|| sqrt(E||Z_i||^4),
    s_i ≤ (c_i+sqrt(3M)) E||Z_i||.               (5)

Conditioning the i-section on its assigned neighbor inputs gives E[U_i|X_{S_i}]=h_i+Z_i. Jensen and the triangle inequality imply E||Z_i||≤E||U_i||+||h_i||. By (3), sum_i E||Z_i||≤15B/a_r, and E||Z_i||≤sqrt(s_i)≤sqrt M. Thus

    sum_i s_i ≤ sqrt(M)sum_i c_i + sqrt(3M)sum_i E||Z_i||
            ≤ (8+15sqrt(3))B sqrt(M)/a_r.

The additive variance is at most sqrt(M) sum_i||h_i||≤7B sqrt(M)/a_r. The two terms sum to D B sqrt(M)/a_r. This proves D1 for finite categorical products.

**Arbitrary measurable products.** Strong measurability reduces to a countable effective input support. Approximate G in L² by bounded finite-rectangular conditional expectations G_n preserving degree at most two; commuting coordinate-averaging operators ensures I_i(G_n)≤I_i(G), and V(G_n)→V(G). Each G_n is a finite categorical full-support product after discarding null cells. Pass D1 to the limit. No minimum atom, regular conditional kernel on arbitrary alphabets or pointwise null-input guarantee is used.

The constant a_r satisfies a_r²≥1/(3r): E u_1²=1/r and E u_1^4=3/[r(r+2)], so L¹–L²–L⁴ interpolation gives a_r²≥(r+2)/(3r²)≥1/(3r). D<41, hence D2's integer coefficient 5043.

## Actual posterior proof of the adaptive hard budget

Project F onto a fixed leading covariance rank-r subspace, G=P_rF, with ||G||≤B. After t adaptive whole-coordinate queries the unobserved coordinates retain an independent product posterior and the conditional section of G still has degree ≤2 almost surely. At the random transcript let v be posterior variance, p=sum_i I_i its total trace influence, and m=max_i I_i. The countable nonnegative summable sequence of influences attains its maximum when positive; a fixed order provides a measurable greedy choice. Let V_t=E v, P_t=E p, M_t=E m, and κ=a_r²/(D² B²).

Posterior ANOVA gives v≤p≤2v; D1 gives m≥κ v². Jensen, then P_t≤2V_t, give

    M_t ≥ κ E v² ≥ κ V_t² ≥ κ P_t²/4.          (6)

The exact conditional ANOVA identity for querying i is

    E_{X_i}[T(G|X_i)] = T(G) − I_i(G),   T=sum_j I_j.

Every interaction term containing i loses one unit of its degree-weighted energy after revealing i. Therefore for the actual greedy procedure,

    P_{t+1} = P_t − M_t ≤ P_t − κ P_t²/4.       (7)

Whenever P_{t+1}>0, reciprocal telescoping yields 1/P_{t+1}−1/P_t≥κ/4. It follows that after at most ceil(4/(κη)) queries P_N≤η, and hence V_N≤η. The fixed output projection and Hilbert orthogonality imply

    E||F−E[F|transcript]||² ≤ V_N + τ_r ≤ η+τ_r.

This proves D2 with a **deterministic hard budget**, not merely an expected or best-iterate bound.

## Exact lower bounds and separation

For the additive F_{r,k} above, after any ≤q adaptive queries the remaining independent signs contribute exactly (rk−q)/(rk²) to posterior MSE. Query adaptivity cannot reduce it faster. For the address observable f(K,Z)=Z_K, the two fixed-query conditional means are E[f|K,Z_Q]=1_{K∈Q} Z_K and E[f|Z_Q]=(1/m) sum_{j∈Q} Z_j, giving (D6) exactly. These are finite, explicit constructions and need no fourth-moment or influence theorem.

## Reproduction and certification boundary

Run the standard-library exact-rational checker next to this manuscript. It examines 220 heterogeneous full product Hilbert models with direct conditional-expectation influence computations independent of ANOVA expansion, validates the integer 5043 coefficient and actual assigned-increment fourth moments, uses outward rational square-root bounds on matching costs, and reproduces 36 rank-lower and 36 exhaustive address-tree Bayes-risk cases. Seed: 20261111. Finite PASS does not prove the universal theorem.

The present proof independently unfolds the rank-lifting step noted briefly in PR #362 and composes its scalar matching construction with the already pinned many-increment result in PR #364. The analytic Hilbert and posterior composition has **not** been compiled as one named Lean theorem. Global originality requires separate dated prior-art comparison and non-author proof review; a new proof presentation is not evidence of new mathematical priority.

## Prior art checked (11 Nov 2026) and next decisive test

- Aaronson–Ambainis, *The Need for Structure in Quantum Speedups* (2014), https://www.theoryofcomputing.org/articles/v010a006/, Boolean-cube query motivation.
- David Turturean, *A proof of the Aaronson–Ambainis conjecture* (6 Nov 2026), https://arxiv.org/abs/2611.09773, uniform-cube 5/2 exponent for arbitrary degree. The general-degree NIGHTFALL finite theorem imports his method.
- Girish, Mittal, Nehoran, Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture* (28 Sep 2026), https://arxiv.org/abs/2609.35327, fixed common bias / Boolean slice reductions, not visibly the arbitrary-heterogeneous degree-two rank-r theorem.
- Escudero Gutiérrez, *Influences of Fourier Completely Bounded Polynomials* (2023), https://arxiv.org/abs/2304.06713, squared-variance exponent already present for completely bounded polynomials on uniform Boolean input. Do not claim the exponent itself as new.
- Classical Littlewood and Bohnenblust–Hille bilinear mixed-norm inequalities (e.g. https://pmc.ncbi.nlm.nih.gov/articles/PMC11090839/): crucial pending historical comparison. Simple bounded root-influence sums cannot automatically extend to arbitrary alphabets: the address family has sum of square-root leaf influences growing as sqrt(m) while bounded output remains ±1.
- O'Donnell–Saks–Schramm–Servedio (2005), https://www.cs.columbia.edu/~rocco/papers/focs05osss.html, classical decision-tree influence theory and general products; the address construction itself is not claimed invented here.
- Soltani Moakhar et al., *Decision Tree Learning on Product Spaces* (ICML 2026), https://proceedings.mlr.press/v306/soltani-moakhar26a.html, tree learning from assumed optimal depth rather than rank-optimal Hilbert observation of low-degree functions.
- Kunsch–Wnuk, *Uniform approximation of vectors using adaptive randomized information* (2026), DOI 10.1016/j.jat.2025.106216, oracle permits arbitrary linear functionals, not whole input-coordinate observations.
- NIGHTFALL PR #362: complete scalar arbitrary-law matching analytic reconstruction; PR #364: finite many-Hilbert-increment kernel receipt. Credit original program and preserve their exact source versions.

**Targeted originality audit outcome:** no exact earlier theorem match identified in these sources for the joint unrestricted categorical/continuous-input, rank-optimal quadratic Hilbert adaptive upper bound and alphabet-independent fixed-query impossibility. **Global originality is NOT certified by a search**, and the general finite scalar matching proof remains outside end-to-end Lean compilation.

**Next decisive Lean experiment:** formalize actual global even/odd matching-product coupling and greedy endpoint cover from finite product functions, then instantiate the kernel-checked full-family fourth moment and ANOVA influence bridge. Follow by a finite-dimensional spherical/reverse-Rademacher scalar-to-Hilbert transfer and posterior recursion. Independent reviewer must attack all source assumptions and compare with categorical Littlewood/Grothendieck theorems before an originality promotion. No site Original Finding promotion or journal submission is authorized by this checkpoint.