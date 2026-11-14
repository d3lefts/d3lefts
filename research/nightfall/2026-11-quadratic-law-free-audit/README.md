# NIGHTFALL quadratic law-free analytic proof audit

> **14 November exploratory checkpoint (not a new certified theorem):** [Shifted-owner Hilbert fourth moment](Q2_SHIFTED_OWNER_MOMENT_107_20261114.md) replaces the old \(\mathbb E\|Z_i\|\le u_i+a_i\) route with a direct shifted \(L^1\)–\(L^2\)–\(L^4\) bound. It gives author-side source-level **targets** \(C_2=273.012\) using an elementary \(c/3\) lemma and pre-existing \(8B\) budgets, \(C_2=251.426\) using the exact \(c/4\) polynomial certificate, and \(C_2=107.393\) **only when** PR #525's sharper section budget is independently proved. The [exact rational Bernstein checker](check_shifted_owner_moment_107.py) verifies the \(c/4\) scalar inequality, not the full Lean/source theorem. Keep existing source-level certified coefficients distinct; do not promote these targets to publication.


## Current checkpoint — November 13, 2026 (read before the historical v7 notes)

The historical material below is not the strongest current author-analytic proof. The leading original-source finite categorical claim is
\[
\operatorname{Var}(f)^2 \le
K_2 B^2\max_i I_i(f),\quad
K_2=(10+2\sqrt2)^2(1+\sqrt3)^2\approx1228.356324.
\]
It uses full finite heterogeneous Cartesian alphabets, normalized source marginals permitting zero masses, a pointwise bound \(|f|\le B\), and *genuine* Hoeffding degree at most two, with **no pre-supplied** matching/section/amplitude/energy witnesses.

- [Merged PR #448](https://github.com/d3lefts/d3lefts/pull/448): complete *author-side* source-level proof, rational finite-model falsification and exact scope. External non-author proof review and worldwide priority remain unresolved.
- [Merged PR #452](https://github.com/d3lefts/d3lefts/pull/452): **new proposed source-preserving soft ownership** using coordinate refresh/Markov operators instead of discrete owner-neighbor distribution transport. Its two local rational checkers and analytic derivation passed scoped CI as a **merged author-analytic alternative**, not an independently reviewed or kernel-checked terminal theorem.
- [Merged PR #447](https://github.com/d3lefts/d3lefts/pull/447): adversarial normalization, categorical Grothendieck and false-martingale controls. Do not repeat the disproven root-influence summability or expected-max-interchange transfer.
- [Merged PR #445](https://github.com/d3lefts/d3lefts/pull/445): active Lean **4.36.0-rc2** strict integrated Hilbert Jensen receipt, scoped to its declarations; [merged PR #444](https://github.com/d3lefts/d3lefts/pull/444): historical 4.33 original-law first-moment/owned-neighbor receipts. Historical compilation does not establish an active-pin composite.
- Main [source merge/tower and scalar integrated Jensen](https://github.com/d3lefts/d3lefts/commit/2dbfdf7a8f09190d5b4f4dafb942c14b9be94590) are a narrower **compiled** original-source operator layer; the full terminal Q2 theorem remains **uncompiled**.

The earlier 11-November \(225(1+\sqrt3)^2\) and related \(15(1+\sqrt3)\) coefficients below remain archived, not overwritten. A result that is *new to this archive*, an author-side analytic proof, a machine proof of a named sublemma, and a historically new theorem are distinct statuses. For integration order and overlapping branches, consult [the dated PR queue](../ACTIVE_RESEARCH_QUEUE_20261113.md).


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
