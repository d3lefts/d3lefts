# R1: sharp odd-exponent central-symmetry obstruction (2026-10-31)

**Internal AI-assisted proof candidate; no external human referee or historical-priority certification. Keep PR #284 draft and unmerged.**

## Exact sharp theorem
Let G be a finite abelian group of odd order N>1 and exponent e. A set A is centrally symmetric if A=s-A. The maximum |A| over such A for which some translate D=c+A contains no distinct opposite pair {x,-x} is

    N(e-1)/(2e) + 1.

In an odd-characteristic field this is equivalent to injectivity of x→x² on D. For elementary abelian G=Fp^d the bound is p^(d-1)(p-1)/2+1. **Attainment is for arbitrary centrally symmetric sets, not necessarily affine binary cubes.**

## Proof: upper bound
For A=s-A, write m=-2c and t=m-s. The ordered pair-sum representation count satisfies

    r_A(m)=|A ∩ (m-A)|=|A ∩ (A+t)|.

If D=c+A has no distinct opposite elements, then r_A(m)≤1 (only a possible diagonal). If t=0 this forces |A|≤1. Otherwise t has odd order l≤e. G decomposes into N/l cycles of length l under translation by t. On each cycle a vertex set of size k with a adjacent selected pairs satisfies k≤(l-1)/2+a: delete at most one endpoint for every adjacency to leave an independent set, and the independent-set number of an odd l-cycle is (l-1)/2. Summation gives

    |A| ≤ N(l-1)/(2l)+r_A(m) ≤ N(e-1)/(2e)+1.

## Proof: sharpness
Choose t of order e and H=<t>. The quotient G/H has odd order, so all nonzero cosets pair with their negatives. Let h=(e-1)/2. For one coset of each negative pair, select positions {0,2,4,...,e-3} in the t-coordinate (h mutually nonadjacent vertices); in its negative coset select exactly the negatives of those vertices. In the invariant coset H, take a symmetric h+1-set with precisely one adjacent pair:
- if h even: {0, ±2t, ±4t, ..., ±h t};
- if h odd: {±t, ±3t, ..., ±h t}.

The resulting A=-A has N(e-1)/(2e)+1 elements and exactly one adjacent pair under translation by t. Setting c=-t/2 makes D=c+A contain exactly one element in D∩(-D), necessarily 0. Hence no two distinct elements are negatives, proving sharpness.

## Transfer to squared-field observations
For K=GF(p^d), p odd, the information alphabet has (p^d+1)/2 squares. The structural upper bound for an affine binary cube is

    b_sq(p,d) ≤ floor(log2(p^(d-1)(p-1)/2+1)),

which can be strictly lower than the information-only floor(log2((p^d+1)/2)). Exact integer exhaustive scan of every odd prime p≤200,000, dimensions d=2,3,4, finds precisely:
- d=2: p=23 (8→7 bits; 265 vs 254 codeword ceiling).
- d=3: p=13 (10→9; 1099 vs 1015), p=3251 (34→33).
- d=4: p=3 (5→4; 41 vs 28), p=5 (8→7; 313 vs 251), p=4871 (48→47), p=55109 (62→61).

These are upper bounds only, except p=23,d=2 where the 7-bit lower construction is verified in P23_GLOBAL_OBSTRUCTION.md. Scan makes no claims beyond the stated p,d range. A p=23 symmetric sign-separated set of 254 points exists but is not a 256-vertex 8-bit affine cube, and thus does not contradict b_sq(23,2)=7.

## Adversarial audit and provenance
- Test 0-translation separately.
- Distinguish the general sign-separation problem from field squaring; characteristic 2 is excluded.
- In odd abelian groups nonzero t can have different orders. The exponent e, not the smallest prime divisor of N, controls this extremal construction.
- Independently test cyclic composite groups and products, not just Fp^d.
- The earlier rectangular obstruction is now a special-case check, not evidence for the universal bound.
- **Novelty not established:** odd-cycle independent-set bounds and restricted sumset representation methods are classical. Relevant context: B. Bedert, *On Unique Sums in Abelian Groups*, Combinatorica 44 (2024), DOI:10.1007/s00493-023-00069-w; *Restricted sumsets in a finite abelian group*, Discrete Math (2009), DOI:10.1016/j.disc.2009.06.028; Han–Ren arXiv:2610.14496 (Oct 2026). None established here as an exact-model priority precedent.
- External notation warning: Bedert already uses b(p) for an unrelated balanced-set invariant; distinguish our b_sq(p,d).

**Decision:** Preserve as theorem candidate and exact certificates, not as globally novel result or new published theorem. Next research targets the stricter binary-cube structure below this sharp symmetric-set barrier.
