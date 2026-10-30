# Axiom / base-subfield orbit-transversal phase packing

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

## Stronger base-field formulation (supersedes prime-only restriction)

The proof of Lemmas 1–2 and Theorems 3–4 uses only finite-field axioms; **primality of the base field and odd characteristic are unnecessary**. The correct general statement is:

Let **q be any prime power**, r≥1, K=F_(q^r), and H≤F_q* have order h>1. Observe **exactly** (a·x)^h over K, modulo a single global scalar in H. If there is c∈F_q for which eta↦(c+eta)^h is injective on H, then for all k≥2:

    adaptive(k;K,H) ≤ k+ceil((k−1)/r),
    fixed(k;K,H) ≥ 2k−1.

The shift condition is guaranteed by **q>(h−1)h²**: the forbidden list B={(g v−u)/(1−g):g∈H\{1},u,v∈H} has at most (h−1)h² elements even when q is composite. The tower K/F_q supplies an r-element basis. In the lower-bound proof, λ∈H\{1} is enough; there is no reliance on the distinctness of −1 or on characteristic three.

**Why this improves the generality of the candidate:** it covers nontrivial H of odd order in characteristic two, not only ±1 sign ambiguity in odd characteristic. It also identifies the exact testable obstruction for this *one-row digit-packing operator* at each (q,H), while preserving every observation and global quotient in a fixed ambient field.

**Characteristic-two concrete example (independent exact checker).** Take q=16, K=F256, H=F4*={1,6,7} (a full F4 phase subgroup, inside the F16 base field), and unchanged cubic output z³. Represent F16 as F2[z]/(z⁴+z+1), and F256 as F16[u]/(u²+u+8), with Tr_F16/F2(8)=1. The offset c=2∈F16 separates all **nine H² phase words** by one powered F256-linear form:

    (eta_1,eta_2) ↦ ((2+eta_1)+(2+eta_2)u)^3.

The [tower verifier](check_f256_subfield_escape.py) checks each output and all 16 offsets; successful c are 2,3,4,5,8,9,10,11,12,13,14,15. All c∈F4={0,1,6,7} fail; this is the **full-subfield shift obstruction** in the smaller base field, not an impossibility of escaping it in F16. **Crucial scope:** K is F256 here, not the previously studied F16 ambient field. This does not improve Tessera's F16 adaptive optimum, and is not a two-query F16 result.

For each fixed qualifying K/F_q with r≥2, the same gap lower bound grows as k−1−ceil((k−1)/r). For r≥k−1, the information bound gives exact k+1. The additional F256 test is a **finite phase block**, not a 16-million-signal exhaustive full decoder; that universal transfer is a mathematical claim supported by the written proof, requiring independent review.

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

**Major non-transfer limitation:** In the ORIGINAL F16/F4* sensing model, a shift c restricted to F4 cannot pack all three phases, since c+H is contained in F4 and has at most two H-orbit outputs (zero and nonzero). The new F256 construction permits c∈F16 and therefore uses a DIFFERENT ambient field; it is not an F16 result. Our large-prime/proper-subgroup theorem does **not** deliver a new F16 four-by-seven static block, nor does it improve Tessera's two-query adaptive F16 full-subfield block. It gives a distinct **field-/subgroup-uniform sufficient mechanism** for families with suitable prime-subfield shifts, with the same h-th power oracle as each individual model. No comparison of measurements across **different subgroups of the same field** is advertised as a same-model improvement.

**Independent attack plan:** Lemnis reprove/attack the if-and-only-if digit lemma, dimension count, global-scalar equivalence and fixed lower bound; Ryev independently implement a different extension-field representation and validate complete k=3 prime/h=3 traces; Tessera test whether orbit-transversal criteria can be generalized to full-subfield H=F_q* without secretly changing the oracle; Vesper perform dated priority examination against separating invariants and restricted-powered query literature.

**Budget/stop:** no paid computing; six prime cases plus three exhaustive 3-dimensional examples; no broad random search; stop at R1. A no-offset finding for one (p,h) limits this digit mechanism only, not all powered-linear adaptive strategies.

**Discovery graph:** scalar subgroup action → coset shift transversal → prime-field collision avoidance → F_p-basis packing → legal adaptive k+ceil((k−1)/r) decoder → exhaustive finite transcript audit → fixed complementary-kernel bound → unbounded gap for fixed r≥2 → limitation (full subfield H fails this shift trick).
