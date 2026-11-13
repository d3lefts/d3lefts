# Finite-product quadratic influence from genuine source sections
## Author-side theorem and proof, 13 November 2026 — version 0.2

**Status:** complete *paper-level* argument in the finite discrete setting, conditional on the previously established source matching, sharp section and fourth-moment lemmas with their stated scope. Individual Lean certificates do **not** constitute a compiled end-to-end theorem. The new source-level variance proof is being checked separately in PR #428; a terminal declaration from only the source assumptions has not passed. No originality or independent-human-review claim.

### Theorem FQ2 (precise finite source scope)

Let (I) be a finite coordinate set (possibly empty). For each (i\in I), let (A_i) be a nonempty finite alphabet with a nonnegative normalized probability law (\mu_i) (zero-mass symbols are permitted). Put (\mu=\bigotimes_{i\in I}\mu_i). Let (f:\prod_i A_i\to\mathbb R) be of **Hoeffding/Efron–Stein degree at most two** and (|f|\le B) almost surely, with (B\ge0).

Define
[
V=\operatorname{Var}_{\mu}(f),\qquad
I_i(f)=\mathbb E_{X_{-i}}\operatorname{Var}_{X_i\sim\mu_i}(f(X)),\qquad
M=\max_{i\in I} I_i(f),
]
with (M:=0) when (I=\varnothing). Then
[
\boxed{V\le16(1+\sqrt3)B\sqrt M},\qquad
\boxed{V^2\le256(1+\sqrt3)^2B^2M}.
]
This is the **weaker constant**, not the v5 proposed (C_2\approx1228.356). Neither priority nor a terminal Lean certification is asserted.

### 0. Source and support normalization

Discard symbols of (\mu_i)-mass zero, yielding finite positive supports (A_i^+). All product states in (\prod_i A_i^+) have positive mass; the a.s. bound becomes pointwise there. Conditional expectations and every ANOVA component on supported states, plus (V) and (I_i), are unchanged. In the all-source common-alphabet implementation, different positive-support alphabets can be transported by tagging (A=\coprod_i A_i^+): let the (i)-th law charge only tag (i), project symbols back via a supported default otherwise, and pull back (f) through the coordinatewise projections. The bound and degree survive this transport. **The dependent-type Lean transport has not compiled.**

For (B=0), (f=0) on support and (V=0). Otherwise scale by (1/B), preserving degree, variance and influences with degree-two homogeneity. The compiled sharp section theorem currently has the normalized (|f|\le1) form; its use at general (B) is by this scaling.

### 1. Source-derived matching budget

Write the canonical degree-two ANOVA decomposition
[
f(X)=m+\sum_i u_i(X_i)+\sum_{\{i,j\}\in E}K_{ij}(X_i,X_j),
]
where (E) contains each unordered nonloop pair **exactly once**. Each pair kernel is centered separately in each coordinate.

For an edge (e=\{i,j\}), let (w_e=\max_{a\in A_i^+,b\in A_j^+}|K_{ij}(a,b)|). By separate centering, an oriented four-corner rectangle of the *actual source* (f) exists whose value (\Delta_e\ge w_e): take a maximum-absolute cell, represent its signed value as the mean of its oriented mixed rectangles, and choose a rectangle dominating that mean. For any matching (S\subseteq E), independently choose parity couplings on the distinct matched coordinate blocks and fix unmatched coordinates at supported base symbols. Quadratic source rectangles are invariant under background changes. The even/odd expectation difference is therefore
[
\mathbb E_{\rm even} f-\mathbb E_{\rm odd} f
   ={1\over2}\sum_{e\in S}\Delta_e.
]
Each expectation lies in ([-B,B]); hence (\sum_{e\in S} w_e\le4B).

Run the exact maximum-first greedy matching on the simple weighted graph (E). If (S) is its selected matching, define (c_i\ge0) as the sum of weights of selected edges incident to (i). Then
[
\sum_i c_i=2\sum_{e\in S}w_e\le8B,
\qquad w_{\{i,j\}}\le\max(c_i,c_j).
]
Assign each unordered edge to one endpoint of maximal cost. For each owner (i), let (J_i\subseteq I\setminus\{i\}) be its set of assigned neighbors. A simple unordered graph ensures that distinct owned edges have distinct neighbors; each edge is owned **exactly once**. Thus for (j\in J_i), (|K_{ij}(a,b)|\le c_i) on the supported alphabets.

**Existing source boundaries:** the arbitrary embedded matching and source 4B bound occur in `ActualESGeneralMatching.lean`, strict run 43482674865; `ActualESMatchingMass.lean` and `ActualESGreedyCover.lean` connect to graph matching (their current receipt must be checked on the exact integration commit); `ActualESGreedyOwnership.lean` proves the algebraic edge partition and distinct-neighbor property. No matching mass or vertex cover is an input to the claimed source theorem.

### 2. True source-to-energy identity

Let (H_i=L^2(A_i^+,\mu_i)), including zero-weight coordinates if still using the unreduced common alphabet, and write (\|\cdot\|_i) for its Hilbert seminorm. Set
[
P_i(a,X)=\sum_{j\ne i}K_{ij}(a,X_j),\qquad
Y_i(a,X)=\sum_{j\in J_i}K_{ij}(a,X_j).
]
Define (Z_{ij}(X_j)\in H_i) by (Z_{ij}(X_j)(a)=K_{ij}(a,X_j)) for (j\in J_i). These are independently distributed, centered, and (\|Z_{ij}(b)\|_i\le c_i). No coordinate is repeated.

Because the variables (X_j) are the **original independent product coordinates** and each omitted pair kernel is centered in its neighbor,
[
\boxed{\mathbb E[P_i\mid X_{J_i}]=Y_i}
]
as an equality of finite vectors, componentwise at each (a\in A_i^+). Thus the conditional projection is not an analogy to synthetic samples. The independence and mean-zero property give
[
s_i:=\mathbb E\|Y_i\|_i^2
=\sum_{j\in J_i}\|K_{ij}\|_{L^2(\mu_i\otimes\mu_j)}^2.
]
Source orthogonality yields
[
I_i(f)=\|u_i\|_i^2+
\sum_{j\ne i}\|K_{ij}\|_2^2,
\qquad
V=\sum_i\|u_i\|_i^2+
\sum_{e\in E}\|K_e\|_2^2.
]
Consequently, (s_i\le I_i(f)\le M), (t_i:=\|u_i\|_i\le\sqrt M), and
[
\boxed{\sum_i s_i=\sum_{e\in E}\|K_e\|_2^2}.
]
The final equality uses **exactly-once greedy ownership**, not simply a matching of selected edges.

### 3. Apply the previously proved fourth moment endpoint

Let (z_i=\mathbb E\|Y_i\|_i). The fourth-moment calculation for centered independent Hilbert increments of norm at most (c_i) gives
[
\mathbb E\|Y_i\|_i^4\le c_i^2s_i+3s_i^2.
]
By weighted interpolation,
(s_i^3\le z_i^2\mathbb E\|Y_i\|_i^4).
For (s_i>0), divide by (s_i) and use (s_i\le M); for (s_i=0), the endpoint is immediate:
[
\boxed{s_i\le z_i(c_i+\sqrt{3M})}.
]
The genuine-neighbor law must be identified with the independent-input law in the existing `actual_product_fourth_endpoint` interface. The older `actual_source_pair_fourth_endpoint` accepts a potentially repeating map (\mathbb N\to I); that theorem cannot be invoked by merely renaming repeated neighbor inputs.

### 4. The one sufficient source section budget

Define the **actual centered coordinate section**
[
A_i(a,X_{-i})=
f(X_{-i},a)-\mathbb E_{b\sim\mu_i}f(X_{-i},b)
=u_i(a)+P_i(a,X).
]
The compiled sharp finite source-section theorem `Q2AllDimensions.actual_degree_two_source_section_budget_eight_all` gives, for every supported (X),
[
\sum_i\|A_i(\cdot,X_{-i})\|_i\le8B.
]
Hence (\sum_i\mathbb E\|A_i\|_i\le8B).

Centering gives (\mathbb E A_i=u_i), so Hilbert Jensen yields
[
\sum_i t_i=\sum_i\|u_i\|_i
\le\sum_i\mathbb E\|A_i\|_i\le8B.
]
For each (i), true conditional Jensen from the projection in §2 yields
[
z_i\le\mathbb E\|P_i\|_i
\le\mathbb E\|A_i\|_i+t_i.
]
Therefore
[
\boxed{\sum_i z_i\le16B},\qquad
\boxed{z_i\le\sqrt{s_i}\le\sqrt M}.
]
Neither an additive 2(1+sqrt2)B lemma nor a separate 16B full-range source theorem is needed for this weaker constant.

### 5. Final source variance closure

By §2, §3, §4 and (\sum_i c_i\le8B),
[
\begin{aligned}
V&=\sum_i t_i^2+\sum_i s_i\\
&\le\sqrt M\sum_i t_i+
   \sum_i z_ic_i+\sqrt{3M}\sum_i z_i\\
&\le8B\sqrt M+\sqrt M\sum_i c_i+
  16B\sqrt{3M}\\
&\le16B\sqrt M+16B\sqrt{3M}\\
&=16(1+\sqrt3)B\sqrt M.
\end{aligned}
]
All nonnegative factors and the (M=0) boundary are explicit. Squaring proves Theorem FQ2.

### Exact evidence boundary and remaining formal obligations

The displayed mathematical proof is a **source-based analytic composition** of previously derived component theorems. It is not an independently verified new theorem and is not Lean-compiled as a single declaration. The remaining machine obligations are: 
1. Compile the original-source ANOVA variance and coordinate influence energy equalities on the same pinned compiler. Check zero-dimension and two-point support cases.
2. Build the genuine owned-neighbor-to-`moment2` identification (a bijection between a finite neighbor product and its restriction of the original source product). Do not assume the desired identity as a parameter.
3. Link the graph weights to the canonical (\{i,j\}) simple graph and make the generated 8B greedy costs the *same* costs used in every independent Hilbert increment.
4. Compile the scaled sharp 8B source-section theorem from `ESDegreeLE` for general (B\ge0), and the source conditional Jensen/budget summation.
5. Print and audit one theorem with exactly `p, hp, hp1, f, B, hB, hf, hdegree` and the (V^2\le256(1+\sqrt3)^2B^2 M) conclusion. **No extra amplitude, energy, matching, quadratization, oracle, or section hypotheses are acceptable.**
6. Only then consider heterogeneous-type and measurable-product formal lifts and independent prior-art clearance.

Source provenance (all draft unless otherwise stated): PR #422 strict section run 43360916112; PR #424 matching/endpoint run 43482674865; PR #425 finite true-source projections and orthogonality (check corresponding CI); PR #428 integrated source variance declaration, current CI pending.

_Attribution_: research programme NIGHTFALL/PHASESHIFT, applicant Devin J. Wright, extensive AI-assisted construction and critique. No independent human specialist review is asserted.
