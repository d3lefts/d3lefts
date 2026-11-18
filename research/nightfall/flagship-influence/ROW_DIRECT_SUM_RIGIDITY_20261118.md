# NIGHTFALL real-row structural gate: disjoint-sum tensorization, binary pairs and a categorical obstruction

**Version 1.0 — 2026-11-18.** Status: *author-analytic exact finite-product theorems plus independent exact-rational source replay.* A source-level Lean kernel theorem for the full row operator has **not** been obtained. The unrestricted real-valued full-row conjecture of Turturean §9.5, its arbitrary-product extension, the degree-weighted singleton-R conjecture, and the sharp general-product quadratic C₂=4 upper bound remain OPEN. No originality or global priority is asserted. These are structural transfer/proof-attack tools.

## Goal and precise normalization

Let (X=(X_i)_{i\in N}) be independent, full-support, finite categorical random variables. Let (f:N\text{-product}\to\mathbb R), (V=\operatorname{Var}(f)), (I_i=\mathbb E\operatorname{Var}(f\mid X_{-i})=\tfrac12\mathbb E(f(X)-f(X^{i\leftarrow X_i'}))^2), (M=\max_i I_i).

At each input (x), a **full fractional row** is (a_i(x)\ge0) for which, **for every** (y), (|f(x)-f(y)|\le\sum_{i:x_i\ne y_i}a_i(x)). Define (κ_f(x)=\min\sum_i a_i(x)), (K(f)=\max_x\kappa_f(x)). (Do NOT replace this with (R(f)=\max_x\sum_i|f(x)-\mathbb E_i f(x)|); #823 disproves a degree-free bound with R.)

The proposed sharp real-row statement is (4V^2\le K^2M). It is **not** proved here for unrestricted f.

## Theorem A: exact direct-sum row cost and original-law tensorization (all finite categorical products)

Partition coordinates into disjoint nonempty blocks (B_1,\ldots,B_m), with independent product laws, and set (f(x)=c+\sum_{j=1}^m h_j(x_{B_j})).

Then **exactly**, at each supported input (x):
[
\kappa_f(x)=\sum_j\kappa_{h_j}(x_{B_j}),\qquad
K(f)=\sum_j K(h_j).
]
Also
[
V(f)=\sum_jV(h_j),\quad
M(f)=\max_j M(h_j),\quad
R(f)=\sum_j R(h_j).
]
Every coordinate's original-law resampling influence is the influence in its own block.

**Proof of the cost equality.** Given any valid global row at x, hold all blocks but (B_j) fixed in the comparison y. The restricted weights in (B_j) must constitute a valid full row of (h_j) at (x_{B_j}); hence the global cost is at least the sum of local optimum costs. Conversely concatenate arbitrary optimal local rows. The triangle inequality makes them globally feasible, with cost exactly the sum. Product support allows the independent maximization of the local κ. The variance/influence identities follow by independent block orthogonality and the actual coordinate refresh definition. Pointwise the singleton residual sum also splits by blocks and maxima add on a product support. QED.

**Sharp bridge closure.** If every nonconstant h_j satisfies (4V_j^2\le K_j^2M_j), then (2V_j\le K_j\sqrt{M_j}\le K_j\sqrt M). Sum to get (4V(f)^2\le K(f)^2M(f)). This is an all-block-count theorem conditional **only on the already-valid component cases**, not an assertion for arbitrary interacting functions.

**Weighted R closure.** If each h_j has canonical Efron-Stein degree (d_j\ge1) and satisfies (V_j^2\le c\,d_j R_j^2M_j) for a fixed c, then the sum has degree (d=\max_j d_j) and satisfies (V(f)^2\le c\,d R(f)^2M(f)). Proof: sum (V_j\le\sqrt{cd}\,R_j\sqrt M) and use exact R additivity. This does NOT prove the local weighted-R conjecture. In either route, **disjoint additive composition cannot amplify a valid ratio beyond the best block ratio**. A violating example must have a violating indecomposable component.

## Theorem B: the sharp full-row bridge holds for ANY function on TWO biased binary coordinates

Let (f:\{0,1\}^2\to\mathbb R) and let (X_1,X_2) be independent Bernoulli variables of arbitrary full-support biases (0<p_i<1). Define global edge oscillations
[
A_1=\max_{t\in\{0,1\}}|f(1,t)-f(0,t)|,\quad
A_2=\max_{s\in\{0,1\}}|f(s,1)-f(s,0)|.
]

**Exact row identity:** (K(f)=A_1+A_2). For every x, any valid full row must assign the actual incident single-flip changes to its coordinate weights, so its cost is at least the sum of the two incident edge changes. Maximizing x chooses the x₂ that realizes A₁ and the x₁ that realizes A₂ *independently*, giving (K\ge A_1+A_2). Conversely the constant row (A₁,A₂) is valid: compare x,y along a path changing only the differing coordinates and apply the triangle inequality. Hence equality.

True-law influence (I_i=p_i(1-p_i)\mathbb E_{X_{-i}}[\Delta_i f(X_{-i})^2]\le A_i^2/4). Efron–Stein gives (V\le I_1+I_2). With (M=\max(I_1,I_2)), the pair of inequalities (I_i\le M) and (4I_i\le A_i^2) implies (2I_i\le A_i\sqrt M). Therefore
[
\boxed{2V\le(A_1+A_2)\sqrt M=K\sqrt M},\quad
\boxed{4V^2\le K^2 M}.
]
No Boolean-valued output restriction, no balanced-bit law and no bound on f's numerical range are needed. The case M=0 is trivial. **Coefficient 1/4 is optimal within this scope:** (f(x)= (2x_1-1)+(2x_2-1)) under two fair bits has V=2, M=1 and K=4, giving equality.

For a **single arbitrary categorical coordinate**, K is the output range L, M=V and (V\le L^2/4) by Popoviciu, giving the same sharp inequality.

**Corollary (any dimension):** by Theorem A the proposed sharp real-row inequality is established for any real function that is an additive sum of independent blocks, each block either (a) one arbitrary categorical site or (b) two arbitrary biased binary sites. All block outputs and biases may be heterogeneous. This is a restricted but unbounded-dimension positive theorem, not a universal row bridge.

**Quadratic influence corollary:** these functions have Efron-Stein degree at most two. For this class (V^2\le2B^2M), where B is the centered half-range. Proof: every block has at most two original independent coordinates, so (V_j\le2M_j) by Efron–Stein and (V_j\le B_j^2) by Popoviciu. Thus (V_j\le\sqrt2\,B_j\sqrt{M_j}), and independence, exact range additivity B=ΣB_j, and common M yield (V\le\sqrt2\,B\sqrt M). This weak (C=2) is **not claimed novel**; it is included to show how the true-law source bound composes and is stronger than the (C=4) bound obtained by K≤4B in this class.

## Theorem C: exact 2-coordinate degree-2 falsifier of a tempting stronger gradient step

The stronger intermediate statement
[
\sum_i\sqrt{I_i(f)}\le K(f)/2
]
is **FALSE even at Efron–Stein degree exactly 2 on one trit and one fair bit**. This closes a potentially attractive but incorrect proof step; it does NOT refute the sharp full-K inequality.

Take independent (T\in\{0,+,-\}) with masses ((1/100,99/200,99/200)) and fair (S\in\{-1,+1\}). Define
[
f(0,S)=S/4,\quad f(+,S)=1,\quad f(-,S)=-1.
]
The optimal full row at a (T=0) input has cost (5/4+1/2=7/4). At a (T=+\) or (T=-) input, cost is 2; hence **K=2 exactly** (the explicit feasible primal rows and tight singleton/diagonal constraints are independently enumerated).

Direct original-law moments are:
[
V=317/320,\quad
I_T=158499/160000,\quad
I_S=1/1600,\quad M=I_T.
]
Since (\sqrt{I_S}=1/40) and (I_T>(39/40)^2), it follows *exactly* that (\sqrt{I_T}+\sqrt{I_S}>1=K/2).

**Exact scope boundary for Theorem B.** In this same trit/bit example, the global coordinate-edge oscillations are A_T=2 and A_S=1/2, yet K=2<5/2=A_T+A_S. Thus the two-*binary*-site identity K=ΣA_i cannot be extended naively to a categorical site. This is an independent obstruction to the edge-alignment proof, not to the variance-squared conjecture.

The actual target remains satisfied:
[
\frac{4V^2}{K^2M}=\frac{2512225}{2535984}<1.
]
The function is (g(T)+\mathbf 1_{T=0}S/4), so the mixed (T,S) ANOVA component is nonzero (and there are only two distinct coordinates): degree **exactly 2**.

**Mechanism:** a rare middle categorical value permits a small independent perturbation without raising the *maximal full-row cost*, yet its square-root influence contributes at first order (\sqrt\varepsilon), while the dominant categorical coordinate influence loses only order ε. Hence any argument demanding (K\ge2\sum_i\sqrt{I_i}) cannot prove the full-row theorem, even in a two-coordinate low-degree case. The true variance-square coupling retains the needed covariance cancellation.

## Reproducibility, independent attack, and limitations

Standard-library exact source checker:
`python3 -I research/nightfall/flagship-influence/check_row_direct_sum_rigidity_exact.py`

- 300 seeded biased two-binary original laws and arbitrary rational f, exact row primal at all four source worlds, two-replica influence independently rederived, Popoviciu/ES tests, and additive exact equality.
- Six-world explicit trit-bit categorical obstruction with exact K, V, both original-source I, and rational strict inequality avoiding floating-point acceptance.
- 15 disjoint-sum trials combining two binary pairs, a categorical singleton and a binary singleton, across six original coordinates; physical V, all native I and R are computed from the entire source truth table, compared with independent block calculations. Global K additivity is established by Theorem A, not inferred from a sampled optimum.
- **CI: PASS** direct exact-head source-hash and fail-closed Python run [GitHub Actions #44377643358](https://github.com/d3lefts/d3lefts/actions/runs/44377643358) on source commit `fc890082de0bffeec9ba49b40deed448a48c8ee7`, custody artifact `14460649584`. This receipt predates this editorial scope note, but its mathematical checker source is unchanged. This is *not* a Lean kernel formalization of the full row theorem. The exact computations audit the author-side analytic deductions and falsifier but cannot substitute for external mathematical review.

**Prior art:** the notions of fractional certificates and disjoint-sum composition are classical. Cite Turturean, *A proof of the Aaronson–Ambainis conjecture* (arXiv:2611.09773, 2026), especially §§5 and 9.5, and related certificate/OSSS work. Our contribution here is a sourced integration of the exact tensorization operator, its closed binary-pair class, and the categorical counterexample to a tempting source-gradient reduction. Do not advertise either straightforward tensorization or two-coordinate inequalities as globally new.

**Next decision:** attack genuine overlapping three-site and categorical two-site interactions with a coupled threshold/bilinear method. Require exact primal/dual and true-law replay of any candidate before concluding a conjecture has been refuted.
