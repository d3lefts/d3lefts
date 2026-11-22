# Lean certification frontier: shifted prime-zeta first strip and natural boundary

**2026-11-22 — STATUS: exact kernel bridge work under CI; BOTH PAPER THEOREMS NOT END-TO-END LEAN CERTIFIED.** Research source [PR #1035](https://github.com/d3lefts/d3lefts/pull/1035); paper-level promotion [PR #1043](https://github.com/d3lefts/d3lefts/pull/1043); non-author analytic audit [issue #1040](https://github.com/d3lefts/d3lefts/issues/1040). This scope document accompanies formalization [PR #1049](https://github.com/d3lefts/d3lefts/pull/1049).

## Exact target claims

**First strip:** For every nontrivial ζ zero ρ and integer n≥1, λ=ρ/n, s0=λ−1. Let Fλ={m≥1: μ(m)≠0 and ζ(mλ)=0} and M(λ)=Σ_{m∈Fλ} μ(m) ord_{mλ}ζ /m. For A⁺(s)=Σ_p[(p−1)^(−s)−p^(−s)] initially on Re(s)>0, a local analytic continuation has s*M(λ)log(s−s0)+holomorphic and extends holomorphically iff M(λ)=0.

**Natural boundary:** For every s with Re(s)=−1, no branch of the original A⁺ analytically continues holomorphically through s. Deduce from the established classical no-branch natural boundary Re(w)=0 of prime zeta P and the analytic H remainder crossing all nonreal s.

Neither theorem is a direct statement about an *arbitrary* pair of functions P,H: it requires actual Dirichlet-series sources and the analytic facts below.

## What the Lean source verifies if a pinned exact-head run succeeds

1. `PrimeZetaAnalyticBridge.analyticAt_shifted_iff`: for any analytic H and s≠0, local analyticity of the literal shifted expression sP(s+1)+H(s) iff local analyticity of the selected P branch at s+1. This uses genuine `AnalyticAt ℂ`, with multiplication, translation and analytic composition.
2. `PrimeZetaAnalyticBridge.shifted_not_analytic_of_source_not_analytic`: source nonanalyticity transfers to the shifted expression for that branch.
3. `PrimeZetaChartExtension.chart_extension_transfer`: if an analytic continuation Ã agrees with A on chart U and H is holomorphic at s, there is an explicitly built analytic source continuation P̃ at s+1 that agrees with P on translatedChart U. Assumes the **on-chart identity** A(z)=zP(z+1)+H(z) and 0∉U. This is strictly stronger than a pointwise nonanalytic implication and handles chosen local continuation charts.
4. `PrimeZetaChartExtension.chart_boundary_transfer`: contrapositive for each chart, with the no-extension premise on P explicitly stated, never hidden.
5. `PrimeZetaAnalyticBridge.shifted_log_coefficient_eq_zero_iff`: for s≠0, s*M=0 iff M=0.
6. `PrimeZetaAnalyticBridge.cleared_integer_coefficient_eq_zero_iff`: for s≠0, D∈ℤ\{0}, integer A, s*((A:ℂ)/(D:ℂ))=0 iff A=0.

These are **source-agnostic algebraic or complex-analytic bridges**, not full source-specific analytic continuation, zeta residues, or the classical prime-zeta boundary.

## Open formal obligations, ordered by dependency

- [ ] Define the actual prime-zeta Dirichlet series P(w)=Σ_{p prime}p^(−w) for Re(w)>1 and shifted deformation A⁺(s) for Re(s)>0 with exact summability hypotheses.
- [ ] Prove `A⁺(s)=s P(s+1)+H(s)` from a normally convergent shifted expansion. Prove H holomorphic on Re(s)>−1.
- [ ] Prove the stronger H decomposition H(s)=s(s+1)P(s+2)/2+H₃(s), with H₃ holomorphic on Re(s)>−2, and prove local H extension across each nonreal s=−1+it.
- [ ] Define and prove classical Möbius inversion plus the normally convergent tail of P'(w)=Σ_m μ(m) ζ'(mw)/ζ(mw) for Re(w)>0.
- [ ] Extract the residue at a nonreal λ using actual ζ orders and exact scaling r/m; derive local primitive logarithmic germ and its monodromy.
- [ ] Reconstruct a typed branch/path-indexed notion of accessible local continuation, not merely a single global analytic function. Link the chart bridge to every path-branch from the original domain.
- [ ] Formalize or independently import **with explicit unproved dependency flag** the classical prime-zeta natural-boundary theorem for every branch. Without this input, the boundary theorem is not Lean certified.
- [ ] Source-check all axioms, dependencies, exact type equivalence, named kernel replay, independent specialist proof review and dated original-source prior-art audit.

An axiom or named hypothesis **identical to either target conclusion** is prohibited. A named classical natural-boundary hypothesis can support a *conditional* kernel-checked corollary, never a fully unconditional Lean theorem.

## Certification and prior art

Lean 4: `leanprover/lean4:v4.36.0-rc2`; Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`. Workflow: `.github/workflows/nightfall-prime-zeta-analytic-bridge-lean.yml`; source file hashes and `#print axioms` must be pinned at the exact PR head. GitHub's "Lean pin metadata audit" is **not** a Lean compiler run.

Classical prime-zeta derivative residues, their collision addition and removability are already described in MathWorld *Prime Zeta Function* (equations 10–11), drawing on Fröberg 1968/Landau–Walfisz 1920. The classical P natural boundary at Re(w)=0 is established prior art. Any claim of first discovery of these mechanisms is false. The shifted paper-level corollaries do not thereby acquire a global novelty certificate.

**Stop rule:** if named exact-head Lean compilation fails, preserve a draft PR with failed receipts. Never mark these two theorem passports as `merged-lean` or claim the entire paper kernel certified merely from the conditional bridge proofs.
