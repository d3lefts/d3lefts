# Exact all-depth pair-XOR fiber classification for binary tensor rows — 2026-11-22

**Status:** Source-level complete paper proof using published Lovitz–Petrov product-tensor splitting; exact frequency-histogram independent implementation checked for L=1..7. NOT an end-to-end Lean certificate; no worldwide novelty cleared. Refines the earlier tensor one-query M=2L+2 multiplicity bound, and feeds the rank-free two-query draft #1016.

## Theorem

For L≥1, let R_L be the 3^L product tensors from nonzero F2² local factors. For z≠0, let p_z be the number of unordered pairs of **distinct** original rows {a,b} with a XOR b=z.

Every frequency realized by such a pair is exactly one of these disjoint classes:

- **Product row** z∈R_L: p_z=L. There are exactly 3^L such frequencies.
- **Two-site rank-two frequency:** z∉R_L represented by a pair whose local factors differ in exactly two tensor sites: p_z=3. There are exactly 2·3^(L−1)·binom(L,2) such frequencies.
- **Three-or-more-site rank-two frequency:** z∉R_L represented by a pair whose factors differ in h≥3 sites: p_z=1. There are exactly 3^L·sum_{h=3}^L 2^(h−1) binom(L,h) such frequencies.

In the second and third cases, distinct representations necessarily have the stated Hamming-distance type: a two-site pair never represents the same z as a three-or-more-site pair.

The ordered nonzero XOR-fiber multiplicity for D_L=R_L∪{0} is therefore exactly

    M_L = max_{z≠0} #{(a,b)∈D_L² : a XOR b=z} = 2L+2.

This sharp M_L was already present as an author-level bound in prior NIGHTFALL one-query work; the complete frequency distribution and the proof through product-circuit support are the additional detail here. Do not claim that the pair bound M_L is entirely new.

## Proof

For any ordered starting row a, choosing the exactly h varying factor positions and one of the two other nonzero local factors at each position gives binom(L,h) 2^h choices of second row. Dividing by two gives 3^L 2^(h−1) binom(L,h) **unordered** pairs differing in exactly h tensor sites.

**h=1.** Their XOR has exactly the same fixed factors except at the unique changed site; the sum of two distinct nonzero vectors of F2² is the third nonzero vector. Thus the output is itself a product row. Conversely for any product row z and any choice of one site i, choose the other two nonzero vectors at that site, keep z's factors elsewhere: one pair. Such representations are exactly L, and no pair varying ≥2 sites has rank-one sum (see flattening below).

**h=2.** After factoring out the common nonzero factors at other sites, the XOR of the two product rows is a 2×2 matrix M over F2 of rank two. Every decomposition M=uvᵀ+u'v'ᵀ with nonzero rank-one summands requires (u,u') and (v,v') each be bases. There are |GL₂(F₂)|=6 ordered first bases; each uniquely determines the second basis, and unordered pairs are counted twice. Thus exactly three local pair decompositions.

To show no alternative pair varies outside the original two sites, suppose {a,b} and {c,d} represent the same nonzero z with distinct unordered pairs. They have no common row (otherwise equality forces identical pairs). The four distinct nonzero pure tensors XOR to zero, and form a circuit: a proper zero subset of size 1 or 2 is impossible, and if three summed to zero, the remaining fourth would be zero. The published Lovitz–Petrov splitting theorem (Theorem 4) then gives at most |E|−2=2 varied factors in this four-tensor circuit. The first pair already varies at two sites; hence every factor outside those two sites is common to all four rows. Consequently all representations come from the same local 2×2 problem, proving p_z=3.

**h≥3.** Any distinct alternative pair would give the same four-element circuit, but the original pair already varies at h≥3 sites, contradicting the Lovitz–Petrov upper support bound two. Hence p_z=1.

A pair with h≥2 cannot have a rank-one sum: flatten the tensor at any site where the local factors differ versus all remaining sites. Both left factors are independent (over F2, any two different nonzero vectors in dimension2 are independent), and the two right tensor factors are distinct and nonzero if at least one other site differs. A sum of two elementary matrices with independent left and right factors has rank two. This also separates the row class from the non-row classes.

Counting frequencies follows by dividing the numbers of h=1 pairs by L and of h=2 pairs by 3; h≥3 pairs have unique frequencies. Finally for z∈R_L, ordered D_L² representations comprise 2L ordered nonzero pairs plus (0,z) and (z,0): 2L+2. For z outside R_L the ordered multiplicity is 2 or 6, both bounded by 2L+2 for L≥2; L=1 has no non-row pairs. So M_L=2L+2.

The sole external high-level ingredient is Lovitz–Petrov (2023): https://doi.org/10.1017/fms.2023.20 . The complete rank-two matrix classification uses elementary GF₂ linear algebra.

## Exact audit and verification boundary

The independent C++ pair-XOR histogram checker constructs *all* n(n−1)/2 unordered pairs for n=3^L, aggregates exact XOR frequencies with 128-bit integer tensor masks, and checks the three classes plus their predicted counts through L=7. The same checker independently confirms primitive four-row coefficients through level seven.

This is finite execution, not a proof of the quoted all-L splitting theorem or a Lean kernel check of the current theorem. The previously kernel-certified #977 tensor-subspace intersection theorem and #1029 cancellation lemmas have different statements. Next Lean target: exact L=2 nonrow pair-multiplicity 3 and full source L=3 histogram; then all-L circuit support formalization or a verified external splitting interface. Counterexamples or failed CI must demote the claim.
