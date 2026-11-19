# NIGHTFALL: rational refutation completeness and automatic infinite-product component cover

Checkpoint: 2026-11-18. STATUS: author-side mathematical proofs and an exact finite regression checker. These results are NOT proofs of N-UE2(6), N-UE2(2), or N-UE2(2,1). No Lean kernel theorem, non-author review, or novelty-priority clearance is claimed. Based on and extends the scoped finite component-cover mechanism in PR #809 and the finite-information approximation machinery in merged PR #776 / research #805.

## Goal and exact hypotheses

Let I be an arbitrary index set (including uncountable). Each (X_i, Sigma_i, mu_i) is a probability space. Let mu be the independent product measure, and let f be an essentially bounded REAL L2 class, with centered essential radius B(f), variance V(f), and original-law resampling influences
\[
I_i(f)=\|f-\mathbb E[f\mid X_{I\setminus\{i\}}]\|_2^2,\qquad M(f)=\sup_{i\in I}I_i(f).
\]
For fixed integer d>=1, degree <=d means L2-closure of genuine Hoeffding components supported on at most d coordinates. All assertions involving a full product are understood modulo null sets. A constant f has B=V=M=0.

### Theorem A: exact rational refutation completeness (author-side)

Fix an integer k>=0 and a real C>=0. Consider the assertion for ALL such product spaces (any I), and ALL essentially bounded real f of Hoeffding degree <=d:
\[
\tag{UE2(d,k,C)}
V(f)^2\le C\, d^k\, B(f)^2\, M(f).
\]

This universal assertion is TRUE if and only if it holds for every FINITE coordinate product, each coordinate with a finite alphabet and STRICTLY POSITIVE RATIONAL probabilities, and every table of RATIONAL function values having algebraic interaction degree <=d. One can restrict probabilities and table coefficients to DYADIC rationals without changing the equivalence. Because the inequality is homogeneous of degree four in f, after choosing dyadic table values one may multiply by a common power of two and take all table values to be INTEGERS. Thus strictly failing examples, if any, have a dyadic-probability / integer-table exact normal form.

Equivalently: ANY strict counterexample on ANY independent product admits a FINITE full-support categorical RATIONAL counterexample of the SAME degree bound. For rational C (including C=1), every resulting violation has an exact integer-arithmetic certificate. This is a refutation-completeness theorem, not a claim of a finite search bound or decision procedure for truth.

#### Proof, with each transfer gate exposed

1. **Finite coordinates.** For finite F subset I, set P_F f = E[f | sigma(X_i: i in F)]. Finite-cylinder functions are L2-dense in an arbitrary probability product, so P_F f -> f in L2 along the directed finite-set net. Since P_F is a positive Markov contraction, B(P_F f)<=B(f). Independence gives coordinate residual commutation R_i P_F=P_F R_i for i in F (for i outside F the projected influence is zero), so M(P_F f)<=M(f). P_F preserves the genuine Hoeffding degree bound. Consequently V(P_F f)->V(f). If the inequality fails strictly for f, a sufficiently accurate finite projection also fails, because its right-hand side cannot increase.

2. **Finite alphabets.** For a fixed finite F, approximate the finite-product sigma algebra by finite coordinate-wise measurable partitions. The resulting product-cell conditional projections Q f converge in L2 and are again positive Markov contractions, commute with original coordinate residuals, and retain degree <=d. Thus a strict finite-coordinate violation survives for a finite table of cell averages. Discard null-probability cells; every remaining categorical letter has positive mass. The induced finite table has B no larger than before and its variance converges from below. The actual resampling influences are exactly those of the induced categorical product.

3. **Rationalizing values while preserving EXACT degree.** With one reference letter per coordinate, write the table using the law-independent anchored Mobius decomposition:
\[
g(x)=\sum_{S\subseteq [n]} h_S(x_S),\qquad
h_S(x_S)=\sum_{T\subseteq S}(-1)^{|S|-|T|}g(x_T,0_{-T})
\]
for nonreference positions in S, extending each h_S by zero if a coordinate equals its reference letter. This formula is a finite integer-coefficient change of basis. A full-support finite categorical table has product-Hoeffding degree <=d exactly when its anchored components h_S vanish for |S|>d, equivalently when it is a sum of functions of at most d coordinates. Approximate the finitely many remaining h_S coefficients by dyadic rationals. The reconstructed table stays EXACT degree <=d.

4. **Rationalizing probabilities.** Approximate every positive cell mass by a positive dyadic rational, preserving that each coordinate row sums to one. The table remains degree <=d under the perturbed law: the representation as a sum of functions supported on at most d coordinates is an algebraic, law-independent property on a full-support table. Its variance, every true conditional-variance influence, and its centered half-range B (max minus min divided by two) vary continuously with the finitely many probabilities and table values. Hence the original strict violation persists for sufficiently accurate approximants. Finally, multiply all table entries by a common power of two: the resulting table is integer-valued, retains degree<=d, and its strict violation is unchanged because V² and B²M both scale as the fourth power.

The reverse implication follows by inclusion of the finite rational class among arbitrary product laws. This establishes the equivalence for all fixed (d,k,C), independently of the truth of the conjectured inequality.

**Computability:** for fixed rational C and k, exact rational instances can be recursively enumerated and their violations checked in finitely many integer operations. Therefore falsity of the universal claim is semi-decidable by a complete unbounded enumeration. There is NO computable size bound established here and NO assertion that truth is decidable.

### Theorem B: automatic range summability and infinite component-cover influence (author-side)

Let f be ANY real essentially bounded L2 function on an arbitrary independent product; no degree bound is necessary. Its finite-support orthogonal Hoeffding expansion is
\[
f=\mathbb Ef+\sum_{\varnothing\ne S\subset_{\rm fin} I} f_S,\quad
W_S=\|f_S\|_2^2,\quad
V=\sum_S W_S,\quad I_i(f)=\sum_{S\ni i} W_S .
\]
Because \(\sum_S W_S=V<\infty\), only COUNTABLY many W_S are nonzero, even when I is uncountable. Make these active nonempty supports into a hypergraph; let C_a denote its (at most countably many) pairwise-disjoint connected coordinate components. Define
\[
g_a=\sum_{S\subset C_a}f_S
=\mathbb E[f\mid\sigma(X_i:i\in C_a)]-\mathbb Ef,\quad
B_a=B(g_a),\quad V_a=\operatorname{Var}(g_a),\quad M_a=\sup_{i\in C_a} I_i(g_a).
\]

**Automatic summability lemma.** For ANY finite set A of components,
\[
\mathbb E[f\mid\sigma(X_i:i\in\cup_{a\in A}C_a)]
=\mathbb Ef+\sum_{a\in A}g_a
\]
in L2. The conditional expectation has centered radius at most B(f). The g_a's are independent because their coordinate supports are disjoint. For finitely many independent bounded real summands their centered essential radii ADD EXACTLY (positive-probability near-extremal events multiply). Hence
\[
\sum_{a\in A}B_a\le B(f)\quad\text{for every finite A},\qquad
\boxed{\sum_a B_a\le B(f).}
\]
In fact this implies the stronger EXACT identity
\[
\boxed{\quad B(f)=\sum_a B_a.\quad}
\]
**Additional proof:** Every g_a is mean-zero, so 0 lies between its essential infimum and supremum. Therefore \(\|g_a\|_\infty\le2B_a\). The automatically summable radii imply that \(\sum_a g_a\) converges absolutely in essential sup norm, and hence in L2. Its L2 limit is \(f-\mathbb Ef\) by the Hoeffding decomposition, so this sum equals f a.e. Subadditivity and continuity of centered radius in L-infinity give \(B(f)\le\sum_aB_a\), reversing the preceding inequality. For every finite component set A this also certifies the a.e. tail bound
\[
\left\|f-\mathbb Ef-\sum_{a\in A}g_a\right\|_\infty
\le 2\sum_{a\notin A}B_a .
\]
Thus the previous assumption sum B_a < infinity in the explicit block-summable infinite extension is AUTOMATIC, with exact range equality and essential-uniform convergence, for bounded f whose active Hoeffding interactions split into independent components. No countability/atom-floor assumption on I or its factors is needed.

Define the (possibly infinite) fractional vertex-cover value
\[
\tau_a=\inf\left\{\sum_{i\in C_a}w_i:
\, w_i\ge0,\ \sum_{i\in S}w_i\ge1\ \forall S\text{ with }W_S>0,\ S\subset C_a\right\},
\]
where all weight sums are nonnegative extended sums. Let \(\Theta=\sup_a\tau_a\). If \(\Theta<\infty\), then source ANOVA orthogonality and Tonelli give, for every admissible cover,
\[
V_a=\sum_{S\subset C_a}W_S
\le\sum_{i\in C_a}w_i\sum_{S\ni i}W_S
=\sum_iw_i I_i(g_a)\le (\sum_i w_i)M_a.
\]
Taking the infimum yields \(V_a\le\tau_aM_a\). Separately, Popoviciu gives \(V_a\le B_a^2\). Geometric mean followed by automatic summability gives the **local profile and global inequalities**
\[
\boxed{\quad V(f)\le\sum_a B_a\sqrt{\tau_a M_a}
\le B(f)\sqrt{\Theta\,M(f)} \quad}
\]
and thus
\[
\boxed{\quad V(f)^2\le\Theta(f)\,B(f)^2\,M(f).\quad}\tag{ICFCI}
\]
No degree restriction, countable index, discrete marginal, or prior range-summability assumption is required. If Theta is infinite, the displayed global bound is vacuous; the local bound may still have meaning when summable.

**Sharpness of the local profile:** on countably many independent fair signs \(\epsilon_j\), \(f=\sum_{j\ge1}2^{-j}\epsilon_j\). Then \(B=1\), each component has B_j=2^-j, V_j=M_j=4^-j, tau_j=1, and every term obeys \(V_j=B_j\sqrt{\tau_jM_j}\) with equality. Thus \(V=\sum B_j\sqrt{\tau_jM_j}=1/3\) exactly. A second nontrivial sharp example uses independent 4-sign Hadamard quadratic blocks h_j=ac+ad+bc-bd, scaled by 2^-j: V_j=4*4^-j, B_j=2*2^-j, M_j=2*4^-j, tau_j=2, again local-profile equality component by component.

### Theorem C: exact reduction to a finite rational CONNECTED high-cover falsifier

Suppose N-UE2(2,1) is FALSE on any independent product, possibly with an uncountable index set. By Theorem A, obtain a strictly failing finite rational full-support degree<=d categorical table. Partition its active Hoeffding hypergraph into connected components. If every component g_a satisfied the sharp inequality, then
\[
V=\sum_a V_a\le d\sum_a B_a\sqrt{M_a}\le dB\sqrt{M},
\]
contradicting the witness. Hence SOME connected component is itself a strictly failing rational table of degree <=d. Its canonical ANOVA coefficients are rational because the table and source cell probabilities are rational.

The finite fractional-cover inequality from PR #809 (or Theorem B) then forces its connected support to satisfy
\[
\boxed{\tau^*(\mathcal H(g_a))>d^2.}
\]

**Exact search-size consequences:** If all nonzero ANOVA supports have size >=r, assigning weight 1/r to every active coordinate is feasible. Therefore tau* <= n/r on a component with n active coordinates. A hypothetical N-UE2(2,1) counterexample whose every component is r-homogeneous must have
\[
\boxed{n>r d^2.}
\]
In particular, a connected pure-quadratic (r=2,d=2) counterexample needs AT LEAST 9 coordinates; a connected pure-cubic (r=3,d=3) counterexample needs AT LEAST 28 coordinates. Mixed quadratic degree<=2 can fail only on a component of at least 5 coordinates (r=1). These are NECESSARY geometric conditions, not existence claims.

This unifies finite-to-infinite transfer, rational exact-checking, and component-cover localization. It tells the parallel instances exactly where an unrestricted counterexample must lie. The remaining hard problem is still the source-consistent cubic mean-coupled quadratic gate of PRs #799/#803 or a genuinely new global influence operator.

## Exact certificate checker

The stdlib-only source file check_ue2_rational_falsification.py reads finite categorical rational probabilities and lexicographically ordered rational function values. It checks:
- full-support product mass and actual half essential range;
- the exact law-independent anchored Mobius degree condition;
- original-source conditional-variance influences TWO independent ways, by conditional second moment and by two-replica squared differences;
- exact rational V^2 versus C d^k B^2 M.
A true strict rational violation is a genuine counterexample to the *specified coefficient*. Passing one table is never a universal proof. Included negative control: the four-sign Hadamard quadratic violates the FALSE stronger coefficient C=1/4 (while respecting C=1). The example shows the checker detects genuine known violations and rejects higher-degree contamination.

Run: python3 research/nightfall/flagship-influence/check_ue2_rational_falsification.py

No counterexample to the actual coefficient-one N-UE2(2,1) was found in the local bounded searches conducted during this turn (fair/biased degree-2 and degree-3 polynomial starts, up to 10 bits); those exploratory searches do not certify the conjecture and did not exhaust the rational space.

## Independent audit tasks and limits

A: independently reconstruct arbitrary-index finite-support ANOVA via finite-cylinder density, checking completely general measurable coordinate sigma-fields.
B: attack the positive-probability extremal-event argument for additivity of essential oscillation, conditional projections, and the countable-support reduction.
C: check law-independent anchored degree across all finite alphabets (including nonbinary) and under dyadic perturbation.
D: independently check source-residual commutation for finite-label projections, exact categorical influence formula and certificate parser.
E: investigate prior-art status for this conditional rational-completeness lemma and componentwise infinite transfer; no originality claim is made.

No axiom-free Lean certification or non-author review was completed. The strongest universal conjecture N-UE2(2,1) remains OPEN. Theorems A-C are author-side derivations with reproducible exact finite controls, not externally certified landmark theorems.
