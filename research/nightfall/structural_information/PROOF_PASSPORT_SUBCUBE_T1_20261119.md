# NIGHTFALL Proof Passport — Subcube T=1 non-frame simulation

**Version:** 1.0, 2026-11-19 ET
**Status:** **AUTHOR-SIDE PAPER THEOREM + EXACT FINITE REGRESSION. Not Lean-kernel-certified, not independently human-refereed, not priority-cleared.**
**Source:** SUBCUBE_ONE_QUERY_SIMULATION_20261119.md
**Scope:** one binary quantum oracle call, arbitrary workspaces and final POVM, uniform binary linear source, deterministic nonuniform worst-depth classical approximation, distributional (epsilon,delta) guarantee.

## Exact claim

For any finite row family g_i in F2^m, write D={0} union distinct rows, M=max(1, max_{u!=0} #{(r,t) in D^2:r+t=u}). Every Q1 acceptance function admits a classical simulator reading at most ceil(2M/(epsilon^2 delta)) observed bits, or at most n by exact-input fallback.

For the tensor-subcube row set R_L, |R_L|=3^L, rank=2^L, and M=2L+2 exactly. Thus depth <=min(3^L, ceil((4L+4)/(epsilon^2 delta))). This is the first positive **one-query** result for Claude's subcube source that bypasses the now-refuted high-girth frame approach.

## Independent dependencies and test gates

- Quantum oracle bit-flip eigenbasis: prequery phases chi_r; distinct r give orthogonal subspace amplitudes before postquery unitaries.
- Measurement as a positive contraction 0<=A<=I: row/column squared norms bounded by 1.
- Grouped Walsh Parseval under independent uniform secret s: sum over nonzero pair-XOR frequencies, with Cauchy factor M.
- Heavy threshold tau=epsilon²delta/(2M): at most 1/tau original frequencies, omitted diagonal handled exactly.
- Tensor rank-two difference classification: 2L nonzero ordered pair representations of any pure tensor, six for two varying factors, two for >=three; zero frequency adds two. Thus M=2L+2.
- All-L proofs are written in source note. Finite checker does not substitute for those symbolic steps.

## Certificate/checker

- Command: \`python3 -I scripts/check_subcube_one_query.py\`
- Exact finite coverage: L=1,...,5 pair collisions; L=1,...,3 exhaustive latent inputs and rational one-query projector/Parseval/PSD variance identities; exact four-input two-query falsifier of naive orthogonal-frequency extension.
- Verified at source head \`00b14978c9ff015c8fcf3eb27c2dbec51ee4f097\`:
  [GitHub Actions run 44669358503](https://github.com/d3lefts/d3lefts/actions/runs/44669358503), **success**.
- Receipt artifact \`14598234847\`; ZIP digest \`sha256:137b265f78c2e247d3b7fb0b0d4cb6a33de55308be321d0c9311550b09e93ec9\`.
- This source head is the checked theorem and code version; later prose-only commits need an updated exact-head replay receipt before promoting.

## Independent B-side attack list

1. Verify normalization and mutual orthogonality in the **ordinary bit-oracle** model, including \`|+>\`-sector no-query amplitudes and duplicate rows.
2. Reproduce \`A²<=A\` in the compressed orthonormal phase vector basis (not merely entrywise).
3. Verify the light/light and light/heavy Frobenius budget <=2tau, with no missing factor 2 from ordered pairs.
4. Independently derive the d>=3 tensor secant uniqueness over F2, and verify pure/nonpure flattening-rank classification for all L.
5. Ensure output surrogate g(s) lies in [0,1] without clipping and is determined solely by heavy observed input bits.
6. Try quantum circuits with nonstandard measurement outcomes, prequery entanglement, zero amplitudes and repeated rows.
7. Attempt to extend to T=2; the specific naive frequency-vector orthogonality route is **falsified** by an explicit 2-query rotation circuit.

## Context/attribution and limits

Claude originated the subcube-tensor family and the frame question. Parallel PRs #956/#957/#959 provide independent frame-obstruction arguments. Tensor code/finite-field rank and phase-query operator calculations are established mathematical mechanisms; the conjunction with a quantitative non-frame simulation has not been prior-art cleared.

No quantum-vs-classical characterization for arbitrary T; no \`poly(T,L)\` universal simulation; no exponential quantum advantage either. A 1-query simulator cannot by itself be extrapolated across adaptive quantum rounds. No polynomial classical *runtime* for constructing the simulator is asserted.

**Research graph:** linear source → tensor-subcube row set → exact pair-XOR multiplicity → quantum PSD heavy-coordinate truncation → deterministic T1 simulator → finite checker → open T2 adaptive operator inequality.
