# External referee packet — Erdős minimum overlap (C₁b)

**Research lead:** Devin J. Wright · **Compiled:** 29 October 2026 · **Program:** NIGHTFALL / PHASESHIFT  
**Status:** exact finite construction with public replay and internal independent implementations; **external mathematical referee and independent literature-priority review OPEN**. This packet is a request for criticism, not a declaration of refereed publication or of a solved open problem.

## Precise claim

With the normalization used in [C₁b](https://teorth.github.io/optimizationproblems/constants/1b.html), the minimum overlap constant satisfies the explicit constructive **upper** bound

```text
                      34788888032212764146872525963225147703298526879
C₁b ≤ Q = ----------------------------------------------------------------
                      91343852333181432387730302044767688728495783936
      = 0.3808563701180293252462787636560246135327211883155...
```

Witness: `N=131072` cells on `[0,2]`, integer numerator denominator `D=2^70`, grid width `h=2/N`. Define `f(x)=A_i/D` on cell `i`, zero outside `[0,2]`; define `g=1-f` **inside** `[0,2]` and zero outside. The frozen input satisfies `0<=A_i<=D` and `sum(A_i)=(N/2)*D`. Both functions are admissible and `integral f=1`.

Set `B_j=D-A_j` on `0<=j<N` and **zero** elsewhere (do not continue the complement outside the support), and `S_k = sum_i A_i B_{i-k}`. The finite exact claim is

```text
max over integer -(N-1) ≤ k ≤ (N-1) of S_k / ((N/2)*D²) = Q
unique maximizing k = -17280
real translation t = -k*(2/N) = +135/512
```

**Finite-to-continuous lemma (the mathematical step):** for `t/h=m+θ` with integer `m` and `0≤θ<1`, the overlap `R(t)=integral f(x)g(x+t)dx` equals `[(1-θ)S_{-m}+θ S_{-(m+1)}]/((N/2)*D²)`. This follows from partitioning each original step cell into two subintervals of lengths `(1-θ)h` and `θh`. It is affine between adjacent grid shifts, and vanishes outside `[-2,2]`. Thus the **continuous** supremum is the exact finite maximum stated above. This is a witness-specific upper bound; it says nothing about the global optimality of this construction.

## Frozen inputs and exact public reproduction

- [Public approved release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28) · curated math ZIP `NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip`, 11,882,806 bytes, SHA-256 `f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23`.
- ZIP member: `programs/erdos-overlap/frozen-witness/heights_u70.txt` · SHA-256 `a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e`.
- [Public release receipt](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/CURATED_PUBLIC_DOWNLOAD_RECEIPT_20261029.json) records anonymous download, size, hashes, complete ZIP manifests and exact rational peak.
- [Public CI run](https://github.com/d3lefts/d3lefts/actions/runs/40831149715) passed fresh anonymous asset downloads and GMP replay of all 262,143 signed shifts. [Independent Python implementation](https://github.com/d3lefts/d3lefts/blob/main/scripts/verify_erdos_independent.py) uses carry-free big-integer multiplication, distinct from original six-modulus NTT/CRT computation. [GMP agent audit](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_131072/EA36_AGENT_AUDIT_REPORT.md) includes an independently derived continuum lemma and the exact runner-up.

From a checkout of the reviewed PR branch (and later main, after merge):

```bash
python3 scripts/download_nightfall_curated_assets.py public-assets
python3 scripts/verify_erdos_independent.py --self-test
python3 scripts/verify_erdos_independent.py public-assets/heights_u70.txt
```

The download script verifies the two approved ZIPs and extracts the **exact fixed-path witness**, verifying its SHA-256 independently; it never extracts arbitrary ZIP paths. No private archive, token, or contest submission payload is required.

## External baseline and priority check (29 October 2026)

The [Optimization Constants C₁b page](https://teorth.github.io/optimizationproblems/constants/1b.html) lists Atris's exact 114,688-cell bound `0.38085855031642856010...`, independently replayed by C. Toledo on 18 October 2026. Our `Q` is approximately `2.18019839923485×10⁻⁶` **smaller** under the common normalized continuous overlap definition. Recheck the external registry and literature **on the review date** before awarding priority.

[EinsteinArena leaderboard](https://einsteinarena.com/problems/erdos-min-overlap) separately displays NIGHTFALL-DevinWright rank 1 at about `0.3808564`; its accepted source input remains unrecovered ([issue #6](https://github.com/d3lefts/d3lefts/issues/6)). The released 131,072-cell witness is **too long** for the Arena's 100,000-entry cap; it must not be represented as the accepted competition payload.

An unrelated 4,096-cell `0.380856` value was [shown to arise from a normalization defect](https://www.benzanghi.com/blog/erdos-minimum-overlap-technical); its corrected value is approximately `0.38094895`. Distinguish by integer mass, grid denominator, full hash and exact score; do not conflate these constructions.

## Reviewer contract

An external reviewer is asked to independently:

1. Download the asset anonymously, verify the bytes, inspect the actual height array and audit mass and bounds.
2. Implement the signed-grid objective **without reusing our original NTT or our Python checker**, including both translation directions and endpoints; certify all 262,143 shifts, the peak and any ties with exact integers.
3. Critique the finite-to-continuous affine interpolation proof, especially the zero-extended complement, shift sign and `[0,2]` support.
4. Independently check the same-model prior-art comparison and publication priority (including later public records).
5. Report **PASS / FAIL / INCONCLUSIVE**, code or exact proof, commands, environment, original input SHA-256, reviewed commit and dated external source comparison. Negative outcomes welcome.

**Do not remove an unverified marker solely because an internal second implementation passes.** The outside registry explicitly requires a genuinely separate reviewer, verified formalization or maintainer signoff.

## External registry submission preparation

Per [teorth/optimizationproblems contributing instructions](https://github.com/teorth/optimizationproblems/blob/main/CONTRIBUTING.md), update all three records in a fork-based pull request:

- `constants/1b.md`: append, retaining all earlier rows, a `C₁b ≤ Q` construction by **Devin J. Wright with AI-assisted NIGHTFALL research**; include exact fraction, witness size, release hash, code/receipt links, and an **unverified marker pending independent external review**.
- `README.md` constant table: revise the 1b upper-bound cell to the new rounded value, flagged as unverified.
- `README.md` Recent progress: add a dated C₁b record describing the construction, public certificate, and verification limitations.

This is a **prepared contribution specification**, not an upstream submission. Submit through the upstream fork-and-PR procedure after human review of attribution, source links and publication wording. The external maintainer decides whether to list the bound and which verification marker applies.

## Status boundaries

- **Internally reproducible explicit construction:** yes, subject to the publicly inspectable evidence and existing CI checks.
- **External human mathematical referee:** open.
- **Global novelty/priority:** unconfirmed pending a dated exhaustive comparison.
- **Arena first place:** reported by its live leaderboard; accepted payload identity separate.
- **Exact determination of the minimum-overlap constant:** no.
