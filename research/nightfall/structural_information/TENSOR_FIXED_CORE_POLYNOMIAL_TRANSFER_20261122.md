# Fixed-core finite-to-infinite polynomial law for primitive binary tensor decompositions

**Version:** v1, 2026-11-22. **Status:** Paper theorem derived from the published Lovitz–Petrov 2023 tensor-splitting theorem; independent exact C++ check through L=7 and unrelated direct brute enumeration L=2..4 for the example. No all-depth Lean terminal, no specialist referee or worldwide novelty clearance. This is a distinct bridge beyond the pure-row polynomial law. The theorem does not certify unrestricted T=2 quantum simulation.

## Theorem — arbitrary fixed tensor core

Let V_L=(F₂²)^{⊗L} and R_L be its full family of nonzero product tensors. Fix depth d≥1 and any nonzero core z∈V_d of product-tensor rank r≥1. Extend to L≥d by z_L=z⊗e₀^{⊗(L−d)}. Let A_k(L,z_L) count unordered sets of k **distinct, nonzero product rows** that XOR to z_L and whose every nonempty subset has nonzero XOR.

Then, for every fixed k≥1, there are nonnegative integers a_{k,j}(z) such that

    A_k(L,z_L) = Σ_{j=0}^{min(L−d, r+k−2)}
                       a_{k,j}(z) * binom(L−d,j).

In particular, for a fixed core and fixed k, the count is an exact binomial polynomial in the number of appended tensor factors, of degree at most r+k−2. Each coefficient counts source representations using **exactly** j appended sites, and can be certified by finite computations at depths d+j. No asymptotic approximation or large-L interpolation is required.

### Proof of the support bound

Choose a minimal r-row product representation C of core z and extend each row by common factor e₀ on the appended sites. This reference is primitive: a zero-XOR nonempty subcollection could be deleted to shorten the rank-r representation. Fix any primitive competitor C' of size k, possibly sharing some reference rows. In characteristic two, the symmetric difference C Δ C' has total XOR zero.

Partition this symmetric difference into pairwise disjoint **circuits** by repeatedly removing a minimal nonempty zero-XOR subset. Because neither C nor C' contains a nonempty zero-XOR subset, every circuit E_i intersects both C\C' and C'\C. Let r_i≥1, k_i≥1 denote their respective element counts. The published Lovitz–Petrov splitting theorem (Theorem 4 / circuit corollary, Forum Math. Sigma 11 (2023), e27) gives at most |E_i|−2=r_i+k_i−2 varying tensor sites in each circuit. This is valid in F₂, and for L=1 the local bound follows directly.

Every competitor row that is also a reference row has fixed factor e₀ on appended sites. Every other competitor row lies in some circuit containing at least one reference row, so each site where that row differs from e₀ is varying in that circuit. Consequently, if C'≠C, the union S of varied appended sites satisfies

    |S| ≤ Σ_i(r_i+k_i−2) ≤ r+k−2c ≤ r+k−2,

where c≥1 is the number of circuits. If C'=C, S is empty. The proof does not require the sites of distinct circuits to be disjoint.

Outside S all competitor rows have the common e₀ factor. Removing those factors preserves the XOR equation, row distinctness and subset nonvanishing, because tensoring with a nonzero pure factor is injective. Thus for each support S of size j, there are exactly a_{k,j}(z) local primitive configurations of depth d+j varying at every appended site, independent of the positions of S. Sum over binom(L−d,j) possible supports. This proves the theorem.

**Caveats:** The all-depth bound on circuit variation is a published theorem, not independently proved here. This paper proof still needs an external referee to certify its application to the symmetric-difference circuit partition. A purely conditional Lean formalization would not be an unconditional kernel proof of the polynomial law.

## Sharper special case: fixed two-site rank-two core

Take z₂=e₀⊗e₀ + e₁⊗e₁, a rank-two matrix in F₂²⊗F₂², and z_L=z₂⊗e₀^{⊗(L−2)} for every L≥2. Use reference rows C={e₀⊗e₀,e₁⊗e₁}, extended by e₀ factors. The two reference rows differ in **two core tensor sites**.

For any circuit meeting only one reference row, its appended-site variation is ≤k_i−1. For a circuit meeting both reference rows, the two core sites already vary, so appended-site variation is ≤(2+k_i−2)−2=k_i−2. Summing these contributions yields ≤k−1 varied appended sites for any primitive k-row competitor. Thus in this case the degree cap improves from r+k−2=k to **k−1**.

The exact finite pair-XOR contraction gives the following depth-2 through depth-5 data, and a distinct direct row-subset enumerator checked depths 2,3,4:

| L | primitive pairs | primitive triples | primitive quadruples |
|--:|--:|--:|--:|
| 2 | 3 | 7 | 6 |
| 3 | 3 | 13 | 60 |
| 4 | 3 | 19 | 144 |
| 5 | 3 | 25 | 258 |

The degree bounds and binomial inversion give all nonzero support coefficients. For quadruples (j=0,1,2,3) the coefficients are **(6,54,30,0)**; for triples (j=0,1,2) they are (7,6,0); for pairs (j=0,1) they are (3,0). The zero cubic coefficient is certified by the L=5 source count, not conjectured by polynomial fitting.

Therefore, **for every L≥2**, the precise primitive representation counts for the fixed rank-two target are

    A1 = 0
    A2 = 3
    A3 = 7 + 6(L−2) = 6L−5
    A4 = 6 + 54(L−2) + 30*binom(L−2,2)
       = 15L²−21L−12
    A1+A2+A3+A4 = 15L²−15L−14.

At L=2 the total is 16, versus 12 for a pure-row frequency, explaining the small-level negative control. At L=3 the fixed-core rank-two total is 76, versus 61 for pure rows, though the **global** nonrow maximum is 84 at another frequency. These are distinct scopes.

The exact independent C++ pair-XOR checker [check_tensor_fixed_rank2_fibers.cpp](check_tensor_fixed_rank2_fibers.cpp) verifies the closed form for L=2,3,4,5,6,7; at L=7 the counts are A2=3, A3=37, A4=576, total 616.

## Why this matters and what it does not settle

**Mechanism transfer:** A published upper bound on the variation support of matroid circuits converts global representation counting over arbitrarily many tensor factors into a finite coefficient table. For any **fixed** core tensor and fixed query path length, the counting problem is polynomial in the number of extra factors. The rank-two example is an exact non-pure family, not merely a pure-row special case.

**Remaining gap to quantum simulation:** Frequencies generated by four tensor rows may have a core whose complexity grows with L. The constant-coefficient fixed-core theorem does not give a uniform K_L bound over *all* frequencies. The unrestricted complex-Hilbert coefficient-energy lemma and original oracle-to-query equivalence remain separate. The full T=2 theorem in archived PR #1016 remains provisional under issue #1021.

**Novelty:** The Lovitz–Petrov splitting theorem is prior art; the fixed-core polynomial transfer and explicit rank-two coefficients were derived here as potential new corollaries. A targeted date-stamped search did not find these exact statements, but there is no independent worldwide priority certificate or human review. No publication claim or merge as a completed T2 theorem.


## Critical prior-art reconciliation (2026-11-22)

**Haoming Wang and Ming Yuan**, *Structure and Exact Certification of Nonnegative Tensor Decompositions*, arXiv:2610.32787 (posted **October 23, 2026**), Theorem 4.3, already use Lovitz–Petrov splitting to prove that an irreducible exchange between p supplied and q competing tensor terms has effective order **at most p+q−2**, independently of the number of tensor modes, with sharpness constructions. Source: https://arxiv.org/abs/2610.32787 .

This is materially closer prior art than generic rank-decomposition literature: the mechanism of comparing decompositions, localizing active modes, and eliminating inert tensor factors **is not a novel NIGHTFALL discovery**. Their model concerns nonnegative real tensor decompositions, positive exchanges and exact algorithms, whereas the present count concerns primitive binary XOR fibers, finite-field characteristic two, explicit nonnegative-integer binomial coefficients and an exact fixed-rank-two primitive count. No evidence located that their paper states the latter combinatorial formulas; nevertheless it substantially reduces the novelty scope of the general fixed-core support argument.

**Priority gate and attribution:** Explicitly credit Wang–Yuan 2026 alongside Lovitz–Petrov 2023 in any paper, proof passport or public claim. Claim only a *candidate finite-field enumerative specialization and exact coefficients*, never the general active-mode exchange bound or the independent invention of the dimension-reduction operator. A specialist must compare Wang–Yuan Theorem 4.3 and Sections 3–5 source-level before declaring novelty. Do not promote the fixed-core polynomial theorem to "novel contribution" until that review.
