# COST V — Trine Extremality and the Visibility-Only Transfer Frontier

**NIGHTFALL / Wright · 12 November 2026 · source-integration research note**  
**Status:** exact proven-in-source special cases + independent exact trine saturation replay; the principal qubit extremality inequality is a **CONJECTURE**, not a theorem. This file neither supersedes the uploaded original nor claims external review, global priority or Lean certification.

## Source and mathematical contract

Canonical uploaded source: Devin J. Wright, *The Trine Extremality Conjecture: Sharp Visibility-Dependent Quantum Interaction Transfer for Qubit Registers*, version 1.0 (11 November 2026), SHA-256 `821e5f39a269c1b0d2da5f7a735b34732a2b3e5930b75b1a66f0859509588df0`. This is a six-page companion to *The Observability Principle*. Its source checker `check_trine_conjecture.py` was **not included in this upload**; this integration supplies a separate narrower exact checker. The uploaded PDF is the primary source of its conjecture, supporting lemmas and reported counterexample.

Dependencies already in the repository:

- `papers/quantum-operational-anova/OPERATIONAL_QUANTUM_ANOVA_v2.md`: exact scalar Personick gain `G(Q)=sum_{S subseteq Q, S != empty} gamma_S` for faithful product quantum averages. Analytic, not end-to-end Lean certified.
- `papers/quantum-sld-tensorization/THEOREM_AND_AUDIT.md`: optimal inverse-SLD tensor comparison based on local condition numbers; physical trine saturation for those specified condition numbers. Analytic + exact finite checks.
- `research/nightfall/2026-11-sld-transfer-sharpness/PROOF_PASSPORT.md`: no extra tensor loss for binary simple Hermitian contrasts; geometric-vs-SLD parameter warning.
- `papers/finite-product-influence/V8_PROOF_PASSPORT.md`: author-side analytic bias-free degree-two influence `max_i I_i >= V^2/(C_2 B^2)` with `C_2=(10+2 sqrt(2))^2 (1+sqrt(3))^2`. Not end-to-end Lean-certified.
- `COST IV` (conversation source): local replacement noise scales each interaction of order `s` by `t^(2s)`.

**Models:** independent finite classical inputs; **locally product-prepared** finite-dimensional quantum registers; faithful local average states; real scalar target; one-copy optimal collective POVM and squared-error Bayes gain. The universal product-average quantum ANOVA alone does not imply the visibility-only transfer inequality, especially for entangled conditional encodings.

## Representation and existing unconditional comparison

Let `V_i=L^2_0(mu_i;R)` be the local real centered contrast space, and for a centered local contrast `g` set

`T_i g = sum_x mu_i(x) g(x) rho_{i,x}`, `b_i=sum_x mu_i(x) rho_{i,x}`,

`J_b(H)=(bH+Hb)/2`, `K_i=T_i^* J_{b_i}^{-1} T_i`, `a_i=lambda_min(K_i)>0`.

For each pure Hoeffding support `S`, with signal `A_S=(tensor_{i in S} T_i) f_S`, put

`gamma_S = Tr(A_S J_{B_S}^{-1}(A_S))`, `B_S=tensor_{i in S} b_i`.

The repository's existing analytical SLD comparison proves

`gamma_S >= 2^(1-|S|) (prod_{i in S} a_i) ||f_S||_2^2`.

For binary source alphabets (or commuting encodings), the stronger `gamma_S >= (prod_i a_i) ||f_S||_2^2` is already available. The `2^(1-|S|)` loss is sharp for the **unconstrained superoperator comparison**, which does NOT prove sharpness when local visibility gaps `a_i` are fixed.

## Conjecture C5.1 — exact qubit visibility penalty (NOT PROVED)

When every quantum register in `S` has dimension 2, define

`u_i = sqrt(1 - 2 min(a_i,1/2))`,

`Phi_s(a_1,...,a_s)= 2(prod_{i in S}a_i) / [prod_i(1+u_i)+prod_i(1-u_i)]`, `s=|S|`.

The uploaded conjecture asserts, **for every pure real interaction**,

`gamma_S >= Phi_s(a_S) ||f_S||_2^2`.

It is supported by its exact simple-support cases, physical trine saturation, numerical attacks, and a *reported* qudit counterexample that prevents extending the formula dimension-independently. It is not implied by the sharp condition-number theorem, since local gap `a_i` does not bound `kappa(b_i)` as required. No general qubit proof or independent specialist review has been supplied.

For two sites the candidate constant simplifies to

`Phi_2(a,b) = ab/[1+sqrt((1-2 min(a,1/2))(1-2 min(b,1/2)))]`.

For a uniform visibility floor `0<a<=1/2`, `Phi_2(a,a)=a^2/[2(1-a)]`. This strengthens the currently proved universal `a^2/2` coefficient by the factor `1/(1-a)` (between 1 and 2), **only if** Conjecture C5.1 holds.

## Unconditional supporting mathematics, separately scoped

1. **Total qubit visibility bound (author-side proof in the uploaded note).** For any local qubit encoding, `Tr K_i <= 1`. Writing the average in its eigenbasis `b=diag(p,q)`, the note decomposes `K` into its diagonal and complex-off-diagonal contrast directions and uses `|rho_x(0,1)|^2 <= rho_x(0,0)rho_x(1,1)`. Consequently any local alphabet with `m >=3` positive-mass symbols has `a_i <= 1/(m-1) <=1/2`. Since a traceless Hermitian qubit operator space has dimension three, `a_i>0` on the full `m-1` dimensional contrast space also forces `m<=4`. These are elementary analytic consequences, not Lean certificates.
2. **Trine sharpness (author-side construction, independently replayed here).** Let `X_i` be independent uniform on `Z/3Z`, `p_i>=q_i>0`, `p_i+q_i=1`, and encode `x` as the pure qubit state with diagonals `(p_i,q_i)` and off-diagonal `sqrt(p_i q_i) omega^{-x}`, where `omega^3=1`, `omega!=1`. Then `K_i = 2p_iq_i I` on the two-dimensional centered contrast space. For `f(X)=Re(omega^(sum_i X_i))`, the interaction is pure order `s`, with `Var f=1/2` and

   `gamma_S = (prod_i p_i q_i)/(prod_i p_i + prod_i q_i)`,

   `gamma_S / Var f = Phi_s(2p_1q_1,...,2p_sq_s)`.

   This proves the **candidate value cannot be increased**, but does not prove no other qubit encoding falls below it. The provided independent `check_trine_exact.py` uses Q(omega) Fourier sums and exact fractions for s up to 4, including heterogeneous site parameters. It does not replay the source's unspecified optimization program.
3. **Known cases:** one-site, all-binary, and commuting encodings satisfy the conjectured inequality, by existing analytic comparisons. Noncommuting higher-alphabet joint qubit configurations remain the main open case.
4. **Dimension restriction:** the uploaded note reports a qutrit–qubit numerical violation with `c_S=0.0632115 < Phi_2=0.0643367` and says it was checked by two numerically independent SLD implementations. Only rounded inputs and no executable checker were uploaded. This integration therefore records it as **source-reported numerical evidence**, not an independent exact counterexample certificate.

## Proposition C5.2 — conditional noise-robust quadratic visibility

Assume Conjecture C5.1. Let `f` be a real bounded `|f|<=B` degree-2 Hoeffding target, with `V=Var f>0`, all retained local registers qubits, and all nontrivial contrast gaps `a_i>=a` for `0<a<=1/2`. Suppose the source-side Wright quadratic influence inequality with constant `C_2` holds. Subject each locally encoded register to replacement noise

`rho_{i,x}(t) = t rho_{i,x} + (1-t) b_i`, `0<=t<=1`,

and write `Delta_i(t)=G_t([n])-G_t([n]\{i})` for terminal Bayesian gain. Then the **conditional** result is

`max_i Delta_i(t) >= [t^4 a^2/(2(1-a) C_2 B^2)] V^2`.

If every nontrivial source coordinate is binary, the already established simple-tensor route gives the **unconditional relative to source influence** stronger coefficient `t^4 a^2/(C_2 B^2)` (and permits `a` up to 1).

**Proof of the conditional implication.** In the exact product-encoding ANOVA, write `gamma_i` and `gamma_ij` for singleton and pair components. Under local replacement noise, `Delta_i(t)=t^2 gamma_i+t^4 sum_{j!=i} gamma_ij >= t^4 Delta_i(1)`. The conjecture at degrees 1 and 2 and monotonicity of `Phi_2` in its gap arguments give `Delta_i(1)>=Phi_2(a,a) I_i(f)` (the singleton coefficient `a_i` is no smaller than `Phi_2(a,a)`). Apply the author's quadratic influence inequality `max_i I_i>=V^2/(C_2B^2)`. QED as an implication **of two separately unrefereed analytic claims, one of which is still conjectural**.

The `t^4` exponent is exact for a pure quadratic support. Importantly, using the original visibility penalty and the positive COST spectrum gives a stronger lower bound than merely reapplying the conjecture to the noisy gaps `a_i(t)=t^2a_i`, because `Phi_2(t^2a,t^2a) <= t^4 Phi_2(a,a)` for `0<=t<=1`.

## Recoverability and computational complexity

COST III's positive-hypergraph physical realization and NP-complete degree-2 register-selection problem concern **fixed-subset optimization** and are not altered by the conjecture. If true, the conjecture improves the *quantitative transfer rate* for nonbinary qubit sensors; it does not by itself make optimal subset selection polynomial-time, produce a polynomial-time quantum decoding algorithm, or prove a quantum adaptive query bound. No equivalence between general product-average ensembles and independent locally encoded classical sources is asserted.

## Priority and certification gates

- Verify the complete qubit conjecture starting with two ternary qubit encodings and an extremal contrast eigenvector, preferably via exact semialgebraic elimination or interval-certified optimization. Fail fast if a rigorous counterexample exists.
- Obtain the exact original qutrit–qubit parameters and source `check_trine_conjecture.py`; reproduce the claimed violation independently with interval arithmetic. Rounded PDF parameters alone are not a certificate.
- Formalize `Tr K<=1`, the exact trine Fourier support cancellation, `gamma=Phi Var`, and the noise scaling in pinned Lean. These do **not** certify Conjecture C5.1.
- Obtain a non-author review of the original quantum-ANOVA and source quadratic influence proofs and a dated prior-art comparison. Credit Personick, Tsang, Petz and the classical product-ANOVA background.

**Current status:** Source-conjecture incorporated into COST as an explicit, conditional upgrade path. No theorem promotion, submission, merge into main, or broader novelty claim follows from this integration alone.