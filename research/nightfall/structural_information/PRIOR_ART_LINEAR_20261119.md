# Quick prior-art check: structural information and linear distributions (2026-11-19)

Four web searches, abstracts and snippets only (no full papers read). Specialist check still needed.

| Our item | Closest prior work found | Verdict |
| --- | --- | --- |
| Theorem A (`h`-wise independence inherits product simulation) | Folklore/polynomial method: a `2k`-wise independent distribution fools every `k`-query quantum *distinguisher* (e.g. Prop. 26 in arXiv:2508.08852). | The distinguishing version is known and must be cited. Our statement is stronger (pointwise `(ε, δ)`-simulation of the acceptance probability, needs `h = poly(T, 1/ε, log 1/δ)`), but the idea is standard. Present it as a lemma, not a contribution. |
| Relaxing to *almost* `k`-wise independence (next step 2 in `LINEAR_DISTRIBUTIONS`) | Aaronson (Fourier Checking / BQP vs PH): Fourier Checking is almost `k`-wise independent yet has a quantum advantage; the generalized Linial–Nisan conjecture was refuted (arXiv:1110.6126). | **Warning.** Any approximate version of Theorem A must lose a factor that grows with the number of degree-`h` monomials; naive "almost independent ⇒ no advantage" is false. |
| Theorem C (Bernstein–Vazirani on a subspace in a short sumset; bent-function parity-tree bound) | Bernstein–Vazirani; parity decision tree lower bounds and Fourier growth of parity decision trees (Girish–Tal–Wu, arXiv:2103.11604). | Ingredients standard; the statement in terms of `r·R` not found. |
| Subspace number `N_r(R)`, frame cost `Λ_T`, Conjecture E | Bogolyubov's lemma used in a quantum context for worst-case to average-case reductions for linear problems (arXiv:2212.03348). Coding-theoretic Fourier sampling (DQI). | No characterization of quantum advantage over linear input distributions by sumset structure found. Appears new. |
| Wyner common information as a simulation resource | Wyner common information appears in distributed source simulation, including quantum settings (arXiv:2301.04301). | No link to query simulation found. Appears new. |

Actions taken: `LINEAR_DISTRIBUTIONS_20261119.md` now credits the known distinguishing version of
Theorem A and carries the almost-independence warning.
