# NIGHTFALL — Werner-state thresholds through 100 copies and an analytic every-finite-copy guarantee

**Date:** 2026-10-28. **Problem:** Undistillability of the Werner family, with the parameter convention `alpha=-t` and the strict NPT qutrit region `t>1/3`.

## Evidence and labels

- **Published inputs:** Tejasvi Singh Tomar, *Undistillability of Werner states from three, four and five copies*, https://www.mefyi.com/papers/werner-states-copies/werner-states-copies.pdf (accessed 2026-10-28). Theorem 1.5 supplies all-dimensional `t=11/(5k)` for `k>=6`, strengthened to `56/(25k)` for `k>=9`; Theorem 1.4 supplies qutrit `t=0.4979` (4 copies) and `t=0.47` (5 copies). Two/three copies have sharp `t=0.5`.
- **Archive-verified source-dependent constructions:** k=4–14 use stored exact polynomial identities from `WERNER_SOURCE_AUDITED_R3_20261027.zip`. Their stronger numerical thresholds depend on Tomar's printed positive source margins; the source margin values were inferred conservatively from rounding, without rerunning the upstream semidefinite calculations. At 7–14, a separate zero-margin certificate tier depends solely on published nonnegativity theorem statements.
- **Archive-verified source-theorem-only constructions:** k=15–20, using `NIGHTFALL_WERNER_15_TO_20_20261027.zip`; a fresh run of its independent symbolic-polynomial checker on 2026-10-28 passed all six exact identities, positive weights/margins, and the adversarial invalid-spectator test.
- **New analytic derivation, k=21–100 and every other finite k:** a positive explicit rational increment above the PPT boundary, depending on k. A complete mathematical proof is supplied below. The independent computational audit checks only algebraic recurrences and low-degree randomized sanity tests; **a separate human/non-author proof review is pending**. Earlier literature already establishes the qualitative existence of finite-k NPT intervals. No novelty claim follows from this derivation alone.
- **Rejected numerical experiments:** an LP with 534 permitted 21-copy rows returned approximate 0.36300–0.36480 thresholds, but its support failed exact rational reconstruction. Those values are **numerical artifacts/candidates, not certified bounds**.

## Quantitative results

The qutrit certified/conditional archive thresholds, k=1–20:

|k| strongest archive-bound t | status |
|--:|--:|--|
|1–3|0.50000|published sharp|
|4|0.49791|conditional on quantitative source margins; published theorem alone gives 0.4979|
|5|0.47189|conditional on quantitative source margins; published theorem alone gives 0.4700|
|6|0.44819|conditional on quantitative source margins|
|7|0.43140|conditional; source-theorem-only lower bound 0.4298|
|8|0.41880|conditional; source-theorem-only lower bound 0.4175|
|9|0.40920|conditional; source-theorem-only lower bound 0.4080|
|10|0.40140|conditional; source-theorem-only lower bound 0.4003|
|11|0.39500|conditional; source-theorem-only lower bound 0.3942|
|12|0.38980|conditional; source-theorem-only lower bound 0.3890|
|13|0.38540|conditional; source-theorem-only lower bound 0.3847|
|14|0.38160|conditional; source-theorem-only lower bound 0.3809|
|15|0.37752|source-theorem-only exact certificate|
|16|0.37492|source-theorem-only exact certificate|
|17|0.37226|source-theorem-only exact certificate|
|18|0.37007|source-theorem-only exact certificate|
|19|0.36812|source-theorem-only exact certificate|
|20|0.36636|source-theorem-only exact certificate|

**For every integer k>=1 in d=3**, the following weaker analytic sufficient threshold holds:

    a_k = 36 / 108^(2^(k-1))
    epsilon_k = a_k/(6*k) = 6/[k * 108^(2^(k-1))]
    t_k = 1/3 + epsilon_k.

At 21 copies, `log10(epsilon_21)` is about `-2,132,200`; at 100 copies it is about `-1.289e30`. The bound is *strictly* inside the NPT region at every fixed finite copy count and far too small to be competitive as a numerical threshold. The spreadsheet preserves the exact expression; a displayed 0.3333333333 is a rounding artifact.

## Main analytic argument

Let `d>=3`, and identify the Hilbert–Schmidt space of `d^k x d^k` matrices with `k` tensor factors of the `d x d` matrix space. Define the orthogonal projector

    T_d(X) = X - Tr(X) I_d / d.

Let `P_k=T_d^(tensor k)`, also an orthogonal projector. For any matrix `C` of rank at most two, set `e_k(C)=||P_k(C)||_F`.

**Claim (coercivity in the rank-two cone).** Set

    b_(d,1) = 1 - 2/d,
    b_(d,k) = b_(d,k-1)^2 / (2d+1)^2,    k>=2.

Then for every rank-at-most-two matrix `C` on `(C^d)^tensor k`,

    e_k(C)^2 >= b_(d,k) ||C||_F^2.

**Base case.** The Cauchy–Schwarz trace bound for rank≤2 gives `|Tr C|^2<=2||C||_F^2`; hence `||T_d C||_F^2=||C||_F^2-|Tr C|^2/d >= (1-2/d)||C||_F^2`.

**Inductive step.** Write `c=sqrt(b_(d,k-1))` and `epsilon=||P_k C||_F`. Partition `C` into `d x d` blocks `C_ij` of size `d^(k-1)`. Each block has rank≤2. Since off-diagonal blocks survive the first-site traceless projection unchanged, the square-sum of their `P_(k-1)` images is at most `epsilon^2`. Induction yields

    ||E||_F <= epsilon/c,

where `E` is the off-diagonal part of `C`. The block-diagonal part `D=C-E` therefore lies within `epsilon/c` of the rank-two matrix `C`. The third singular value of `D` is at most `epsilon/c`. Since `D` is block diagonal and `d>=3`, some diagonal block `C_jj` has operator norm at most `epsilon/c`. Its rank≤2 implies

    ||C_jj||_F <= sqrt(2) epsilon/c.

The `P_k` norm also bounds the difference between any pair of traceless-projected diagonal blocks:

    ||P_(k-1)(C_ii-C_jj)||_F <= sqrt(2) epsilon.

The reverse triangle inequality and induction give, for every i,

    c ||C_ii||_F <= ||P_(k-1)C_ii||_F
                    <= sqrt(2) epsilon(1+1/c).

Consequently,

    ||C||_F <= ||D||_F+||E||_F
            <= [sqrt(2d)/c^2 + (sqrt(2d)+1)/c] epsilon
            <= (2*sqrt(2d)+1) epsilon/c^2
            <= (2d+1) epsilon/c^2.

The final inequality uses `d>=3` and `0<c<=1`. Rearrangement gives `c_k >= c^2/(2d+1)`, equivalently the claimed rational recurrence for `b_(d,k)`. This completes the induction.

The recurrence unfolds exactly to

    b_(d,k) = [(d-2)/d]^(2^(k-1)) / (2d+1)^[2*(2^(k-1)-1)].

In the special case `d=3`, the coefficient `2d+1=7` may be tightened to `6`, since `2*sqrt(6)+1<6`. Therefore

    ||P_k C||_F^2 >= [36 / 108^(2^(k-1))] ||C||_F^2.

**Perturbation to the NPT side.** Let `Omega_d=vec(I_d)`, and `A_d(t)=I-t|Omega_d><Omega_d|`. Then `A_d(1/d)` is precisely the orthogonal projector `T_d` after vectorization. For `t=1/d+delta` with `0<=d delta<=1`, both `||A_d(t)||` and `||A_d(1/d)||` are at most one. A telescoping product expansion gives

    ||A_d(t)^(tensor k) - A_d(1/d)^(tensor k)|| <= k*d*delta.

For rank≤2 `C`, the Werner quadratic form is

    Q_k(t,C) = <vec C | A_d(t)^(tensor k) |vec C>.

Thus

    Q_k(t,C) >= [b_(d,k)-k*d*delta] ||C||_F^2.

Choose `delta=b_(d,k)/(2*d*k)`. Then `Q_k >= b_(d,k)||C||^2/2>0`. The exact **all-dimension, every-finite-k** sufficient bound is therefore

    t_(d,k) = 1/d + (1-2/d)^(2^(k-1))
                       / [ 2*d*k * (2*d+1)^(2*(2^(k-1)-1)) ].

Combining with the published universal bound, the strongest *general-dimensional* bound obtained here is the maximum of `t_(d,k)`, `1/d`, and Tomar's appropriate `11/(5k)` or `56/(25k)`, plus his low-copy bounds.

At `d=3` the improved special-case recurrence yields `t_k=1/3+6/[k*108^(2^(k-1))]` as stated.

## Scope / failure modes

1. **Every finite k**: the threshold is allowed to depend on k and tends to `1/d`. This is established by the displayed mathematical derivation, subject to an independent proof review.
2. **One fixed t>1/d for all k**: *not* established. This is the unresolved all-copy problem. No asymptotic Werner bound-entanglement claim is made.
3. The induction proves coercivity of a tensor product orthogonal projection **restricted to rank-two matrices**. It does not assert a full-operator positive spectral gap, which would be false.
4. The perturbation is an **operator-norm** estimate. It does not assume tensor-stability of arbitrary 2-block-positive operators.
5. The explicit formula decays doubly exponentially in k; its scientific contribution is a transparent construction rather than a competitive numerical bound. Prior-art novelty is unclaimed.
6. The attempted 21-copy LP had incomplete algebraic reconstruction. No such candidate is included in `NIGHTFALL_WERNER_1_TO_100_20261028.csv`.

## Reproduction and package integrity

- `python verify_finite_k_theorem.py` independently checks 100 scalar recurrences symbolically, lower-dimensional exact identities, and randomized matrix sanity checks (the latter are **not** a proof).
- `NIGHTFALL_WERNER_1_TO_100_20261028.csv` and `.xlsx` contain all hundred rows and published comparison sources.
- The archived 15–20 theorem-dependent identities were additionally replayed using their *separate* independent SymPy verifier. They are separate from this analytic derivation.
- SHA-256 hashes in `SHA256SUMS` certify the exact package bytes.

## Handoff

**Best competitive finite-copy bound:** 20 qutrit copies at `t=9159/25000=0.36636`, exact positive source-theorem-dependent polynomial certificate.

**Best every-finite-k result:** the displayed analytic `t_(d,k)>1/d`, proof candidate awaiting independent non-author review, quantitatively very weak.

**Last decisive failed experiment:** approximate 21-copy LP supports cannot be reconstructed in exact rational arithmetic.

**Next experiment:** replace monomial-basis floating LP with a conditioned positive-basis/interval method and exact feasible interior-point reconstruction at 21 copies, then use a representation transition to 22–100. An unrestricted fixed NPT `t` needs a fundamentally stronger inequality with k-independent gain.
