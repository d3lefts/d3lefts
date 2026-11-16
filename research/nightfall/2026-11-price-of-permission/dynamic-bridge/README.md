# NIGHTFALL: Dynamic, Correlation-Aware Permission Price (v0.1)
2026-11-15. Author direction: Devin J. Wright; AI-assisted model, proof and checker.
Status: **candidate Lean proofs awaiting pinned CI**, independent finite audit locally passed.
No priority, production safety, legal authorization or physical effect certification.

## Formal scope
1. **Within-window source change (single checkpoint).** The authority can change after work begins. A trusted checkpoint consumes `spent` worker slots; `R` counts the complete *post-change* fresh independent obligations and excludes valid transferable evidence. Any stale prior observations are invalidated. Epoch is fixed from that checkpoint to atomic effect commit. No unobservable update, source/version ambiguity or unsafe sink bypass is allowed by assumption.
2. **Exact conditional price.** For suffix capacity `K=mH-spent`, with `K≥R`, `guards≥N` and `d≥2c`:
   `C*(R,K)=sunk+2cR+(d-2c)(2R-K)_+`.
   If capacity or guards are insufficient, no fully accepting zero-error plan exists. `sunk` is a provided previously paid amount, not audited from an execution trace. Facility and effect guard fees from the original PR #603 may be added unchanged under its assumptions.
3. **Explicit disclosure cost accounting.** Replace c by c+rawFee and d by d+predicateFee if `d+predicateFee≥2(c+rawFee)`. This accounts for disclosure *fees* only and is not differential privacy or compositional leakage certification.
4. **Correlated-support checker.** Independent of the counting theorem, arbitrary dependent possible-world supports are covered by the exact condition: the selected transcript must distinguish the nominal safe world from *every* unsafe possible world. Cached observations require independent authenticated transfer; newly disclosed observations must obey an allowlist and suffix slot budget. A minimum-cost private bundle exists whenever feasible, by well ordering. In general its computation is combinatorial.
5. **Counterexample.** A source constraint x=y makes the safety predicate vacuously true and justifies a zero-read certificate; broadening the possible worlds to all four Boolean pairs invalidates it. Publishing only `x=y` (not x or y) restores the certificate without revealing more than the permitted predicate; no-new-slot must fail.

**Critical type separation:** The independent-obligation closed-form optimum does NOT automatically extend to correlated shared evidence. For correlated evidence, only the finite-world certificate and existence result are stated here. No false universal substitution of R for rank or support size.

## Reproducible audit
`python3 audit_independent.py` computes 16,225 zero-error checkpointed integer price instances and 1,024 independent finite-world, sensor, and privacy combinations. The checker is source-different from Lean and independent of the original price functions. It checks the specific formula and counterexample, not a universal proof.
Pinned Lean 4.36.0-rc2 + Mathlib, source hashing and named standard-axiom audit are in the dedicated workflow. Do not claim Lean certification before CI success.

## Prior art checked
- Lyu et al., *From Version Conflicts to Decision Conflicts*, https://arxiv.org/abs/2609.08015.
- Wang, *Matoi*, https://arxiv.org/abs/2610.21394.
- Zhu and Wang, *Authorization Revocation for Long-Running AI Agents*, https://arxiv.org/abs/2609.21284.
- Zhang et al., *PrivacyPeek*, https://arxiv.org/abs/2606.00152.
- Classical decision certificates, finite weighted hitting sets, dynamic programming, monitor-selection and source-dependent recertification; original NIGHTFALL PR #603.

## Still open
The genuine joint minimax problem with **multiple adaptive source changes inside the suffix**, changing correlated observation channels, cross-action shared/private observations, probabilistic error/availability constraints, and a fully mediated physical sink. The cheapest decisive next experiment is two adversarial in-window changes of distinct correlated source dependencies with a privacy-constrained adaptive monitor, attacked by an independently implemented exact finite dynamic program. Stop if the proposed formula fails against this oracle; do not relabel a restricted suffix theorem as a general dynamic solution.
