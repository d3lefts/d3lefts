# Exact negative controls and non-transferability checks

**Purpose:** delimit the 2026-11-15 change-local authority theorem; these are source-assumption violations, **not** counterexamples to the stated theorem.

1. **Stale cache invalidates authorization.** One edge over `Z_2`, initial values `(A_{u,e},A_{v,e})=(0,0)` and a cached read of both agents gives `K_e=0`. If `A_{v,e}` changes to `1` but its cache is incorrectly marked current, a zero-cost policy authorizes on cached readings, while the true `K_e=1`. Thus a valid change impact and authentication protocol is necessary before the theorem applies to any operational system.

2. **Marginal uniformity without independence invalidates the posterior formula.** Let two edge checks `K_1,K_2` be the same shared uniform binary variable `T`. Each marginal is uniform, yet after reading `K_1=0`, `K_2` is known exactly, rather than independently uniform. The purported risk formula `1-2^{-1}=1/2` would give a false *exact* posterior (actual risk 0); the cut strategy can be strictly suboptimal because it ignores cross-edge inference.

3. **Asymmetric misspecification can invalidate the risk guarantee.** For one untested gate let the actual probability of unsafe outcome be `9/10`, while the verifier's declared model assumes uniformity (`1/2`). The model's risk budget `δ=1/2` permits authorizing without observation, but actual unsafe probability is `9/10`. Even independent edges do not rescue a wrong marginal distribution.

4. **Overlapping evidence can make conditional risk larger than claimed.** Suppose `P(K_1=0)=1/2` and `P(K_2=1|K_1=0)=9/10`, with full support. After direct verification `K_1=0`, an untested gate `K_2` has unsafe posterior probability `9/10`, not the `1/2` predicted by independent fair gates. This is compatible with genuinely safe worlds (which occur with conditional probability 1/10) and therefore violates the intended posterior guarantee.

5. **Authority is model-relative.** The theorem certifies truth of a fixed finite modular predicate, not that the predicate adequately describes a real plant, mission or policy. Formal verification of the optimizer cannot validate its external sensors, goal semantics or source authentication.

6. **Conditional-risk trade-off is not an operational policy.** Illustrative `δ=1/2` and `δ=3/4` values show that mathematical optimality may authorize with insufficient evidence for any realistic high-consequence system. Deployment risk targets require independent institutional signoff.

7. **Computation scope:** strict minimum-cut exactness is polynomial in graph size under rational-capacity arithmetic; the brute-force `≤k` omission enumeration takes `O(|E|^k poly(|V|+|E|))` for fixed `k`, an XP bound. Do **not** claim fixed-parameter tractability `f(k)poly(n)` from this algorithm.

**Research transition:** retain matching lower/upper bounds under correlated secrets via graphical models, with explicit separators and calibrated noisy observation likelihoods; also prove cache source authentication and impact invalidation at the operational boundary.