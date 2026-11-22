# NIGHTFALL: A Rigidity-to-Certificate Principle (v1.1)

**Date:** 2026-11-22. **Status:** elementary proved conditional corollaries and an exact arithmetic checker; general framework is a synthesis of classical finite-dimensional duality, arithmetic integrality, and the original source-rigidity theorem. Not Lean-checked, not externally reviewed, not priority-cleared.

**Original source:** September 2026 paper *Affine Source Rigidity and Möbius Cancellation in a Shifted Prime-Zeta Deformation*, corrected LaTeX version held in the user's Library as affine_source_rigidity_v_final_corrected.tex. **Other source:** the Simon fixed-degree paper-level proof in #1023, merged at 66f70ee3b981f18f9e3d743219db7ba06eeaf104. The proposed Simon all-k statement is not yet independently or Lean certified.

## Research contract

Objective: decide precisely when source-collision rigidity can be converted to a finite, quantitatively stable, externally checkable cancellation or distortion certificate.

Inputs/feasible set: (i) source maps with finite collision fibers; (ii) analytic singular modes modulo holomorphic germs, **only if local continuation/remainder conditions hold**; (iii) exact rational channel weights; (iv) finite-dimensional observable subspaces and bounded probes.

Strongest external predecessors examined this session: classical Prony/super-resolution stability and confluent Vandermonde analysis (Batenkov and Yomdin, SIAM 2013; 2014/2025 works), standard norming-set/dual-certificate and Hahn-Banach arguments, and Candela–González-Sánchez–Szegedy, *On F_2^omega-affine-exchangeable probability measures* (Studia Mathematica 279, 2024). These own broad mechanisms; **no general novelty claim**.

Best verified advance: **the first shifted layer (k=1) now has an unconditional local removability classification**, proved by combining the classical meromorphic continuation of P'(w) on Re w>0 with the September paper's holomorphic first-layer remainder. The isolated higher-layer local-germ quotient is rank one and exactly decidable under the original conditional decomposition hypotheses. There are an arithmetic gap, modular noncancellation certificates, and a precise monodromy noise threshold. Exact checker with 1,700 synthetic fibers and rational probe matrices passed locally. A 2.5x sharper threshold than a naive denominator-times-condition-number bound is demonstrated in one rational toy system; not a scientific record.

Independent audit: reconstruct the conditional analytic hypothesis directly from the manuscript; attack the alleged global continuation implications; independently verify integer and p-adic proofs; audit the probe operator against the Simon paper's source-specific test norm. Stop rule: if any conditional hypothesis is missing, demote the holomorphic-removability conclusion to a statement solely about the isolated finite channels. Cheapest decisive experiment: check the local-germ proposition's common prefactor and holomorphic remainder, then replay the modular cancellation and noisy reconstruction checks. Scope limits and prior-art status travel with these results.

## 0. New unconditional first-strip upgrade (version 1.1)

A separate source-level proof is in **FIRST_STRIP_PRIME_ZETA_RIGIDITY_CERTIFICATE_20261122.md**. For lambda=rho/n with nontrivial zeta zero rho and s0=lambda-1, the Möbius derivative

  P'(w) = Σ_{m>=1} μ(m) ζ'(mw)/ζ(mw)

converges normally in its tail and defines a single-valued meromorphic function on Re w>0. Its residue at the nonreal point lambda is exactly M(lambda)=Σ_{m∈F_lambda} μ(m)r_m/m. Thus the local prime-zeta germ has the complete form M(lambda)log(w-lambda)+holomorphic, **without** the original manuscript's separately assumed local continuation hypothesis.

The manuscript's proved first-layer identity A_plus(s)=sP(s+1)+H(s), H holomorphic Re s>−1, then gives for every s0=lambda−1 in the first strip

  A_plus(s)=s M(lambda) log(s-s0)+holomorphic.

Consequently the **full first-strip local continuation is holomorphically removable iff M(lambda)=0, unconditionally** (relative to classical zeta meromorphic continuation). The all-layer statement below remains conditional for k>=2. The source paper's all-layer 'complete germ cancellation open' language is not contradicted outside this first-strip scope. Broad prime-zeta continuation is classical; global originality not established.

## I. Finite singular-mode reduction

Let s0 be a candidate singular point, and let F be a finite collision fiber. Suppose in a fixed punctured local chart

  f(s) = Σ_{i∈F} f_i(s) + h(s),

where h is holomorphic through s0. Suppose each source term has a decomposition modulo holomorphic germs

  [f_i] = Σ_{j=1}^r q_{ij} [ψ_j],

where the r modes [ψ_j] are **linearly independent modulo holomorphic germs** and q_ij are rational. Then

  [f] = Σ_j b_j [ψ_j],    b_j = Σ_i q_ij.

The germ is holomorphically removable at s0 **if and only if** b_j=0 for every j. If a common positive integer D clears all denominators, A_j=D b_j is an integer vector. Hence the exact certificate is

  f removable  <=> A=0,
  f not removable => ||b||_∞ >= 1/D.

This is finite-dimensional linear algebra *conditional on the complete local mode decomposition*. A finite collision fiber alone does not imply bounded r, mode independence, control of the remainder, or well-conditioned observations. The statement is a direct classical observation, not claimed novel.

## II. Prime-zeta specialization: a stronger conditional local theorem

The corrected September manuscript defines

  Phi(rho,n,k)=rho/n-k,   lambda=rho/n,   s0=lambda-k,

and proves collisions require the same translation layer k and rationally dilated zeta zeros. Write

  C_lambda={m>=1 : m lambda is a nontrivial zeta zero},
  F_lambda={m in C_lambda : mu(m)!=0},
  r_m=ord_{m lambda}(zeta),      P_k(s)=(s)_k/k!.

The original manuscript's **Conditional Local Germ Decomposition** (Proposition prop:local-germ, relying on prop:local-continuation) states, under a simply connected local chart, compatible logarithm branches, isolation of all other singular arguments, and a normally convergent holomorphic remainder,

  A_plus(s) = P_k(s) [Σ_{m∈F_lambda} mu(m) r_m/m] log(s-s0) + h(s),
  h holomorphic through s0.

**Proved conditional corollary (full local cancellation classification).** Let D_lambda=lcm(F_lambda), with D_lambda=1 for an empty active fiber, and define

  A_lambda=Σ_{m∈F_lambda} mu(m)(D_lambda/m) r_m ∈ Z.

Then the isolated channel germ space modulo holomorphic functions has dimension **one if F_lambda is nonempty, zero if empty**: all active modes are scalar multiples of the single nonholomorphic germ [P_k(s) log(s-s0)]. Because 0<Re(lambda)<1, P_k(s0)!=0. Consequently, **under exactly the strong local decomposition hypotheses above**,

  A_plus extends holomorphically through s0  <=>  A_lambda=0.

If A_lambda!=0, then the *leading logarithmic coefficient* C0 satisfies

  |C0| >= |P_k(s0)| / D_lambda.

Proof: numerator integrality gives |A_lambda|>=1 if nonzero; nonvanishing of P_k(s0) follows from its factors lambda-j, 1<=j<=k. Conversely if A_lambda=0 the full common logarithmic term vanishes **identically as a germ**, not merely at s=s0, and the remainder is holomorphic. If A_lambda!=0, continuation around s0 has nonzero monodromy, so no holomorphic extension exists.

**Manuscript reconciliation:** The source paper treats M(lambda)=0 as *only* cancellation of the leading coefficient, and lists complete germ cancellation as open. That caution remains warranted **without** a proof of the local analytic continuation and holomorphic-remainder hypotheses. But *once Proposition prop:local-germ's stated hypotheses are assumed*, its displayed formula implies full local equivalence and rank one. The proposed open problem dim(G_lambda)>|C_lambda| cannot hold within this same complete local model, since dim(G_lambda)<=1. This is a scope correction, not an unconditional analytic continuation proof.

### II.a Quantitative binomial gap

Write a=Re(lambda)∈(0,1). Since |lambda-j|>=j-a,

  |P_k(s0)| = ∏_{j=1}^k |lambda-j|/j >= ∏_{j=1}^k (1-a/j).

If a<=1/2 (in particular, whenever lambda=rho/n for some n>=2, since Re(rho)<1),

  |P_k(s0)| >= ∏_{j=1}^k (1-1/(2j)) = binom(2k,k)/4^k.

Therefore a nonzero local coefficient in this range obeys the explicit, uniform-in-height lower bound

  |C0| >= binom(2k,k)/(4^k D_lambda).

This is a genuine *conditional* quantitative strengthening of the manuscript's qualitative nonvanishing statement. It does not bound D_lambda uniformly as lambda varies. Indeed m Re(lambda)<1 only implies m<1/Re(lambda), so the denominators may grow as Re(lambda) approaches zero.

### II.b Prime-adic no-cancellation test

Let p be a prime dividing D_lambda. Since every active m has mu(m)∈{−1,+1}, its denominator is squarefree. If p divides **exactly one** active denominator m0 and p does not divide r_m0, then

  A_lambda ≡ mu(m0) (D_lambda/m0) r_m0  (mod p) != 0.

More generally, let v=max_{m∈F_lambda} v_p(m), and T_p={m:v_p(m)=v}. Then

  A_lambda ≡ Σ_{m∈T_p} mu(m)(D_lambda/m) r_m (mod p).

Any nonzero residue is a finite exact noncancellation certificate. Independent proof route: the distinguished p-adic valuation is strictly smaller than every other term's valuation; a unique minimal valuation term cannot cancel under the ultrametric inequality.

**Caveat:** Synthetic fibers are not certified realizable by actual zeta-zero dilation relations. The test becomes an assertion about the original analytic function only after all relevant zeros, multiplicities, the fiber's completeness, and the local continuation hypotheses have been established. An empty active fiber gives A_lambda=0.

### II.c One-loop monodromy certificate and exact recovery threshold

For any basepoint s in a sufficiently small punctured local chart where P_k(s)!=0, analytic continuation once around s0 changes the germ by

  Δ A_plus(s)=2π i P_k(s) A_lambda/D_lambda.

Thus, if the complete local chart is available, one normalized monodromy probe recovers the **exact rational** cancellation coefficient:

  Δ A_plus(s)/(2π i P_k(s)) = A_lambda/D_lambda.

For complex measurement error at most η in Δ A_plus(s), nearest-integer rounding of

  D_lambda Δtilde/(2π i P_k(s))

recovers A_lambda exactly whenever

  η < π |P_k(s)|/D_lambda.

The factor one-half in this separation threshold is optimal in the unrestricted one-dimensional nearest-neighbor noise model (two adjacent integer numerators have monodromy values separated by 2π|P_k(s)|/D_lambda). **This requires a certified analytic loop and its measurement; it is not a computational claim that such a loop is currently accessible.**

## III. General task-aware calibrated certificate

Let V be a D-dimensional real vector space of bounded observables on some sample space, with invariant basis U_1,...,U_D. Suppose P_i:V->R, i=1,...,D, are **norm-one-or-less** expectation probes: |P_i(g)|<=||g||∞. Let M_ij=P_i(U_j), invertible; let L:V->R be the target functional with ell_j=L(U_j). For every ||g||∞<=1,

  L(g) = Σ_i w_i P_i(g),     w=M^{-T} ell,

hence

  |L(g)| <= ||w||_1.

The weight vector w is the **unique exact certificate in the selected D-probe basis**. It is a task-specific certificate and may be much smaller than a full inverse's condition number. It need not equal the optimal norm of L over all possible probes or test functions.

For a family indexed by t, suppose M_t=M_∞+E_t, M_∞ invertible with ||M_∞^{-1}||∞=K, and ||E_t||∞<=epsilon_t with K epsilon_t<1. If |L_t(U_j)|<=delta_t for all j, then

  sup_{g∈V_t,||g||∞<=1}|L_t(g)|
    <= D K delta_t / (1-K epsilon_t).

Proof: the Neumann resolvent yields ||M_t^{-1}||∞<=K/(1-K epsilon_t). Write ell^T M_t^{-1} P(g) and use ||P(g)||∞<=1. For a rank-deficient probe system, a certificate still exists for a **particular target** L iff L annihilates ker(P), equivalently L belongs to the probe span; invertibility of the entire basis is sufficient but not necessary. This is classical duality and finite-dimensional perturbation theory.

**Discrete coefficient recovery.** Suppose the target collision coefficients are b_j=A_j/d_j, with A_j∈Z and d_j>=1 known. A measurement is y=M b+e, ||e||∞<=η. Put Ddiag=diag(d_j). Then

  Ddiag M^{-1} y = A + Ddiag M^{-1}e.

Nearest-integer rounding recovers **all** A exactly if

  η < 1/(2||Ddiag M^{-1}||∞).

This is a sharper and more task-aware condition than replacing the denominator-weighted inverse by (max d_j)||M^{-1}||∞. The exact rational toy test achieves a **2.5x larger certified error threshold** than that coarse inequality. The 1/2 factor is sharp in one-dimensional nearest-lattice ambiguity; the displayed multidimensional norm threshold is sufficient, not necessarily globally optimal.

### III.a Why rigidity by itself is insufficient

Take two distinct source locations x0,x1 and two genuine probability probes

  P1(g)=g(x0),
  P2(g)=(1-eps)g(x0)+eps g(x1),    eps>0.

The sources are perfectly rigid (different locations), but the exact unique probe representation of L(g)=g(x1)-g(x0) is

  L=(P2-P1)/eps,

whose certificate cost is **2/eps** and diverges as eps->0. No dimension- or model-uniform robustness follows from injectivity alone. Similarly, distinct sources can carry coefficients 1/n and have arbitrarily small nonzero amplitudes: exact uniqueness is not a uniform arithmetic separation bound.

## IV. Relation to Simon and limits of transfer

The Simon result uses affine action of AGL(m,2) on address sets and label permutations. Its finite invariant directions at k<=5 and exact k=6 structural dimension D_6=24 are documented in #1013/#1023. Here the calibrated-probe theorem identifies precisely the **conditioning** obligation. Under the all-k affine-rank interpolation lemma still awaiting independent audit, Simon would have bounded inverse probes at each fixed k and therefore a uniform distortion certificate Γ_k<=C_k/N. There is **no rational-integer cancellation lattice** available for arbitrary bounded test functions, and no justification for importing the prime-zeta modular obstruction into Simon.

For the September prime-zeta paper, the integer arithmetic makes exact cancellation decidable once the complete finite fiber is supplied **in the first strip**, because the classical prime-zeta derivative and the source manuscript's first-layer localization supply local continuation. In higher layers, local analytic continuation remains a separate hypothesis; the checker does not make zero-fiber enumeration automatic. The two papers instantiate different modules of the same conditional general scheme: rigidity → finite modes → (discrete gap OR norming probes) → exact or robust certificate.

## V. Evidence, audit and priority

- Reproducible stdlib checker: scripts/rigidity_to_certificate_exact_audit.py.
- 1,700 seeded synthetic fibers; exact independent Fraction summation and integer clearing; modular residue tests; 3x3 rational inverse plus exact minors; an explicit 2.5x threshold improvement; 2-source ill-conditioning and midpoint ambiguity controls.
- These checks **do not** establish any actual multi-member zeta-zero dilation fiber or independent proof review. They do not repair missing analytic continuation.
- Prior art for the matrix inverse/probe framework is extensive: Hahn–Banach duality; stable sampling and norming sets; Prony, Vandermonde and super-resolution (e.g. https://epubs.siam.org/doi/10.1137/110836584, https://www.sciencedirect.com/science/article/pii/S1063520324000642). Affine exchangeable pattern-limit theory is substantial (https://www.impan.pl/en/publishing-house/journals-and-series/studia-mathematica/all/279/1/115674/on-mathbb-f-2-omega-affine-exchangeable-probability-measures). Prime-zeta Möbius inversion and local singularities are classical. The conditional germ rank-one and p-adic tests are direct corollaries of the **original NIGHTFALL manuscript's local formula**, not a worldwide novelty claim.
- Most important external criticism task: prove whether prop:local-continuation and prop:local-germ can hold at interesting sources, or exhibit a source where remaining terms invalidate local isolation. A second task is whether the abstract finite-probe theorem can be strengthened to a problem-specific nontrivial quantitative inequality beyond standard linear algebra. No publication or claim promotion without specialist review and dated priority clearance.

## VI. Discovery graph

**Prime-zeta** source map → same-layer dilation rigidity → finite active fiber → rank-one logarithmic mode → integer numerator A_lambda → modular noncancellation / monodromy + gap → **unconditional local first-strip cancellation decision** (conditional higher layers) → blockers: complete zero-fiber certificate, higher-layer analytic continuation and prior-art audit.

**Simon** input affine action → finitely many orbit types at fixed k → pure-degree invariant modes → random affine pullback probes → inverse-conditioned dual certificate → conditional Γ_k O(1/N) → blocker: independent all-k rank-filtration audit and useful growth of C_k.

**General transfer:** exact rigidity is only the first step; uniform certificates also require a finite-dimensional mode description and either arithmetic separation or stable probe conditioning. This is a reusable framework, *not yet a novel general mathematical law*.
