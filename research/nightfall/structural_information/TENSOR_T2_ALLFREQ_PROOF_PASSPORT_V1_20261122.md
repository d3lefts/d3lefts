# Proof Passport v1 — all-frequency tensor two-query candidate (2026-11-22)

Identity: NIGHTFALL-TENSOR-T2-ALLFREQ-SIXSITE-20261122. Status: PAPER-LEVEL THEOREM CANDIDATE, not end-to-end Lean certified, no external non-author referee, no worldwide novelty clearance.

## Statement and representation
For R_L the 3^L nonzero F2² rank-one product tensor rows, secret s uniform on the binary dual, a two-query finite-dimensional complex quantum phase-oracle circuit with arbitrary 0≤P≤I has a proposed nonadaptive original-row acceptance-probability simulator with Q≤min(3^L, ceil(2(2√B4+145√B2)²/(ε²δ))), Bk=(1+k·3^(2k−2))^k Σ_{j≤min(2k−2,L)}binom(L,j). Thus O(L^6/(ε²δ)) queries, not polynomial computation, state simulation, pointwise correctness, or higher-query simulation.

## Certificate graph — source and scope
| Dependency | Receipt | Status |
| --- | --- | --- |
| Equal XOR => zero-sum symmetric difference | https://github.com/d3lefts/d3lefts/actions/runs/45057667635 | Lean kernel PASS |
| Existence of minimal zero circuit | https://github.com/d3lefts/d3lefts/actions/runs/45058158295 | Lean kernel PASS |
| Remove minimal zero circuit; remainder strictly smaller and zero | https://github.com/d3lefts/d3lefts/actions/runs/45058340885 | Lean kernel PASS |
| Partition every finite zero-sum set into disjoint minimal circuits, with exact sum of cardinalities | https://github.com/d3lefts/d3lefts/actions/runs/45058533313 | Lean kernel PASS |
| Per-circuit active factor support ≤size−2 | Lovitz 2018 and Lovitz–Petrov 2023 | Published external theorem, **not source-matched Lean** |
| Aggregate conditional per-circuit supports into ≤2k−2 active sites | https://github.com/d3lefts/d3lefts/actions/runs/45057230471 | Lean kernel PASS conditional on published support lemma |
| Six active sites attained by one source-identified eight-row binary tensor circuit | https://github.com/d3lefts/d3lefts/actions/runs/45057016520 | Lean kernel PASS, construction only |
| Count alternatives matching a reference outside active sites | https://github.com/d3lefts/d3lefts/actions/runs/45056810501 | All-L paper argument plus finite exact tests, no Lean full terminal |
| Unrestricted complex Hilbert light-frame and six equality/four zero-triple coefficient bounds | https://github.com/d3lefts/d3lefts/issues/1021#issuecomment-7083589329 | Two internal paper derivations and complex finite tests, no Lean theorem/external reviewer |
| Walsh conditional projection and query-depth terminal | https://github.com/d3lefts/d3lefts/pull/1059 | Paper candidate; no end-to-end Lean theorem |

## Mechanism, audit and ownership
Compare primitive sets C,C′ of k or fewer row labels with equal nonzero XOR; their symmetric difference is zero-sum. Partition into disjoint minimal circuits (now Lean certified generically). Published tensor splitting limits variable sites per circuit to size−2; the now Lean-certified conditional budget bounds total active sites by 2k−2. Each alternative row matches a reference row outside active sites; ≤(1+k3^j)^k assignments for a j-site support. This proves the claimed O_k(L^(2k−2)) all-frequency counting at paper level, not yet in Lean for the tensor-specific implication.

The quantum Fourier partition must classify ALL repeated labels, including zeros, into group B before primitive all-slot-distinct A and unique-zero-triple C. Internal parallel PR #1068 independently reached the same general binary-label operator criterion and identified this bookkeeping risk. Credit as ONE shared result candidate.

## Priority and stop criteria
Lovitz arXiv:1812.00264 (2018) already gives circuit support under local dimension two; Lovitz–Petrov (2023) extends it. Wang–Yuan arXiv:2610.32787 (Oct 2026) uses bounded-active-mode exchanges. Blanc–Docter–Strassle–Tan FOCS 2026 and Liu–Mutreja (2026) provide constant-round simulation for full-uniform/dense oracle inputs, whereas the tensor response law is a thin code of density 2^(2^L−3^L). No originality clearance. At ε=δ=1/4 the coarse bound first becomes smaller than 3^L at L=50; query-only asymptotic interest.

Open gates: source-faithful Lean proof of Lovitz tensor-circuit support and the all-L row-cover count; independent adversarial proof of arbitrary-complex rank-free frame estimates, a full Lean terminal, dated specialist priority search and non-author review. No merge/public submission/promotion without human approval. Preserve all failed CI and superseded branches.

Next decisive experiment: formalize the source-equivalent all-L F2² tensor support lemma separately from the generic finite-Hilbert light-frame inequality; either failure demotes the full simulator. Source code and receipts reside in stacked draft PR #1059 and base PR #1029.