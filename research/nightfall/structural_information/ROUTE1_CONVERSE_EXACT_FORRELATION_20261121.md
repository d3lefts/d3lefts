# Route 1 converse, exact Forrelation information, and support rigidity
2026-11-21 | Research checkpoint | Paper arguments, **not** new Lean certificates | No priority or publication claim.

## Provenance
Claude and collaborators' merged Route 1 Lean PR #970, at research/nightfall/formalization/product_space/Route1WynerGeneral.lean, is the source. PR #948 (open) already contains a Forrelation lower bound of order sqrt(N)/log N **and** a heuristic linear-bound refinement (Nov 20). This note makes the latter exact, with no Gaussian CLT, and derives explicit constants from the merged theorem. Quantum circuit source connection #974 is separate. Credit Aaronson–Ambainis for Forrelation (arXiv:1411.5729).

## Theorem A: explicit quantitative contrapositive
The actual Route 1 theorem says: for any finite-product PMF ν, bounded degree-d real acceptance polynomial f∈[0,1], d≥1, 0<τ≤1, ε>0, natural n≥1, and any s>C_W(ν), there is a deterministic depth≤n query tree t with

  Bad_ν(f,t,ε) ≤ [ A(d,τ) + s/B(d,τ) ]/n + τ/ε²,

where Bad is Pr_ν(|f−t|>ε), using strict > on the bad event, and

  K=π²d²/2,
  γ=sqrt(3τ⁵/[12500(π²(d+1)²)⁶]),
  η=γ/(512d²),
  w0=γ/(16K),
  A=K/(2γ),  B=η²w0=γ³/(16·512²·d⁴·K)>0.

If EVERY deterministic query tree of depth≤n satisfies Bad_ν(f,t,ε)>δ, then

  C_W(ν) ≥ B [ n(δ−τ/ε²) − A ].

Proof: insert any s>C_W into the theorem; hardness implies δ<[A+s/B]/n+τ/ε². Multiply by n and B (positive), rearrange and let s approach C_W from above. Nontrivial when δ>τ/ε² and n large enough. C_W≥0 separately.

**Required discrimination bridge:** Let ν=(D0+D1)/2, Δ=E_D1 f−E_D0 f>0. Suppose every randomized classical distinguisher making at most n original-coordinate queries succeeds with probability at most 1/2+κ under equal priors. If Δ>2κ+2ε+2δ, then a deterministic depth-n tree with Bad_ν(f,t,ε)≤δ would contradict this: clip t's leaf values to [0,1], giving g and E_ν|f−g|≤ε+δ; therefore E_D1 g−E_D0 g≥Δ−2(ε+δ)>2κ. A Bernoulli coin with success probability g(X) yields a distinguisher of success >1/2+κ at the same query cost. Thus the approximation-hardness hypothesis holds. Classical **time** is not bounded.

This check prevents erroneously using a classical promise-problem lower bound that has the wrong input law, advantage, error model, or query encoding. For fixed d,ε,δ,τ, the Forrelation Ω(sqrt N/log N) distributional classical lower bound gives only Ω(sqrt N/log N) through Route 1, much weaker than Theorem B.

## Theorem B: exact correlation-Frobenius information lower bound
Let X∈{−1,1}^m, Y∈{−1,1}^k be jointly distributed. Assume X has independent unbiased coordinates and Y has independent unbiased coordinates. They can be correlated across the two blocks. In **nats**,

  I(X;Y) ≥ (1/2) Σ_i Σ_j E[X_i Y_j]².

Proof: write q_j(X)=E[Y_j|X]. Since the Y_j are independent unbiased, conditional entropy subadditivity gives I(X;Y)≥Σ_j I(X;Y_j). Binary Pinsker (natural-log KL) gives I(X;Y_j)≥(1/2)E[q_j(X)²]. The functions X_i are orthonormal in L²(P_X), so Bessel's inequality gives E[q_j²]≥Σ_i E[X_i q_j]²=Σ_i E[X_iY_j]². Sum j. This is classical Pinsker+Bessel, not an unreviewed novelty claim.

### Exact Forrelation application
Let N=2^k, g_i iid N(0,1), H normalized Walsh–Hadamard (entries ±1/sqrt N), X_i=sign(g_i), Y_j=sign((Hg)_j), F=Law(X,Y), and U the fully independent uniform 2N-sign law. Put ν_λ=λF+(1−λ)U for 0≤λ≤1. Both blocks retain independent fair signs for every λ, because H is orthogonal. The classical bivariate Gaussian sign identity yields

  E_νλ[X_iY_j]=λ(2/π) arcsin(H_ji).

Therefore

  C_W(ν_λ) ≥ I_νλ(X;Y)
    ≥ (2 λ² N²/π²) arcsin²(1/sqrt N)
    ≥ (2 λ²/π²)N.

This is non-asymptotic and **does not** need Route 1. At λ=1 (F), C_W≥2N/π² nats (~0.292 bits per signal coordinate). At λ=1/2 (actual Forrelation-vs-uniform mixture), C_W≥N/(2π²) nats (~0.0731 bits per coordinate). Taking W=(X,Y) gives C_W≤H(X,Y)≤2N ln2, so both are Θ(N). The heuristic ~0.38 bits/coordinate in PR #948 is NOT established by this proof. New quantitative exact lower bound and mixture application are the additional result.

## Theorem C: precise support-rigidity criterion
Define a Hamming edge of a finite Cartesian product to be two points differing in **exactly one original queried coordinate**. For any PMF ν on such a product with support S,

  C_W(ν)=H(ν) iff S has no Hamming edge.

Edge-free direction: each latent product component must have support inside S by positivity. Any non-point-mass product law contains two supported inputs differing at one coordinate (fix positive atoms in all others). Thus every product component is a Dirac law and H(X|W)=0; W=X achieves H(X).

Converse: if x,y∈S form a Hamming edge, put a=min(ν(x),ν(y))>0. Allocate weight 2a to product law (δ_x+δ_y)/2 and use point masses for residual ν; expected conditional entropy is exactly 2a ln2. Thus

  C_W(ν) ≤ H(ν)−2a ln2 < H(ν).

The same argument holds with arbitrary latents by conditioning on their product-law pushforward. **Prior art:** Roberto Bruno and Ugo Vaccaro, arXiv:2610.15402 (Oct 2026), explicitly derive the product-component support-rectangle mechanism and a closely related bivariate uniform-table criterion (Lemmas 5,7,8; Corollary 9). Treat this as an elementary multivariate extension/application of known geometry, **not** a novel theorem priority claim.

### Model consequences and exact upper bounds
* Duplication: m independent fair bits, each written twice as separate queried coordinates, give edge-free support and C_W=m ln2; grouping each duplicated pair into one recoverable one-query block yields independent blocks and block C_W=0.
* Bernstein–Vazirani uniform secret s∈{0,1}^m: for m≥2 any two distinct parity truth tables differ in 2^(m−1)≥2 coordinates, so C_W=m ln2; at m=1 the support contains a Hamming edge and C_W=0, an important edge case.
* Standard Simon injective-label promise: n≥1, D=2^n, hidden secret s uniform nonzero and labels injectively chosen for the D/2 XOR-pair cosets. Each n-bit output appears exactly twice. Changing one table entry violates this multiplicity condition. Hence support has no Hamming edge and

  C_W(ν_Simon) = H(X) = ln(D−1) + ln[D!/(D/2)!] nats,

**exactly**. The hidden secret s alone is NOT a conditionally independent latent: the paired outputs are identical and the labels across cosets are injectively coupled. The trivial latent W=X attains this bound. This provides the requested direct upper bound **and a matching lower bound** on Simon's standard promise law.

## Query-aware representation refinement — sufficient only
For partition 𝔅 of the original queried coordinates into blocks, let Z_B=X restricted to block B. Let κ(𝔅) be the maximal exact-on-support worst-case original-query complexity of reconstructing a whole block (not simply its cardinality). Define R_ν(κ) as the infimum of C_W((Z_B)_B) over partitions with κ(𝔅)≤κ. Since regrouping cannot increase interaction degree of a bounded quantum acceptance polynomial, Route 1 suggests a classical upper-bound profile

  depth ≤ poly(T,1/ε,1/δ) · inf_κ κ(1+R_ν(κ)),

**conditional on** the heterogeneous block-alphabet and source-decoding theorem bridges. For duplication, κ=1,R_ν(1)=0. Coarsening the whole oracle into one block is not free because κ can be large. This is a simulation sufficiency operator, **not an iff characterization** or proof of quantum advantage. Task- and oracle-relative necessity remains OPEN.

## Certification passport
* Claimed mathematical scope: Theorems A/B/C above; independent formalization pending. Exact source and classical priors explicitly identified. No new Lean proof was claimed by this note.
* Numerical/exhaustive test: scripts/check_route1_converse_information_exact.py verifies finite Frobenius/Bessel via rational arithmetic, checks entropy lower bound, enumerates support boxes and small Simon/BV cases. Finite tests never certify arbitrary dimension or continuous Gaussian integrations.
* Unproved mechanistic transfer: entropy/degree under on-support block decoding; lower-bound-to-quantum acceptance semantics for each named promise problem; theorem statements as exact Lean declarations.
* Novelty threshold: dated literature review, including Bruno–Vaccaro; independent critique from a non-author. This note supplies verified-at-paper-level explicit constants and source reconciliation, not a competitively new theorem.

---

## 2026-11-23 addendum: worst-case linear Wyner dependence via hard-law sparsification

**Status: new author-side paper deduction, not independently reviewed or Lean-certified.** This resolves the existential sharpness question subject to review; it does not assert pointwise necessity, explicit efficiently samplable sources, or novelty. The earlier exact Forrelation information calculation and #1150's diagonal gap alone do not prove this result.

**Theorem (existential sharpness).** There are finite Boolean-coordinate laws nu_m and fixed-query quantum acceptance functions f_m, globally in [0,1], such that with accuracy epsilon=1/4 and failure delta=1/4 the minimum worst-case-depth classical acceptance estimator (even randomized, error averaged over input and coins) satisfies

    Q_class(nu_m,f_m;1/4,1/4) = Theta(C_W(nu_m)),
    C_W(nu_m) -> infinity.

All query costs are original individual bits, C_W is in nats, and constants are absolute for this family. This is an existential worst-case tightness result, not an equivalence for every input distribution.

**Proof.** Use Girish–Servedio, *Forrelation Is Extremally Hard*, ITCS 2026, Theorem 4 (https://doi.org/10.4230/LIPIcs.ITCS.2026.72, https://arxiv.org/abs/2508.02514). On m=2^(k+1) truth-table signs, extremal Forrelation has a one-query quantum algorithm with acceptance exactly 0 or 1 on the two promise classes, and randomized bounded-error original-coordinate query complexity at least 2^(Omega(k)). Its acceptance function is globally bounded and has interaction degree at most 2 by the polynomial method (or use two standard phase queries if the oracle convention counts the combined controlled query differently; then degree at most 4, still fixed). Choose integer q=q_m below the published lower bound, tending to infinity and with q >= log log(m+2), e.g. floor(2^(k/8)) for sufficiently large even k. Yao's finite minimax principle supplies a law mu on the promise for which every deterministic depth-q Boolean-output tree succeeds with probability at most 2/3. No equal-prior assumption is needed.

Pad each deterministic tree to full binary depth q (repeated queries permitted for counting). The number of distinct syntactic trees is at most D=m^(2^q-1) * 2^(2^q). Draw L=ceil(288*(ln D+1)) independent samples from mu. For any tree, Hoeffding's one-sided inequality bounds the probability that its empirical success exceeds its true success by more than 1/24 by exp(-L/288). A union bound gives D exp(-L/288) <= exp(-1) < 1. Hence there is a fixed sample multiset whose empirical law nu has every depth-q tree's success at most 2/3+1/24=17/24. The sample need not be algorithmically found; the lexicographically first qualifying multiset defines a finite family once the promise and q are fixed. Repeated samples are allowed. Every randomized depth-q tree is a mixture of deterministic trees and obeys the same bound.

Since f is binary on the promise, thresholding any acceptance estimate at 1/2 converts success at epsilon=1/4 into correct classification. Thus every depth-q estimator has failure at least 7/24 > 1/4 (also for randomized estimators). Independently, C_W(nu) <= H(nu) <= ln L, by the point-mass latent W=X. Since ln D <= 2^q ln(2m), ln L <= q ln 2 + ln ln(2m) + O(1) = O(q).

Now apply the merged general-latent Route 1 theorem #970 with fixed degree d (2 or 4), epsilon=delta=1/4, tau=1/128; the residual tau/epsilon^2=1/8. Theorem A above therefore gives C_W(nu) >= B(d,tau)*(q/8 - A(d,tau)) = Omega(q). There is no circularity: the depth lower bound was independently obtained from the published extremal Forrelation lower bound and uniform sampling over the finite class of trees, before applying Route 1. Conversely the forward theorem gives Q_class <= O(1+C_W(nu)) at these fixed tolerances, also for the randomized model since a deterministic tree suffices. Combining q < Q_class, C_W=Theta(q), and this upper bound proves the theorem. The same lower bound holds for deterministic estimators; no classical runtime or expected-query bound is claimed. QED.

**Scope controls.** The bound matches the dependence on C_W only at fixed d, epsilon, delta. It does not match the numerical constants, prove the dependence on degree/error optimal, measure information actually acquired in an individual transcript, or imply all high-C_W laws are hard. The duplicate-bit example #1150 (ambient C_W=N ln 2, recoverable independent blocks with C_W=0) and even a constant acceptance target are counterexamples to pointwise necessity. The original unsparsified Forrelation mixture in Theorem B has C_W=Theta(N), while its cited classical lower bound alone is sublinear in N; do not conflate it with the new sparsified hard law.

**Source and credit audit (2026-11-23).**
- Aaronson–Ambainis, https://arxiv.org/abs/0911.0996 (uniform-input acceptance simulation framework) and https://arxiv.org/abs/1411.5729 (Forrelation); Beals–Buhrman–Cleve–Mosca–de Wolf, https://arxiv.org/abs/quant-ph/9802049 (degree <=2T).
- David Turturean, https://arxiv.org/abs/2611.09773: uniform Boolean influence theorem; the level integration, third moment, median/doubling and light-coordinate averaging mechanism is his. NIGHTFALL #317 ports that mechanism to finite product spaces with arbitrary coordinate laws. Route 1 #970 builds on that foundation, adding the latent-star switching/lift and remaining conditional-information potential; credit both Turturean and the internal contributors, not independent invention of AA.
- Girish–Mittal–Nehoran–Raz, https://arxiv.org/abs/2609.35327, Theorem 1.1: fixed common bias and fixed-density slices equivalent to uniform AA. This directly overlaps nonuniform-input motivation; it is not a general-latent Wyner-parametrized upper bound.
- Ben-David et al., https://arxiv.org/abs/2610.06835: distributional quantum-query composition/direct-sum/direct-product lower bounds via distributional adversary measures. Distinct resource (quantum queries rather than classical acceptance-estimation depth); exact overlaps with the new sparsification deduction remain subject to full priority review.
- Ambainis–de Wolf, https://arxiv.org/abs/quant-ph/9904079 and Aaronson, https://arxiv.org/abs/cs/0001013: older average-case query models; distinguish expected depth / total Boolean evaluation from fixed-depth acceptance approximation.
- Girish–Servedio, ITCS 2026, Theorem 4, above: the imported exact quantum / classical hard promise, not a NIGHTFALL separation. Classical Simulation of One-Query Quantum Distinguishers, https://doi.org/10.4230/LIPIcs.APPROX/RANDOM.2023.43, addresses distinguishability and must be compared by oracle, advantage and adaptivity.
- Wyner (1975), *The Common Information of Two Dependent Random Variables*, is the common-information source. Hoeffding plus finite union bound and Yao are standard tools; related hardness distillation for decision trees appears in https://arxiv.org/abs/2307.04093. No worldwide priority claim. Search was targeted, not exhaustive.

**Audit/checker contract.** Independently verify the extremal Forrelation oracle convention, minimax direction, full padded tree count, Hoeffding exponent, strict rounding-error gap, entropy bound, and source theorem constants; formalize the finite empirical-law lemma separately before the imported lower bound composition. A small exact tree-enumeration stress test would only check counting/thresholding, not certify the asymptotic theorem. No independent reviewer or successful new kernel run is asserted. Stop after the scoped paper proof; do not promote to flagship status or publish a new preprint without review.
