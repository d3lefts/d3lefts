# Erdős minimum-overlap: witness identity, certification scope, and prior-art baseline

**Research lead:** Devin J. Wright. **Source audit:** 2026-10-28. **Purpose:** remove ambiguity between exact mathematical certificates, competition submissions, and third-party bounds.

## Exact mathematical witness — strongest NIGHTFALL internal object

- **Type:** explicit step-function **upper bound**, not a global lower bound and not a value of the unknown constant.
- **Cells:** 131,072 uniform pieces on [0,2].
- **Integer heights:** denominator `2^70`, mass exactly 1, every height in [0,1], as checked by the archived verifier.
- **Exact rational score:**

```
34788888032212764146872525963225147703298526879
-------------------------------------------------
91343852333181432387730302044767688728495783936
= 0.3808563701180293252462787636560246135327211883155...
```

- **Maximizing signed lag:** -17,280. **Lag convention:** with zero-extended cell heights, the exact numerator at signed index k is `sum_i A_i * (D - A_{i-k})` over valid pairs, with `i` in `[max(0,k),min(N,N+k))`. Under the opposite `i+k` indexing, the numerical value at k changes; use the original checker’s stated orientation.
- **Witness height file SHA-256:** `a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e`.
- **Recorded internal verification:** six-prime NTT/CRT reconstruction, signed-lag integer checks, mass and bounds checks, continuum breakpoint argument, and dyadic fiber audits. Replayed by the research collaboration on 2026-10-27. **No external human referee has yet verified the whole result.**
- **Download access (updated 29 October):** the owner-approved [curated math evidence ZIP](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28) is public, anonymously downloadable and hash-verified; it contains `programs/erdos-overlap/frozen-witness/heights_u70.txt` matching the frozen source hash above. Public CI independently replayed every signed grid shift with GMP ([completed release issue #5](https://github.com/d3lefts/d3lefts/issues/5)). This resolves public byte access; it does **not** establish external human refereeing. See [referee packet](EXTERNAL_REFEREE_PACKET_20261029.md).

## Arena records — distinct objects

**Leaderboard snapshot of 2026-10-27, as archived in the submission receipt:**

- Displayed rank 1: agent `NIGHTFALL-DevinWright`, accepted score **0.3808564043546676**, one accepted submission shown.
- **Accepted entry:** October 20 Work-session history associates the accepted score with **solution #2628**, contemporaneously describing **2,048 cells** and a receipt package `NIGHTFALL_Arena_Submission_2628_Receipt.zip`. The actual accepted values, SHA-256, exact rational score, maximizing lag and direct API confirmation remain unrecovered. Treat the cell count and submission identity as **historical provenance leads**, not a verified source-file match. The preceding named 2,048-cell `NIGHTFALL_B2048_Projected_Handoff.zip` had source-reported exact value `0.380856407054191088321511097114…` (maximizing lag −458); the Arena score is roughly 2.6995234332×10⁻⁹ smaller, consistent with a later Work iteration. Recovery is tracked in [Issue #6](https://github.com/d3lefts/d3lefts/issues/6).
- **Rejected attempt of 2026-10-27 19:07 UTC:** separate 131,072-value submission, SHA-256 `f9ff0bee291c196710768a335afc368108b3d36c0b77b531c89be66f07973b4b`, locally exact score `235738674893000319714322121/618970019642690137449562112 = 0.380856370118029394982...`. API returned HTTP 400: `solution.values: Too big: expected array to have <=100000 items`.
- **Older v3** (separately referenced in the manuscript; submission outcome not established by the accessible receipt): another 131,072-value construction at `0.380856370118785003720...`, maximizer +52,440; original witness SHA-256 `b00f821ba6d99fd992230e9d2b96b36acb3f6b06fff15a4e00e3a5b441ea9fe2`. Its relationship to the one accepted Arena entry has not been verified.

**One explicit API rejection is documented by the public receipt.** The older v3 artifact is an archived 131,072-cell candidate; its exact submission disposition is unverified. Neither is evidence for the accepted leaderboard input. The exact mathematical certificate does not acquire competition eligibility from its numerical strength.

## Prior work: upper bounds (smaller is better)

| Method / cited source | Published or listed upper bound | Status |
|---|---:|---|
| AlphaEvolve (2025) | 0.380924 | Published baseline |
| TTT-Discover (2026) | 0.380876 | Published baseline |
| Together AI (2026) | 0.380871 | Public construction |
| SimpleTES (2026) | 0.380868 | Listed in the optimization-constants index |
| CodexProLong, Aug 2026 | 0.380858574857858309… | Listed; independently normalized/replayed |
| Atris, Aug 2026 | **0.38085855031642856010…** | Independently replayed exact mathematical witness, SHA-256 prefix `62a976fa1366` |
| NIGHTFALL accepted Arena snapshot, Oct 2026 | 0.3808564043546676 | Exact underlying artifact unknown |
| NIGHTFALL internal 131,072-cell mathematical construction | **0.380856370118029325246…** | Internally exact replay; full external audit pending |

For comparisons use the actual construction under a common mass, support, zero-extension, and real-shift normalization. The NIGHTFALL exact number is **0.00000218019839923485… smaller** than the independently replayed Atris value. That numerical difference constitutes an upper-bound improvement only if our full exact construction and equivalence proof survive independent reproduction and the historical comparison remains current.

The September 2026 *Hill Sampling* study reports approximately 0.38090 for its best Erdős run: it improves AlphaEvolve and trails TTT-Discover's 0.380876. The paper's qualitative comparison alone is insufficient to identify it as the best available 2026 construction.

A separate widely discussed **4096-cell 0.380856 normalization error** was analyzed by Ben Zanghi. Its corrected objective is approximately 0.38094895. That is a **different mathematical object** from our 131,072-cell exact-rational certificate. Source hashes and explicit normalization should be used to prevent conflation.

## Lower bound / true remaining gap

- White (2023) established **c > 0.379005**.
- Price (2026) reports **c > 0.38055470**. The finite interval-arithmetic certificate was independently reproduced by VibeMathed and additional reviewers; MathWorld (as updated Oct 26, 2026) observes that specialist review of the entire analytic reduction had not been documented.
- **NIGHTFALL conditional improvement, originally certified October 27; recovered and replayed October 28:** **c > 0.38062747462668** follows from eight exact rational dual returns and retained Wetch analytic/interval premises. This is **+4.962668×10⁻⁸** against Wetch's published threshold, while the original Arb integrations have **not** received a fresh independent numerical replay. The unchanged eight-row proof family has an exact rational pointwise ceiling **below 0.380627474626686**, leaving less than 6×10⁻¹⁵ of potential room through row selection or nonnegative mixing. [Lower-bound audit and caveats](../../agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md) · [standalone checker](../../agent-reports/ea36_lower_20261028/verify_dual_ceiling.py).
- **Conditional bracket from the recovered NIGHTFALL return** (pending the inherited analytic/Arb replay): `0.38062747462668 < c <= 0.380856370118029325246…`, gap width `0.000228895491349325246…`. This is an improvement to the lower deduction under its explicit source premises, not a newly reproduced unconditional theorem.
- Wetch's separately public [Erdős #36 repository](https://github.com/justinwetch/erdos-36-minimum-overlap) reports the stronger **c > 0.380627425**, with original/local full fresh-copy verification and explicit analytic premises. Wetch's own README states that these are **not externally peer-reviewed**. This is a stronger **source-reported result**, rather than a lower bound independently rerun in this research turn.
- **If Wetch's full bound holds**, the sharper bracket is:

```
0.380627425 < c <= 0.380856370118029325246...
conditional gap width < 0.000228945118029325246...
```

- **If the full Price reduction is valid**, the joint bracket is:

```
0.38055470 < c <= 0.380856370118029325246...
conditional gap width < 0.000301670118029325246...
```

This bracket should not be presented with a completely certified lower-end status until that analytic link is independently reviewed. The historical White-based gap to our upper endpoint is approximately 0.001851370118029325246.

## External references and review routes

- [Tao / teorth optimization constants, Erdős minimum-overlap](https://teorth.github.io/optimizationproblems/constants/1b.html) — historical upper constructions and source links.
- [Wolfram MathWorld minimum-overlap](https://mathworld.wolfram.com/MinimumOverlapProblem.html) — Price lower-bound status.
- [Justin Wetch, Erdős #36 exact local verification](https://github.com/justinwetch/erdos-36-minimum-overlap) — stronger source-reported lower bound with explicit lack of external peer review.
- [Together AI public upper-bound construction](https://github.com/togethercomputer/EinsteinArena-new-SOTA/tree/main/erdos-minimum-overlap).
- [Beck–Ogren–Kobren, Hill Sampling, arXiv:2609.25510](https://arxiv.org/abs/2609.25510).
- [Ben Zanghi, independent 4096-cell normalization warning](https://www.benzanghi.com/blog/erdos-minimum-overlap-technical).
- [NIGHTFALL receipt (2026-10-27)](../../audit/erdos-arena-submission-receipt.json).
- [Reviewer issue #1](https://github.com/d3lefts/d3lefts/issues/1).
- [Missing accepted-submission identity issue #6](https://github.com/d3lefts/d3lefts/issues/6).
- [Public curated certificate release — issue #5, closed](https://github.com/d3lefts/d3lefts/issues/5).

**Interpretation policy:** Internal independent implementation ≠ independent external specialist referee. A timestamped leaderboard screenshot ≠ a mathematical construction certificate. A verified finite numerical inequality ≠ an independently reviewed analytic transfer theorem.
