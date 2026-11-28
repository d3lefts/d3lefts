# Dependency-reduced all-fixed-order tensor simulation: prefix-rank geometry and Markov–Bonami junta route
NIGHTFALL author-side addendum, 2026-11-25. Follows #1229 PROOF.md. Status: complete written arguments below; local Lean component formalization proceeding, not a full kernel terminal or independent review. No novelty claim for classical tensor rank, Markov or Bonami inequalities. This note removes the need to import Lovitz–Petrov Corollary 21 and Boolean Bohnenblust–Hille as theorem-shaped assumptions for the binary tensor model. Their prior contributions remain credited. Objective: reduce formalization burden while improving query dependence. No polynomial-time or variable-T guarantee.

## A. Elementary binary tensor circuit localization via prefix rank
Let C be a minimal nonempty zero-sum set of s distinct nonzero pure tensors a_i=⊗_{j=1}^L v_{ij}, over F2 with nonzero local factors. Let u_i^j be the prefix through site j, u_i^0=1, and r_j=dim span_i u_i^j. Each prefix vector is nonzero. We have r_0=1 and r_L=s-1: over F2 a nontrivial dependence is exactly a nonempty zero-sum subset, so all proper subsets are independent while the full set sums to zero.

Fix j. Choose indices B forming a basis of the prefix span before site j. The r_(j-1) vectors u_b^(j-1)⊗v_bj are independent: apply the dual coefficient functional for b to the prefix tensor factor, leaving the coefficient times the nonzero v_bj. Hence r_j≥r_(j-1). Suppose equality. Then these tensorized basis vectors span the new prefix vectors, and for each i there are unique binary expansions
u_i^(j-1)=sum_b c_bi u_b^(j-1),
u_i^j=sum_b d_bi (u_b^(j-1)⊗v_bj).
Applying the same dual coefficient functional to the second equality gives c_bi v_ij=d_bi v_bj. Nonzero local vectors and F2 scalars imply c_bi=d_bi, and any nonzero coefficient forces v_ij=v_bj.

If site j varies, select a local factor v appearing among some but not all circuit rows. The subset I_v={i:v_ij=v} is nonempty and proper. Define the linear projection P on the prefix span by P(u_b)=u_b for v_bj=v and 0 otherwise; extend linearly to the ambient finite prefix tensor space using any complementary basis. The expansion property proves P(u_i)=u_i if i∈I_v and 0 otherwise. Apply P⊗id on the remaining tensor factors to the full zero sum. This produces sum_{i∈I_v} a_i=0, contradicting circuit minimality. Therefore equality is impossible at a varying site and r_j≥r_(j-1)+1 there.

Sum the rank increments: #varying sites ≤r_L-r_0=s-2. This is the exact needed binary specialization, independently derived at author side, not a new global tensor theorem. It can replace the external LP dependency using finite-dimensional basis/dual functionals, tensor product maps and rank arithmetic already available in Mathlib. It also establishes all prefix rank monotonicity explicitly. No reliance on nonminimal circuits. Nonzero factors essential; over other fields replace equality by proportionality with additional bookkeeping.

## B. Dimension-free square-root influence bound by Markov plus fourth moment
Let G be a real multilinear polynomial of degree≤d on a finite independent uniform sign cube, ||G||∞≤M. Assume d≥1. For x fixed, write x^(i) for flipping sign i and Δ_i(x)=G(x^(i))-G(x). For any set J of coordinates, independently flip each coordinate in J with probability t∈[0,1]. The expectation F_x,J(t) is polynomial of degree≤d in t: each Fourier monomial x_S contributes x_S(1-2t)^|S∩J|. It is bounded in absolute value by M. Its derivative at zero is sum_{i∈J} Δ_i(x). Markov on [0,1] gives |sum_{i∈J}Δ_i(x)|≤2d²M. Choose J+ and J- according to the signs of Δ_i(x), then sum the bounds. Thus ∑_i |Δ_i(x)|≤4d²M. Put ∂_i G=(G(x with i=+1)-G(x with i=-1))/2, a degree≤d-1 polynomial on remaining signs. Since |Δ_i|=2|∂_i G|, averaging gives ∑_i E|∂_i G|≤2d²M.

For any real polynomial h of degree≤r on independent uniform signs, prove E h^4≤9^r(E h²)^2 by induction on number of signs, simultaneously for all r. Constant r=0 immediate. Write h=g+x_n k with deg g≤r, deg k≤r-1. Let A=E g², B=E k². Then E h²=A+B and E h^4=E g^4+6 E g² k²+E k^4. Cauchy–Schwarz and the induction bounds imply E g² k²≤3^(2r-1) A B. Consequently E h^4≤9^r A²+6·3^(2r-1)AB+9^(r-1)B²≤9^r(A+B)². For zero second moment h is zero everywhere. Otherwise two Cauchy–Schwarz applications give (E h²)^2≤E|h| E|h|³ and (E|h|³)^2≤E h² E h^4, hence (E h²)^3≤(E|h|)^2 E h^4. Combining yields sqrt(E h²)≤3^r E|h|.

By Boolean Parseval I_i:=E(∂_i G)^2=∑_{S containing i} g_S². Thus
∑_i sqrt(I_i)≤B_d(M):=2d²3^(d-1)M.
The operator is elementary and uses exactly the certified Markov derivative estimate. Classical hypercontractivity/low-degree influence bounds precede this application; do not claim their invention.

## C. Primitive quotient junta terminal, stronger accuracy dependence
Let G be the primitive extension from #1229, with degree≤d and ||G||∞≤U_d(L)||P||∞. Let K_d(L) bound the number of its primitive supports per frequency, as in #1229 (zero frequency has only the empty support). Define B=B_d(U_d(L)||P||∞). For threshold τ>0, query the original variables Q={i:sqrt(I_i)≥τ}. Then |Q|≤B/τ and
∑_{S not subset Q} g_S²≤∑_{i not in Q} I_i≤τ∑_i sqrt(I_i)≤τ B.
The first inequality charges each omitted nonempty support to at least one unqueried index. The estimator G_Q discards monomials with S not subset Q; it is evaluable using exactly the selected legal oracle coordinates, with no free hidden-secret query. On the correlated uniform tensor-character source, orthogonality of distinct characters and Cauchy–Schwarz on each primitive frequency fiber give
E_s (G(x(s))-G_Q(x(s)))²
=∑_f (∑_{S omitted:XOR S=f} g_S)^2
≤K_d(L) ∑_{S omitted}g_S²
≤K_d(L) τ B.
If B=0, G is constant, requiring no queries. Otherwise choose τ=ε²δ/(K_d(L)B). Then failure≤δ by Markov, with
Q_C≤min(|R|, floor(K_d(L)·[2d²3^(d-1)U_d(L)||P||∞]^2/(ε²δ))).
If all rows are queried one may evaluate P exactly; clip the prediction to [0,1] for acceptance. This replaces the earlier bound with power d of the inverse error by the single ε^-2 δ^-1 dependence, though U_d(L) and K_d(L) still have extremely large degree-dependent growth. It avoids the Boolean BH formalization altogether. For any fixed T, take d=2T. This is valid for every globally bounded polynomial under the same source/geometry assumptions; it does not show efficient classical runtime. The numerical bound should be compared on the actual model; no world-record or global novelty claim.

## D. Formalization boundary and audit
Use actual prefix basis rank in A, actual fourth moment induction and independent-sign orthogonality in B, and actual primitive frequency collision count and Cauchy–Schwarz aggregation in C. No theorem-shaped axioms or unproved external imports. The existing signed block Markov estimate is locally kernel replayed. The new Lean component modules target circuit partition and anchor geometry, finite threshold and energy aggregation, and fourth-moment algebra; complete integration is still required. Independent review should challenge rank-equality projection extension, minimality over F2, degree of the random-flip interpolation, Cauchy exponent factors, zero-influence case, support counting and the final query-vs-runtime distinction. The existing norm-control recurrence of #1229 is unchanged, and its global block assembly still needs exact formal composition. No merge/publication authorization.
