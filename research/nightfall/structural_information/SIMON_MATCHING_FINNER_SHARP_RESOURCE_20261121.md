# Simon matching–Finner domination law: candidate sharp structural cost
Version v1.1 (critical audit addendum) | 2026-11-21/22 | Provisional paper proof + exact arithmetic checker | NOT Lean-certified | NOT priority cleared.

## Objective, feasible set and attribution

Directly lower-bound the new query-aware density-dominated Route 1 resource for **all** fixed partitions and **all** finite product mixtures, independently of Simon's quantum/classical query lower bound. This is a stronger test than the M=1 Jensen bound in QUERY_AWARE_DOMINATED_ROUTE1_SIMON_20261121.md.

Essential prior methods: Finner's generalized Hölder inequality (classical); Cauchy–Schwarz/Hellinger affinity (classical); Simon's shift matching promise and deterministic XOR difference-cover query sets (classical). Source theorem Route 1/Wyner is merged PR #970 but **NOT USED** anywhere in this lower bound. Prior-art search checked Finner 1992/2017 hypergraph inequalities and Simon deterministic query complexity; the particular optimized profile / direct matching bound has not yet undergone specialist dated novelty clearance. Do not call this a new peer-reviewed record or theorem without non-author proof review.

## Set-up and exact target

Let N=2^m, m≥1, with N distinct input addresses identified with GF(2)^m and N possible output symbols. Let ν_N be the standard uniform hidden-shift Simon oracle law: choose s≠0 uniformly and assign injectively N/2 output labels to the N/2 pairs {i,i⊕s}. Distinct valid truth tables have distinct s, and each shift has exactly

  J_N=N!/(N/2)!

supported truth tables. Total support L_N=(N−1)J_N; every ν_N-atom has probability 1/L_N.

Choose ANY fixed partition P of the N addresses into blocks B. Let b=max_B |B|. Suppose each whole block can be reconstructed **deterministically and without error on every supported Simon oracle** using at most κ original table-entry queries. This decoder may adapt and query anywhere in the table, but the partition and the algorithm are fixed independently of the hidden input. Let Q be an **arbitrary M-component mixture** of independent block distributions:

  Q(x)=sum_{θ=1}^M w_θ prod_{B in P} q_{θB}(x_B),

with w_θ≥0, sum w_θ=1 and q_{θB} any probability masses on the full output-vector alphabet of B. Assume pointwise ν_N(x)≤R Q(x), with 1≤R<∞. Define the simple raw structural proxy

  C_N := inf_{P, decoders, Q, R} κ R (1+ln M).

Do not confuse C_N with Wyner common information or with the exact degree/error-calibrated simulator budget; it is a proxy measuring **actual block-query cost × density amplification × mixture entropy upper bound**.

## v1.1 adversarial audit: robust trade-off, stronger decoder bound, and limitation

**Priority correction (2026-11-21 CST):** The exact asymptotic value 1/2 belongs only to the **author-chosen** score κ·R·(1+ln M). Route 1 has a polynomial rather than fixed linear dependence on the density factor R. Do not present the 1/2 as a universal quantum-advantage law. The stronger theorem is the score-independent trade-off.

**Robust finite-N statement.** Under the same precise assumptions as Lemmas 1–4 (fixed partition P, arbitrary M-component block-product mixture Q, pointwise ν≤RQ, and exact deterministic whole-block reconstruction with at most κ original-coordinate queries, including outside-block/adaptive queries), for every N=2^m≥2,

    ln M + ln R + [N(2κ−1)/(2(N−1))] ln N
       ≥ ln[(N!/(N/2)!)/(N−1)].

Consequently for every fixed ε with 0<ε<1/2, κ≤(1/2−ε)N implies

    ln(MR) ≥ [ε N²/(N−1)] ln N − (N/2)ln 2 − ln(N−1).

The second inequality uses only N!/(N/2)!≥(N/2)^(N/2), so MR≥exp(Ω_ε(N ln N)) for all sufficiently large N. This is independent of any selected way to score κ, R and M. The earlier exact C_N/N→1/2 is a valid **secondary corollary for its explicitly chosen score**, not the principal result.

**Adaptive decoder audit — original lemma valid.** Fix s≠0 and a supported injectively labeled Simon table x. Trace the decoder's complete deterministic *adaptive* query path. If a shift-s coset C intersecting B was never queried (including queries outside B), change its label to an output symbol unused by the other N/2−1 cosets. A fresh label exists because the alphabet has N symbols and there are N/2 occupied cosets. The modified table remains on the same Simon promise slice S_s, gives identical responses on all queried addresses, and forces exactly the same adaptive decisions, but has a different value on at least one coordinate in B. Thus a universally correct decoder must query at least one address from every coset intersecting B, even if it learns the hidden shift from earlier answers. This fails if the output alphabet is restricted to only N/2 symbols, or reconstruction need only succeed with some probability; neither modification is allowed in the theorem.

**Strictly stronger block bound.** For a fixed block B of size b, let h_s(B) count shift-s matching pairs whose two endpoints are in B. The number of s-cosets meeting B is b−h_s(B), and summing over the N−1 possible shifts yields sum_s h_s(B)=binom(b,2). Some shift has h_s(B)≤floor[binom(b,2)/(N−1)]. Therefore

    κ_B ≥ b−floor[binom(b,2)/(N−1)] ≥ ceil(b/2).

In particular, if binom(b,2)<N−1, then κ_B≥b: small blocks cannot save any original-coordinate queries. The original ceil(b/2) bound is **valid but not tight** (a two-coordinate block costs two queries when N≥4). All cases of the original proof remain valid, including adaptive outside-block queries.

**Decisive limitation: cost characterization fails on Simon.** The standard Simon shift-finding promise has Θ(sqrt N) classical randomized/deterministic query complexity (birthday collision / XOR difference-cover). The author-chosen static full-block-reconstruction score has Θ(N), since the matching lower bound and one-whole-table block upper construction squeeze it. Thus their ratio is Θ(sqrt N), and the numerical query costs have a quadratic separation. This is a counterexample to claiming this score characterizes classical query cost, even though it remains sufficient as a general Route 1 simulation upper bound.

**Next mechanism:** allow transcript-conditioned, *task-relative* structural certificates with adaptive stopping when the relevant hidden cause (here s) is known. A dynamically selected partition alone may still force unnecessary table reconstruction; the objective/polynomial and success certificate must enter the resource. Formalize the score-free MR-kappa frontier before refining constants.

**Evidence and limits:** The strengthened finite checker exhausts decoder-transcript ambiguity through this larger bound for N=2,4 and checks shift-coset averaging on all 15 partitions for N=4 and selected N=8 partitions. This is an author-side adversarial audit, not independent non-author certification. The general matching/Finner proof remains paper-level pending Lean or independent expert review; credit classical Finner and Simon query prior art.

## Lemma 1: hidden-shift matching contraction (Finner certificate)

Fix a shift s≠0. Let E_s be its perfect matching of N/2 unordered address pairs, and let

  h_s(P)=number of pairs in E_s whose two endpoints belong to one block B.

For every product law q(x)=prod_B q_B(x_B) on the grouped alphabet,

  sum_{x in S_s} sqrt(q(x)) ≤ N^{h_s(P)/2},

where S_s is the set of J_N injectively labeled functions respecting shift s.

*Detailed proof:* Write each valid table as an injective assignment a_e∈[N] to the matching edges e∈E_s. Dropping injectivity only enlarges a nonnegative sum. For each block B let I_B={e∈E_s:e meets B}, and define

  F_B((a_e)_{e∈I_B}) =
      sqrt(q_B((a_{e(i)})_{i∈B})).

The map from edge labels indexed by I_B to the B-table vector is injective; its image imposes equality at the endpoints of every matching edge internal to B. Thus
  sum_{a_{I_B}} F_B(a_{I_B})² ≤ sum_{z_B} q_B(z_B)=1.

Take all edge labels independently uniform on N symbols. Each edge-label variable occurs in exactly one block factor if the edge is internal and in two factors otherwise. With exponents p_B=2, its total reciprocal exponent is therefore 1/2 or 1, as required by **Finner's hypergraph Hölder inequality**. Hence

  E[prod_B F_B] ≤ prod_B (E[F_B²])^(1/2)
                ≤ N^{−(sum_B |I_B|)/2}.

Since |E_s|=N/2 and sum_B |I_B|=2|E_s|−h_s(P), restoring the counting-measure sum multiplies by N^{|E_s|} and yields exactly N^{h_s(P)/2}. The injective-label sum is a subset, proving the lemma. ∎

The entire bound is over *arbitrary within-block correlations* q_B; it is not restricted to product laws on the original individual outputs.

## Lemma 2: all-M pointwise-domination lower bound (no quantum hardness)

For Q=sum_θ w_θ q_θ, sqrt(Q(x))≤sum_θ sqrt(w_θ) sqrt(q_θ(x)); by Lemma 1 and sum_θ sqrt(w_θ)≤sqrt M,

  sum_{x in S_s} sqrt(Q(x)) ≤ sqrt M · N^{h_s(P)/2}.

But ν_N(x)=1/L_N and ν_N≤RQ imply Q(x)≥1/(R L_N) for EVERY supported x, including every x∈S_s. Therefore

  sum_{x in S_s} sqrt(Q(x)) ≥ J_N/sqrt(R L_N).

Squaring and using L_N=(N−1)J_N gives, FOR EVERY NONZERO s,

  BOXED: M R ≥ J_N / [(N−1) N^{h_s(P)}].

This inequality is exact, with no tolerances, unknown constants, lower-bound oracle theorem, or hidden dependence on M.

For singleton blocks h_s=0 for all s, so every M-product mixture of original-coordinate product laws obeys

  M R ≥ [N!/(N/2)!]/(N−1).

This directly solves the original-coordinate arbitrary-M Simon domination test. For N=4 the bound is 4, for N=8 it is 240; the explicit subset-output mixtures in the previous note satisfy it. Neither bound assumes symmetric mixtures.

## Lemma 3: some hidden shift is nearly transverse to every fixed partition

Every unordered pair of addresses {i,j} inside one block belongs to exactly one Simon matching, namely s=i⊕j. Consequently

  sum_{s≠0} h_s(P) = sum_{B in P} binom(|B|,2).

There are N−1 shifts and sum_B |B|=N. Thus at least one s_star has

  h_star := h_{s_star}(P)
    ≤ [sum_B binom(|B|,2)]/(N−1)
    ≤ N(b−1)/[2(N−1)].

This exact counting lemma is the key structural distinction between an unknown-shift Simon source and a known duplicated-pair distribution. A partition cannot align all XOR matchings.

## Lemma 4: original-query reconstruction costs at least half the block size

For a fixed shift s, a block B of size b meets at least ceil(b/2) distinct matching cosets. Any exact deterministic decoder of the entire B-value must query at least one address in **each** of these cosets.

Why: Fix any supported Simon table with shift s and inspect the actual decoder transcript. If some coset meeting B has not been queried, change that coset's label to a different symbol unused by all other N/2−1 cosets. Since there are N output symbols and only N/2 cosets, at least two choices are possible. Both functions remain valid tables with the **same shift**, and their answers agree at every queried address. The deterministic decoder follows the same branch and emits the same block result, but one block coordinate has changed: contradiction. This works even when decoder queries outside B or adapts its addresses.

Thus κ≥ceil(b/2), hence b≤2κ. Combined with Lemmas 2–3,

  BOXED: M R · N^[N(2κ−1)/(2(N−1))] ≥ J_N/(N−1),

where the real exponent is interpreted as an inequality after relaxing the integer h_star. Equivalently, in nats, for N≥2,

  ln M + ln R + [N/(N−1)] κ ln N
    ≥ H_N := ln(J_N/(N−1)).

The logarithmic inequality is marginally weaker than the preceding exact integer h_star bound, but makes the asymptotic profile transparent.

## Theorem candidate: sharp asymptotic Simon resource cost

Put a_N=[N/(N−1)]ln N and H_N=ln(J_N/(N−1)). For every feasible partition and dominating mixture, κ≥1, R≥1, M≥1. By ln R≤R−1 and ln M≥0,

  H_N≤ln M+ln R+a_N κ
     ≤R(1+ln M)−1+a_N κ
     ≤(1+a_N) κ R(1+ln M)−1.

Therefore, taking the infimum,

  BOXED LOWER: C_N ≥ [1+ln(J_N/(N−1))]/[1+N ln N/(N−1)].

By Stirling, the RHS is (1/2−o(1))N.

For a matching **upper** construction, put the entire truth table in a single block, choose Q=ν_N (trivially a product law on the one-block space), M=R=1, and reconstruct the block as follows. Split m=a+b address bits, a=ceil(m/2), b=floor(m/2). First query every address in
  A={(u,0):u∈GF(2)^a}
  and B={(0,v):v∈GF(2)^b}.
This uses at most q0=2^a+2^b−1=O(sqrt N) queries. Every nonzero shift s=(u,v) is the difference between a queried member of A and a queried member of B, so **some observed duplicate output** must occur; its two addresses reveal s exactly. Once s is known, query one member of every XOR pair whose output has not yet been seen, using at most N/2 further queries. Thus an exact-on-support deterministic whole-table decoder exists with

  κ ≤ min{N−1, N/2+2^ceil(m/2)+2^floor(m/2)−1}.

The N−1 option queries every address but one and recovers the missing entry from the unique output label appearing once among queried values.

Hence

  BOXED UPPER: C_N ≤ min{N−1, N/2+2^ceil(m/2)+2^floor(m/2)−1}.

The lower and upper bounds squeeze the limit:

  BOXED: lim_{m→∞} C_{2^m}/2^m = 1/2.

This is an exact asymptotic characterization of the **new raw density-and-reconstructibility structural proxy on the standard Simon promise**, not of Simon's classical query complexity (which is Θ(sqrt N)), not of Wyner common information, and not a proof of an iff quantum-speedup law. All proof steps above are paper-level and need independent theorem review. Finner itself and deterministic difference covers are credited classical ingredients.

## Reproducibility / independent criticism / novelty gate

- Exact checker: scripts/check_simon_matching_finner_exact.py, all-integer squares of Finner sums for independent randomly weighted within-block distributions; enumerates all partitions for N=4 and selected partitions for N=8, with zero-tolerance checks. It also computes rational mixture Q and R on every valid table for test families, verifies all-M domination inequality, internal-match double counts and small-block decoder ambiguity exhaustively for N=2,4. Finite checks do **not** prove the general Finner claim.
- Checker implementation is independent of the symbolic derivation; no external Lean theorem or scoring tolerance is involved. A non-author critic should test the hypergraph incidences, normalization, fractional exponents, arbitrary zero masses, injection constraint, quantifier order (partition fixed before s), and decoder's permitted outside-block queries.
- Prior art: Finner (1992) generalized Hölder; e.g. the 2017 paper Hölder-type inequalities and their applications to concentration and correlation bounds. Simon's O(sqrt N) deterministic difference cover is standard (see Query Complexity Zoo). Search this particular combination of max-relative entropy, product-mixture Hellinger and matching geometry independently before any novelty statement.
- Research status: **provisional theorem candidate, author-side exact checks**; no new Lean certification, specialist novelty search or human/non-author proof review yet. The full query-cost simulator / block-alphabet formalization remains a separate obligation.
- Generalization: every family of equally weighted hidden perfect matchings with injective labels yields the per-matching Finner obstruction; if matchings are sufficiently dispersed relative to every low-cost partition, the same structural transition persists. Duplicated bits constitute the opposite extreme (only one matching, so grouping resolves it).
