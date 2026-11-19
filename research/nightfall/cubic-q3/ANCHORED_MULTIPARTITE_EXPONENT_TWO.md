# Anchored multipartite exponent-two influence theorem

**2026-11-17; author-side proof only.** The unrestricted cubic theorem remains open. This is a restricted structural theorem based on a *classical* sharp Khintchine–Kahane inequality; there is no external novelty claim, Lean receipt, or independent expert review.

## Theorem (finite-coordinate arbitrary-law anchors)

Partition a finite independent product into blocks A, U, W. Variables in A have arbitrary probability laws and alphabets; variables in U and W are independent unbiased signs. Assume the bounded f has no ANOVA components except triples {i,j,k} with i in A, j in U, k in W. These triple tensors may have arbitrary dependence on X_i, without a rank-one assumption. Write B=||f||∞, V=Var(f) and M=max_i Inf_i(f) for genuine original-law resampling influence. Then

**V² ≤ 4 B² M**.

There is **no bound on the overlap** of triples or the number of coordinates.

## Proof

Write f(x,u,w)=Σ_{i∈A} H_i(x_i,u,w) with

H_i(x_i,u,w) = Σ_{j∈U,k∈W} h_{ijk}(x_i) u_j w_k,

where every h_{ijk} is centered in original law μ_i. All anchor rows are independent, centered, and orthogonal in full L². In particular E_i H_i=0 and Inf_i(f)=E_{u,w}||H_i(·,u,w)||²_{L²(μ_i)}.

For fixed u,w, f(·,u,w)=Σ_i H_i(X_i,u,w) lies in [-B,B] a.s. Independence implies the essential oscillations of its summands add. With s_i(u,w)=||H_i(·,u,w)||_{L²(μ_i)}, Popoviciu gives s_i ≤ oscillation_i/2. Therefore

(1)  Σ_i s_i(u,w) ≤ B.

Treat each row H_i as a bilinear decoupled Rademacher chaos valued in Hilbert space L²_0(μ_i). The sharp vector Khintchine–Kahane inequality gives E_signs ||Σ ε_j v_j|| ≥ (1/√2)(Σ ||v_j||²)^(1/2), for every Hilbert space (indeed every Banach space, with the corresponding L² norm). Applying once to U in H=L²(μ_i) and once to W in H^{|U|} yields

(2)  E_{u,w} s_i(u,w) ≥ (1/2)(Σ_{j,k}||h_{ijk}||²_2)^(1/2) = (1/2)√Inf_i(f).

Average (1), sum (2): Σ_{i∈A} √Inf_i(f) ≤ 2B. The original ANOVA variance is V=Σ_{i∈A} Inf_i(f), because every nonzero support meets exactly one anchor. Thus V≤√M Σ_i√Inf_i(f)≤2B√M, proving V²≤4B²M.

**Credit for classical input:** S. Latała and K. Oleszkiewicz, *On the best constant in the Khinchin–Kahane inequality*, Studia Mathematica 109 (1994), https://www.impan.pl/en/publishing-house/journals-and-series/studia-mathematica/all/109/1/108398/on-the-best-constant-in-the-khinchin-kahane-inequality . The cited result proves (E||Σ ε_i v_i||²)^(1/2)≤√2 E||Σ ε_i v_i|| for vectors in arbitrary normed linear spaces.

## Dimension-free all-d anchored transfer

For d disjoint blocks, one arbitrary-law anchor block A and d−1 independent unbiased-sign blocks, assume every nonzero canonical ANOVA support has *exactly one coordinate from each block*. Iterating the same vector Khintchine–Kahane step d−1 times proves

**Var(f)² ≤ 2^(d−1) ||f||∞² max_i Inf_i(f)**.

This is not an unrestricted exponent-two theorem at degree d. Under arbitrary biased laws in the other blocks, a universal local L¹/L² lower estimate fails without additional structure.

## Checker, stress tests and scope

Finite exact rational checker: research/nightfall/cubic-q3/check_anchored_tripartite_exact.py. It enumerates heterogeneous categorical anchors, dense genuinely nonseparable links, original product-law influences, the anchor Parseval identity, and the 256-state routing witness of PR #797 (B=1, V=1, M=1/2, ratio=2). Direct tests are not a proof of the general statement; the proof is the displayed argument using a separately established classical result.

The theorem makes no illegal exchange of E max_i with max_i E; the entire anchor-range estimate is **pointwise in the fair-sign blocks**.

**Missing for unrestricted cubic Q3:** transferring this fixed-anchor row budget through arbitrary-product two-replica selectors without losing the global coordinate maximum. PRs #799 and #803 do not discharge that gate. Do not promote or merge as unrestricted Q3 closure.