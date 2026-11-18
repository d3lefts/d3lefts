# NIGHTFALL full-row K bridge: adversarial dual-mask check (v0.1)

**Status:** deterministic finite search + exact source-world replay; NOT a theorem proving (4V^2\le K^2M). No bound on a universal constant follows from the absence of violations. Draft, pending independent mathematical/code review.

## Objective and scope

Given a finite full-support independent *categorical* source, real-valued (f), original-law variance (V), maximal original-law coordinate resampling influence (M), and full fractional-row cost (K), search for **a single** counterexample to the candidate sharp inequality (4V^2\le K^2M). This follows the correction in #823: the singleton (R=\sup_x\sum_i|f-E_i f|) degree-free substitute is false on biased AND; do not use (R) in place of (K). The full-row question remains open, including its separate uniform-cube antecedent in Turturean §9.5.

## Exact universal difference-mask reduction

At each input (x), for each nonempty subset (T\subseteq[n]), let

[
b_T(x)=\max_{y:\{i:y_i\neq x_i\}=T}|f(x)-f(y)|.
]

When every coordinate letter has positive probability and every alphabet has at least two letters, every mask occurs. The full row LP is exactly

[
K(x)=\min\{\sum_i a_i:a_i\ge0,\ \sum_{i\in T}a_i\ge b_T(x)\ \forall T\ne\varnothing\}.
]

Its finite LP dual is

[
K(x)=\max\{\sum_{T\ne\varnothing}\lambda_T b_T(x):
\lambda_T\ge0,\ \sum_{T\ni i}\lambda_T\le1\ \forall i\}.
]

The dual feasible polytope depends **only on coordinate count** (not category sizes, values, biases or (x)). Any vertex has at most (n) nonzero dual weights, so exact-support and active-capacity enumeration is complete. The script obtains 16 distinct vertices for (n=3); an independent SciPy primal LP cross-check found 95 for (n=4). Neither vertex count is claimed historically novel; this is standard fractional packing LP duality, repurposed as a reusable proof-attack operator.

## Test protocol

- Script: `research/nightfall/flagship-influence/check_bridge_dual_adversary.py`, Python standard library only, RNG seed `20261118`.
- Samples: **3500** input/value/law tables of shape (2,2,2), **3000** of shape (3,2,2), **2200** of shape (2,3,3) — total **8700** full-support rational-law, integer-valued candidates.
- Seven deterministic cyclic modes: fair additive functions, random entries, sparse / large-magnitude outputs, biased AND-like isolated triggers, sparse-interaction forms and near-additive perturbations. Nonuniform source weights include 1, 2, 3, 17, 100, and 1000.
- For *every* sampled candidate, recompute genuine full (K) using the precomputed dual vertices, not singleton sensitivity. Search-phase arithmetic is floating point; it is a candidate filter only.
- At the best found value for each shape, independently recompute **exact rational** (V,M,R,K); compute (M) twice using original-law conditional residuals and fresh replicas; verify every optimal full row by a separate **primal exact-rational basis enumeration** (not using the dual algorithm). Any numerical ratio greater than (1+10^{-9}) enters the exact audit and fails the run if an exact violation is found.
- Separate exact additive fair-three-sign control achieves (4V^2/(K^2M)=1). This proves a universal coefficient (<1/4) in (V^2\le cK^2M) is impossible; it does not prove (c=1/4) suffices.

## Local source results, before remote CI

| Shape | Candidates | Best exact ratio (4V^2/(K^2M)) |
|---|---:|---:|
| (2,2,2) | 3500 | 1 |
| (3,2,2) | 3000 | ≈0.7415123457 |
| (2,3,3) | 2200 | ≈0.6016666667 |

Additional independent **numerical** differential-evolution / SciPy LP exploration (not included in standard-library CI) inspected approximately 61,732 evaluations on the 3-coordinate shapes, plus 2,480 on the four-bit shape, and found no violation. Maxima were ≈0.98835 for (2,2,2), ≈0.97292 for (3,2,2), ≈0.24544 for (2,3,3) and ≈0.29352 for (2,2,2,2). SciPy/primal and mask-dual values were independently compared for randomly generated tables. The counts describe optimization objective evaluations and must not be interpreted as independent tests.

**Reproduce:** `python3 -I research/nightfall/flagship-influence/check_bridge_dual_adversary.py`

## Limits and next decisive experiment

This is finite sampled evidence, NOT a proof of the full-row conjecture or matching sharp constant. The search samples arbitrary tables without enforcing low Hoeffding degree; consequently it is relevant directly to the degree-free (K) bridge but it does not independently certify a degree-restricted upper theorem. The earlier separate fixed-degree (R) numerical search (d=2,3, n=4,6,8) also found no violation of (V^2\le dR^2M), but did not produce a theorem or a CI artifact. The all-degree (V^2\le C dR^2M) route remains an unproved hypothesis and is not entailed by #823.

Priority: devise a joint threshold/covariance inequality for **full** (K); search larger supports and continuous laws only after source-consistent masks and a primal/dual exact witness recorder are retained. A numerical violation must be converted to a small rational source table and independently audited before publication. Preserve #823's false singleton-bridge correction and credit classical fractional certificate LP duality.
