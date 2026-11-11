# NIGHTFALL quadratic law-free analytic proof audit

New independently reconstructed **analytic proof** from Wright's 11 November 2026 v4 synthesis. In scope: all heterogeneous finite-product scalar functions of ANOVA degree ≤2, including arbitrarily small atoms and dense interaction graphs; extension to arbitrary measurable product probability spaces by finite rectangular conditional expectation.

- `QUADRATIC_LAW_FREE_ANALYTIC_AUDIT.md`: full mathematical proof; precise formula, complete matching coupling and four-moment arguments, finite-to-infinite transfer, prior-art review and certification limits.
- `check_exact_quadratic.py`: independent Fraction-based exhaustive finite checks (run with Python 3, no dependencies).

The checker was produced independently of the earlier repo’s v4 finite replay and examines exact parity-coupling expectation identities, exact Hilbert fourth moments, and bias-sensitive configurations. Directed rational square-root bounds are used for radical inequalities; finite tests do not prove the all-law theorem.

**No end-to-end Lean certification or human referee review is claimed. Global historical novelty is unresolved.** The proof source is an internally audited derivative, not the original `matching-core.tex`; preserve original author credit and archive provenance. See draft PR #359 for separate scoped Lean declarations.