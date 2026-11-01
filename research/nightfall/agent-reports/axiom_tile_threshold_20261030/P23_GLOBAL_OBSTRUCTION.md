# P23 global resolution: centrally symmetric squared-code obstruction

**Status:** R1 internal proof candidate; independent human review and historical-priority review open. Do not merge, publish, or promote as Original Finding.

## Theorem
Let G=(F_p)^d be an elementary abelian group for odd prime p. Let A be centrally symmetric, A=s-A, and let n=|A|. For each m in G define r_A(m)=|{(a,b) in A^2: a+b=m}| (ordered representations). Then

    r_A(m) >= n - p^(d-1)(p-1)/2

for every m. If n >= p^(d-1)(p-1)/2+2, then every m has an off-diagonal representation a!=b, so **no translate c+A has injective squaring in GF(p^d)**.

## Proof
Central symmetry implies m-A = A+(m-s). Thus

    r_A(m) = |A intersect (m-A)| = |A intersect (A+t)|, t=m-s.

For t=0 the quantity is n. Otherwise t has additive order p, and G partitions into p^(d-1) cyclic orbits, each of length p. A subset of k vertices on an odd p-cycle has at least k-(p-1)/2 adjacent occupied pairs (it has at most p-k runs of occupied vertices, with the full cycle handled separately). Summing these lower bounds gives the inequality.

For n at least the specified threshold plus two, r_A(m)>=2 for every m. In odd characteristic, at most one ordered representation of m is diagonal, since 2a=m has a unique solution in G. Hence some a!=b sum to m. Setting m=-2c gives c+a = -(c+b), distinct points with equal squares. QED.

## Exact p=23 application
For G=F_23^2 the group has 529 elements and 23 cycles of length 23 for each nonzero translation. The maximum independent occupancy over those cycles is 23*11=253. Any proper eight-generator binary cube has 256 vertices, is centrally symmetric about half the sum of its generators, and satisfies

    r_A(m) >= 256-253 = 3

for every m. Therefore eight-sign squared-injective coding is impossible **for all generator choices and translations**, not just the rectangular families excluded by this PR.

The structural upper bound for a centrally symmetric injective squared code is 254 vertices (versus the information-only 265 square outputs). This leaves at most seven binary signs.

## Matching seven-sign witness
Work in K=F_23[u]/(u^2-5), where 5 is a quadratic nonresidue. Let the affine anchor be c=(4,4), with binary generators

    (1,0), (2,0), (4,0), (8,0), (0,1), (0,2), (0,4).

The 128 code points lie in [4,19] x [4,11], and all are distinct. Negation sends their second coordinates into [12,19], disjoint from [4,11]. No two distinct code points are negatives, so squaring is injective. The exact-field script check_p23_seven_signs.py additionally computes all 128 squares.

Thus **b(23)=7 for the specified single squared-field observation and affine binary-sign cube model**.

## Audit and limitations
- check_p23_odd_cycles.cpp exhausts every one of the 2^23 occupancy patterns of C_23, recovering exact minimum adjacent-pair counts by occupancy k.
- check_p23_small_symmetric.py exhausts 32 symmetric subsets of F_3^2 and 8192 symmetric subsets of F_5^2, checking overlap identity, lower bound and distinct-pair condition.
- check_p23_seven_signs.py verifies irreducibility and all 128 squares in GF(23^2).
- No proof of novelty or of implications for non-centrally-symmetric symbol sets.
- No change to any production site or PR merge without human authorization.
- Related but not exact-model sources: Bedert, On Unique Sums in Abelian Groups (Combinatorica 44, 2024); Han and Ren, When Do Restricted Sumsets Cover a Finite Abelian Group? (arXiv:2610.14496, 2026).

## Independent referee attack requests
Check reflection-to-translation identity; cyclic orbit lengths; counting with one diagonal; characteristic-two exceptions; code construction and field irreducibility; exact scope of the affine cube oracle; and dated prior art before novelty claims.
