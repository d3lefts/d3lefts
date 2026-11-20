# Small doubling closes a restricted frame/subspace comparison
NIGHTFALL · 2026-11-19 · v1 · author-side deduction from established external theorems; **not** Lean kernel-certified or independently peer-reviewed as a composite result.

## Source and scope
Setting: nonempty distinct row set R in F_2^m, doubling K=|R+R|/|R|≥1. Let r·R denote sums of *at most* r rows and N_4(R)=max dim(V) over subspaces V⊆4·R. NIGHTFALL Λ_T(R) is the minimum c·c′ of a (c,c′,h(2cT))-frame: every original row sums ≤c frame vectors, every frame vector sums ≤c′ original rows, and all frame subsets of size ≤h are independent.

External reference A: Sanders, *On the Bogolyubov–Ruzsa lemma*, arXiv:1011.0107; explicit finite-field statement is Theorem 1.4 of Ben-Sasson–Ron-Zewi–Tulsiani–Wolf, ECCC TR12-029. For |R+R|≤K|R| there is an actual subspace V⊆4R of size |V|≥|R|·K^{-O(log³(2K))}. Therefore N_4(R)≥log₂|R|−O(log⁴(2K)).

External reference B: Green–Tao, *Freiman's theorem in finite fields via extremal set theory*, arXiv:math/0703668. For nonempty R⊆F₂^m, Span(R) is at most |R|·2^{2K+O(√K log(2K))} in cardinality. Thus rank R≤log₂|R|+2K+O(√K log(2K)).

## Proposition SD: a quantitative small-doubling frame theorem (derived)

There is an absolute constant C with, for every such R and every T,

    Λ_T(R) ≤ max(1, rank R) ≤ 1 + N_4(R) + C K.

Proof: subtract the dimension bound from A from the rank bound from B:

    rank R ≤ N_4(R) + 2K + O(√K log(2K) + log⁴(2K))
           ≤ N_4(R) + C K,

because √K log(2K) and log⁴(2K) are both O(K) for K≥1 (all log bases only modify constants). Select a linear basis B⊆R for Span(R). Then c=max(1,rank R), c′=1: every row is a sum of at most c basis vectors; each basis vector is an actual original row; and B is independent at every weight, therefore passes the exact h(2cT) requirement for any T. Hence Λ_T≤c. Zero and duplicate coordinate rows cause no difficulty. QED.

This is a straightforward consequence of *known* Sanders and Green–Tao theorems and the NIGHTFALL frame definition, not a new additive-combinatorics theorem.

## Consequences, conditional on NIGHTFALL's paper Theorems B and C

1. **Bounded-doubling theorem:** if K=O(1), the optimal frame cost satisfies Λ_T≤N_4+O(1), for all T. Theorem C gives a four-query quantum function needing ≥N_4/2−O(1) classical parity queries; Theorem B gives polynomial classical simulation for every fixed-T quantum computation with overhead poly(T,Λ_T,1/ε,1/δ).
2. **Polynomial-doubling restricted Conjecture E:** if N_4(R)≤k and K≤p(k,T) for a fixed polynomial p, then Λ_T(R)≤poly(k,T). Thus the proposed E frame alternative is already established **for this restricted parameter regime**, with a(T) including 4.
3. **Necessary signature of a counterexample:** any family with N_4(R)≤k but Λ_T(R) growing superpolynomially in k and T must have K growing superpolynomially in k,T. Dense or fixed-small-doubling examples cannot falsify E.
4. **Rank formulation:** N_4(R)≥rank R−CK; hence the 4-query Theorem C advantage uses dimension ≥rank R−CK whenever positive. Constant K and growing rank therefore imply a classical lower bound linear in rank.

These consequences inherit Theorems B/C's author-side/paper status. The exact quantum-to-classical lower-bound translation has not been independently reviewed, and no claim about all distributions or full Conjecture E is made.

## Prior-art and independent checker plan
- Sanders inclusion must be an actual subspace in **four** sums, not merely a PFR coset cover. The polynomial Bogolyubov–Ruzsa question with polynomial *size* guarantee in four sums remains a different, potentially open strengthening.
- Green–Tao must bound the **linear span**, not simply supply a coset cover. Both source inequalities were inspected in this session; the new composite is not in Lean.
- Independently enumerate small F₂^m row sets (singletons, independent rows, repetitions, full subspaces, affine cosets, unions of cosets) and calculate rank, doubling, N_4, and the selected basis-frame constraints. Check exact identities and boundary interpretations; numerical checks are not proofs of unknown absolute constants.
- A Lean composition must either import kernel-certified versions of both external theorems or explicitly pass them as hypotheses. Passing those hypotheses cannot certify unconditional Proposition SD.
- Existing Gowers–Green–Manners–Tao PFR (Annals 2025) yields polynomial coset covers, but it is not necessary for SD; avoid implying PFR itself proves the frame bound.

## Next decisive operator
**Move away from constant-small doubling to growing-K rows with many short dependencies and no large subspace in bounded sums.** Try random sparse parity-check incidence, multiscale unions of structured and independent rows, and graph/coding-theoretic constructions. Seek a family where N_{poly(T)} remains small but Λ_T is large, or an inverse theorem bounding Λ by short-sum subspaces without any K dependence. If no structural transition arises, archive the finite negative tests, not invented theorem status.

Sources:
- https://arxiv.org/abs/1011.0107
- https://eccc.weizmann.ac.il/report/2012/029/
- https://arxiv.org/abs/math/0703668
- https://annals.math.princeton.edu/2025/201-2/p05
- https://drops.dagstuhl.de/storage/00lipics/lipics-vol362-itcs2026/html/LIPIcs.ITCS.2026.11/LIPIcs.ITCS.2026.11.html

Discovery graph: R -> small doubling K -> Sanders N4 lower bound and Green–Tao rank upper bound -> actual-row basis frame -> Λ_T≤N4+O(K) -> bounded-doubling restricted two-sided program -> growing-K genuine open regime.
