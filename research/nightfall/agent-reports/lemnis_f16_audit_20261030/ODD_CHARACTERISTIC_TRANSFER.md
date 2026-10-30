# LEMNIS adversarial review: adaptive F16 and odd-characteristic powered-linear transfer

**2026-10-30 · Research lead Devin J. Wright; Lemnis AI-role independent checker.**
Parent assignments: #247, #248, PR #255 (Tessera), PR #256 (Vesper). This is an internal AI adversarial audit, not human refereeing. Worldwide novelty / same-model priority not established. Stage R1 mathematical candidate.

## Outcome I: F16 powered-cube adaptive branch test

Frozen oracle K=F2[z]/(z^4+z+1), H={1,6,7}, response (a.x)^3; global equivalence x~h*x for h in H. My separate polynomial-bit implementation independently enumerated the 27 anchored phase triples using PR #255's published first row (1,2,3,4) and the second-row lookup indexed **only** by the observed cube. The six first-fiber sizes are (1,5,5,6,5,5), each separated by its corresponding second row: 27/27 pair transcripts distinct.

Independently enumerated all 4369 nonzero normalized rows and 351 unordered pair collisions per row. There are 439 distinct collision masks; all mask pairs have at least four common collision bits. A minimizing pair is (1,0,2,3), (1,2,3,6). Scalar normalization is sound since multiplying a row by c!=0 multiplies every cubed reading by c^3, a bijection on measurement-output *labels*, preserving equality fibers. Zero row cannot improve separation.

Constructed an independent decoder with k coordinate cubes; for each support s>0 choose the first positive coordinate as anchor, normalize canonical cube roots, split s-1 residual phases into blocks of three, query first row and then its data-dependent second row, spending two per full block; each leftover phase uses 1+2η under one cube query, which is injective on H. The latter follows because 1 and 2 are linearly independent over F4: equality (1+2η)^3=(1+2η')^3 implies 1+2η=h(1+2η'), h∈H, which forces h=1 and η=η'. Normalization removes a global h because h^3=1; no unpowered hidden information chooses the second row.

**Exact replay:** all 65,536 vectors in F16^4, including zero and all supports, recover up to H; cost histogram 4:61,5:1350,6:64125. All 5,461 support/relative-phase representatives in dimension seven recover, with support-size histogram (7,63,315,945,1701,1701,729). General arbitrary nonzero amplitudes follow from the normalized-root algebra; only the dimension-four enumeration is exhaustive over amplitudes. Global decision-tree lower bounds k4=6 and k7=11 use six outputs per legal query and (16^k-1)/3+1 global classes. These are fixed-oracle statements, not new global priority. PASS in this scoped mathematical audit.

## Outcome II: field- and exponent-uniform transfer theorem (additional result)

Let K=F_{p^r} where p is **any odd prime**, r≥1, and e≥1 with gcd(e, p^r−1)=2. The legal oracle is y=(a.x)^e∈K, and the target is x∈K^k modulo one global sign ±1. Let A_{K,e}(k), F_{K,e}(k) denote optimal adaptive worst-case and fixed nonadaptive query counts, respectively.

**Theorem, elementary proof candidate:** for k≥2,

    k+1 ≤ A_{K,e}(k) ≤ k + ceil((k-1)/r),
    F_{K,e}(k) ≥ 2k-1,
    F_{K,e}(k)-A_{K,e}(k) ≥ k-1-ceil((k-1)/r).

For fixed r≥2 the guaranteed gap diverges linearly with k, **for any fixed odd prime p**. If r≥k−1 then A_{K,e}(k)=k+1 exactly. The result transfers Vesper's PR #256 characteristic-three square argument and classical complement lower bound beyond characteristic three; it does not assert worldwide priority.

**Exact oracle equivalence:** put q=p^r. The multiplicative cyclic group has q−1 elements, and gcd(e,q−1)=2 implies e=2t with gcd(t,(q−1)/2)=1. Thus y=z^e=(z^2)^t. The map w↦w^t is a permutation of the nonzero-square subgroup, extended by 0↦0. It is an invertible public output relabeling. Adaptive and nonadaptive query complexity is *identical* for e and 2, including zero outputs and all adaptive branches.

**Adaptive upper proof:** First spend k coordinate queries, revealing zeros and each nonzero coordinate up to ± using square roots. Pick an anchor t from support; write x_j=λ_j u_j and η_j=λ_j/λ_t∈{±1}. For a block of b≤r other supported coordinates, choose Fp-linearly independent beta_1,...,beta_b and legal coefficients a_t=(sum beta_i)/u_t, a_{j_i}=beta_i/u_{j_i}. Its squared reading, after canceling global λ_t, is (sum beta_i(1+η_{j_i}))^2. Each 1+η lies in {0,2}⊂Fp. The coordinate vectors {0,2}^b and their negatives intersect only in the all-zero vector because p odd. Thus no distinct patterns are square-equivalent; decode exactly b signs from the single powered reading. There are ceil((s−1)/r) extra queries, at most ceil((k−1)/r), and no support side oracle.

**Fixed lower proof:** If fixed measurement matrix has nonzero kernel, it cannot distinguish zero and a kernel vector. Otherwise m≤2k−2 rows partition into S,T with <k each; their kernels provide linearly independent nonzero u,v. Then x=u+v, x'=u−v are not globally sign-equivalent, while on S/T each linear reading agrees up to ±; every e-output is identical. Hence F≥2k−1. The output alphabet has M=(q+1)/2 and the signal orbit space N=(q^k+1)/2; for k≥2, N>M^k (by N_{a+b}−N_a N_b=(q^a−1)(q^b−1)/4>0), so even an early-terminating adaptive depth-k decision tree fails.

**Coding-theory transfer (preexisting results properly credited):** For any odd q, fixed square-retrieval is equivalent to a full-rank K-linear intersecting image code; if supports of two nonzero codewords are disjoint, u±v collide, and conversely equal-square outputs give A(x−y), A(x+y) disjoint supports. Thus F_{K,e}(k)=i(k,q), the classical shortest q-ary linear intersecting code length. Borello–Schmid–Scotti (2025), Theorem 3.9, already proves liminf i(k,q)/k≥2+1/(q−1). Combining with our explicit adaptive upper:

    liminf_{k→∞} (F_{K,e}(k)−A_{K,e}(k))/k ≥ 1+1/(q−1)−1/r.

Do not claim the intersecting-code theorem, complement property, output relabeling, or prime-field basis as original. Full same-oracle historical novelty remains unresolved.

**Independent finite checks, no producer code imported:**

| exact field | k | exponents e | exhaustive input count | sign-orbits checked | legal-query cost histogram |
|--|--:|--|--:|--:|--|
| GF(9)=F3[t]/(t²−2) |4| 2 and 6 | 6,561 per e |3,281| 4:33,5:2432,6:4096 |
| GF(25)=F5[t]/(t²−2)|3|2 and 10|15,625 per e|7,813|3:73,4:15552|
| GF(49)=F7[t]/(t²−3)|2|2 and 10|2,401 per e|1,201|2:97,3:2304|

Each powered measurement was evaluated directly as a legal K-linear form and then exponentiated, with the decoder using only that powered output and publicly computed finite-field inverses/powers. Both exponents match the same histograms. The scripts contain assertions for every orbit, support, branch and uniqueness of the block code.

## Provenance and required audit

- `independent_f16_branch_audit.py`: SHA256 `a52fb0bbb91d8ea460632cdf6c71d70f0761f331547fb4f77aaf67bdd772ccb0`; `python3 independent_f16_branch_audit.py` PASS.
- `independent_odd_field_audit.py`: SHA256 `cc73b2bf7b230f05fc5a7f774bd9edc6dd7c1362a84959b5477d43c63305742b`; `python3 independent_odd_field_audit.py` PASS.
- Exact sources preserve all enumeration and negative checks. This note is an independent internal mathematical deduction and does not replace nonauthor human review, separate code replay or source-priority comparison.
- Strongest predecessor checked: Borello–Schmid–Scotti, *The geometry of intersecting codes and applications to additive combinatorics and factorization theory*, JCTA 214 (2025), Theorem 3.9, https://arxiv.org/abs/2406.04034 . Balan–Casazza–Edidin complement condition is classical; Kemper et al. separating invariants permit more general polynomial invariants.
- Cheapest decisive next falsifier: p=5 r=3 or a general proof attack identifying an odd-p obstruction to coefficient-cube injectivity; alternatively a dated paper proving the same entire p-general exact-oracle theorem, which would **demote originality** without changing correctness.

**Disposition:** PASS scoped F16 validity and exact finite p3/p5/p7 checks; all-p formal proof complete at the level of an elementary written argument but awaiting independent review. Stage R1 / novelty UNKNOWN. No website promotion, merge, external publication or mathematical record claimed.
