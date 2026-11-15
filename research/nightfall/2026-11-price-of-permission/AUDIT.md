# Independent exact audit — 2026-11-15

## Protocol

Checker B was designed as exhaustive enumeration of every legal guard and inspection choice, independently of the proposed closed-form scalar capacity. It does not call the formula or greedy construction while evaluating the alternative. Checker B independently solves the calibrated monitor-mixing optimization by enumerating all rational LP corner intersections rather than using the proposed analytical formula.

## Observed exact results

`python3 audit_independent.py`:

- 2,240 complete scheduling-parameter comparisons (N from 0 to 6, T from 1 to 5, m,g each 0..3, K every 0..N) against independent exhaustive recursion.
- 1,425 parameter combinations in which the capacity is strictly below N.
- 1,540 minimum installed-capacity cases; verifies both the constructive pair and that reducing either worker capacity by 1 makes the target unavailable.
- Cache-invalidating adversary checked by enumerating all subsets of initially cached certificates for each case.
- Independent decisive example verified exactly: N=3, T=2, m=2, g=3, K0=1, B=1 => max 2. Without invalidation or with m=3 => max 3.
- Ordered-case SHA-256: `8f4d3efbf568a46c0a919d37a1dbcb57309a36990562963662d95de262e85412`.

`python3 monitor_mixing.py`:

- 500 exact rational prior/postselection/unsafe-frequency/availability constraint tuples, comparing Theorem 2 to independent rational LP vertex enumeration.
- Ordered-case SHA-256: `af5c9c239ad90fb87c884f90f5f38bfd07052a91123b7430ed09ae7f852cac5c`.
- Illustrative calibrated case p=1/5, delta=1/20, eta=1/20, alpha=3/4: direct-commit probability 1/20, deep-monitor rate 7/10, denial rate 1/4. These are toy model values, not observed frontier-model performance.

These are finite-model audits and do not independently verify general theorem proofs, detect monitor bypass in an actual runtime, or prove the derived result is novel. No Lean kernel certificate.
