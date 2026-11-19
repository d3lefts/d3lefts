# NIGHTFALL: degree-two binary FUR via Grothendieck factorization
Version 0.1 — 2026-11-19. **Author-side proof with independently replayed exact finite tests. No Lean terminal, non-author mathematical review, or novelty clearance.**

## Objective / strongest external reference

Close the missing `FUR`/hidden-latent-coordinate branch of `mixture_aa/MIXTURE_AA_POLYLOG_M_BRIEF_20261119.md` **for globally bounded Fourier degree ≤2 on Boolean inputs**. This does not prove the arbitrary-degree, arbitrary-alphabet or general quantum-query target.

**Critical external theorem checked this session:** real Grothendieck's inequality + finite matrix factorization, in Le–Levina–Vershynin, *Concentration and Regularization of Random Graphs*, Theorems 4.2 and 4.4 and equation (4.2), https://escholarship.org/content/qt3rh827d9/qt3rh827d9.pdf ; finite real Grothendieck constant `K_G < 1.783 < 2`. The `D_p^{-1/2} B D_q^{-1/2}` certificate is **not** proved in Lean by NIGHTFALL. Prior polynomial/quantum Grothendieck mechanism: Aaronson–Ambainis–Iraids–Kokainis–Smotrovs, CCC 2016, https://doi.org/10.4230/LIPIcs.CCC.2016.25. Credit these antecedents; no world-first label.

## Theorem A (paper derivation): one fixed squared-difference row

Let `n>=1`, `f:{−1,+1}^n -> [0,1]` have **global Fourier degree ≤2**. There exist nonnegative `w_1,...,w_n`, depending ONLY on f and not on any source laws, such that

    sum_i w_i <= 2
    for all x,y: (f(x)-f(y))^2 <= 289 * sum_{i:x_i!=y_i} w_i.  (A)

Construction and proof:

1. Write `f(x)=c+a·x+(1/2)x^T B x` with `B=B^T`, diagonal zero. Since `f(x),f(-x) ∈[0,1]`, `|2a·x|=|f(x)-f(-x)|≤1` for every sign vector. Consequently `sum |a_i|≤1/2`.
2. Let `f_2(x)=(f(x)+f(-x))/2-c=(1/2)x^T B x`. The constant `c=E_uniform f` is in [0,1]. Therefore `|f_2(x)|≤1` on the sign cube and, since `B_ii=0`, `f_2` is multi-affine and `|f_2(z)|≤1` for every `z∈[-1,1]^n`.
3. Polarization: for any sign vectors `s,t`,
   
       s^T B t = 2 [ f_2((s+t)/2) - f_2((s-t)/2) ].
   
   Thus `||B||_{infty->1} = max_{s,t signs} |s^T B t| ≤4`.
4. By the *external* Grothendieck inequality plus factorization theorem, there are probability weights `p_i,q_i` (nonnegative, each summing to 1) such that for all real `u,v`,
   
       |u^T B v| <= 2 ||B||_{infty->1}
          sqrt(sum_i p_i u_i^2) sqrt(sum_i q_i v_i^2)
       <= 8 sqrt(sum_i p_i u_i^2) sqrt(sum_i q_i v_i^2).
   
   If zero rows lead to vanishing weights, use the standard limit/compactness formulation.
5. Define `w_i=2|a_i|+p_i`. Then `w_i≥0`, `sum w_i≤2`. For any `x,y` put `t=x-y` and `v=(x+y)/2`. The symmetric quadratic identity gives `f(x)-f(y)=a·t+t^T B v` and `||v||_∞≤1`. Cauchy–Schwarz gives
   
       |a·t| <= (1/2) sqrt(sum_i 2|a_i| t_i^2).
       |t^T B v| <= 8 sqrt(sum_i p_i t_i^2).
       |f(x)-f(y)| <= (1/2+8) sqrt(sum_i w_i t_i^2).
   
   Since `t_i^2 =4*1[x_i!=y_i]`, squaring proves (A) with `4*(17/2)^2=289`.

**Stronger comparison of product means.** For any two Bernoulli products `P,Q`, let `m_i=2P[X_i=+1]-1` and `m'_i=2Q[X_i=+1]-1`. The identical polynomial identity yields

    |E_P f-E_Q f|^2 <= (17/2)^2 sum_i w_i(m_i-m'_i)^2
                     <= 578 sum_i w_i H^2(P_i,Q_i),          (B)

where `H^2(p,q)=1-BC(p,q)` and `TV(p,q)^2≤2H^2(p,q)`. Thus this fixed vector also proves the proposed **mean-level Hellinger FUR** in the Boolean degree-two case. Neither coefficient nor proof depends on n, M, tiny atom probabilities, or positive support.

## Theorem B (paper derivation): control hidden latent-coordinate increment by observable mutual information

Let `Theta` be finite with arbitrary prior `pi`; conditional on `theta`, bits `X_i` are independent with `P[X_i=+1|theta]=r_{theta,i}`. Let `U_i` be independent common uniform seeds, and set `h_i(theta,U_i)=+1` exactly if `U_i≤r_{theta,i}` (otherwise -1). **For binary alphabets this is simultaneously maximal for every pair of components:** `Pr_U[h_i(theta,U_i) != h_i(theta',U_i)]=|r_{theta,i}-r_{theta',i}|`.

Define `G(theta,U)=f(h(theta,U))`. It has values in [0,1], the same output law as f under the original mixture, and **global interaction degree ≤3** on the product space Theta × ∏U_i: each degree-two term touches ≤2 seeds plus the single Theta coordinate. Common seeds may be replaced by a finite partition of [0,1] at the M thresholds for each i, without approximation.

Let `J_theta=E_{theta,theta',U}|G(theta,U)-G(theta',U)|`, where theta,theta' are independent posterior draws. Write `I_i=I(Theta;X_i)` in *nats* for the actual component mixture, and `Imax=max_i I_i`. Then

    J_theta^2
      <= E_{theta,theta',U}(G(theta,U)-G(theta',U))^2
      <= 289 sum_i w_i E_{theta,theta'} |r_{theta,i}-r_{theta',i}|
      <= 289 sum_i w_i sqrt(2 I_i)
      <= 578 sqrt(2 Imax).

The third step: with `rbar_i=E_theta r_{theta,i}`,
`E_{theta,theta'}|r_theta-r_theta'|≤2E_theta|r_theta-rbar_i|≤sqrt(2I_i)` by triangle inequality, Pinsker `TV≤sqrt(KL/2)`, and Jensen. In particular

    Imax >= J_theta^4 / 668168.                              (C)

The seed-coordinate mean absolute increment satisfies exactly
`pincr_{U_i}(G)=E_theta pincr_i^{mu_theta}(f)`.

## Theorem C (paper derivation): degree-two Boolean Mixture-AA crux, independent of M

Apply the already kernel-checked product-space mean-increment theorem to the degree-≤3 lifted G. Denote `K_3=9*pi^2/2`. If the mixture variance `Var_nu(f)=Var(G)≥tau>0`, some coordinate `j` in {Theta} ∪ {U_i} has

    pincr_j(G) >= eta(tau) := tau^(3/2) / (12 K_3^2)
                            = tau^(3/2)/(243*pi^4).

If `j=U_i`, the posterior-averaged original-component mean absolute increment at i is at least eta. If `j=Theta`, equation (C) implies an original observed bit `i` with

    I(Theta;X_i) >= eta^4 / 668168.

Hence for **every** posterior mixture of Boolean product sources and every bounded **global Fourier degree≤2** section f with variance ≥tau, an observable coordinate i satisfies

    E_theta pincr_i^{mu_theta}(f) >= g(tau)
    OR  I(Theta;X_i) >= g(tau),

    g(tau) = [tau^(3/2)/(243*pi^4)]^4 / 668168
           = tau^6 / [668168*(243*pi^4)^4].                   (D)

For 0<tau≤1/4, g≤eta. This is precisely the n- and M-free **degree-two Boolean** instance of the repo's Mixture-AA crux, conditional only on *standard cited external Grothendieck factorization and Pinsker* and on the already certified product mean-increment theorem.

**Consequential scope boundary:** The existing two-potential stopping-time argument of `MIXTURE_AA_POLYLOG_M_BRIEF_20261119.md`, if checked at the posterior/conditioned-tree level, now gives the desired polynomial-in-log(M) classical depth for degree-2 bounded Boolean-polynomial acceptance functions. No terminal Lean declaration or independently reviewed end-to-end simulation has been produced here. This statement does not establish general quantum T (degree 2T), degree≥3, or arbitrary categorical alphabets.

## Independently registered checks and failure/edge cases

1. Exact-rational finite Fourier decomposition from truth-table averaging; checks every sign pair against a **separately constructed explicit** row-weight witness `w_i=2|a_i|+s_i/S` for cases with `S=sum_{ij}|B_ij|≤8`. That restricted witness follows *elementarily* from triangle inequality and does not test the universal Grothendieck factorization directly.
2. Fourier identity and cut-norm ≤4 are checked independently on all pairs of signs, not merely guessed from a random nonlinear optimizer.
3. Separate finite common-quantile coupling enumerates all cut-intervals for 3 latent components with 0,1 and small rational Bernoulli parameters, reproducing `J_theta²≤289 sum w_i E TV` without floating-point arithmetic.
4. Inputs include n=2..7, linear/additive, ferromagnetic quadratic and signed random dense quadratic functions. Source exact checked replay of **222,165** rational assertions / **216,960** ordered pairs / **96** hidden-coordinate cases (script under this PR).
5. **Independent criticism required:** challenge the matrix factorization constant, Fourier normalization (B_ij), the label/seed degree bound at zero atoms, the information-base conversion (nats versus bits), the posterior conditional step, and prior art. An explicit n-dimensional counterexample refutes our derived lemma; finite non-refutation cannot certify it.
6. Prior-art gap: Grothendieck was already applied to bounded quadratic quantum polynomials in CCC 2016. The *mixture entropy potential* and *fixed Hellinger row* may still be known; **no priority assertion**.

## Certification status and next actions

- A: paper-level derivation from a **fully identified external theorem**, not Lean certified.
- B–C: paper-level deductions, not independent referee certified.
- Exact checker: reproducible finite witness, not global proof.
- Overall theorem poly(log M) for bounded degree 2: **provisional paper-level composition**, not yet a named Lean terminal, venue-ready paper, or novelty-cleared breakthrough.

Cheapest next decisive test: independently replay a second implementation of the n=3/4 matrix factorization via an SDP dual and verify finite explicit factorized p,q; then source-level Lean encode A assuming the standard Grothendieck factorization theorem (do not assert it as an axiom without labeling), B, the finite quantile coupling, and C. Target generalization: arbitrary finite alphabets via a block-operator Grothendieck factorization retaining one total mass per coordinate; expect a distinct proof obligation rather than naive one-hot reduction (would leak alphabet size).

*Provenance:* NIGHTFALL research derivation based on `mixture_aa` original FUR crux and imported classical GP theorem. Preserve author/source attribution and invite external mathematical adversarial review.


## Independent adversarial no-go: pointwise fixed rows fail for categorical degree 2

**Exact analytic counterexample, not a counterexample to the Boolean theorem or to the mean-level Hellinger FUR.** For every integer N≥2, let A be **one categorical coordinate** taking N possible addresses, Y_1,...,Y_N independent binary coordinates, and set

    f(A,Y_1,...,Y_N) = Y_A in {0,1}.

This f has **global indicator-interaction degree 2**: f=Σ_{j=1}^N 1[A=j]·Y_j. For any proposed *fixed* nonnegative coordinate weights w_A,w_1,...,w_N and squared row constant C in

    |f(x)-f(y)|² <= C Σ_{i:x_i!=y_i} w_i   for ALL input pairs,

fix A=j at both endpoints, change only Y_j from 0 to 1, and keep every other coordinate identical. Then 1<=C w_j; summing the N independent leaf constraints gives

    Σ_i w_i >= N/C.

Thus there cannot be a universal coefficient C(d) and total fixed weight W(d) depending only on degree d=2 (without alphabet-size dependence) for the **pointwise** fixed-row statement on arbitrary categorical products. The obstruction is alphabet-size-addressing, not a failure of the latent-product crux. A comparison of *product expectations* can charge the categorical address change in Hellinger distance, so the weaker Hellinger **mean** FUR still requires a separate proof or counterexample. This is the decisive proof-attack for any attempt to port Theorem A by replacing bits with arbitrary one-hot atoms.

Transfer directive: keep the proven Boolean-degree-two fixed row + common monotone coupling; do **not** announce all-alphabet closure or substitute categorical pointwise weights. To reach arbitrary alphabets investigate source-dependent mean-level FUR and/or a block-Grothendieck theorem controlling changes to a *categorical address* by its own information. Note the existing categorical selector context in #811/#812; do not claim the selector construction itself is new.
