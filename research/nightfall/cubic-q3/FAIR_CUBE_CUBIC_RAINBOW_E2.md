# FAIR-CUBE CUBIC EXPONENT-TWO: N-RAINBOW-Q3 v1.0

**2026-11-17, NIGHTFALL / AI-assisted mathematics.** Status: **author-side analytic deduction with exact finite replay, NOT a Lean certificate or an independently reviewed theorem**. No claim of novelty or unrestricted arbitrary-product Q3. Ingredients: existing author-side sharp anchored multipartite inequality [PR #804](https://github.com/d3lefts/d3lefts/pull/804), original-product Q2 C105.416 [merged PR #776](https://github.com/d3lefts/d3lefts/pull/776), classical sharp Hilbert Khintchine–Kahane (Latała–Oleszkiewicz 1994).

## Main theorem: finite fair cube, mixed Fourier degree <= 3

Let f : {−1,+1}^n -> R have Fourier degree <= 3, and define B := (max f − min f)/2, V := Var(f), M := max_i Inf_i(f) with **original fair resampling influence** Inf_i(f)=sum_{S contains i} hat_f(S)^2. Write V3 = sum_{|S|=3} hat_f(S)^2.

**(A) Top cubic energy:** V3^2 <= 81 B^2 M.

**(B) Total cubic variance:**
V^2 <= (5 sqrt(C2) + 9)^2 B^2 M < 3661 B^2 M
with C2 = (2 sqrt(3)(1+sqrt(2)) + 11901/6250)^2 approximately 105.41623982, the Q2 result of #776. This improves Turturean's 5/2 variance dependence **when restricted to degree 3 on the fair Boolean cube**. It does not improve his unrestricted all-degree polynomial-in-degree theorem.

## Proof A: random rainbow parity projection

Let h=f−(max f+min f)/2, so ||h||∞=B. Independently color each variable c(i) in {1,2,3}. For sigma in {−1,+1}^3 put x^(sigma)_i=sigma_{c(i)} x_i, and define

R_c h(x) = (1/8) sum_sigma (sigma_1 sigma_2 sigma_3) h(x^(sigma)).

Being an average of signed bounded values, ||R_c h||∞ <= B, **with no loss in B**. Walsh character orthogonality means R_c h retains exactly those supports containing an odd number of variables in each of the three colors. Because deg(f)<=3, these are exactly rainbow triples with one coordinate from each group. Thus R_c h is a homogeneous three-partite cubic with fair signs in all groups.

Fourier orthogonality gives Inf_i(R_c h) <= Inf_i(f) <= M. The previously established anchored tripartite inequality of PR #804 gives Var(R_c h)^2 <= 4 B^2 M, hence Var(R_c h) <= 2 B sqrt(M).

A fixed 3-set of coordinates is rainbow under independent three-coloring with probability 3!/3^3=2/9. Orthogonal Fourier energies therefore give E_c Var(R_c h) = (2/9) V3. Averaging the **already-uniform upper bound** on variance, NOT swapping E max_i with max_i E, gives (2/9) V3 <= 2 B sqrt(M), proving A.

## Proof B: remove odd cubic by source-preserving noise

Write h_odd(x)=(h(x)−h(−x))/2 = h1(x)+h3(x). Then ||h_odd||∞<=B. For the fair-cube noise operator T_t, ||T_t h_odd||∞<=B (0<=t<=1) and T_t h_odd=t h1+t^3 h3. At t=1/2 one has the exact identity

h3 = (4/3) h_odd − (8/3) T_(1/2) h_odd,

so ||h3||∞<=4B. Define g=h−h3: it is Fourier degree <=2, ||g||∞<=5B, and Inf_i(g)<=Inf_i(f) for every i. Apply #776's degree-2 inequality to obtain V_<=2 = Var(g) <= 5 sqrt(C2) B sqrt(M). By A, V3 <= 9 B sqrt(M). Orthogonal sector decomposition gives V=V_<=2+V3 and proves B. Exact rational margin: C2<106, 5sqrt(106)+9<121/2, and (121/2)^2=14641/4<3661.

## All-degree *top-sector*, not all-degree total-variance, theorem

For deg(f)<=d and d>=1, color each coordinate uniformly in {1,...,d} and use the analogous signed parity average (1/2^d) sum_sigma (product_r sigma_r) h(sigma_color(i) x_i). It is a norm-one projection onto rainbow Fourier monomials of *exact* degree d. Every d-set survives with probability p_d=d!/d^d. The degree-d anchored multipartite theorem from #804 gives Var(R_c h) <= 2^((d−1)/2) B sqrt(M). Therefore

**(C) V_d^2 <= 2^(d−1) (d^d/d!)^2 B^2 M.**

At d=1 coefficient 1, d=2 coefficient 8, d=3 coefficient 81. Dependence on d is exponential, not Turturean's polynomial d^6. Lower Fourier levels are not controlled by (C) alone. The mixed cubic bound (B) specifically uses the separate Q2 theorem.

## Audits, provenance, novelty, remaining gap

- Exact enumerations: check_cubic_fair_rainbow.py; 45 seeded rational models, exhaustive d-colorings for n<=6, independent physical-table influence calculation, **independent direct parity-sign projector evaluation** against Fourier selection, explicit eight-sign router.
- For any infinite product of independent fair signs, the finite Q3 inequality transports through finite-coordinate conditional expectations, L2 convergence, boundedness and original-influence contraction. This is an author-side corollary, **not a new Lean declaration**.
- Prior art: DFKO 2006/07, O'Donnell–Zhao 2016 and Defant–Mastyło–Pérez 2019 prove exponential-in-degree influence bounds; Escudero Gutiérrez 2023 proves stronger inequalities for *completely bounded* homogeneous forms. Our derivation is an explicit mixed-degree d=3 quantitative deduction from classical tools, not a global-originality claim. Compare [Turturean 2611.09773](https://arxiv.org/abs/2611.09773) and [Stanford exposition 2611.11626](https://arxiv.org/abs/2611.11626).
- **Open:** extend (B) to arbitrary biased/categorical original source laws. The two-replica fair orientation does not justify E(max_i I_i) <= O(max_i E I_i); that is precisely the source-coupled gate in [PR #803](https://github.com/d3lefts/d3lefts/pull/803). Neither N-UE2(6) nor N-UE2(2) is established.
- No Lean kernel run, nonauthor independent proof sign-off, global priority clearance, or paper submission is claimed.

**Discovery graph:** finite fair cube -> random grouping -> signed norm-one parity projector -> anchored multipartite bound -> exact 2/9 energy retention -> top-level exponent 2 -> odd-noise decomposition -> mixed cubic exponent 2 -> arbitrary-law obstruction.
