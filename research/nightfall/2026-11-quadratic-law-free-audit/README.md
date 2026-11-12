# NIGHTFALL quadratic law-free analytic proof audit

New independently reconstructed **analytic proof** from Wright's 11 November 2026 v4 synthesis. In scope: all heterogeneous finite-product scalar functions of ANOVA degree ≤2, including arbitrarily small atoms and dense interaction graphs; extension to arbitrary measurable product probability spaces by finite rectangular conditional expectation.

- `QUADRATIC_LAW_FREE_ANALYTIC_AUDIT.md`: full mathematical proof; precise formula, complete matching coupling and four-moment arguments, finite-to-infinite transfer, prior-art review and certification limits.
- `check_exact_quadratic.py`: independent Fraction-based exhaustive finite checks (run with Python 3, no dependencies).

The checker was produced independently of the earlier repo’s v4 finite replay and examines exact parity-coupling expectation identities, exact Hilbert fourth moments, and bias-sensitive configurations. Directed rational square-root bounds are used for radical inequalities; finite tests do not prove the all-law theorem.

**No end-to-end Lean certification or human referee review is claimed. Global historical novelty is unresolved.** The proof source is an internally audited derivative, not the original `matching-core.tex`; preserve original author credit and archive provenance. See draft PR #359 for separate scoped Lean declarations.

## Standalone source-function proof — 11 November 2026 (analytic, NOT a Lean endpoint)

- [Complete analytic argument](UNIVERSAL_QUADRATIC_INFLUENCE_E2E_ANALYTIC_v1.md) derives the finite heterogeneous-product quadratic variance-squared inequality **directly from the original bounded degree-two function**, including a new-in-this-record switch-polynomial pointwise oscillation budget \(\sum_i \operatorname{osc}_i(f)\le16B\) and the corresponding \(\sum_i\mathbb E\|U_i\|\le8B\). It then proves matching parity mass \(\le4B\), greedy endpoint ownership \(\le8B\), additive budget \(\le7B\), actual Hilbert conditional/Jensen step, fourth-moment bound, and finite-cylinder \(L^2\) passage.
- [Exact rational regression](q2_e2e_exact_audit.py) checks 52 heterogeneous positive-mass finite models (independently calculated ANOVA/influences, switch identities, matchings/parity, Hilbert fourth moments, and endpoint). These are **finite tests**, not a mathematical or Lean certificate for the universal theorem.
- [Immutable SHA-256 source manifest](SHA256SUMS_E2E_ANALYTIC_v1) and [dedicated GitHub Actions replay](../../../.github/workflows/nightfall-quadratic-analytic-proof-replay.yml) make the saved proof and checker source-exact. From this directory: `sha256sum -c SHA256SUMS_E2E_ANALYTIC_v1 && python3 q2_e2e_exact_audit.py`.
- Result: \(\operatorname{Var}(f)^2\le225(1+\sqrt3)^2 B^2\max_i I_i(f)\), with **arbitrary measurable product alphabets** covered by a written cylinder-approximation argument. This is the already recorded v7 constant, strictly weaker than the v8 analytic constant; it is not an independently original theorem claim.
- **Certification boundary:** full written proof, finite rational regression and exact source hashes; **no single end-to-end Lean-compiled declaration, no external mathematical referee, and no worldwide novelty clearance**. The previously reported scoped Lean intermediates remain exactly scoped. Do not promote claims, modify the frozen v8 source manifest, or imply computational verification of an infinite-dimensional limit.
