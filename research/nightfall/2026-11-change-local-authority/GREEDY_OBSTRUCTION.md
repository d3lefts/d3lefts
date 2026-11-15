# Quantitative mechanism: unbounded gap for myopic information acquisition

**Scope:** exact analytic corollary in the independent modular-edge evidence model of `THEORY.md`. It does **not** claim that no adaptive method can perform well; the counterexample applies specifically to myopic policies selecting a sensor only when it has positive *immediate* mutual information with the safe/unsafe mission outcome, and choosing a positive-information direct test over zero-information node observations. This phenomenon has antecedents in information synergy and is not claimed globally original.

## Theorem

Take complete graph `G=K_n`, `n≥2`, with per-node read cost `w>0` and per-direct-gate read cost `d>0`, `r≥2`, every edge's two modular halves independent uniform. Let `K_e` be the edge checksum and `Φ=1` exactly when all `K_e=0`. Then:

1. Any **single** node reading `N_v` is independent of the *entire* vector of gate checks `K=(K_e)_{e∈E}`, hence `I(Φ;N_v)=0`. The reason is that for every `e∋v`, the other endpoint's unseen uniform half masks the read half. Product structure makes the entire checks vector independent of that single node transcript.
2. Each direct gate read has **strictly positive** immediate information about `Φ` while any gate remains unresolved on a safe transcript; its read value changes the probability of mission success from `r^{-m}` to either zero or `r^{-(m-1)}`.
3. Consequently an always-positive-immediate-information greedy procedure never reads a node on a safe transcript, and instead directly tests all `m=binom(n,2)` gates, incurring cost `d*m`.
4. The exact **globally optimal** zero-risk safe-path cost is
   `C*=min(d*binom(n,2), w*n)`.
   Proof: with `k` queried nodes, `binom(k,2)` edges are automatically known, leaving direct costs for every other edge. The cost is `g(k)=wk+d[binom(n,2)-binom(k,2)]`, a concave quadratic in `k`, so its minimum on `0≤k≤n` occurs at an endpoint `k=0` or `k=n`. Both endpoint policies exist.
5. When `d*binom(n,2)>w*n`, the ratio of greedy to optimal cost is exactly
   `d*(n-1)/(2w)`. Thus it grows without bound as `n→∞` for fixed positive `d,w`.

The result is *not* a generic impossibility theorem about all greedy algorithms. A two-step synergy-aware heuristic can discover the advantage of paired node reads. It is a precise obstruction to selecting sensors solely by one-step mutual information of each observation with the mission verdict.

## Connection to authority recertification

The mechanism is not lack of information anywhere: the relevant information is split across pairs, and individual readings of those halves have exactly zero immediate mission information. A minimum-cut policy purchases a globally useful set of mutually complementary readings, not locally positive information scores. That is the distinctive reason a mission-conditioned evidence strategy must model interactions rather than rank each sensor in isolation.

## Checks

For `n=5`, `w=2`, `d=3`, the greedy safe-path cost is `30`, while the optimal node strategy costs `10`, ratio `3`. The exact minimum-cut solver checked `n=2..7` for four positive rational `(w,d)` pairs against the closed form; all matched. This finite check is corroborating only; the proof above applies to all finite `n`.

## Boundaries

The proof assumes all half-secrets independent uniform and node sensors reveal all incident halves at the stated cost. Correlated evidence can make a single node read informative, and arbitrary observation costs or alternate queries change the optimization. Risks `δ>0` require the separate risk-bounded theorem. Cache provenance and real agent sensor validity are not established here.
