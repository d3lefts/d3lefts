# NIGHTFALL v8 — Homogeneous cubic / soft-cover bridge

**2026-11-11 · Research checkpoint · NOT publication-cleared.**

This directory preserves the author's v8 analytic theorem and reviewer obligations with executable, dependency-free exact tests. This is **not** a proof of unrestricted cubic squared-variance influence. The Q2/Lk analytic premises imported from v5 still require independent specialist review; global priority and arbitrary-product posterior measurability also remain open.

- [THEOREM.md](THEOREM.md): finite-product homogeneous extraction; pure-cubic equivalence; conditional top-linearity/layerwise-linearity and soft-cover observability.
- [TRIPARTITE_REDUCTION.md](TRIPARTITE_REDUCTION.md): universal reduction to 3-partite homogeneous cubics with a factor-36 implication; related decoupling antecedents explicitly credited.
- [checks/tripartite_projection_exact.py](checks/tripartite_projection_exact.py): 243-color exact rational test of variance preservation and norm/influence bounds.
- [TRIPARTITE_LINK_OPERATOR.md](TRIPARTITE_LINK_OPERATOR.md): exact block-l1 quadratic link representation and an explicit **open** sufficient inequality (LE(C)).
- [checks/tripartite_link_exact.py](checks/tripartite_link_exact.py): rational link-bookkeeping sanity check.
- [REVIEW_GATES.md](REVIEW_GATES.md): separately listed proof obligations and falsification plan.
- [PROOF_ATTACK.md](PROOF_ATTACK.md): new weighted complete 3-hypergraph no-go for a *combinatorial-only* cover shortcut, plus an exact 5-bit pure cubic disproving the coefficient-one inequality.
- [checks/exact_bridge.py](checks/exact_bridge.py): independent exact rational ANOVA and energy-cover replay.
- [checks/weighted_hypergraph_no_go.py](checks/weighted_hypergraph_no_go.py): rational combinatorial no-go replay.
- [checks/five_bit_cubic_witness.py](checks/five_bit_cubic_witness.py): 32-input exact cubic witness.

Run all tests from repository root:

\`\`\`bash
python3 research/new-moon/spectral-observability/homogeneous-cubic-v8/checks/exact_bridge.py
python3 research/new-moon/spectral-observability/homogeneous-cubic-v8/checks/weighted_hypergraph_no_go.py
python3 research/new-moon/spectral-observability/homogeneous-cubic-v8/checks/five_bit_cubic_witness.py
python3 research/new-moon/spectral-observability/homogeneous-cubic-v8/checks/tripartite_projection_exact.py
python3 research/new-moon/spectral-observability/homogeneous-cubic-v8/checks/tripartite_link_exact.py
\`\`\`

The [dedicated GitHub Actions workflow](../../../../.github/workflows/nightfall-homogeneous-cubic-v8.yml) reruns the tests on the PR and branch changes. The original separately generated v8 source ZIP's SHA-256 manifest was verified in the originating conversation, but is **not** reproduced as a repository manifest; GitHub provides individual tracked file hashes and the workflow tests the committed versions.

**What remains open:** a bound for densely overlapping *bounded pure cubics* that genuinely uses global \(\|f\|_\infty\) information and cannot be derived from weighted edge energies alone.
