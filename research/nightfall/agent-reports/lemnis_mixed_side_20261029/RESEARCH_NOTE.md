# LEMNIS / NIGHTFALL — mixed-side orthogonality and tensorized principal-angle transfer

**Research checkpoint:** 2026-10-29. **Research lead:** Devin J. Wright, NIGHTFALL PHASESHIFT. **Proof and independent executable checks:** Lemnis (GPT-6). **Status:** self-contained restricted-family theorem, exact internal tests PASS. Comprehensive same-scope novelty and external specialist review OPEN. **Do not claim unrestricted Werner positivity.**

## 1. Precise setting

At sites `j=1,...,n`, let `H_j` be a finite-dimensional complex Hilbert space and `0 <= t_j <= 1`. For a matrix `C` on `H=tensor_j H_j`, set

`Q_t(C) = sum_{S subset [n]} (-1)^|S| (prod_{j in S} t_j) ||Tr_S C||_F^2`.

Write `C=sum_{i=1}^r X_i`, `X_i=u_i v_i*` with arbitrary complex, possibly entangled u_i and v_i. For each i,j, assume **only**

`u_i in tensor_j U_(i,j)` and `v_i in tensor_j V_(i,j)`

for specified nonzero local subspaces `U_(i,j), V_(i,j) <= H_j`. These spans may have dimension >1. Let

- `A_i=||u_i|| ||v_i||`, `z_i=Tr X_i=<v_i,u_i>`;
- `L=prod_j(1-t_j)`, `M=prod_j t_j`;
- `alpha_(ih,j)=||P_(U_i,j) P_(U_h,j)||_op`, `beta_(ih,j)=||P_(V_i,j)P_(V_h,j)||_op`;
- `gamma_(ih,j)=alpha_(ih,j) beta_(ih,j)`, an **observable principal-angle overlap** in `[0,1]`;
- `E_ih=prod_j(t_j+gamma_(ih,j))-M >=0`.

The subspaces in this theorem are fixed before a witness is tested; the conclusions hold for every choice of complex factors within them.

## 2. Main theorem — exact mixed-side support and quantitative robustness

**Theorem.** Every witness in the stated class satisfies

`Q_t(C) >= L sum_i A_i^2 + (-1)^n M (|sum_i z_i|^2 - sum_i |z_i|^2) - 2 sum_{i<h} E_ih A_i A_h`. (1)

Consequently, using `deg_E(i)=sum_{h!=i} E_ih`:

- **even n:** `Q_t(C) >= sum_i [L-M-deg_E(i)] A_i^2 + M |sum_i z_i|^2`;
- **odd n:** `Q_t(C) >= sum_i [L-(r-1)M-deg_E(i)] A_i^2`.

These provide sufficient PSD tests for arbitrary complex rank-≤r inputs in the specified factorized block family. The graph degree can be replaced by any stronger rigorous copositivity certificate on the exact displayed quadratic form in the nonnegative variables `A_i`.

**Exact mixed-side theorem.** Suppose for every pair `i != h` and every site `j`, **at least one** of `U_(i,j) ⟂ U_(h,j)` and `V_(i,j) ⟂ V_(h,j)` holds, with the side allowed to vary among pairs and sites. Then `gamma_(ih,j)=0`, all `E_ih=0`, and the exact full-trace-only interference formula holds:

`Q_t(C)=sum_i Q_t(X_i)+(-1)^n M(|sum_i z_i|^2-sum_i |z_i|^2)`.

Assuming `r>=2` and all dimensions `d_j>=r`, positivity for **every** such C is equivalent to

- **even n:** `L>=M`;
- **odd n:** `L>=(r-1)M`.

Sharpness follows from the previously verified product-basis diagonal examples, which are a subclass: two opposed signs for even n and `r` equal signs for odd n. The statement is restricted to the mixed-side block factorization; it says nothing about arbitrary rank-r matrices.

**Two-block principal-angle corollary.** For `r=2`, the sufficient condition for both parities is

`prod_j(1-t_j) >= prod_j(t_j+gamma_(12,j))`. (2)

At homogeneous `t` with all `gamma_j<=g`, this is guaranteed whenever `g<=1-2t`, for *every copy count n*. Equation (2) is a **sufficient condition** for nonzero overlap; it is sharp in the exact-zero-overlap subfamily, and should **not** be advertised as a sharp necessary threshold for g>0.

At an even-copy endpoint `L=M`, the stronger input-sensitive inequality (1) retains the nonnegative stabilizer `M|sum_i z_i|^2` and rank-one slacks `delta_i=Q(X_i)-L A_i^2`. Thus nonzero overlaps may still be certified if they are outweighed by these explicitly computable terms. This is an exact structural condition beyond a generic norm-continuity statement.

## 3. Proof independent of rank-destroying projections

The rank-one swap identity implies `Q_t(X_i)>=L A_i^2` for each i, because `I-t_j F_j >= (1-t_j)I` and the local swaps commute.

Fix i<h and a proper subset S of sites traced out, with remaining set R=[n]\S. Then `Y_i=Tr_S X_i` belongs to the Hilbert–Schmidt operator space `Hom(tensor_{j in R} V_(i,j),tensor_{j in R} U_(i,j))`. Upon vectorization its containing subspace is

`(tensor_{j in R} U_(i,j)) tensor conjugate(tensor_{j in R} V_(i,j))`.

Its subspace projector has overlap operator norm with the h-th subspace precisely

`prod_{j in R} ||P_(U_i,j) P_(U_h,j)|| ||P_(V_i,j)P_(V_h,j)|| = prod_{j in R} gamma_(ih,j)`.

Therefore the principal-angle inequality and trace-norm contractivity give

`|<Tr_S X_i,Tr_S X_h>_HS| <= (prod_{j in R}gamma_(ih,j)) ||Tr_S X_i||_F ||Tr_S X_h||_F <= (prod_{j in R}gamma_(ih,j)) A_i A_h`.

Here `||Tr_S X_i||_F <= ||Tr_S X_i||_1 <= ||X_i||_1=A_i`, valid even for non-Hermitian rank-one X_i. Summing the *absolute values* for proper S and expanding the product yields the exact error envelope

`sum_{S proper} prod_{j in S}t_j prod_{j notin S}gamma_(ih,j) = prod_j(t_j+gamma_(ih,j)) - M = E_ih`.

The full trace term is exact: `Tr X_i=z_i`. Polarization produces (1). For even n, rewrite the full-trace term as `M|sum z|^2-M sum|z|^2`, use `|z_i|<=A_i` and `2AiAh<=Ai^2+Ah^2`. For odd n, bound `-2M Re sum_(i<h) conjugate(z_i)z_h >= -2M sum_(i<h) AiAh` and likewise `E` terms. This proves both degree certificates, for arbitrary complex coefficients.

If every `gamma_(ih,j)=0`, every proper-subset cross term vanishes **exactly**; full trace remains. The resulting even/odd criteria follow from the existing sharp full-trace sign controls, using genuine rank-r diagonal witnesses for necessity. No grade projection is assigned a false rank assumption.

## 4. A strict four-qutrit endpoint witness outside the one-sided and coordinate-PSD baselines

At `n=4,d_j=3,t_j=1/2`, let `B=|0>+|1>`, `T=|0>+|1>+|2>`, `D=|2>`. Define

- `u1=B⊗T⊗B⊗T`, `v1=T⊗B⊗T⊗B`;
- `u2=D⊗T⊗D⊗T`, `v2=T⊗D⊗T⊗D`;
- `C=u1 v1* - u2 v2*`, with complex matrix rank **exactly two**.

For the pair of blocks, row spaces are orthogonal at sites 1 and 3, while column spaces are orthogonal at sites 2 and 4. Neither the left factors *nor* the right factors are locally orthogonal on **every** site. Every potential alternative rank-two decomposition on the left has the same one-dimensional local factor T on sites 2,4; thus no alternative decomposition can satisfy Vesper's all-row-site-orthogonal hypothesis. Every alternative right factor shares T on sites 1,3, analogously excluding a pure right-sided version.

Two independent algorithms give

`Q(X1)=256`, `Q(X2)=625/16`, `<X1,KX2>=1`, `Q(C)=4689/16 > 0`.

The theorem's conservative bound is `(36-9)^2/16=729/16`. The coupling `1` occurs in the **conserved zero-difference grade** through the full traces; all proper-subset pairings vanish.

The coordinate support includes `E_(0000,0000)`, `E_(0100,0100)` and `E_(2222,2222)`. A signed rank-three combination of these diagonal units has exact `Q=-3/16`, so Axiom's **ambient PSD coordinate-support** criterion cannot certify the entire source support. This mutation does not contradict the rank-two theorem. We do **not** claim this defeats every existing basis-changed or input-specific sufficient certificate.

The rank-two witness has Hilbert–Schmidt norm squared `1377`, hence normalized physical value `4689/(16*1377)` and normalized theorem lower bound `729/(16*1377)`.

## 5. Strict nonzero-overlap control and its scope

As an exact qutrit example take `u1=v1=|0000>`, `u2=(|0>+5|1>+5|2>)^⊗4`, and `v2=|0000>+|1111>+|2220>`. Put `C=u1 v1*+u2 v2*`. At each site, `U1=span{|0>}`, `U2=span{|0>+5|1>+5|2>}`, and compatible unrestricted column subspaces give

`gamma_j=1/sqrt(51)<1/7`, for every j.

At `t=2/5`, `(1-t)^4>(t+1/7)^4`, and the full rank-two family defined by those prescribed local subspaces is PSD. Independent physical 16-trace computation gives `Q=8044907574/625` for this C with a **nonzero proper-subset cross term** `-987/125`; the tensorized lower bound using 1/7 is positive. The coordinate support contains an unbalanced ternary three-word diagonal triple with exact negative `-3/16` at the endpoint, so the *original coordinate subspace* is not ambient PSD.

More strongly, at the **endpoint** `t=1/2`, this same C obeys the quantitative even-copy certificate obtained from (1): with `z1=1`, `z2=751`, `A1=1`, `A2=51² sqrt(3) < 51²(7/4)`, and `E<=(1/2+1/7)^4-1/16=260/2401`,

`Q(C) >= (752²/16) - 2*(260/2401)*[51²*(7/4)] = 11784862/343 > 0`.

Its exact physical value is `11591033`. This example is **not** claimed to beat all previously known basis-aware positivity classes: its rank-one block factors are product vectors, and local two-dimensional row spans can support other positive certificates. The new theorem's important strictness witness is the previous mixed-side example, which escapes the one-sided *premise itself*.

**Necessary hypothesis control.** Global orthogonality alone is insufficient. For `n=2`, take `C=E_(00,00)+E_(10,10)` at `(t1,t2)=(3/4,1/10)`. Although `L=9/40 >= M=3/40`, the exact physical form is `Q=-9/10`. One site shares both row and column support, violating the required local complementarity.

## 6. Reproduction, priority and research impact

Fresh source-independent checker paths:

- `verify_mixed_side.py`: explicit physical 16-subset partial traces, four-qutrit strict mixed-side witness, nonzero zero-grade cross term, rank-three ambient-PSD mutation, heterogeneous controls, missing-site falsifier.
- `verify_mixed_kernel_independent.py`: local matrix-unit Werner kernel and product-factor operator derivation, plus *nonfactorized entangled complex* three-site example without importing partial-trace routines.
- `verify_principal_angle.py`: independent rational tensor-angle sufficient test for n=2..5; a four-qutrit full-three-letter witness with a nonzero proper-trace cross term and endpoint positive bound.

**Closest literature:** Costa Rico (2025, *Letters in Mathematical Physics*, DOI 10.1007/s11005-025-01935-y); Bharti–Gajjala–Haug (July 2026, arXiv:2607.24479); Costa Rico–Wolf (2026, *Journal of Mathematical Physics*, DOI 10.1063/5.0294537); Song–Chen (July 2026, arXiv:2607.23416). Their published tensor-factorization, rank-two partial-trace and swap-inequality tools are essential prior art. A limited title/abstract search did not resolve the priority of **this exact mixed-side principal-angle certificate**. Do not claim worldwide novelty, unrestricted endpoint positivity, or improvement of any qutrit physical threshold.

**Scientific role:** The meaningful structural transition is from **one globally orthogonal side** (Vesper PR #38) to **site-dependent alternating orthogonal sides**, plus a dimension-free, tensorized overlap modulus. It creates exact rank-two endpoint families with genuinely nontrivial zero-grade interference beyond Axiom's ambient-coordinate certificate. The result is a restricted geometric theorem and remains a draft pending independent adversarial cross-review.
