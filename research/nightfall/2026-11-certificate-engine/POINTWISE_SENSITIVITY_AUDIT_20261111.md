# Pointwise total sensitivity and squared-variance influence: exact checkpoint

**NIGHTFALL Constellation / 11 November 2026**  
**Research lead:** Devin J. Wright  
**Stage:** rigorous elementary restricted-class deductions + independently rerun exact finite falsification; **unrestricted sharp inequality OPEN**. No external referee, Lean proof, or novelty clearance. This is distinct from the [quartic antipodal AQ(C) program](QUARTIC_ANTIPODAL_AUDIT_20261110.md).

## Objective, definitions, and normalization

For a real function `f: {-1,1}^n -> R` on the **uniform** Boolean cube, write `x^i` for its i-th bit flip and put

    V = Var(f),  I_i = (1/4) E[(f(X)-f(X^i))^2],
    M = max_i I_i,  R = max_x sum_i |f(x)-f(x^i)|.

The sharp proposed **pointwise-sensitivity inequality (PSI)** is

    V^2 <= (R^2/4) M.                                           (PSI)

The constant `1/4` cannot be reduced: every nonconstant dictator `f(x)=a+b*x_i` has `R=2|b|`, `V=M=b^2`, with equality. This candidate is **not proved** in general. It is not an instance of the quartic antipodal inequality and does not inherit its validity from the antipodal certificate engine. The finite enumerations below test only exactly specified subfamilies.

## Verified elementary theorem: a degree-dependent squared-variance inequality

Let `d >= 1` and suppose the Fourier-Walsh degree of `f` is at most `d`. Then

    M >= 4 V^2 / (9^(d-1) R^2).                                (1)

Proof: define `D_i f=(f(x)-f(x^i))/2`, so `||D_i f||_2=sqrt(I_i)` and `D_i f` has degree at most `d-1`. Bonami--Beckner hypercontractivity gives

    ||D_i f||_4 <= 3^((d-1)/2) ||D_i f||_2.

Interpolation `||h||_2 <= ||h||_1^(1/3) ||h||_4^(2/3)` yields `||D_i f||_1 >= 3^(-(d-1)) sqrt(I_i)`. Therefore

    R/2 >= sum_i E|D_i f|
        >= 3^(-(d-1)) sum_i sqrt(I_i)
        >= 3^(-(d-1)) (sum_i I_i)/sqrt(M)
        >= 3^(-(d-1)) V/sqrt(M),

where the last step is the Fourier/Efron--Stein inequality `sum_i I_i >= V`. Rearrangement gives (1). Constants have `V=0` and are trivial; nonconstants have `M,R>0`.

At `d=2`, `D_i f` is an affine Rademacher sum. The sharp real Khintchine bound `||D_i f||_1 >= ||D_i f||_2/sqrt(2)` (including constant term by adjoining a Rademacher sign) improves (1) to

    M >= 2 V^2 / R^2.                                         (2)

At `d=1`, (1) agrees with the dictator-optimal constant `M >= 4 V^2/R^2`. None of these elementary deductions establishes (PSI) for arbitrary degree. Combining (1) with the **pre-existing** FHKL pointwise estimate `sum_i |f(x)-f(x^i)|/2 <= d^2` for bounded `|f|<=1` (as recalled in Turturean, Sec. 9.4) gives only

    M >= V^2 / (9^(d-1) d^4),

which has exponential dependence on degree. It is **not** the target uniform `(2,4)` bound.

## Verified special case: additive functions on arbitrary finite products

For `f(x)=c+sum_i h_i(x_i)` on independent finite alphabets, define the general-product pointwise sensitivity by

    R_prod(f) = sup_x sum_i sup_{z_i} |f(x)-f(x_{-i},z_i)|.

Set `v_i=Var(h_i(X_i))`, `r_i=max h_i - min h_i`, and `M=max_i v_i`. Then `R_prod(f)=sum_i r_i` and Popoviciu's bound gives `sqrt(v_i)<=r_i/2`. Thus

    Var(f) = sum_i v_i <= sqrt(M) sum_i sqrt(v_i)
           <= (R_prod(f)/2) sqrt(M),

which proves `Var(f)^2 <= R_prod(f)^2 M/4`. This is a **restricted-class theorem**, not the conjecture on arbitrary product functions.

## Structural obstruction: immediate differences are not certificate rows

Local gradients need not certify distant input changes: for AND on two bits at `00`, both one-bit increments vanish, but the value changes at `11`. Therefore neither the original fractional-certificate inequalities nor their localized weight removal can be invoked with `a_i(x)=|f(x)-f(x^i)|` as though this were a globally valid row.

There is an unbounded complexity separation. For each positive integer `m`, partition `2m^2` bits into `m` blocks, each with `m` disjoint bit pairs. Let `g_m(x)=1` iff some block has **exactly one pair `11` and every other bit of that block is zero**. Then:

    R(g_m) = 2m,     max_x (minimum fractional-certificate cost at x) >= m^2.

Proof of the lower bound: at the all-zero input, turning on either of the `m^2` disjoint pairs changes `g_m` from 0 to 1. Each valid fractional row therefore has total weight at least 1 on each pair, giving total cost >=`m^2`. For sensitivity, if exactly one block accepts, changing any of its `2m` bits destroys its acceptance; flips outside cannot destroy acceptance. If >=2 blocks accept, one flip cannot change the output. At a rejecting input, one flip can create acceptance in at most one way per block because the accepting patterns within a block are mutually Hamming distance 4 apart. Hence the maximum number of output-changing one-bit flips is exactly `2m`. The cost/sensitivity ratio is at least `m/2`, unbounded.

This is an obstruction to a **proof substitution**, not a counterexample to (PSI). The paired-block construction is in the classical sensitivity-versus-block-sensitivity tradition; global originality is not claimed.

## Exact checker and integer inequality

File: [`checks/check_pointwise_sensitivity_exact.cpp`](checks/check_pointwise_sensitivity_exact.cpp). Requirements: C++17, GNU/Clang compiler with `__builtin_popcountll`, no network or third-party libraries.

    g++ -O3 -std=c++17 -Wall -Wextra -pedantic \
      research/nightfall/2026-11-certificate-engine/checks/check_pointwise_sensitivity_exact.cpp -o /tmp/check_psi
    /tmp/check_psi

For an `N=2^n`-entry truth table with integer outputs, put `A=N*sum_x f(x)^2-(sum_x f(x))^2` and `H=max_i sum_x (f(x)-f(x^i))^2`. The checker tests the **integer-exact**, denominator-free equivalence

    16*A^2 <= R^2*N^3*H.

Results independently rerun from the available source on 2026-11-11:

| Exact function family | Nonconstant functions | Violations | Equality cases |
| --- | ---: | ---: | ---: |
| All Boolean-valued functions of 4 bits | 65,534 | 0 | 8 |
| All values in `{0,1,2}` on 3 bits | 6,558 | 0 | 30 |
| All monotone Boolean functions of 6 bits | 7,828,352 | 0 | 6 |

The six-bit monotone count includes all `7,828,354` Dedekind-number cases and omits two constants when evaluating (PSI). The optimized bit-parallel oracle was independently cross-checked against explicit vertex-by-vertex differences on 1,000 fixed-seed random six-bit truth tables. A dictator serves as an exact equality and stricter-constant negative control. The family `g_m` sensitivity was verified by full vertex enumeration for `m=1,2,3` (2, 8, 18 inputs). All computations use unsigned 64-bit integer inequalities for these bounded test sizes.

**Falsification limitation:** bounded-size exhaustive testing does not establish an all-dimension theorem. The 6-bit monotone family does not exhaust all 6-bit Boolean functions.

## Research contract and audit gate

- **Strongest external reference checked this session:** D. Turturean, *A proof of the Aaronson--Ambainis conjecture* (2026), https://arxiv.org/abs/2611.09773 (Sec. 9.4 pointwise row bound); Y. Filmus, H. Hatami, N. Keller, N. Lifshitz, *On the sum of the L1 influences of bounded functions*, Israel J. Math. 214 (2016), https://arxiv.org/abs/1404.3396. Related public exposition: Blanc et al. https://arxiv.org/abs/2611.11626. No exhaustive novelty review performed.
- **Verified construction:** the paired-block family, the additive-product bound, hypercontractive degree-dependent bound, and exact finite screens above. **Unproved:** unrestricted PSI, arbitrary-product nonlinear generalization, exponent-two with a degree-independent constant, novelty and external correctness review.
- **Cheapest decisive proof attack:** use exact nonlinear functions and adversarial graph/Fourier parameter optimization; test the extremal constant `1/4`, especially nonmonotone 5--8 variable functions with sparse switching sets, then rationalize and replay counterexamples independently. A positive result should pursue a functional proof that does not assume local differences form valid certificate rows.
- **Stop rule:** do not promote a universal theorem from finite cases; pursue independent proof review and an exact/interval checker for any claimed universal step. Distinguish validity from originality and publication readiness.
- **Transfer boundary:** `R_prod` varies with the coordinate replacement model; for general nonlinear products and zero-mass symbols the claimed PSI analogue has not been established.

**Attribution:** NIGHTFALL / Devin J. Wright; Bonami--Beckner, Khintchine, Popoviciu, FHKL and Turturean are imported standard or published inputs. This checkpoint contains a new **within-program formulation and falsification corpus**, not a priority-certified universal discovery.
