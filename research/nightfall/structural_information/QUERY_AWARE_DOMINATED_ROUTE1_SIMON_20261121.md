# Query-aware density-dominated Route 1; Simon stress test
2026-11-21/22 | Version 1 | Paper proof / source-reconciliation, **not a new Lean certificate**.

## Objective, attribution, and existing sources
This checkpoint extends the Route 1/Wyner theorem proved by Claude and colleagues in merged PR #970. Quantum acceptance-polynomial interface is developed in PR #974. The related NIGHTFALL representation work is #946/#948, and the exact converse is PR #987. Bounded density-ratio change of measure and max-relative entropy are classical. Prior-art anchors include arXiv:1302.0215 and the relaxed common-information literature; do not assert novelty without dedicated review.

## Definitions
Fix original queried positions I with finite alphabet A. Let ν be a probability mass function on A^I, and let a fixed, input-independent partition P of I create blocks B. A block query returns the **entire vector** X|_B; its alphabet is A^B. Suppose a deterministic algorithm, on every ν-supported input, reconstructs the entire B-value using at most κ_B original-coordinate queries, and let κ=max_B κ_B. This is worst-case query complexity, NOT computational time. Decoder queries count against the original cost; the decoder must be fixed before seeing the input or hidden shift.

Let Q on the grouped blocks be a mixture of M≥1 product distributions:
  Q(z)=sum_{θ=1}^M w_θ prod_{B in P} q_{θB}(z_B),
with nonnegative component probabilities and zero masses allowed. Suppose ν_P(z) ≤ R Q(z) for every z, R≥1. This is one-sided density domination, D∞(ν_P||Q) ≤ ln R. If Q has zero mass where ν is positive, R is infinite and this candidate is inadmissible. The grouping is a bijection of the entire underlying product, not merely its support.

## Theorem 1: rigorous mathematical sufficiency
Let f:A^I→[0,1] have finite-product interaction degree ≤d, d≥1. Assume 0<ε≤1 and 0<δ<1. Use the **exact merged Lean Route1WynerGeneral source**:
  K(d)=π²d²/2,
  γ(d,τ)=sqrt(3τ^5/[12500(π²(d+1)²)^6]),
  η(d,τ)=γ/(512d²),
  w0(d,τ)=γ/(16K),
  A_d(τ)=K/(2γ), B_d(τ)=η²w0.
Choose τ=ε²δ/(2R), s=ln M+1, and an integer
  n≥max{1, (2R/δ)[A_d(τ)+s/B_d(τ)] }.
Then there is an original-coordinate deterministic decision tree of depth at most κ n with
  Pr_ν[ |f(X)−t(X)| > ε ] ≤ δ.

*Proof.* Reinterpret the original polynomial on the full product of block alphabets. A single interaction monomial on ≤d original coordinates touches ≤d blocks. Each function of one block can be expanded exactly in the finite indicator basis of that block. The grouped interaction degree remains ≤d, and f remains [0,1]-valued on the full Cartesian product. Distinct block alphabets can be embedded into one homogeneous finite tagged alphabet with deterministic projections to valid local symbols, preserving degree and boundedness; the Lean source bridge for this tagging is still TODO. Since Q is an M-product mixture, C_W(Q)≤ln M<s. Apply the merged Route 1 Wyner simulator to obtain a block tree of depth n with Q-failure probability at most [A+s/B]/n+τ/ε²≤δ/R. Along ν-supported inputs, replace each block query by its support-correct decoder, costing ≤κ original queries and producing the identical tree output. Since ν(E)≤R Q(E) for any event, ν-failure is at most δ. ∎

Asymptotically the bound is κ·poly(d,1/ε,R/δ)·(1+ln M), where R=exp(D∞). It says nothing about runtime, nor does its source demonstrate that a classical prover can efficiently find the decision tree. The polynomial has the (large) exponents already in Route 1.

**Smooth optional extension:** If ν(E)≤R Q(E)+σ for every E and 0≤σ<δ, replace δ by δ−σ in the construction. For finite laws the least possible σ at fixed R is sum_z max(ν(z)−R Q(z),0). This is a smooth one-sided max-divergence envelope. It is not part of the baseline theorem or yet formally compiled.

## Logical direction audit
Define a calibrated budget C_{d,ε,δ}(ν) as the infimum of the above κn over all valid fixed partitions, support-correct decoders, M-product Q and R. If some degree-d bounded quantum acceptance polynomial requires >q original-coordinate classical queries to achieve error (ε,δ) under ν, then C_{d,ε,δ}(ν)>q (up to equality/ceil conventions). **This is the immediate contrapositive of the proved sufficiency, not an open converse discovery.** The genuinely unproved reverse claim is that a large optimized budget forces a hard quantum algorithm to exist. It could fail on structurally complex but low-degree-invisible distributions. Keep the Pareto profile (κ,ln M or C_W(Q),D∞), rather than labeling an arbitrary scalar as an iff quantum-advantage law.

## Parity and duplicate baselines
Even parity ν on m≥2 fair bits: ν(x)=2^{−(m−1)} on xor-zero support. Let Q be fully independent uniform U, M=1. Then ν≤2U with **R=2** exactly. Although C_W(ν)=(m−1)ln2 (no Hamming edges), the model is easy by the density operator. For m>2 any proper block B of size b<m has independent uniform projected symbols, so reconstructing the entire B takes b actual coordinate queries; one giant block takes m−1. Thus grouping alone does not give a constant-cost escape. For m=2 it does (the two bits are duplicates).

Duplicated fair bits X=(Z1,Z1,...,Zm,Zm): group each repeated pair, recover the whole block by one query (κ=1), and Q=ν_P is a product with M=1, R=1. The original C_W=m ln2 but the query-aware envelope is dimension-independent at fixed d,ε,δ.

Forrelation: the direct C_W((F+U)/2)≥N/(2π²) (PR #987) concerns the original coordinates and does not alone lower-bound the **optimized** (κ,lnM,D∞) envelope. The classical Forrelation hardness against the same equal-prior mixture supplies a separate conditional lower bound via the quantitative Route 1 contrapositive.

## Simon: exact direct M=1 minimax theorem

Let m≥1, N=2^m input addresses and N output symbols. Choose s uniformly among N−1 nonzero masks, and assign distinct output symbols uniformly to its N/2 XOR-pair cosets. The resulting law ν_S is uniform on the set S of
  L_N=(N−1)·N!/(N/2)!
valid truth tables, and every table output coordinate has the uniform marginal on N symbols. Each table determines its period uniquely.

**Theorem (uniform-marginal domination minimax):** If ν is uniform on S⊆A^I, |A|=h, |I|=r, and each coordinate marginal is uniform on A, then over ALL product laws Q=prod_i q_i, including ones with zero masses,
  min_Q D∞(ν||Q) = r ln h − ln|S|.
The unique natural optimizer is the fully independent uniform Q (other equality cases require checking the marginal support).

*Proof.* If any q_i(a)=0, an S-supported tuple uses a and ν≪Q fails. Otherwise
  E_{X∼ν} ln Q(X) = sum_i (1/h)sum_a ln q_i(a) ≤ −r ln h
by Jensen and normalization of each q_i. Therefore some x∈S has Q(x)≤h^{−r}. At that x ν(x)/Q(x)≥h^r/|S|, giving the lower bound; Q=U makes it equality for every supported x. ∎

Thus the exact single-product Simon domination cost is
  D∞_{M=1}(ν_S)=N ln N−ln[(N−1)·N!/(N/2)!]
                =(N/2)ln N−(N/2)ln2+N/2+O(ln N).
It grows as Θ(NlnN); the elementary uniform-Q baseline is exponentially poor in number of addresses.

**Limit:** This lower bound is for M=1 only. Mixtures of product laws can specialize on different support regions. It does NOT establish any lower bound simultaneously involving M, κ and D∞. That is the direct structural research gap.

## Simon: exact M-product dominating family (all N, all t)

For every integer t in [N/2,N], uniformly choose a t-element subset A of the N output symbols and independently sample each of the N table outputs uniformly in A. This is a mixture Q_t of

  M_t=binom(N,t)

product distributions, one per output subset. A valid Simon table x uses **exactly N/2 distinct symbols**, each twice. Precisely binom(N/2,t−N/2) subsets A contain all of them. Hence Q_t is constant on Simon's entire promise support:

  Q_t(x)=binom(N/2,t−N/2)/[binom(N,t)·t^N]   for every x in S_N.

Its pointwise domination factor is therefore not an estimate but **exact**:

  R_t=binom(N,t)·t^N / [L_N·binom(N/2,t−N/2)],
  D∞(ν_S||Q_t)=ln R_t.

At t=N, M=1 and R=N^N/L_N: the optimal single-product reference. At t=N/2, M=binom(N,N/2) and R=M·(N/2)^N/L_N, which is strictly better for N≥2 but uses exponentially many components.

For fixed k with 0≤k≤N/2 and t=N−k,

  M=binom(N,k),
  R_{N−k}/R_N=[binom(N,k)/binom(N/2,k)]·(1−k/N)^N.

As N→∞ with **k fixed**, the ratio tends to (2/e)^k while M∼N^k/k!. Thus polynomial-size mixtures **in this particular family** improve R by constant factors rather than eliminating the exponential density penalty. This does *not* prove any lower bound for arbitrary mixtures, adaptive output-coordinate-specific component laws, or fixed block partitions.

Small exact benchmark: N=4 and L_N=36. M=1 gives R=64/9; t=3, M=4 gives R=9/2; t=2, M=6 gives R=8/3. This is the first nontrivial M>1 Simon envelope with completely explicit probabilities and a finite exact checker.

## Simon: direct collision-coupling classical hardness

Let a classical algorithm query at most q distinct truth-table addresses, each returning the entire N-symbol output, and guess a fixed hidden-shift bit s_j. Let a fake oracle return a fresh uniform unused output symbol at each queried address, independent of s. Couple the true Simon oracle to the fake oracle by using the same random label whenever a new XOR coset is observed. Transcripts are identical until two queried addresses differ by the hidden shift. Conditional on the fake transcript, s is still uniform among N−1 nonzero differences. At most C(q,2) distinct queried-address differences exist. Thus the probability of divergence is at most q(q−1)/(2(N−1)).

The best blind guess of s_j succeeds with probability N/[2(N−1)] (there are N/2 shifts with bit 1 and N/2−1 with bit 0). By coupling, for any adaptive randomized q-query algorithm,
  Pr[guess s_j correctly] ≤ N/[2(N−1)] + q(q−1)/[2(N−1)].
This is the standard Simon/birthday lower-bound mechanism with an explicit finite bound (credit prior art). Constant-advantage prediction requires q=Ω(sqrt N). To turn this into a bound on the density-aware simulator's profile, link the correct n-bit-output coherent quantum oracle to its T=O(m) acceptance polynomial, and match the simulator's ε/δ failure guarantee. **This does not provide an independent structural lower bound on the profile; it uses known query hardness.**

## Certification passport and next decisive experiments
- Objective: rigorous mathematical sufficiency and a direct baseline for Simon's candidate envelopes.
- Proven at paper level: domination transfer and grouped degree argument; optimal one-product Simon D∞ and collision coupling. The homogeneous-alphabet tagged encoding is specified but not yet Lean-kernel-checked.
- Checker: fixed-seed / exact-arithmetic enumeration of parity domination, grouping, Simon support, uniform marginals, and selected product-law nonuniform alternatives. Finite tests only.
- Audit: distinguish original table-entry queries from bit queries; partition fixed independent of secret; decoder correct only on ν support; Q may have off-support mass; ensure same acceptance/distributional error model.
- Strongest prior reference: merged #970 source, classical Simon lower bound, classical max-divergence/change of measure (arXiv:1302.0215 and follow-ups). No novelty clearance.
- Stop rule: do not claim a general M-product or grouping lower bound from the product-only certificate; independent source-checker and non-author review required.
- Next cheapest test: exact M=1 minimax on m=1,2 and enumeration of M=2 mixture candidates for small Simon, then attempt a dual geometric lower bound on κ·R·(1+ln M) for all M with no appeal to Simon quantum hardness.

**No merge, publication or broad characterization implied.**
