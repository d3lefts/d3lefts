# Shifted prime-zeta natural boundary — paper theorem

**NIGHTFALL Proof Passport — 2026-11-22. Tier: `analytic`; paper theorem based on an established classical boundary.**

## Claim and quantifiers

For A⁺(s)=Σ_p[(p−1)^(−s)−p^(−s)] initially on Re(s)>0, the entire vertical line **Re(s)=−1 is a natural boundary for ordinary analytic continuation**. This imports as a classical theorem the natural boundary Re(w)=0 for the prime-zeta function P(w).

## Mechanism

The September manuscript establishes `A⁺(s)=sP(s+1)+H(s)`, `H(s)=Σ_{j≥2}(s)_j P(s+j)/j!`, H holomorphic Re(s)>−1. At each s*=−1+it, t≠0, split
`H(s)=s(s+1)P(s+2)/2+H₃(s)`.
Here H₃ extends holomorphically to Re(s)>−2, while P is locally holomorphic at w=1+it because ζ(1+it)≠0 (classical zero-free Re(w)=1) and every higher Möbius channel lies in Re(w)>1. Thus H has a holomorphic local continuation at s*. If A⁺ also extended across s*, then `P(s+1)=(A⁺−H)/s` would extend across it, contradicting P's classical natural boundary. Every neighborhood of the remaining point s=−1 includes nonreal boundary points, completing the theorem.

## Exact dependency certificate

- Classical natural boundary of prime zeta P at Re(w)=0: Landau–Walfisz (1920) and Fröberg (1968); see [MathWorld](https://mathworld.wolfram.com/PrimeZetaFunction.html) and *Pacific Journal of Mathematics* 273 (2015), "On a prime zeta function".
- ζ nonvanishing on Re(w)=1 except the pole at 1: Hadamard and de la Vallée Poussin; [NIST DLMF §25.10](https://dlmf.nist.gov/25.10).
- The 2026 September manuscript supplies the shifted expansion, cross-boundary H₃ tail obtained by the same local-uniform convergence estimate.
- Proof source: [PRIME_ZETA_FIRST_STRIP_BOUNDARY_PAPER_THEOREMS_20261122.md](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/structural_information/PRIME_ZETA_FIRST_STRIP_BOUNDARY_PAPER_THEOREMS_20261122.md).
- Earlier paper argument: [PR #1035](https://github.com/d3lefts/d3lefts/pull/1035), merged `e71ed7d14e4bdd9b11b5c1dc71c801794d08a8ef`.

## Falsifiability and limitations

A counterexample would consist of a point s* with Re(s*)=−1 where A⁺ has a holomorphic continuation from its original branch, or a failure of H to extend through a nonreal boundary point. **No numeric finite computation verifies a natural boundary**: the theorem stands on an imported, established *analytic* natural-boundary result. If the classical premise does not cover all branches, this downstream claim must be demoted.

No RH assumption. The claim applies to ordinary holomorphic analytic continuation, not resurgent/regularized methods. k≥2 algebraic source coordinates lie behind this barrier; the algebraic source-rigidity theorem is not invalidated.

## Certification and priority

**Promoted to scoped paper theorem only.** No named Lean kernel certificate, no independent specialist referee, and no global novelty clearance. The known boundary of P is classical, not original. The shift argument is a direct corollary whose first-priority remains unresolved. Review task: [issue #1040](https://github.com/d3lefts/d3lefts/issues/1040). Do not apply a "certified" or "novel" label from the paper proof or GitHub CI.


## 22 November 2026 direct prior-art correction

The natural boundary of P at Re(w)=0 is explicitly attributed to Landau–Walfisz (1920) and Fröberg (1968) in MathWorld: https://mathworld.wolfram.com/PrimeZetaFunction.html . The derived Re(s)=−1 theorem is **a shifted-boundary corollary**, not a new natural-boundary mechanism. This strengthens source attribution but does not constitute independent review of the A⁺ proof.

## Exact public-ledger identity (v1, 2026-11-22)

**Claim:** The original shifted prime-difference series A⁺(s)=Σ_p[(p−1)^(−s)−p^(−s)] has no ordinary analytic continuation across any point of Re(s)=−1.

**Limit:** The classical natural boundary is established prior art, not original. No global novelty clearance for this shifted corollary; formal k≥2 source coordinates behind the boundary are not ordinary reachable germs. The prime-zeta natural-boundary mechanism is directly classical; this is its shifted corollary, not a new boundary theorem mechanism.

**Source:** https://github.com/d3lefts/d3lefts/pull/1043
