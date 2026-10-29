# AXIOM addendum — explicit product-state fidelity from the swap spectral gap

**Date:** October 28, 2026 New York / October 29 UTC. **Dependency:** `REVIEW_AND_RIGIDITY.md` and the physical partial-trace/swap identities. **Status:** analytic deduction plus independently checked exact two-site fixtures; external novelty and peer review open.

## Quantitative theorem

Let `n>=1`, local dimensions `d_j>=2`, and `0<t_j<1`. Put `L=prod_j(1-t_j)`, `Delta=min_j 2t_j prod_(h!=j)(1-t_h)>0`. For **arbitrary nonzero complex vectors** `u,v` in the n-site Hilbert space, let `X=u v*`, `A=||u||||v||`, `delta=Q_t(X)-L A²>=0`, and

    epsilon = delta/(Delta A²).

Write the unit vectors `U=u/||u||`, `V=v/||v||`. Then:

1. **Relative-phase alignment:** `|<U,V>|² >= 1-2 epsilon`.
2. **Local reduced-state purity:** each one-site reduced density matrix `rho_(U,j)` satisfies `Tr(rho_(U,j)²) >= max(0,1-2 epsilon)²` for `epsilon<=1/2`, and in particular `lambda_max(rho_(U,j)) >= 1-4 epsilon` (the latter bound remains trivial when negative).
3. **Full separability fidelity:** there exists a unit **fully tensor-product** vector `a=a_1⊗...⊗a_n` satisfying

       |<a,U>|² >= max(0,1-4n epsilon).

The same product estimate holds for `V` (possibly a separately chosen product). At `epsilon=0` both are the same product up to phase. These estimates are independent of the local dimensions `d_j`; constants are explicit and apply without an assumption that `u` or `v` themselves factorize.

### Proof

Set `w=U⊗V` on two n-site replicas and `P_+=prod_j(I+F_j)/2`. The earlier exact spectral gap gives `||P_+ w||² >= 1-epsilon`. Since the commuting projector `P_+` lies inside the +1 eigenspace of each `F_j`, and also inside the +1 eigenspace of the full swap `F_all=prod_j F_j`, each corresponding swap expectation is at least `1-2 epsilon`.

For `F_all`, the expectation on `U⊗V` equals `|<U,V>|²`, proving item 1. For each single-site swap `F_j`, the expectation equals `Tr(rho_(U,j) rho_(V,j)) >= 1-2 epsilon`. By Hilbert--Schmidt Cauchy--Schwarz and `Tr(rho_V²)<=1`, this forces `Tr(rho_U²) >= (1-2epsilon)²` when `epsilon<=1/2`. Since `Tr(rho_U²)<=lambda_max(rho_U)`, the largest local eigenvalue is at least `1-4epsilon`. Select a unit top eigenvector `a_j` for each one-site `rho_(U,j)`. The associated local projections commute, and the union bound for commuting projections yields

    |<a_1⊗...⊗a_n,U>|² = <U,prod_j P_(a_j) U>
       >= 1-sum_j (1-<U,P_(a_j) U>) >= 1-4n epsilon.

Nonnegativity supplies the stated `max(0,...)`. The argument for V is identical. This proves all three estimates. No numerical optimization, finite-dimensional cutoff, or informal continuity assumption enters the proof.

### Concrete exact control and falsifier

For two sites, local dimension two and `t_1=t_2=1/2`, take `u=v=8|00>+|11>`. The squared norm of each vector is 65, `A²=4225`, `L=1/4`, `Delta=1/2`. Direct physical partial traces give `delta=128`, so `epsilon=256/4225`. The normalized vector has exact largest product overlap squared `64/65`. The theorem's lower bound is `1-8epsilon=2177/4225`, which passes.

A deliberately **100-fold overstated** spectral gap would produce the false bound `1-8epsilon/100 > 64/65`; the checker explicitly rejects this mutation. This confirms the constants have an observable operational meaning rather than being ornamental.

### Research role

This turns the previous purely spectral projection certificate into a **concrete separability-fidelity estimate**. For Lemnis/Vesper one-sided rank-r classes near a sharp zero boundary, each block whose slack `delta_i` is bounded by `epsilon_i Delta A_i²` has locally near-pure row/column factors and near alignment, while the exact sum-of-squares formulas separately constrain the complex block coefficients. It provides a possible quantitative route for perturbative uniqueness and robust certification **inside that restricted family**, not an unrestricted Werner endpoint proof. Constants are coarse; global originality and closest equality-case literature remain open.