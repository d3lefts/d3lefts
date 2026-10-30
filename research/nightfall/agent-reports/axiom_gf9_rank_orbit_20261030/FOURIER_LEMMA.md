# Analytic Fourier certificate for the GF9 seven-sign phase bottleneck

**Axiom / 30 October 2026. Status R1: internal theorem derivation, exact independently implemented regression; global originality and non-author human review unverified.** This replaces the prior reliance on a 38-case search to prove the universal seven-sign lower bound. The search remains as a separately implemented falsifier.

## The exact seven-signed-sum lemma

Let V=F3² (the additive group of GF9), let c1,...,c7∈V be **any** seven coefficients, allowing repeats and zeros, and consider the 64 global-sign equivalence classes of epsilon∈{±1}⁷ (epsilon and −epsilon identified). The observation is the **powered-value class**

    z(epsilon) = (sum_i epsilon_i c_i)^2 ∈ GF9.

Because the kernel of squaring on GF9* is precisely {±1}, this observation takes exactly five *possible labels*: the zero sum and the four nonzero antipodal lines of V.

**Theorem.** Every choice of coefficients sends at least **14 distinct input sign classes** to the same powered output. The constant 14 is sharp. For a coefficient multiset comprising one zero and two copies each of three distinct nonzero projective directions, the five output-fiber sizes are 10,14,14,14,12.

This is a finite, exact statement over **all** seven coefficients, not a sampling result and not an unrelated modified oracle.

## Character-transform calculation (exact algebra, no analytic approximations)

Let p(z)=#{epsilon∈{±1}⁷ : sum epsilon_i c_i=z}, counting all 128 raw sign words. For an additive character χ_u(z)=ω^(u·z), where ω is a formal primitive third root of unity satisfying 1+ω+ω²=0, its Fourier transform is

    phat(u)=product_i (χ_u(c_i)+χ_u(−c_i)).

Each factor is 2 if u·c_i=0, and −1 if u·c_i∈{1,2}; there are no other values.

Let n0 be the multiplicity of zero coefficients. In the four projective lines of nonzero **Fourier characters**, let n_j count the coefficients c_i lying in the one-dimensional subspace perpendicular to line j. This is a permutation of the four projective coefficient-direction occupancies, so n0+sum(n_j)=7. Define the exact signed powers of two

    λ_j = (−1)^(7−n0−n_j) * 2^(n0+n_j), j=1,2,3,4.

For both nonzero characters u in line j we have phat(u)=λ_j. The zero character has phat(0)=2^7=128.

Finite Fourier inversion on V (order 9), using χ_u(z)+χ_{−u}(z)=2 when u·z=0 and −1 otherwise, gives

    p(0) = [128 + 2 (λ1+λ2+λ3+λ4)] / 9.

For each of the four nonzero output antipodal classes ±z, exactly one nonzero character direction annihilates z. Index it j. Then

    p(z) = [128 − (λ1+λ2+λ3+λ4) + 3 λ_j] / 9.

The raw count p(z) equals p(−z). A nonzero output class contains p(z)+p(−z) raw sign words, hence **p(z) global sign classes**. The zero output contains p(0) raw sign words, hence **p(0)/2 global sign classes**. Therefore the exact five output bucket sizes are

    b0 = (128 + 2Σ_j λ_j) /18,
    bj = (128 − Σ_i λ_i + 3 λ_j)/9, j=1,...,4,

and b0+Σbj=64. Crucially, each λ_j is a **signed integer power of two**, independent of normalization choices and of how the seven coefficients were selected.

### Analytic impossibility of maximum bucket ≤13

Suppose all five integer bucket sizes were ≤13. Since their total is 64 and 5·13=65, their multiset must be EXACTLY

    {13,13,13,13,12}.

Case 1: b0=13. The first inversion formula forces Σλ=53. At least three other buckets equal 13, and for any such j the second formula forces

    13·9 = 128 − 53 + 3 λ_j  ⇒ λ_j=14.

This is impossible because 14 is not a signed power of two.

Case 2: b0=12. The first inversion formula forces Σλ=44. All four nonzero buckets must equal 13, so for every j,

    13·9 = 128 − 44 + 3 λ_j ⇒ λ_j=11.

This too is impossible because 11 is not a signed power of two.

The only two possibilities are contradicted. Therefore the largest fiber has size **at least 14** for every coefficient vector.

Sharpness: choose the multiplicity profile n0=1 and (n1,n2,n3,n4)=(2,2,2,0), giving λ=(8,8,8,2), Σλ=26, and

    (b0,b1,b2,b3,b4)=(10,14,14,14,12).

Hence min over all c∈GF9⁷ of the maximum squared-output sign-fiber size is **exactly 14**. QED (subject to non-author mathematical audit).

**Key advance relative to our own 38-type exhaustive proof:** the lower bound is now analytically established by Fourier eigenvalues and two elementary impossible equalities. The verifier no longer constitutes the sole support for the universal finite classification. This representation is reusable for longer signed sums and for other finite additive groups whenever the field-power quotient identifies an orbit structure.

## Consequence for the adaptive GF9 dimension-eight problem

The adaptive rank-phase adversary (in THEOREM.md) leaves, after eight legal queries, >125 global sign-orbits except the sole rank schedule of seven independent nonzero queried forms followed by a dependent eighth. In that exceptional case, seven basis outputs each with two roots ±1 produce **64 relative sign words**, and a dependent eighth row acts exactly as the seven-coefficient map above. Its output has a fiber of at least 14 sign words. Rank remains 7, so each phase word lifts to exactly 9^(8−7)=9 inequivalent original vectors, giving at least 126 orbits. Three remaining queries offer only 5³=125 possible transcripts. Thus eleven total adaptive squared-linear measurements cannot recover all GF9^8 signals modulo global sign.

Combining this lower bound with the legal 12-query upper decoder from Vesper PR #256 (under its separate validity gate) yields the exact **candidate** adaptive count A_GF9(8)=12. No conclusion about all dimensions or worldwide novelty is implied.

## Reproducibility and adversarial checks

- [fourier_obstruction.py](fourier_obstruction.py): independently computes the exact character eigenvalues and five buckets using **integer arithmetic alone**; checks the two forbidden λ cases; compares to the former 38 canonical profiles and explicit sharp construction.
- [independent_seven_phase.py](independent_seven_phase.py): unrelated representation GF3[v]/(v²+v+2), enumerates every 5⁷=78,125 coefficient line-type word and its 128 signed sums, obtaining min-max 14 and exactly 2,520 coefficient line-type attainers.
- [check_seven_phase.py](check_seven_phase.py): independently checks every one of the 128 adaptive rank schedules before invoking the 38-profile regression.
- Falsifier: a coefficient c with all five buckets at most 13, invalid Fourier inversion denominator, a fifth/sixth missing powered-output class, or a legal adaptive path that violates the palette-lift invariant. If found, retract immediately.

## Intellectual provenance and novelty limit

The finite Fourier transform and factorization of a random signed-sum character transform are **classical** additive-combinatorics tools, closely related to the Littlewood–Offord program (e.g. Tao–Vu, *Additive Combinatorics*, 2006, Chapter 7, DOI 10.1017/CBO9780511755149.008). No priority is claimed for Fourier inversion, character orthogonality, random-sign sums or powers-of-two eigenvalues as separate inventions. The research question is whether their **specific role in an adaptive finite-field phase-orbit lower bound for k=8** is historically original. See [PRIOR_ART_20261030.md](PRIOR_ART_20261030.md). Vesper/owner and a non-AI specialist review the composite claim before any manuscript/publication status change.

**Mechanism:** relative sign ambiguity → signed sum as additive convolution → Fourier eigenvalues are signed powers of 2 → forbidden balanced five-way phase partition → minimum phase fiber 14 → adaptive rank obstruction 126>125. This is a structural proof rather than merely recognizing 38 finite cases.
