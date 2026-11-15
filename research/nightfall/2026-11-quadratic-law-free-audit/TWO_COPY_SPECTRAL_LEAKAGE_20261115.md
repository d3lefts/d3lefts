# C96 first-chaos — exact two-copy Fourier leakage obstruction

2026-11-15 UTC. Analytic identity and exact finite counterexample. Does **not** refute the desired unrestricted first-level budget and does **not** provide an end-to-end C96 Lean certificate.

## Universal product spectral identity

For a real scalar finite product function (Fin L^2(igotimes_imu_i)) with orthogonal Hoeffding expansion (F=sum_{Ssubseteq[n]}F_S), let (W_S=mathbb E F_S^2).

Independently sample two draws (A_i,B_isimmu_i) and fair orientation signs (epsilon_i). Let (Z_i(epsilon_i)=A_i) for sign (+1), (B_i) for (-1), and set
[
 t_i(A,B)=mathbb E_epsilon[epsilon_i F(Z(epsilon))].
]

**Exact identity:**
[
oxed{2,mathbb E_{A,B}sum_i t_i(A,B)^2
=sum_{arnothing
eq Ssubseteq[n]} |S|,2^{1-|S|}W_S.}	ag{1}
]

**Proof.** For a pure degenerate component (F_S) with (iin S), the (i)-th first-sign coefficient is the coordinate-pair difference ((D_iF)(a_i,b_i)=rac12(F(a_i)-F(b_i))), followed by coordinate-pair averages (M_j=(f(a_j)+f(b_j))/2) for each (jin Ssetminus{i}). Under independent pairs, each of these maps divides the squared (L^2) norm by (2) on the corresponding centered coordinate subspace. Their product therefore contributes (2^{-|S|}W_S). Components indexed by distinct (S) remain orthogonal because at least one coordinate in their symmetric difference is centered in exactly one component. Sum over (iin S) and multiply by 2. Constants have no signed coefficient.

Equivalently, writing product noise stability (N(ho)=mathbb E F,T_ho F=sum_S ho^{|S|}W_S),
[
2mathbb Esum_i t_i^2=N'(1/2), qquad W_1=N'(0).
]
The two-copy method evaluates the **wrong spectral derivative**. It includes every degree-two component with weight 1, even though the target first-level budget involves only degree one.

## Exact four-sign no-go

Take independent fair (epsilon_1,dots,epsilon_4in{-1,+1}), shift (h=0), (c=1), (F=|epsilon_1+cdots+epsilon_4|). The Walsh expansion is exactly
[
F=rac32+rac12sum_{i<j}epsilon_iepsilon_j-rac12prod_iepsilon_i.
]
Thus (u=mathbb EF=3/2), (W_1=0), (W_2=3/2), (W_4=1/4). Identity (1) gives
[
2mathbb Esum_i t_i^2 = W_2+	frac12 W_4
=	frac32+	frac18=	frac{13}{8}>	frac32=c,u.
]
Hence the proposed *stronger* two-copy comparison
(2Esum_i t_i^2le |h|^2+c u)
is FALSE by exactly (1/8), while the original desired (W_1le|h|^2+c u) holds with (W_1=0). The counterexample is also independently checkable by direct enumeration over (4^4) equally likely draw-pairs and all (2^4) orientations. No floating point or tolerance is involved.

## Research operator to retain

The correct object is *exact zero-correlation first-chaos projection*, not a positive-correlation two-copy sign energy bound. Any proof using pair symmetrization must subtract or cancel all degree-two and higher components before appealing to the (c,E|X|) budget. Increasing the replica count or lowering a fixed positive noise correlation does not achieve a dimension-free conclusion without controlling the residual spectral tail.

**Proof status:** paper identity with independent exact enumeration; no pinned Lean compilation, no external referee. **Scope:** arbitrary finite independent source laws, scalar real output (F) (in particular (F=|h+sum_iY_i|)). This is an operator obstruction, not an inequality for arbitrary high-dimensional agent systems.
