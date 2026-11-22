# Primitive XOR-fiber polynomial for pure tensor targets — v1 (2026-11-22)

**Status: paper-level derived theorem with exact finite coefficient checks, not a Lean theorem or a global priority clearance.** This is a distinct structural refinement of #1016 and does not certify its unrestricted two-query quantum simulator.

## General theorem

Let R_L be the 3^L rank-one tensor rows from all nonzero local F2² factors, and fix z in R_L. Let A_k(L,z) count unordered k-element subsets C of distinct rows with XOR(C)=z and no nonempty subcollection of C having XOR zero. Call these primitive representations.

For every fixed k≥1 there are nonnegative integers a_{k,j}, independent of L, with

    A_k(L,z) = sum_{j=0}^{min(k-1,L)} a_{k,j} binom(L,j).

Coefficient a_{k,j} counts primitive k-row representations of e0^tensor j at depth j that vary at **every** one of the j tensor sites. Consequently each fixed-k count is a polynomial of binomial type in tensor depth L of degree at most k-1. This is an exact all-L statement, not extrapolation from small L.

For k≤4 the coefficient table is:

| k | nonzero support-specific coefficients |
|--|--|
| 1 | a_{1,0}=1 |
| 2 | a_{2,1}=1 |
| 3 | a_{3,2}=4 |
| 4 | a_{4,2}=5, a_{4,3}=30 |

All omitted coefficients for k≤4 are zero. Thus for *every* original row z,

    A_1=1; A_2=L; A_3=4 binom(L,2);
    A_4=5 binom(L,2)+30 binom(L,3).
    Sum(k=1..4) A_k = 1+L+9 binom(L,2)+30 binom(L,3).

These are unordered, distinct, primitive sets. They are not the full ordered quantum path multiplicity, and not a formula for non-row Fourier frequencies.

## Proof via published tensor splitting (source-exact)

1. Coordinatewise GL2(F2) maps any given z in R_L to e0^tensor L, permutes the three nonzero factors at each site, and preserves row distinctness and XOR relations.
2. For k=1 the only primitive set is {z}. For k≥2 a primitive representation C cannot contain z: if it did, C without z would be a forbidden nonempty zero-XOR subset. Since XOR(C)=z, E=C union {z} is a minimally dependent product-tensor family of size k+1. Indeed, an XOR-zero proper subset not containing z contradicts C's primitivity; one containing z forces its nonempty complement inside C to XOR zero, another contradiction. Over F2 a minimally dependent family is a circuit.
3. By the contrapositive of **Lovitz–Petrov, Theorem 4**, Forum of Mathematics, Sigma 11 (2023), e27, https://doi.org/10.1017/fms.2023.20, a connected product-tensor circuit E obeys sum_i(d_i-1) ≤ |E|-2 = k-1, where d_i is the local-factor span dimension. Here d_i is 2 exactly at sites where some source row differs from target factor z_i, otherwise 1. Thus variation support S has cardinality at most k-1.
4. At every site outside S, all source rows have exactly the same nonzero factor as z. Delete these fixed factors. Tensoring back by nonzero fixed factors is injective, so this deletion preserves XOR equality, nonvanishing of every subcollection and distinctness. It gives a bijection between primitive representations whose *exact* variation support is S and the full-variation primitive representations of the depth-|S| canonical target.
5. Choose S in binom(L,j) ways; for each such S, exactly a_{k,j} local configurations exist. Summing over disjoint supports proves the displayed all-k polynomial.

The only external mathematical ingredient is the published Lovitz–Petrov splitting theorem; do not attribute it to NIGHTFALL. The explicit support counts are a finite computational theorem amenable to Lean decidable certification. Full symbolic source-level Lean verification of all-L tensor circuits is **still open**.

## Independent coefficient enumeration and additional exact identity

A direct independent exhaustive checker at depth L=3, using the 27 masks of R_3, classifies primitive k-row XOR representations of the target row by their joint support size:

| k | support 0 | support 1 | support 2 | support 3 |
|--|--:|--:|--:|--:|
|1|1|0|0|0|
|2|0|3|0|0|
|3|0|0|12|0|
|4|0|0|15|30|

This gives the per-chosen-support coefficients 1,1,4,5,30 above. Source-level finite checks must still be elevated into Lean; a script pass is not a kernel certificate.

For a second algorithm, define p_z as the number of unordered distinct row pairs XORing to z. For any nonzero z, the number of **distinct four-row sets** XORing to z (without the primitive filter) satisfies the exact pair-convolution identity

    F_z = [sum_v p_v p_{v XOR z} - 2(n-2) p_z] / 6,  n=3^L.

Every distinct quadruple is counted six times by ordered pair-of-pairs; overlapping pairs contribute exactly 2(n-2)p_z spurious counts. Let T0=(sum_{r in R_L} p_r)/3 be the number of zero-XOR three-row sets. For z in R_L,

    A_4(L,z) = F_z - (T0-p_z),
    A_3(L,z) = [sum_{r in R_L}p_{z XOR r}-(n-1)]/3.

Since every original row has exactly p_z=L representations by pairs, the total zero-triple census is T0=L*3^(L-1).

Independent integer pair-convolution testing through L=7 matches all exact formulas (canonical e0 and a second independent row target); there is no floating point and no four-tuple enumeration at deeper levels.

| L | rows | distinct pair-XOR fibers | zero triples | primitive at row, sizes ≤4 | primitive four-row count |
|---:|---:|---:|---:|---:|---:|
|1|3|3|1|2|0|
|2|9|15|6|12|5|
|3|27|189|27|61|45|
|4|81|2349|108|179|150|
|5|243|25191|405|396|350|
|6|729|247131|1458|742|675|
|7|2187|2316033|5103|1247|1155|

## Novelty and next decisive test

The sharpened four-row count is 5 binom(L,2)+30 binom(L,3), vs the earlier ≥binom(L,3) construction in #1016. This sharp count applies to **row targets only**. The more general binomial-polynomial mechanism may transfer to fixed higher query orders; no general T-query simulator follows without arbitrary-frequency and Hilbert-energy control.

Targeted 2026-11-22 search found no clearly matching published explicit polynomial formula, but this is **not** global originality certification. Retain the published LP attribution, the exact model and the absence of a full Lean proof. Next: independent per-support local enumeration in Lean on the source L≤3 tensor rows; independent audit of support-bijection details; test non-row frequency behavior separately. Do not promote the quantum simulation claim.
