# All-frequency T2 primitive lifts: forced-fourth-row counting
2026-11-22. Status: **source-equivalent paper-level combinatorial improvement**, not a new Lean proof of the published tensor splitting theorem and not a completed quantum simulator. Complementary to the Möbius operator-constant audit in this same branch.

## Decisive information-before-enumeration refinement

In #1059, after independently published Lovitz–Petrov circuit splitting bounds the differing tensor sites by six, one fixes a reference primitive nonzero row support C of size at most four for a given nonzero XOR frequency z. For a candidate alternate primitive four-slot tuple, all nonzero labels agree outside a set U of at most six tensor sites with some reference row. At fixed U of size j, each slot therefore belongs to a source-identified finite candidate set A_U contained in D=R_L∪{0} of cardinality at most

    N_j = 1 + 4*3^j.

The previous all-frequency proof counted **all four slots independently**, giving N_j^4 per U. This is unnecessary: the total XOR is fixed to z, so after choosing the first three labels the fourth is uniquely determined! Consequently **even without any pair-fiber theorem** the same fully sourced all-frequency argument gives

    K4^distinct(L) <= (1+4*3^6)^3 *
        sum_{j=0}^{min(L,6)} binom(L,j).            (1)

This improves the finite constant by the exact factor 2917 while retaining O(L^6). Here K4^distinct counts the **actual Group A** four-slot tuples whose four labels (including zero) are pairwise distinct and whose nonzero entries are primitive; it need not count the repeated-zero overcounting tuples in the older K4 definition, since those are assigned to Group B first. The paper-level quantum operator bound is unchanged when K4 is replaced by this smaller genuine Group A bound.

## Stronger pair-fiber cap

Let M2(D)=max_{u≠0} #{(x,y)∈D²:x XOR y=u}. A four-slot Group A tuple has pairwise distinct labels. For any fixed first two labels x₁,x₂ in A_U, the residual u=z XOR x₁ XOR x₂ is **nonzero**: if u=0, then the remaining x₃,x₄ would have XOR zero and hence x₃=x₄, contradicting pairwise distinctness. Thus there are at most M2(D) ordered completions (x₃,x₄)∈D². There are also at most N_j completions, because choosing x₃∈A_U uniquely fixes x₄. Therefore per U,

    # Group-A tuples <= N_j² * min(N_j,M2(D)).

Using N_j≤N_6=2917 gives the sharpened all-frequency primitive multiplicity bound

    K4^distinct(L) <= 2917² * min(2917,M2(D_L)) *
        sum_{j=0}^{min(L,6)} binom(L,j).            (2)

This remains O(L^6), because min(2917,M2)≤2917; it is **not** an O(L^7) theorem even when M2 grows. The proven paper-level exact pair XOR classification from #1029 gives M2(D_L)=2L+2 for L≥1, but one can use the independent O(L²) or any separately verified bound if that exact classification has not been formalized in Lean.

The improved abstract binary-label criterion from #1097 is valid with the actual Group-A K4^distinct and its existing M2 bound, provided the *previously unverified quantum Hilbert-energy lemmas* survive audit. Hence a conditional tensor application is

    Q <= min(3^L,
      ceil[2*(2 sqrt(K4^distinct(L)) + 35 sqrt(2L+2))²
           / (epsilon² delta)]).

No claim of efficient classical preprocessing, state sampling, or pointwise accuracy is implied.

## Exact significance audit — denominator correction recorded

At epsilon=delta=1/4, epsilon² delta=1/64, so the coefficient in front of (2sqrt K+ c sqrt M)² is **128**. Earlier transient calculations using 16 were wrong and are not retained as evidence. Independent exact integer-square-root interval checks evaluate all integer L from 1 through the first crossover:

| Counting / operator bound | First L where displayed finite Q upper bound < 3^L |
| --- | ---: |
| Original #1059 N^4 count, c=145, M=2L+2 | 50 |
| New forced-last N^3 count, c=35 | 42 |
| New pair-capped N² min(N,2L+2) count, c=35 | **38** |

These are *thresholds of theoretical upper-bound formulas*, not quantum runtime benchmarks, and rely on the paper-level six-site bound. An exact checker uses floor/ceil integer square roots to certify **all smaller L fail the bound comparison** and the displayed threshold succeeds, with no floating-point or tolerance judgments.

## Independent source checks and certification boundary

The new independent source script check_tensor_forced_last_count.py exhaustively checks the general cardinality injection over finite binary-label sets (including zero), deliberately excludes repeated-slot/zero-residual tuples, confirms exact Group-A four-slot maxima 312 at L=2 and 1992 at L=3, and computes threshold comparisons using integer arithmetic. The only additional mathematical inputs to the bound (2) are the already claimed source-six-site support consequence of the **published Lovitz–Petrov Corollary 21** and the pair-fiber M2.

Do not conflate this with all-depth Lean certification: the underlying product-tensor support theorem remains sourced externally at paper level; K4^distinct is a *model-faithful* Group A subcount; group B/C quantum energy still needs independent unrestricted-complex proof and a Lean terminal. No novelty clearance beyond the quantitative refinement of NIGHTFALL's candidate theorem.


## Fixed-order transfer (not a higher-query quantum theorem)

Exactly the same source argument applies to ordered k-slot tuples for **every fixed k≥2**, provided all k labels are pairwise distinct and their nonzero entries are primitive. Lovitz–Petrov bounds the union of variation supports by 2k−2 for equal-XOR primitive references. Define N_k=1+k·3^(2k−2) and the actual original-label nonzero ordered pair-XOR maximum M2. For each support choice U, all k alternate labels belong to a set of at most N_k labels. Fix the first k−2 labels. If the XOR of the last two were zero, those two labels would be equal in F₂ and violate pairwise distinctness. Thus one may complete with at most min(N_k,M2) choices for the final ordered pair, proving the all-frequency **paper-level** count

    K_k^distinct(L) ≤ N_k^(k−2) min(N_k,M2)
       · sum_{j=0}^{min(L,2k−2)} binom(L,j).

This reduces the earlier generic overcount N_k^k by at least N_k and potentially N_k²/M2, without changing its O_k(L^(2k−2)) polynomial degree. The identity is an abstract finite-group completion bound plus the inherited published tensor-circuit support theorem. **It does not imply a T-query quantum simulator for T≥3**: those paths require independent higher-order Hilbert interference estimates.

The Lean sibling module TensorT2RepeatMobius.lean additionally targets three source-specific finite algebra lemmas: forced uniqueness of the fourth label, nonzero XOR of a distinct final pair, and monotonicity of pair-XOR fibers under a restricted candidate set. These are not by themselves a certified counting theorem until matched to the tensor source and successfully kernel checked.
