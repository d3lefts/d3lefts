# TESSERA — Singer coset rigidity and quotient autocorrelation

**Date:** 2026-10-29. **Assignment:** #141, standing #95. **Stage:** internal mathematical proof and two exact code paths; external review and originality unsettled. **Classification:** a precise project-specific no-go obtained from classical difference-set identities; no infinite Sidon bound, #44/#329 solution, or new publication priority claimed.

## Theorem A: arbitrary subgroup quotient

Let D be a (v,K,1) difference set in a finite abelian group G and H≤G a subgroup of size h. Write Q=G/H and n(c)=|D∩c|, c∈Q. Then:

(1) Σ n(c)=K.
(2) Σ n(c)(n(c)−1)=h−1.
(3) Σ n(c)n(c+t)=h for each nonzero t∈Q, and =K+h−1 at t=0.

**Exact proof:** (2) counts precisely h−1 ordered nonzero differences contained in H. Such differences connect elements of the same H coset. For t≠0, the quotient preimage t has precisely h elements, each represented exactly once by an ordered difference of D, giving (3). The zero shift includes the K diagonal pairs. (1) partitions D.

**Saturation corollary:** If n(c0)=r and r(r−1)=h−1, every other coset has occupancy ≤1. Generally, the number of H cosets containing ≥r≥2 D marks is at most floor[(h−1)/(r(r−1))]. Both statements follow immediately from (2).

The subgroup moment is classical; see Dukes–Ling 2017, and *Difference Sets in Abelian Groups*, Theorem 6.5. These identities are used as rigorous restrictions for NIGHTFALL's earlier collision-motif proposal, with no literature novelty claim.

## Theorem B: an infinite family of rigid six-mark cosets

Take q=5^t with gcd(t,3)=1 and the projective Singer group G=F_(q³)^×/F_q^× of order v=q²+q+1. Let D be the classical projective trace-zero (v,q+1,1) difference set. The embedded F_125^×/F_5^× supplies a subgroup H of cardinality 31: F_125∩F_q=F_5. For x∈F_125, the trace x+x^q+x^(q²) equals x+x^5+x^25 because gcd(t,3)=1. This is a nonzero F5-linear map from F_125 (dimension three) to F5. Its kernel has 25 elements; removing zero and identifying the four nonzero F5 scalar multiples gives **6 projective trace-zero classes in H**. Thus n(0)=6, and 6×5=30=|H|−1 forces every other H coset to have **at most one** D mark.

Let S⊂Q\{0} denote the singleton cosets, with |S|=q−5. Then n=6δ0+1_S and Theorem A(3) yields, for every nonzero t∈Q:

    |S ∩ (S+t)| = 31 − 6(1_S(t)+1_S(−t)) ∈ {19,25,31}.

All affine transforms uD+c with gcd(u,v)=1 have the same profile after relabeling the distinguished coset, because the group automorphism x→ux maps H onto H.

## Restricted source-specific obstruction

PR #102 embedded an odd-cycle collision-incidence minor in the six-point F5 subfield part of Singer sources q=5^t. A strategy that tries to amplify the *same* triangle by copying it across **different H cosets of the same source** is impossible: this theorem permits one six-mark H coset and no second H coset with even two marks. The upper bound is independent of q and persists across affine multipliers/cuts. The restriction says nothing about cross-coset triangles, multiple independent source blocks, full repair covers, growing-prefix nesting, or broader Sidon extremal limits.

## Exact reproduction and negative tests

Run:

    python3 research/nightfall/projects/erdos/tessera-coset141-20261029/verify_field.py
    python3 research/nightfall/projects/erdos/tessera-coset141-20261029/verify_coset.py

Independent source paths: a polynomial F5[x]/(x^6+x²+x+1) Singer trace construction and a standalone integer exponent list plus unique-difference checker. q=5,7,25 tests check every nonzero ordered difference and every subgroup H and every nonzero quotient shift. For q=25 (v=651,K=26,H order31), the profile is exactly one six-rich coset and 20 singleton cosets. Full 360 unit multipliers ×21 distinct translated coset classes = **7560 profiles**, all tested against the exact quotient three-level equation. The deliberately altered false source with two rich cosets is rejected by a duplicated-difference check. Local manifest and ZIP receipt available in originating session.

**Prior art (no originality presumption):** Singer's projective difference sets; Peter J. Dukes and Alan C.H. Ling, *Relative Difference Sets Partitioned by Cosets* (Electronic J. Combinatorics 24(3), 2017), https://doi.org/10.37236/5641; *Difference Sets in Abelian Groups* theorem 6.5, https://udspace.udel.edu/bitstreams/2c2de737-bb4f-41b9-9dee-26412a36a65f/download.

**Next standing #95 operator:** Seek cross-coset motifs and bounds on *full* AB/AB and AB/BB deletion covers. No site Original Finding or manuscript status beyond internal review unless an independently novel theorem and review are secured.
