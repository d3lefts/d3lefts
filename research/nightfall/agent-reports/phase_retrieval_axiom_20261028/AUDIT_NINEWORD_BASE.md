# AXIOM — Independent foundational nine-word endpoint audit (2026-10-28)

**Research lead:** Devin J. Wright. **Fresh audit:** Axiom (GPT-6). **Source:** `RESEARCH_NOTE(20261028-080810).md` from the NIGHTFALL research Library, titled *An exact four-copy endpoint certificate on a ternary affine code*. This audits the imported premise in Lemnis's 4,209-dimensional restricted-class lift (PR #17), not the unrestricted four-copy Werner endpoint.

## Exact statement and representation
For each local dimension d>=3, use the nine ternary words A={(x,y,x+y,x+2y): x,y in F3}, embedded as row supports in (C^d)^tensor4. Set Q4(C)=sum_J (-1/2)^|J| ||Tr_J C||_F². For every complex matrix C of rank <=2 with rows supported on A and arbitrary Bob columns, the foundational theorem is Q4(C)>=0.

## Independent decomposition and complete d=3 coefficient audit

Constructed from scratch 25 groups when d=3: one 9-pair center group of weight 2 and 24 three-pair transversal groups indexed by (site j, row symbol v, replacement z!=v), each weight 4. Every paired matrix unit (a,b) belongs to at most one group. Define each group's row and column index sets Rg,Bg and rank-two compressed square matrix Cg=C[Rg,Bg]. Then

    16 Q4(C) = sum_g wg [||Cg||_F² - |Tr Cg|²/2] + sum_(a∈A,b∈[d]^4) delta(a,b)|C_ab|².

The independent checker constructs all groups, computes diagonal residuals delta by the group rectangle and paired diagonal incidence, and evaluates **every one of 729² = 531441 ordered integer kernel coefficients**. They match the literal local Werner tensor formula exactly, with zero mismatches. The residual histogram at d=3 is:

| delta | count |
|---:|---:|
| 0 | 81 |
| 4 | 216 |
| 6 | 72 |
| 8 | 216 |
| 12 | 144 |

The same code constructs 37 groups for d=4, checks all 2304 diagonal residual coefficients, and finds every one nonnegative. This is a finite additional test, distinct from the arbitrary-d proof.

## Analytic extension for every d>=3

Any pair of distinct A words agrees in exactly one coordinate, differing in three. For a pair of distinct matrix-entry coordinates (a,b),(c,e), a nonzero off-diagonal coefficient of the local Werner kernel forces b_j=a_j and e_j=c_j at those three differing positions. At their unique common site, either both Bob symbols equal the common Alice symbol (center group, coefficient -1) or both equal a shared replacement z distinct from it (unique transversal group, coefficient -2). The group trace terms account for every off-diagonal coefficient without overlap.

For diagonal coordinates (a,b), classify by Hamming distance h(a,b). The residual is 0 for h=0 or 1, 4 for h=2, 6 if h=3 with b another code word, 8 if h=3 otherwise, 12 if h=4 and (a,b) lies in one transversal rectangle, and 16 otherwise. Uniqueness follows because two distinct ternary codewords have distance three: no off-code Bob word can arise by a single-symbol edit of two codewords. Thus delta(a,b)>=0 for all d>=3.

Each Cg is obtained through left and right coordinate selection, so rank(Cg)<=rank(C)<=2. The established singular-value trace bound |Tr Cg|² <=2||Cg||_F² makes every group term nonnegative. Together with the residual identity, this gives the restricted four-copy endpoint inequality for arbitrary complex C.

## Negative control (rank is essential)

Take three distinct words a,b,c in A and C=E_aa+E_bb+E_cc. Then rank(C)=3 and the exact source kernel gives

    16 Q4(C) = 3 + 6*(-1) = -3.

Thus extending the theorem to unrestricted matrix ranks would be false. The independent checker reconstructs this exact negative control and checks that a deliberately altered center cross coefficient disagrees with the source kernel.

## Gate
The finite coefficient and rank-three controls are independently replayed **PASS**. The general proof is written and its combinatorial cases checked; **human non-author mathematical review remains open**. Priority is also open. This supports the imported nine-word premise of Lemnis's lift at the internal mathematical-certification tier, without proving the unrestricted Werner endpoint or the originality of the extension. Source bytes in the user Library still need a publicly pinned release.

**Checker:** `audit_nineword_base.py` in the complete reproducibility ZIP provided in the research conversation. Original locally executed checker SHA-256: `a19aa3b647a136d7a383a2826152afb830d378891a8772e40ba89ef0ad95f099`; JSON output SHA-256: `4d7877bdbfc85092e5a7ff965f66fe3c1cedda90e1e6e3f87b441602db89c8c1`.
