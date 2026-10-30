# Dossier 34 — Fixed-field adaptive phase separation

**Editorial snapshot:** 2026-10-30 · **Evidence:** working theorem candidate, original draft PR unmerged · **Originality:** unreviewed.

## Mathematical object and current source
The source studies every signal in K^k, including zero and sparse support, with K=F_(3^r), r≥2, and queries (a·x)^2 from K-linear a. Signals are identified up to one global sign; all adaptively chosen queries count. The producer proposes A(k,r) ≤ k+ceil((k−1)/r) and a nonadaptive fixed-design lower bound F(k,r) ≥ 2k−1. For the fixed field F9 these imply an unbounded F(k,2)−A(k,2) as k grows, **assuming the source proofs hold**.

**Primary draft:** [Vesper PR #256](https://github.com/d3lefts/d3lefts/pull/256). **Linked adversarial internal results:** [Lemnis #264](https://github.com/d3lefts/d3lefts/pull/264), [Ryev #265](https://github.com/d3lefts/d3lefts/pull/265), and [Axiom #266](https://github.com/d3lefts/d3lefts/pull/266). Their separate F9 k=6 and k=9 minima are conditional on the upper construction and review of the rank-conditioned lower-bound proof.

## Reproduction and proof gate
Follow the exact branch source, field representation, checker, hashes, and CI receipts from each PR. The producer's F9 finite regression and other agents' distinct field arithmetic are **internal checks**; they cannot certify a universal all-k theorem. Check the fixed-versus-adaptive oracle match, all-support handling, alphabet bound, branch-rank split, and early stopping. Classical complement property and intersecting-code geometry (including Borello–Schmid–Scotti, 2025) are imported prior art, not new results. No global publication priority or independent human referee is recorded.

**Publication boundary:** This catalogue entry reports a proposed research package; it is not an Original Finding, Proof Passport promotion, or mathematical theorem acceptance.
