# FMEI collision descent and optimal AA exponents — research checkpoint v1

**NIGHTFALL / Devin J. Wright · 2026-11-11 · status: exact finite falsification + standard reduction + analytic extremal family; open conjectures remain OPEN.**

This checkpoint records a concrete new *proof-strategy obstruction*, not a proof of FMEI, FEI, an optimal Aaronson–Ambainis inequality, or a novelty certificate. No source in this note upgrades the independent-review status of any pre-existing NIGHTFALL theorem.

## Objective, feasible set, and external baseline

**Objective A:** find a transferable fourth-order / two-draw route to Fourier Min-Entropy–Influence (FMEI) on all Boolean functions f:{-1,1}^n -> {-1,1} under uniform product measure.

**Objective B:** identify necessary exponents and tractable structural reductions for influence inequalities on bounded degree-d functions, keeping the unrestricted cubic exponent-two problem separate from existing restricted-class results.

**Strongest checked references this session:**
- Xiao Han, *A New Bound for the Fourier-Entropy-Influence Conjecture*, Combinatorica (2025): explicitly notes general FMEI bounds O(I log I) and O(I^2). https://doi.org/10.1007/s00493-024-00133-z
- Zhaole Li and Deng Tang, *A note on the FMEI of the Boolean functions in the Generalized Maiorana-McFarland construction*, Discrete Applied Mathematics 387 (July 15, 2026): FMEI ratio approaches 4 **from below**. https://doi.org/10.1016/j.dam.2026.02.052
- David Turturean, *A proof of the Aaronson–Ambainis conjecture*, Nov. 6, 2026: max-coordinate influence >= c Var(f)^(5/2) / d^6 for bounded polynomials on the uniform cube. https://arxiv.org/abs/2611.09773
- Thomas Huffstutler, David Miloschewsky and Supartha Podder, *A short proof ... via the completion framework*, Nov. 9, 2026: reports O(Q(f)^6/(epsilon delta)^2) classical query simulation in its partial-Boolean setting. Simulation-exponent comparisons must normalize definitions and success criteria. https://arxiv.org/abs/2611.12795

A complete global priority search was NOT performed. The reductions below may be known under other terminology, especially Gowers U2 and Fourier collision norms.

## A. Exact identity: FMEI as a Fourier collision lower bound

Let p_S = (Fourier coefficient of f at S)^2. Parseval for Boolean f gives sum_S p_S = 1. For independent samples S,T from p, set

    C(f) := Pr(S=T) = sum_S p_S^2 = sum_S \hat f(S)^4 = ||f||_{U^2}^4.

Define H_infty(f) = -log_2(max_S p_S) and H_2(f) = -log_2 C(f). Since

    (max p)^2 <= sum p_S^2 <= max p,

we have the exact inequalities

    H_infty(f) <= H_2(f) <= 2 H_infty(f).

Hence existence of a universal constant in FMEI,

    H_infty(f) <= C * I(f) for all Boolean f,

is equivalent, up to doubling constants, to existence of a universal C' such that

    C(f) >= 2^(-C' I(f)).

**Status:** elementary exact reduction, not an originality claim. The Boolean condition f^2=1 is essential; unrestricted spectral probability distributions do not obey an influence theorem. The two-draw appearance identifies a candidate mechanism, not a theorem transferring existing NIGHTFALL two-draw lemmas.

## B. Exact five-variable obstruction to a *local* entropy-descent lemma

Proposed local lemma to falsify:

    For every nonconstant Boolean f, there exists i such that
    D_i := H_2(f) - (H_2(f_{i=0}) + H_2(f_{i=1}))/2
         <= 4 * Inf_i(f).

Represent inputs x by integer masks 0..31, with bit i the i-th coordinate. Set f(x)=-1 precisely when bit x of integer hexadecimal 0x0ABB0203 is 1, and f(x)=+1 otherwise.

Direct exact enumeration gives, for *every* i=0..4,

    Inf_i(f) = 5/16,
    C(f) = 143/2048,
    {C(f_{i=0}), C(f_{i=1})} = {55/256, 5/32}.

Consequently,

    D_i = (1/2) log_2[(55/256)(5/32)/(143/2048)^2]
        = (1/2) log_2(12800/1859)
        = 1.3917725674276...

and

    D_i / Inf_i(f) = 4.453672215768... > 4.

**Fully exact strict comparison:** (12800/1859)^2 > 32. This is equivalent to D_i > 4*(5/16). No floating-point threshold is involved.

For each unordered pair {i,j}, define D_{ij} by restricting both coordinates and averaging conditional H_2 over all four assignments; compare it to the **raw initial** cost Inf_i+Inf_j = 5/8. The pairs split into two classes:

- (0,1), (0,3), (1,4), (2,3), (2,4): conditional collision multiset {1,11/32,11/32,11/32}; D_{ij}/(5/8) = 4.295523803520...
- (0,2), (0,4), (1,2), (1,3), (3,4): conditional collision multiset {11/32,1/4,1/4,1/4}; D_{ij}/(5/8) = 3.127978508609...

Thus a *particular* pair beats the constant-four threshold for this example. **This does not prove a universal small-block induction.** Initial raw influence sums are not interchangeable with posterior influence costs, and a valid amortized proof needs a telescoping invariant and a globally applicable block selector.

**Certificate:** check_fmei_collision.py computes the collision via (i) Walsh–Hadamard fourth powers and (ii) independent exact 3-fold enumeration of the U2 parallelogram identity, recomputes all restriction collisions, and certifies the strict inequality using fractions.

    python3 research/nightfall/2026-11-fmei-aa-frontiers/check_fmei_collision.py

Expected final line: LIMIT: finite counterexample to a local proof lemma, NOT FMEI.

**Novelty:** five-bit example is an internal exact witness; no claim it is globally original. This counterexample neither contradicts FMEI nor supplies evidence against a different universal collision constant.

## C. The AA variance and degree exponent stress tests

Uniform-cube influence normalization: Inf_i(f) = (1/4) E(f(X)-f(X with i flipped))^2.

**Variance exponent necessity.** For the bounded degree-one function f_m = (1/m) sum_{j=1}^m x_j, Var(f_m)=1/m and max_i Inf_i(f_m)=1/m^2 = Var(f_m)^2. Consequently any universal lower bound c Var(f)^a / d^b with constant c>0 and all bounded f requires a>=2.

**Degree exponent necessity at constant variance.** For odd d let n=d^2 and

    f_d(x) = T_d( (1/n) sum_{i=1}^n x_i ),

with T_d the Chebyshev polynomial. Then |f_d|<=1 and Fourier degree<=d. The central limit theorem, the identity T_d(t)= +/-sin(d arcsin t) for odd d, and bounded convergence after the CLT give

    Var(f_d) -> E sin^2(Z) = (1-exp(-2))/2,
    d^2 Inf_i(f_d) -> E cos^2(Z) = (1+exp(-2))/2,

where Z is standard Gaussian. The second limit follows by the finite difference of the two i-sections, of asymptotic size (2/d) cos Z, and boundedness/uniform-integrability control. All coordinates are exchangeable. Thus any universal bound of the displayed form requires b>=2, already at asymptotically constant variance.

These **separate** lower-bound examples motivate the ambitious target

    max_i Inf_i(f) >= c Var(f)^2/d^2,

but do not prove it, do not establish that (2,2) is jointly attainable, and do not exclude further extremal families forcing a larger degree exponent. The Chebyshev argument relies on known approximation/CLT tools and is not priority-cleared.

For numerical orientation, direct binomial averages produce:

| d | Var(f_d) | d^2 Inf_i(f_d) |
|---:|---:|---:|
| 3 | 0.4373486427 | 0.6194347068 |
| 9 | 0.4328683567 | 0.5702430222 |
| 31 | 0.4323791542 | 0.5678745522 |
| limit | 0.4323323584 | 0.5676676416 |

The asymptotic argument is mathematical; these decimal values are sanity checks, not certificates of the limits.

## D. Contact with the existing NIGHTFALL machinery

- [Cubic obstruction passport](../2026-11-active-passports/cubic-obstruction-ledger.md): unrestricted cubic exponent-two inequality remains OPEN; rare-gate fourth-moment counterexamples block naive bias-free L4/L2 transfer.
- [Cubic one-leaf operators](../2026-11-cubic-hidden-gems/PROOF_NOTE.md): optimized one-leaf extraction and bounded leaf-section subclasses, with imported quadratic matching hypotheses. There is no universal cubic theorem in this note.
- [Leaf-spectral reduction](../2026-11-leaf-spectral-transfer/LEAF_SPECTRAL_REDUCTION.md): conditional fixed-leaf-rank inequality and explicit counterexample to an overly broad Hilbert lift.
- [Universal spectral passport](../2026-11-active-passports/universal-spectral.md): status of the analytic product-space/Hilbert/adaptive transfer remains partial.
- [Backdoor transfer](../2026-11-quadratic-backdoor-transfer/QUADRATIC_BACKDOOR_TRANSFER_v1.md): restricted degree-three transfer cannot simply be asserted for unrestricted cubic interactions.

No transfer from the cubic two-draw machinery to FMEI has yet been proved. No formal Lean certificate for the FMEI experiment or the Chebyshev asymptotic was created.

## E. Discriminating next tests and stop rule

**FMEI:** Search for Boolean functions for which the minimum, over all one- and two-coordinate blocks, of D_A / sum_{i in A} Inf_i is large. Distinguish raw initial costs from expected posterior costs. Independent checker should use exact integer Walsh spectra and exact rational comparison by raising rational expressions to integer powers; decimal logs are display only. Pre-register the target C and the block size before running a search. If bounded-block descent fails repeatedly, switch operator family to a potential involving collision cross-terms or a state-dependent Fourier coupling. Never treat finite search as a proof.

**AA:** Attack the alphabet-free generalized quadratic-selector inequality identified by the one-leaf reduction; test against rare-address, Hadamard overlap, and arbitrary high-rank leaf sections. Independently search for bounded functions with degree-normalized max influence below the (2,2) target and include stronger contemporaneous simulation results in any downstream comparison. Do not spend further work merely polishing already-known degree-two constants if no new implication follows.

**Budget/stop rule:** First run the included exact 5-bit regression; next attempt exhaustive n<=4 block search with a separately written checker; then one bounded randomized n=5..8 attack. Stop and record a failed operator if a rigorous counterexample appears. No submission, theorem-status promotion, public novelty claim, or changes to frozen proof passports are authorized by this checkpoint.

**Audit boundary:** The checker certifies a finite obstruction, not the FMEI reduction for arbitrary n, not the global AA conjectural bound, and not external priority. Ask an independent reviewer to recompute the truth table, collision identities, asymptotic Chebyshev derivation, and distinction from pre-existing entropy-descent proofs.
