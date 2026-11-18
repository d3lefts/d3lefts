# NIGHTFALL · Universal product-space influence frontier

**Status:** Research conjectures and scoped supporting results. **No all-degree universal influence theorem is proved in this directory.** The classical origins of Chebyshev and Bernstein extremality are credited; priority and independent mathematical review remain open.

## Conjectures

Let \(\mu=\bigotimes_{i\in I}\mu_i\) be any independent product law (including arbitrary coordinate sets and alphabets), \(f\in L^\infty(\mu;\mathbb R)\) have Hoeffding/Efron–Stein degree \(\le d\), and set
\[
B=\inf_{c\in\mathbb R}\|f-c\|_\infty,\quad V=\operatorname{Var}_\mu(f),\quad
M=\sup_i\mathbb E_\mu[\operatorname{Var}(f\mid X_{-i})].
\]
Assume \(d\ge1\); handle \(B=0\) or empty \(I\) trivially.

| ID | Conjectured inequality | Claim level |
| --- | --- | --- |
| N-UE2(6) | \(V^2\le C\,d^6B^2M\) for some absolute \(C\) | Conservative flagship — **OPEN** |
| N-UE2(2) | \(V^2\le C\,d^2B^2M\) for some absolute \(C\) | Degree-sharp landmark — **OPEN** |
| N-UE2(2,1) | \(V^2\le d^2B^2M\) | Coefficient-sharp landmark — **OPEN** |

The exact coefficient-one conjecture is deliberately falsifiable: a single valid \(d=2\) example with \(V^2/(B^2M)>4\), or \(d=3\) example with ratio \(>9\), refutes N-UE2(2,1) without refuting the weaker conjectures.

## Documents and evidence

- [Universal Product E2 Conjecture](UNIVERSAL_PRODUCT_E2_CONJECTURE_20261117.md): definitions, AA/Turturean normalization, conditional finite-to-infinite transfer and prior-art boundaries.
- [Bernstein-sharp conjecture](BERNSTEIN_SHARP_UE2_CONJECTURE_20261117.md): coefficient-one target; bias-tuned Chebyshev every-degree sharpness (author-side asymptotic proof), spectral-degree counterexample, the classical arcsine-path Bernstein operator, and its limitation.
- [Classical Chebyshev degree obstruction](CHEBYSHEV_DEGREE_SHARPNESS_20261117.md): rigorous author-side parity-restricted CLT argument, necessary \(d^2\) degree penalty.
- [Exact degree-one/tribes checker](check_ue2_sharpness.py).
- [Exact finite Chebyshev checker](check_ue2_chebyshev.py).
- [Exact biased Bernstein saturation checker](check_ue2_bernstein_saturation.py).
- [Lean conditional-implication module](../formalization/universal/UE2ConditionalImplications.lean): premise-explicit scalar implications only, not the product-space conjecture.

## Reproduce the finite checks

~~~sh
python3 research/nightfall/flagship-influence/check_ue2_sharpness.py
python3 research/nightfall/flagship-influence/check_ue2_chebyshev.py
python3 research/nightfall/flagship-influence/check_ue2_bernstein_saturation.py
~~~

Pinned Lean CI is in [nightfall-universal-e2-sharpness.yml](../../../.github/workflows/nightfall-universal-e2-sharpness.yml). Exact-source passing research CI: [run 44237376727](https://github.com/d3lefts/d3lefts/actions/runs/44237376727) on source head \`9ba5bb3aec6540df5e5cb3d48d11f6430fb9bb4b\`. These tests certify finite arithmetic and **conditional** algebra only. They do not certify the analytic limits, the universal conjectures, originality, or peer review.

## Research dependency

The primary unsolved fixed-degree gate is **unrestricted cubic exponent two**, currently framed as a *source-consistent mean-coupled annealed Q2* statement in [PR #799](https://github.com/d3lefts/d3lefts/pull/799) and [PR #803](https://github.com/d3lefts/d3lefts/pull/803). Generic annealed Q2 is already known false; do not substitute it. The infinite-product Q2 with a much larger constant is [merged PR #776](https://github.com/d3lefts/d3lefts/pull/776), which does not prove coefficient one at degree two.

## Attribution / citation boundary

Original Aaronson–Ambainis conjecture (2014); Turturean's 2026 uniform-cube resolution; the classical Chebyshev/Bernstein inequalities, Fourier and Hoeffding decompositions, and subsequent 2026 expositions are prior art. NIGHTFALL's conjecture synthesis, quantitative candidate formulation and replay checks are AI-assisted research, not established priority or referee-certified novelty. Publish as research hypotheses with honest evidence status, not as proved breakthroughs.
