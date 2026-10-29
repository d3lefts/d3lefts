# First autocorrelation — mass transport and exact NTT verification

**Research checkpoint:** October 20, 2026. **Evidence:** exact finite software audit plus experimental search. **Official leaderboard:** no record claimed.

Given n nonnegative weights a_i with total mass S and linear autoconvolution b_k, the Arena objective is **C_n(a)=2*n*max_k(b_k)/S^2** (smaller is better).

The source research derived a mass-preserving edge-transfer update that changes every b_k by an exact quadratic expression, yielding O(n) candidate updates rather than full O(n^2) reconstruction. An integer grid-split operation preserves the full score exactly; the corresponding piecewise-linear continuous autoconvolution attains its maximum at a grid knot. The latter gives a genuine continuous step-function certificate, not an approximation. A triple-NTT/CRT checker reconstructs convolution maxima and the exact rational ratio.

The frozen tested **4,096-cell integer vector** has exact mass 69,181,369,803 and maximum autoconvolution coefficient 885,475,318,899,981,268 at lag 2558. Its audited score is approximately **1.5156121926181447**, above the historical October 20 public leader at about **1.50274349**. It therefore falls short of first place; the achievement is a reproducible experiment and exact checker rather than a contest record.

The research note reports checks using a direct integer convolution, an independent Python big-integer enumeration, and three-prime NTT/CRT. **Original archive:** `NIGHTFALL C1_certificate_20261020.json` and the associated October 20 research bundle, awaiting binary/source witness mirror. External prior-art attribution and later score baselines require review.

This is a distinct convolution optimization problem from the signed-shift Erdős minimum-overlap witness.

[Broader Arena historical/negative-results register](../expansion-2026-10-28/08-arena-and-negative-results.md). Research lead Devin J. Wright; exact finite result only.
