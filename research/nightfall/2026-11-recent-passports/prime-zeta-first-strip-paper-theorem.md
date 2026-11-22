# First-strip prime-zeta removability — paper theorem

**NIGHTFALL Proof Passport — 2026-11-22. Tier: `analytic`; paper theorem / independent certification open.**

## Claim and quantifiers

For every nontrivial zero ρ of ζ and integer n≥1, put λ=ρ/n, s₀=λ−1 (thus −1<Re(s₀)<0 and Im(s₀)≠0). Define F_λ={m≥1: μ(m)≠0 and ζ(mλ)=0}, r_m=ord_{mλ}ζ, and M(λ)=Σ_{m∈F_λ} μ(m)r_m/m. For A⁺(s)=Σ_p((p−1)^(−s)−p^(−s)) initially defined Re(s)>0, there is a local branch
`A⁺(s)=s M(λ) log(s−s₀)+holomorphic`.
Consequently A⁺ continues holomorphically through s₀ **iff** M(λ)=0.

## Mechanism and proof

The classical logarithmic derivative `P'(w)=Σ_m μ(m)ζ'(mw)/ζ(mw)` has a locally normally convergent tail for Re(w)>0 and a *meromorphic*, branch-free continuation there. At nonreal λ, its residue is M(λ), since each zero channel contributes μ(m)r_m/m. Its local primitive is M(λ)log(w−λ)+holomorphic. The September manuscript's proved first-layer identity `A⁺(s)=sP(s+1)+H(s)`, H holomorphic Re(s)>−1, gives the claim; s₀≠0 eliminates prefactor cancellation.

## Exact certificate and numerical limits

Let D=lcm(F_λ) and integer A=Σ_m μ(m)(D/m)r_m. Given a *complete certified fiber*, removability is equivalent to A=0. When A≠0, |s₀M|≥|s₀|/D. Existing checker tests 1,700 **synthetic** fibers and exact modular arithmetic; it proves no actual zeta-zero fiber completeness.

## Sources and provenance

- First paper proof: [merged PR #1035](https://github.com/d3lefts/d3lefts/pull/1035), merge `e71ed7d14e4bdd9b11b5c1dc71c801794d08a8ef`.
- Promoted proof: [PRIME_ZETA_FIRST_STRIP_BOUNDARY_PAPER_THEOREMS_20261122.md](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/structural_information/PRIME_ZETA_FIRST_STRIP_BOUNDARY_PAPER_THEOREMS_20261122.md).
- Original: corrected September 2026 *Affine Source Rigidity and Möbius Cancellation in a Shifted Prime-Zeta Deformation* manuscript.
- Imported predecessor: C.-E. Fröberg, *On the prime zeta function*, BIT 8 (1968), 187–202, DOI 10.1007/BF01933420; classical zeta meromorphy.
- Exact arithmetic replay: [run 45053539129](https://github.com/d3lefts/d3lefts/actions/runs/45053539129) (finite synthetic only).

## Status and audit gates

**Paper theorem derived from classical analytic results; not an independently reviewed theorem under the NIGHTFALL certification ladder.** No named Lean analytic proof, no independently signed non-author review, no exhaustive novelty clearance, and no external submission authorization.

**Independent challenge:** [issue #1040](https://github.com/d3lefts/d3lefts/issues/1040). Required: independently reconstruct normal convergence, all zero/pole residue channels, local primitive/branch scope, and complete source-fiber arithmetic; search Fröberg's primary text for a verbatim theorem.

## Scope limits

No use of RH; no claim of constructing nontrivial rational-dilation zero collisions. This does not establish analytic continuation through the natural boundary at Re(s)=−1, nor classify k≥2 formal sources as reachable analytic germs.


## 22 November 2026 direct prior-art correction

MathWorld, *Prime Zeta Function*, equations (10)–(11) and the following discussion, already explicitly treats the single-valued meromorphic P', its scaled-zeta-zero residues, addition of coincident residues, and removability when the total residue is zero: https://mathworld.wolfram.com/PrimeZetaFunction.html . The NIGHTFALL statement is therefore a **direct corollary for the shifted deformation**, not an original discovery of residue-cancellation theory. This is a positive correctness reference and a negative originality control; the exact shifted corollary's publication priority is not exhaustively settled.

## Exact public-ledger identity (v1, 2026-11-22)

**Claim:** For every λ=ρ/n from a nontrivial ζ zero, A⁺ has local germ s M(λ) log(s−(λ−1))+holomorphic; complete local removability is equivalent to the finite Möbius residue M(λ)=0.

**Limit:** Not an independently certified or first-priority result. Does not prove an actual multi-member zero fiber, global all-layer continuation, or RH. Dated specialist prior-art audit open. The P' residue-cancellation mechanism is already public classical prior art, not original NIGHTFALL mathematics.

**Source:** https://github.com/d3lefts/d3lefts/pull/1043
