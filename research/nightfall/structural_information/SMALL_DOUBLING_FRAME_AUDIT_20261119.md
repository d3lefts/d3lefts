# Small doubling gives a bounded-cost independent frame: scoped audit (2026-11-19)

**Status:** author-side derived corollary of published PFR and dense Bogolyubov–Ruzsa results; not an independent new additive-combinatorics theorem, not Lean-checked, not externally reviewed. Conjecture E remains open. This note supplements, without overwriting, `LINEAR_NECESSITY_20261119.md` and `MERGING_DIRECT_SUMS_20261119.md` (Theorem F). Quantitative constants implicit in the Bogolyubov–Ruzsa big-O are not extracted.

## Precise statement

Work in the additive group `F_2^m`. Let `R` be a **nonempty set of distinct rows**; repeat rows may first be discarded when computing sumsets and the frame, since repeats have the same parity coordinate. Set

- `K = |R + R| / |R| >= 1`, with ordinary two-fold sumset;
- `r·R` = sums of at most `r` rows (the convention of `LINEAR_NECESSITY`);
- `N_4(R) = max {dim V : V <= F_2^m, V subset 4·R}` (the zero space is always allowed);
- `d = dim span(R)`.

**Proposition (bounded-doubling frame bound).** There is an absolute constant `C` such that

    N_4(R) <= d <= N_4(R) + 2 K^12 + C (1 + log_2(2K))^4.

For every choice of the independence parameter `h`, there is a `(d, 1, h)`-frame `B subset R` (take a basis). In the sense of the exact frame cost defined in `LINEAR_DISTRIBUTIONS_20261119.md`, therefore

    Lambda_T(R) <= d <= N_4(R) + O(K^12 + log^4(2K))

for **every** `T`. The lower inequality `N_4 <= d` is immediate because the sumset lies in `span(R)`.

**Restricted Conjecture E consequence:** If `N_4(R) <= k` and `K <= P(k,T)` for a fixed polynomial `P`, then `Lambda_T(R) <= poly(k,T)`. This is a restricted positive result, **not** the unrestricted frame dichotomy: no bound on `K` follows merely from a bound on `N_{a(T)}`. If invoking Conjecture E's premise instead, require explicitly `a(T) >= 4`.

## Proof with dependencies exposed

1. **Polynomial Freiman–Ruzsa (external theorem).** Gowers–Green–Manners–Tao give a subgroup `H <= F_2^m` with `|H| <= |R|` and a cover of `R` by `t <= 2K^12` translates of `H`. Choose any such cover. Repeated or empty cosets can be removed. [GGMT, *On a conjecture of Marton*, Annals of Mathematics 2025, arXiv:2311.05762](https://arxiv.org/abs/2311.05762). This is the conservative published exponent; no claim to optimize it.
2. **Pigeonhole density.** Some coset `a+H` meets `R` in at least `|R|/t >= |H|/t` points. Translate its intersection into `A = (R intersect (a+H)) - a subset H`. Hence `|A|/|H| >= 1/t`.
3. **Dense Bogolyubov–Ruzsa (external theorem).** In the vector space `H`, a subset of density `alpha` has `4A` containing a linear subspace `V` of codimension at most `C (1+log_2(1/alpha))^4`. Thus `dim V >= dim H - C(1+log_2 t)^4`. Since the characteristic is 2, `4(A+a) = 4A` (four copies of `a` cancel), and consequently `V subset 4R subset 4·R`. See [Sanders, *On the Bogolyubov–Ruzsa lemma*, arXiv:1011.0107](https://arxiv.org/abs/1011.0107), and an explicit dense formulation in [Ben-Sasson, Lovett and Zewi, *An Additive Combinatorics Approach to the Log-Rank Conjecture* / related quasipolynomial Bogolyubov–Ruzsa expositions](https://eccc.weizmann.ac.il/report/2012/135/revision/2/download/). The citation to the latter is to the dense lemma, not to claim it proved PFR.
4. **Span rank.** The cover gives `span(R) subset H + span(a_1,...,a_t)`, where `a_i` are its coset representatives. Hence `d <= dim H + t <= dim V + C(1+log_2 t)^4 + t <= N_4(R) + C(1+log_2 t)^4 + t`. Substitute `t <= 2K^12`.
5. **Exact frame witness.** Pick `B subset R` a basis of `span(R)`; `|B|=d`. Every row is a sum of at most `d` vectors in `B` (forward locality `c=d`), every element of `B` is itself a row (`c'=1`), and distinct elements of a basis have **no** nonempty linear dependency, at any length (independence condition for every `h`). Thus the frame cost is at most `d`. QED, conditional only on the two explicitly cited published theorems.

No step constructs the PFR subgroup or the Bogolyubov subspace algorithmically; this is an **existence** certificate. The exact `Lambda_T` depends on the frame and smoothing definitions already in the branch, and the full quantum simulation remains dependent on Theorems A/B and their provisional Route 1/product-simulator dependencies.

## Large doubling need not mean an expensive frame

Let `H = span(e_1,...,e_d)`, and let `f_1,...,f_t` be linearly independent modulo `H`. Choose

    R = H union {f_1,...,f_t},  d >= 1, t >= 1.

The distinct-coset calculation is **exact**:

    |R| = 2^d + t,
    |R+R| = (t+1) 2^d + t(t-1)/2,
    rank(R) = d+t.

Thus the doubling constant grows linearly with `t` (for fixed `d`). Nevertheless `B = {e_1,...,e_d,f_1,...,f_t}` is a `(d,1,h)`-frame for every `h`, since every row in `H` needs at most `d` of the first basis vectors and each `f_i` needs one. Hence `Lambda_T(R) <= d` independently of `t`. Large doubling by itself does **not** imply high local-frame cost.

This example is consistent with the branch's newer Theorem M (direct-sum merging) and reinforces the target: **high doubling plus genuinely interacting short circuits not removable by cheap independent frames**.

A separate small-dimensional exhaustive checker is appropriate for the formula above, but cannot certify the PFR/BR corollary or general Conjecture E.

## Existing branch claims that require correction or extra checking

1. **Theorem C is a sufficient witness of advantage, not the converse.** `V subset r·R` with large `dim V` yields a quantum-vs-classical separation. Necessity of such a witness for *every* quantum advantage is precisely open Conjecture E. Theorem C's proof remains paper-level.
2. **The claimed BCH/APN 'sharp threshold' must distinguish theorems from heuristic comparisons.** Theorem A proves no advantage only when its explicit `h(T,epsilon,delta) <= d(R)-1` hypothesis holds. In particular for `d(R)=5` (APN t=2), the stated proof does not establish a useful all-constant-error `T=1` no-advantage regime: its smoothing parameter is far greater than 4 at ordinary constant accuracy. The short-sum positive witnesses are independent of this issue.
3. **The existing `dichotomy_tests/sumset_tests.py` has a fail-open maximum-subspace routine:** `maxsub` returns `best[0]` even when its 15-second deadline interrupted the DFS; the result then need not be the *exact maximum* `N_r`. Mark interrupted runs as **lower bounds** or throw a timeout, and retain exact labels only for completed enumeration, including the reported `m<=12` table.
4. **The random-row transition has intermediate regimes.** A comparison of `n=O(m)` and `n=2^{Omega(m)}` does not imply that the threshold lies only at those extremes. Study `n=m^alpha` and `n=2^{m^beta}` with `0<beta<1` separately; track `N_r`, dependencies, frame cost and simulation error, rather than treating raw sumset growth as advantage.

## Next falsifiable experiment

**Pre-registered target:** build a family with `N_{poly(T)}(R)` small but `Lambda_T(R)` superpolynomial in `T+N_{poly(T)}`, after exact removal of direct-sum and local-code decompositions. The cost is an existential `(c,c',h)`-frame minimization: avoid using only an approximate `Lambda` lower bound. Either an explicit counterexample defeats Conjecture E, or a general merging/quotient theorem excludes the family.

**Cheapest next test:** deterministic bounded-dimensional enumeration of row sets with many short circuits but large covering radius, reporting (a) exact `N_r` with completion flag, (b) exact minimum frame cost for a fixed declared smoothing threshold, (c) direct-sum decomposition and rank of every quotient. Keep `m` small and identify structural mechanisms before increasing computational intensity.

**Independent audit before theorem promotion:** verify each literature hypothesis (including 4-fold vs at-most-4 sums and translate cancellation), reproduce the rank argument independently, compile finite-set/linear-algebra lemmata under pinned Lean, and distinguish external-theorem imports from self-certified outcomes. Check novelty only after this; the bounded-doubling proposition is presently a derived application of published mathematics, not a new global theorem.

## Research provenance

- Branch checked: `structural-information-theory`; existing sources `LINEAR_DISTRIBUTIONS_20261119.md`, `LINEAR_NECESSITY_20261119.md`, `MERGING_DIRECT_SUMS_20261119.md`, `dichotomy_tests/`.
- External theorems checked in this session: Gowers–Green–Manners–Tao PFR (published 2025) and the dense Bogolyubov–Ruzsa statement.
- Author-side finite check (not general proof): exact set calculations for `d in {1,2}`, `t in {1,2,3,4}` matched the displayed `|R+R|` and rank formula; independent review of the resulting manuscript remains outstanding.
