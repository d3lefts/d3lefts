# Cubic aggregate-link overlap — research checkpoint (12 November 2026)

**Classification:** author-side analytic *conditional lemma* + finite exact falsification; missing universal spike-tail theorem; no referee or Lean cert; no global priority claim.

[Full mathematical note and proof](AGGREGATE_LINK_OVERLAP_LEMMA.md) | [Exact overlap checker](check_aggregate_link_overlap.py) | [Directed spike-tail search](search_spike_tail.py)

## Setup and proved conditional result

For a bounded homogeneous three-partite cubic (f=\sum_{a\in A}q_a(X_a;X_B,X_C)) with (|f|\le B), define each **aggregate** row (Q_a=q_a(\cdot;X_B,X_C)\in L^2_0(\mu_a)), (v_a=\mathbb E\|Q_a\|^2), total (V=\sum_a v_a), and maximum influence (M\ge v_a). Global boundedness of the source gives the pointwise inequality (\sum_a\|Q_a\|\le B), independent of overlap/codegree.

Let (κ_a=\mathbb E\|Q_a\|^4/v_a^2) for positive-energy rows, (K\ge1), and (W_{\mathrm{spike}}(K)=\sum_{a:\kappa_a>K}v_a). The source note proves by Hölder and the aggregate pointwise budget:

```text
V <= sqrt(K) B sqrt(M) + W_spike(K).
```

It also gives the unconditional *data-dependent*, not constant-uniform, inverse-kurtosis invariant (V\Lambda(f)\le B\sqrt M).

**Critical limitation:** Neither a uniform κ bound nor (W_{\mathrm{spike}}(K_0)\le C_0B\sqrt M) has been proved for all bounded cubic functions. The latter is the **open** next gate. Without it, the unrestricted cubic exponent-two theorem and `LE(C)` remain open.

## Exact stress and adversarial cases

- Hadamard interlocking links: (n=4,16,64,256), (V=1/n), (M=1/n^2), (κ=3-2/n). Handles unbounded cover number and pair-codegree.
- Rare categorical addresses: (κ\) unbounded with alphabet size; this prevents assuming uniform aggregate-link kurtosis.
- 120 exact random signed cubic models; 1,600 exact skew-alphabet searches, with a maximum observed squared spike ratio (45369/95000). **Tests are not universal proof.**

This checkpoint extends the [tripartite link-energy representation](../../new-moon/spectral-observability/homogeneous-cubic-v8/TRIPARTITE_LINK_OPERATOR.md), itself part of the merged [PR #349](https://github.com/d3lefts/d3lefts/pull/349). Do not confuse this conditional overlap operator with an unrestricted cubic proof.

## Replay and next decisive experiment

```sh
python3 -I research/nightfall/2026-11-12-cubic-overlap/check_aggregate_link_overlap.py
python3 -I research/nightfall/2026-11-12-cubic-overlap/search_spike_tail.py
```

Try rational skew-atom 2–3 A / 2–3 B / 2–3 C models; independently recalculate conditional second and fourth moments of any candidate violation. If no structural progress, switch operator families to conditional-event overlap or link-covariance. **Do not promote the spike-tail conjecture on finite sampling.**
