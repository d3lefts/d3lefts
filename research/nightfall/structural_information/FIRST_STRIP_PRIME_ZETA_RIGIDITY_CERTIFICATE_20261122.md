# FIRST-STRIP PRIME-ZETA RIGIDITY CERTIFICATE — unconditional local theorem

**Date:** 2026-11-22. **Status:** new *paper-level proof from classical prime-zeta continuation and the September manuscript's proved first-layer localization*. It is an unconditional-in-RH local mathematical argument, **not** externally refereed, Lean-kernel-certified or globally priority-cleared. This theorem **supersedes** the unnecessary conditional local-branch requirement *only for k=1*. For k>=2 the original conditional scope remains.

Source manuscript: *Affine Source Rigidity and Möbius Cancellation in a Shifted Prime-Zeta Deformation* (September 2026 corrected v-final), Theorem "First-layer localization", Proposition "Conditional Local Germ Decomposition", Theorem "First logarithmic coefficient". The general synthesis is in RIGIDITY_TO_CERTIFICATE_PRINCIPLE_20261122.md.

## Theorem: exact removability criterion throughout the first strip

Let P(w)=Σ_p p^{-w} for Re w>1 be the classical prime zeta function and

  A_plus(s) = Σ_p[(p−1)^(−s)−p^(−s)],    Re s>0.

Let λ=ρ/n, where ρ is any nontrivial zeta zero and n>=1, so 0<Re λ<1 and Im λ!=0. Let s0=λ−1. Define the finite active fiber

  F_λ={m>=1: ζ(mλ)=0 and μ(m)!=0},
  r_m=ord_{mλ} ζ,     M(λ)=Σ_{m∈F_λ} μ(m) r_m/m.

**Claim (unconditional first-strip local classification):** The original A_plus admits a local multivalued analytic continuation on a punctured disk about s0 and its local singular component is

  A_plus(s)=s M(λ) log(s−s0)+h(s),     h holomorphic through s0.

Therefore A_plus extends holomorphically through s0 **if and only if** M(λ)=0, and has nontrivial logarithmic monodromy if and only if M(λ)!=0. More precisely

  Δ_loop A_plus(s)=2πi s M(λ).

All quantified statements are local to the first strip −1<Re s<0 and involve no unproved RH premise, no assumption that a nontrivial multi-member dilation fiber exists, and no assertion of a globally single-valued continuation.

### Proof 1: the prime-zeta derivative has a meromorphic continuation

For Re w>1 the standard Möbius inversion formula reads

  P(w)=Σ_{m>=1} [μ(m)/m] log ζ(mw).

Differentiation in its absolutely convergent domain gives

  P'(w)=Σ_{m>=1} μ(m) ζ'(mw)/ζ(mw).            (1)

Fix any compact K in Re w>0 and let a=min_{w∈K}Re w>0. For m sufficiently large, Re(mw)>=ma>=2. The Dirichlet series

  −ζ'(z)/ζ(z)=Σ_{j>=2} Λ(j) j^(−z)

converges absolutely and bounds |ζ'(mw)/ζ(mw)| by O_K(2^(−ma)). Thus the tail of (1) converges absolutely and normally on K. Each of the finitely many lower-m terms is meromorphic (ζ'/ζ is meromorphic; w↦mw is entire). Consequently (1) defines a **single-valued meromorphic function on Re w>0**, agreeing with the derivative of P on Re w>1.

At nonreal λ with Re λ>0, the only possible poles of summands arise where mλ is a nontrivial zeta zero. (The zeta pole at 1 is real; trivial zeros are on the negative real axis.) Such m satisfy m Reλ<1, so only finitely many occur. At each such m,

  ζ'(mw)/ζ(mw)= r_m/[m(w−λ)] + holomorphic.

Multiplication by μ(m) and summation gives

  P'(w)= M(λ)/(w−λ) + G(w),   G holomorphic at λ.       (2)

This is the **complete** principal part: logarithmic derivatives have only simple poles, and all other terms are normally convergent and holomorphic.

A local primitive of (2) obtained by analytic continuation from Re w>1 is

  P(w)=M(λ) log(w−λ)+g(w),  g holomorphic at λ.        (3)

If M(λ)=0 the derivative is holomorphic at λ and its local primitive extends through λ; if M(λ)!=0 the small-loop integral is 2πi M(λ), proving a genuine logarithmic branch obstruction. The branch choice changes g by a constant only.

### Proof 2: the shifted deformation has a holomorphic higher-layer remainder

The September manuscript already proves, using absolute convergence of the shifted prime-zeta layers,

  A_plus(s)=s P(s+1)+H(s),   H holomorphic on Re s>−1. (4)

Since Re(s0)>−1, (4) defines a local continuation of A_plus near s0 by combining the local branch of P(s+1) from (3) with a single-valued holomorphic H. Substitute w=s+1 and λ=s0+1:

  A_plus(s)=s M(λ) log(s−s0)+[s g(s+1)+H(s)].

The bracket is holomorphic through s0. Moreover s0=λ−1!=0 since Im λ!=0 and Re λ<1. Hence the monodromy is nonzero precisely when M(λ)!=0, establishing the iff theorem.

**Critical boundary:** For a source s0=λ−k with k>=2, the first-layer term P(s+1) is evaluated at Re(s0+1)=Re λ−k+1<=0, beyond this meromorphic-derivative argument. One cannot recycle the unconditional k=1 proof for other layers without new analytic continuation machinery. This is why the global all-layer cancellation problem remains open.

## Exact arithmetic, quantitative gap and modular filter

Let D=lcm{m∈F_λ} (D=1 if F_λ empty) and

  A_λ= Σ_{m∈F_λ} μ(m)(D/m)r_m ∈ Z,     M(λ)=A_λ/D.

Then the full first-strip local continuation is holomorphic through s0 exactly when A_λ=0. If nonzero, its logarithmic coefficient satisfies

  |s0 M(λ)|>= |s0|/D >= (1−Re λ)/D.

If λ=ρ/n for some n>=2, then Re λ<1/2 and therefore

  |s0 M(λ)| > 1/(2D).

If a prime p divides exactly one active denominator m0 and p does not divide r_m0, then A_λ is nonzero modulo p, so the source is a **certified nonremovable first-strip logarithmic singularity** after the fiber's completeness is supplied. The exact sum or the p-adic residue are finite arithmetic certificates; they require an actual *certified complete zero fiber*, not a numerical near-match.

At a basepoint s sufficiently close to s0, Δ_loop A_plus(s)=2πi s A_λ/D. Given a measurement of this complex loop difference with absolute error η, nearest-integer recovery of A_λ is certain if

  η < π|s|/D.

This is an exact one-loop quantization threshold, conditional only on the measurement and complete active fiber, **not** on any global formula for A_plus beyond the first strip.

## Why this is a substantive repair, not an RH theorem

The original paper separately proves first-layer localization and states a conditional local germ formula, but leaves complete cancellation open. Combining first-layer localization with the **classical meromorphic prime-zeta derivative** removes the need for the manuscript's general local-normal-convergence assumption in precisely the first strip. It replaces a "leading coefficient only" claim with a genuine complete local classification for the first layer, including cases with several hypothetical active channels.

**The derivative and Möbius inversion are classical**, going back to Fröberg's study of the prime zeta function, and are described in standard references:
- Prime Zeta Function, Wolfram MathWorld: https://mathworld.wolfram.com/PrimeZetaFunction.html
- R. P. Brent, *Primes, the Riemann zeta-function, and sums over zeros*, 2021 lecture notes: https://maths-people.anu.edu.au/~brent/pd/Brent-CARMA21.pdf
- mpmath prime-zeta documentation: https://mpmath.org/doc/current/functions/zeta.html

A specialist prior-art audit is required to establish whether this specific first-strip corollary for A_plus appeared before September/November 2026. It is **not** currently advertised as a novel world-first theorem.

## Independent proof-attack checklist

1. Verify normal convergence of the logarithmic-derivative series uniformly on arbitrary compact K⊂{Re w>0} away from finitely many poles; explicitly handle zeros, zeta's pole and branch independence.
2. Confirm each m-channel's residue is μ(m)r_m/m, not μ(m)r_m (the composition chain factor matters).
3. Verify (4) is a genuine locally normal holomorphic remainder for Re s>−1, including growth of the Pochhammer ratio.
4. Verify the exact s-dependent monodromy factor s and s0!=0.
5. Exhibit a purported actual first-strip singularity where the active Möbius coefficients cancel; if possible, this would refute a blanket "all candidate sources survive" assertion but **not** the iff theorem.
6. Audit Fröberg and later prime-zeta continuation literature for equivalent local cancellation/monodromy theorems. Credit published predecessors.
7. Attempt the k>=2 bridge only after finding a valid path across P's natural boundary; do not infer it by repeating the k=1 proof.

**Status:** self-contained author-side paper proof; arithmetic tests are synthetic; no actual nontrivial multi-member dilation fiber produced; no non-author proof review or Lean kernel certificate.


## Addendum: ordinary analytic continuation stops at Re(s)=-1

See SHIFTED_PRIME_ZETA_NATURAL_BOUNDARY_20261122.md for the paper-level proof using the classical prime-zeta natural boundary. The higher-layer caveat is stronger than a missing technical continuation estimate: for the original A_plus, the entire line Re(s)=-1 is a natural boundary. Therefore k>=2 candidate source germs are not accessible by ordinary analytic continuation from the defining domain. They remain formal algebraic source coordinates unless an explicitly different continuation/summation framework is introduced.
