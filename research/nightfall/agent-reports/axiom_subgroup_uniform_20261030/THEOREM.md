# Axiom / prime-subfield orbit-transversal phase packing

**Checkpoint:** 2026-10-30. **Assignment:** Vesper #248, Axiom #249. **Research owner:** Devin J. Wright. **Research derivation and finite checker:** Axiom (AI role). **Scientific status:** R1 proof candidate plus locally executed exact tests; independent non-author proof, same-scope literature priority, and human approval OPEN. This is not a new F16 full-F4* oracle result, not a new k7 static matrix, and not an Original Finding designation.

## Objective, feasible set, best antecedent, difference

The immediately preceding NIGHTFALL candidate [Vesper PR #256](https://github.com/d3lefts/d3lefts/pull/256) proves, subject to its own review, a fixed-versus-adaptive gap for the **quadratic** oracle on F_(3^r), H={±1}. Its proof uses elementary complement-property reasoning and characteristic-three basis packing. Our new question: can the **same exact-query-model mechanism** be quantified for nonbinary phase subgroups and infinitely many different characteristics?

We use K=F_(p^r), p an **odd prime**, r≥1, and H the unique subgroup of F_p* of order h>1 (h divides p−1). The **permitted observation is exactly**
 
    O_a(x)=(a·x)^h, a∈K^k,

with a selected based only on previous O readings. The kernel of z↦z^h on K* is H. The goal is all x∈K^k modulo **one global H scalar**, including the zero vector and arbitrary unknown support. Every coordinate reading is charged as a query. A fixed protocol commits all a in advance; an adaptive protocol may depend on the observed powers. There is **no replacement by an easier proper subgroup** within any fixed (K,H) instance.

### Theorems / proof candidate (finite-field algebra, no approximation)

Define the *offset-transversal property* for c∈F_p:

    T(c):  eta↦(c+eta)^h is injective on H.

**Lemma 1 (exact characterization of the offset digit packer).** Fix any F_p-basis β_1,…,β_r of K. The map

    (eta_1,…,eta_r) in H^r  ↦  (sum_j β_j(c+eta_j))^h

is injective **if and only if** T(c). In the forward direction, a colliding digit pair u≠v yields colliding constant words (u,…,u) and (v,…,v), since c+u and c+v belong to the same H orbit; conversely, if powered sums agree, their arguments differ by one g∈H; the basis gives c+eta'_j=g(c+eta_j) for every j. T(c) forces eta'_j=eta_j for each j, so the words agree. This includes the zero-powered case: if both sums are zero, uniqueness of basis expansion and T(c) force the same word.

**Lemma 2 (explicit sufficient offset test).** Let

    B = {(g v-u)/(1-g): g∈H\{1}, u,v∈H} ⊂ F_p.

Then |B|≤(h−1)h². Every c∉B satisfies T(c); in fact all c+eta are then nonzero, and no two lie in the same H-coset. Therefore, **if p>(h−1)h², such an offset exists**. This is sufficient, not necessary. We count triples before deduplicating B and do not claim a sharp threshold. When c∈B, T(c) may still hold because a 0=0 identity is not a collision between distinct eta.

**Theorem 3 (uniform adaptive decoder).** Whenever some c∈F_p satisfies T(c), let A(k;p,r,h) be the minimum worst-case number of adaptive powered-linear queries for recovery modulo H. Then for **all k≥2, r≥1**:

    A(k;p,r,h) ≤ k + ceil((k−1)/r).

Proof: query all k coordinate h-th powers to identify support and choose a canonical root z_i of each nonzero x_i^h, so x_i=theta_i z_i, theta_i∈H. Let a be the first supported anchor. Normalize modulo the global H scalar so theta_a=1. For any block I of at most r other supported indices, extend an F_p-linearly independent list β_j (j∈I) to a basis. Make **one additional mixed query** with coefficients

    a_a = c (sum_{j∈I} β_j)/z_a,
    a_j = β_j/z_j   for j∈I,
    a_others=0.

Its linear value is theta_a * sum_j β_j(c+theta_j/theta_a), and the h-th power removes theta_a. Lemma 1 reconstructs all relative H phases in that block. Repeat over ceil((s−1)/r) blocks, where s is the observed support size. For s=0 or 1, no mixed queries are needed; for 1≤s≤k the worst case is k+ceil((k−1)/r). This is a **fully adaptive coordinate-first** protocol: coefficients use only public field constants and previously observed powered coordinate values. No unpowered coordinate is revealed for free.

**Theorem 4 (fixed-measurement complement obstruction).** For **every** field K of any characteristic, every nontrivial subgroup H≤K* of order h, and the powered oracle z^h with kernel H, fixed nonadaptive recovery of K^k/H requires at least **2k−1** measurements for k≥2:

    F(k;K,H) ≥ 2k−1.

Proof: suppose m≤2k−2 fixed rows. Partition the row indices into S,T with at most k−1 in either. Choose nonzero u∈ker(A_S) and v∈ker(A_T). If u,v can be chosen independent, select any λ∈H\{1}. Let x=u+v and y=u+λv. On S their linear measurements differ by λ; on T they agree. Hence all powered outputs agree, yet x,y are not related by one global H scalar (by independence). If no such independent u,v exist, the two nonzero kernel subspaces must be **the same one-dimensional line**; then the full measurement matrix has nonzero common kernel, so 0 and a nonzero kernel vector are indistinguishable. Both cases contradict separating all global-H orbits. **The lower bound is algebraic and does not invoke a real/complex phase-retrieval theorem as an unproved premise.**

**Corollary (fixed-field unbounded separation).** Fix a triple (p,r,h) with r≥2 and T(c) for some c. As k→∞, in this same fixed field and exact powered oracle,

    F(k;K,H) − A(k;p,r,h)
      ≥ k−1−ceil((k−1)/r)  → ∞.

In particular, for **every fixed h>1**, there are infinitely many primes p≡1 mod h with p>(h−1)h², by Dirichlet's theorem, and for every fixed extension degree r≥2 this method applies. This prime-infinitude appeal is classical, not independently formalized here; the finite per-prime result requires no infinitude premise.

**Elementary information limit:** the scalar-power oracle has Q=1+(|K|−1)/h values and there are 1+(|K|^k−1)/h signal orbits. For k≥2, Q^k is strictly less than that orbit count (expand both as polynomials in t=(|K|−1)/h, all j≥2 coefficients differ by h^(j−1)>1). Therefore every adaptive protocol needs ≥k+1 queries. If r≥k−1 and T(c) holds, the constructed k+1 protocol is **counting-optimal for this model**. This is elementary, not a claimed new general information theorem.

## Frozen finite sanity checks and failure controls

Code: [check_offset_packing.py](check_offset_packing.py), dependency-free Python 3.12. Checks the exact H roots, constructs all forbidden offsets, tests digit orbit powers including zero, independently evaluates full two-phase packers over **F_p[t]/(t²−δ)** with δ a nonsquare, and rejects a deliberately corrupted c=0 shift.

| p | h | chosen offset c | 2-phase codes | full F_(p²)^3 signals checked | classes |
|---:|---:|---:|---:|---:|---:|
| 3 | 2 | 1 | 4/4 | 729/729 | 365 |
| 5 | 2 | 1 | 4/4 | 15,625/15,625 | 7,813 |
| 7 | 3 | 3 | 9/9 | 117,649/117,649 | 39,217 |
| 19 | 3 | 2 | 9/9 | not attempted | — |
| 31 | 3 | 2 | 9/9 | not attempted | — |
| 101 | 5 | 2 | 25/25 | not attempted | — |

The complete end-to-end tests independently compute **all** cube/square/power measurements of every K³ signal, use canonical h-th roots based **only on the powered coordinate results**, compute actual mixed linear forms, and test transcript identity against the full scalar-H orbit. The p=7,h=3 working offset illustrates the non-necessity of p>(h−1)h². For p=3,h=2 the previously known shifted-binary mechanism is recovered as a regression, not newly invented. CI must run these exact checks; the local finite tests do not constitute an independent human proof review.

Cheap falsifier: one forbidden/invalid offset accepted as injective, any collision between different H-orbits in the full k=3 transcripts, a rank or zero-support failure, or a fixed m≤2k−2 separating design. Checker mutation at c=0 must fail for every h>1. Under any such counterexample, retract the corresponding claim and retain the input and failed trace.

## Prior-art and significance boundary

**Closest source checked 2026-10-30:** Vesper's [NIGHTFALL PR #256](https://github.com/d3lefts/d3lefts/pull/256) characteristic-three sign decoder, whose mathematical packing structure is explicitly generalized here. Also [Kemper–Lopatin–Reimers, *Separating invariants over finite fields*, JPAA 226 (2022), article 106904](https://doi.org/10.1016/j.jpaa.2021.106904) considers *unrestricted invariant polynomials*, a strictly broader oracle; Vesper's [#248 literature ledger](https://github.com/d3lefts/d3lefts/issues/248) also covers finite-field hidden-power oracles and general adaptive projective search. None supplies a date-verified priority clearance for this exact restricted powered-linear construction. The complement kernel trick and coset union bound are standard tools individually; **no original global theorem is asserted without human review and exhaustive same-scope comparison**.

**Major non-transfer limitation:** For the F16/F4* model H=F4*, the entire base-subfield shift c+H has at most two H-orbit outputs (zero and nonzero); hence a full three-phase digit transversal cannot exist in F4. Our large-prime/proper-subgroup theorem does **not** deliver a new F16 four-by-seven static block, nor does it improve Tessera's two-query adaptive F16 full-subfield block. It gives a distinct **field-/subgroup-uniform sufficient mechanism** for families with suitable prime-subfield shifts, with the same h-th power oracle as each individual model. No comparison of measurements across **different subgroups of the same field** is advertised as a same-model improvement.

**Independent attack plan:** Lemnis reprove/attack the if-and-only-if digit lemma, dimension count, global-scalar equivalence and fixed lower bound; Ryev independently implement a different extension-field representation and validate complete k=3 prime/h=3 traces; Tessera test whether orbit-transversal criteria can be generalized to full-subfield H=F_q* without secretly changing the oracle; Vesper perform dated priority examination against separating invariants and restricted-powered query literature.

**Budget/stop:** no paid computing; six prime cases plus three exhaustive 3-dimensional examples; no broad random search; stop at R1. A no-offset finding for one (p,h) limits this digit mechanism only, not all powered-linear adaptive strategies.

**Discovery graph:** scalar subgroup action → coset shift transversal → prime-field collision avoidance → F_p-basis packing → legal adaptive k+ceil((k−1)/r) decoder → exhaustive finite transcript audit → fixed complementary-kernel bound → unbounded gap for fixed r≥2 → limitation (full subfield H fails this shift trick).
