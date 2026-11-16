# Sharp first-chaos budget for asymmetric nonorthogonal acute-ray sums

**2026-11-15 UTC.** Analytic all-length theorem, **not yet Lean compiled** or reviewed independently by a human probability specialist. This is a **restricted** genuine original-centered-law result, not a proof of the universal nonacute independent-Hilbert comparison or C96.57352. Prior all-n Bernoulli equality is from merged PR #569, not newly claimed.

## Theorem (exact original centered cap)

Let (H) be a real inner-product/Hilbert space and (I) finite. Fix deterministic (b,v_i\in H), satisfying
[
\langle v_i,v_j\rangle\ge0\quad(i\ne j),\qquad
\langle b,v_i\rangle\ge0.
]
Let (Z_i\ge0) be **independent** finite-valued real random variables (heterogeneous laws and zero-probability atoms allowed), with (m_i=\mathbb EZ_i). Assume the **original centered vector increments**
[
Y_i=(Z_i-m_i)v_i\quad\text{satisfy}\quad
\|Y_i\|=|Z_i-m_i|\,\|v_i\|\le c
]
at every support atom. Put
[
h=b+\sum_i m_i v_i,\qquad
X=h+\sum_iY_i=b+\sum_iZ_iv_i,\qquad
F=\|X\|,\quad u=\mathbb E F,
\]
and
[
W_1=\sum_i\operatorname{Var}(\mathbb E[F\mid Y_i]).
]
Then **for every finite n and every real Hilbert dimension**,
[
\boxed{W_1\le\operatorname{Var}(F)\le c\,\mathbb E F.}
]
In particular (W_1\le\|h\|^2+c\,u), the target first-level budget for this asymmetric, nonorthogonally interacting subclass. No assumption of symmetrically distributed (Y_i), pairwise orthogonality, fixed number of increments, a lower atom-probability floor, or a raw-amplitude cap (\|Z_iv_i\|\le c).

### Lemma 1: sharp monotone-Lipschitz conditional variance

Let (Z\ge0) have mean (m), let (g:[0,\infty)\to\mathbb R) be nondecreasing and (L)-Lipschitz, and suppose (L|Z-m|\le c). Then
[
\operatorname{Var}(g(Z))\le c\,[\mathbb E g(Z)-g(0)].
]
**Proof.** With an independent copy (Z'), monotonicity and Lipschitzness give pointwise
[
[g(Z)-g(Z')]^2\le L[Z-Z'][g(Z)-g(Z')].
]
Take expectations, divide by 2, use the two-copy variance/covariance identities, and subtract the constant (g(0)):
[
\operatorname{Var}(g(Z))
\le L\operatorname{Cov}(Z,g(Z))
=L\,\mathbb E[(Z-m)(g(Z)-g(0))]
\le c\,\mathbb E[g(Z)-g(0)].
]
The final inequality uses (g(Z)-g(0)\ge0) and (L(Z-m)\le c). Every step is an exact algebraic/probabilistic identity or pointwise inequality.

### Lemma 2: acute-cone deletion is monotone and self-bounding

Fix a realization (z_i\ge0), put (x=b+\sum_i z_iv_i) and (F_{-i}=\|x-z_iv_i\|). By nonnegative cross-inner products,
[
\|x\|^2-\|x-z_iv_i\|^2
=2z_i\langle b+\sum_{j\ne i}z_jv_j,v_i\rangle+z_i^2\|v_i\|^2\ge0.
]
Therefore (Δ_i=\|x\|-F_{-i}\ge0). The triangle inequality gives (\Delta_i\le z_i\|v_i\|), but **no upper raw-amplitude bound is used**.

For (x\ne0), take the norm-support vector (s=x/\|x\|). The support inequality
[
\|x\|-\|x-z_iv_i\|\le\langle s,z_iv_i\rangle
]
gives
[
\sum_i\Delta_i\le\langle s,x-b\rangle
=\|x\|-\frac{\langle x,b\rangle}{\|x\|}
\le\|x\|,
]
since (\langle x,b\rangle=\|b\|^2+\sum_i z_i\langle v_i,b\rangle\ge0).
If (x=0), acute Gram positivity forces each nonzero summand to vanish and hence (Δ_i=0), so the bound still holds. Thus
[
0\le\Delta_i,\qquad\sum_i\Delta_i\le F\quad\text{pointwise}.
]

### Proof of the theorem

Condition on all coordinates other than (i). The function
(g_i(z)=\|b+\sum_{j\ne i}Z_jv_j+zv_i\|)
is nondecreasing for (z\ge0) by the acute inner products, and it is (L_i=\|v_i\|)-Lipschitz by the reverse triangle inequality. The original centered vector cap says (L_i|Z_i-m_i|\le c). Lemma 1 gives
[
\operatorname{Var}_{Z_i}(F\mid Z_{-i})\le
c\,\mathbb E_{Z_i}[F-F_{-i}\mid Z_{-i}].
]
Finite-product Efron–Stein and Lemma 2 now give
[
\operatorname{Var}(F)
\le\sum_i\mathbb E\operatorname{Var}_{Z_i}(F\mid Z_{-i})
\le c\,\mathbb E\sum_i(F-F_{-i})
\le c\,\mathbb E F.
]
Orthogonal product Hoeffding projection gives (W_1\le\operatorname{Var}(F)). Centered-vector (Y_i) is a function of (Z_i); if (v_i\ne0), it is one-to-one in (Z_i), and if (v_i=0) that coordinate contributes zero. The projections in the statement are therefore exactly the first-level original product projections.

## Exact sharpness, all n

Take any (n\ge1), a unit vector (v), independent (B_i\sim\operatorname{Bernoulli}(p)) with (0<p\le1/2), (Z_i=B_i), (v_i=v), (b=0), (m_i=p), (Y_i=(B_i-p)v), (h=npv), and (c=1-p). Then (F=\sum_iB_i\ge0), so
[
u=np,\quad W_1=\operatorname{Var}(F)=np(1-p)=c\,u.
]
**Equality holds exactly for every n and every rational or real (p\in(0,1/2]\)**. This is the nonnegative-sum equality family already reported in [PR #569](https://github.com/d3lefts/d3lefts/pull/569); its use here certifies sharpness of the acute-cone theorem, not a separate priority claim.

## Genuine nonorthogonal asymmetric example

In (H=\mathbb R^2), choose (v_1=(1,0)), (v_2=(3/5,4/5)), so (\|v_i\|=1) and (\langle v_1,v_2\rangle=3/5>0). Let independent (B_1\sim\mathrm{Bernoulli}(1/4)) and (B_2\sim\mathrm{Bernoulli}(1/3)). Then (Y_i=(B_i-p_i)v_i) are nonsymmetric and **not orthogonal**; their actual maximal norm is (c=3/4). With (b=0) and (h=(1/4)v_1+(1/3)v_2), the exact mean norm is
[
u=\frac{5+4/\sqrt5}{12}.
]
The theorem proves (W_1\le(3/4)u) on the original source with no extra moment or owner premise.

## What remains open

No proof here covers **negative** cross-inner products (cancellation between directions), arbitrary centered increments not representable as acute-ray nonnegative amplitudes, or arbitrary source-owned Hilbert site sums. This restricted theorem cannot be substituted for the unrestricted independent-Hilbert lemma needed to establish the C96.57352 terminal Q2 coefficient.

The reusable operator is `MONOTONE_COVARIANCE + ACUTE_DELETION_SELF_BOUNDING`: instead of the false raw-amplitude estimate (\Delta_i^2\le c\Delta_i), work with a **conditional variance** and the exact centered increment cap. This is the structural advance.

Related prior art: Efron–Stein variance tensorization, classical self-bounding functions (Boucheron–Bousquet–Lugosi–Massart, *Ann. Probab.* 33 (2005)), symmetric Rademacher moment comparison (Latała–Oleszkiewicz), and merged NIGHTFALL #572 (orthogonal subcase). Independent proof review and precise novelty status still pending.
