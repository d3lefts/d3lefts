# NIGHTFALL — Dependent cubic contraction hierarchy

**v0.1, 2026-11-17.** Analytic calculation and exact finite-law replay. A standalone Lean scalar certificate is proposed; **no Lean proof of the dependent-law Poincare bridge, no external review, and no novelty claim**. Does not solve unrestricted Q3 exponent two.

## Contract and prior art

Goal: repair the false, dimension-uniform comparison between ordinary degree-three physical-spin variance under a dependent Ising law and variance under fair product measure. Represent the missing operator through expectations of algebraic derivatives instead of using the noncommuting native residual words as a degree grading.

Checked literature: Diakonikolas–Kane–Stewart–Sun (2021), arXiv:2102.02171, Theorem 4.2 and Lemma 4.1 (degree-two Ising anti-concentration/concentration); Götze–Sambale–Sinulis, arXiv:1801.06348 (higher-order concentration under weak dependence); Adamczak–Wolff, arXiv:1304.1826 (derivative inequalities under Poincare); Adamczak–Kotowski–Polaczyk–Strzelecki, arXiv:1809.03187 (Ising polynomial multilevel bounds). Iterated Poincare and derivative-expectation mechanisms are classical. No novelty or priority established.

## Theorem: all-degree contraction hierarchy

Let nu be any strictly positive finite binary law and let actual-law single-site conditional influences be I_i(g)=E Var(g|X_-i). Assume for every function g,

  Var_nu(g) <= A * sum_i I_i(g), A>=0.

Let D_i g(x_-i)=[g(x_i=+1)-g(x_i=-1)]/2. For a multilinear f of algebraic degree at most d, let D_T=product_{i in T}D_i (commuting physical derivatives), and

  M_k(f)=k! * sum_{T subset [n], |T|=k} (E_nu D_T f)^2,
  V_k(f)=k! * sum_{T subset [n], |T|=k} Var_nu(D_T f).

Since conditional variance of Xi is w_i<=1,
  I_i(g) = E_nu[w_i (D_i g)^2] <= E_nu[(D_i g)^2].
Apply the actual-law Poincare inequality to every D_T f and use E h²=(E h)²+Var h. Counting k! ordered tuples yields

  V_k <= A*(M_{k+1}+V_{k+1}), k<d; V_d=0.

Therefore:

  Var_nu(f) <= sum_{k=1}^d A^k M_k(f).  (HIERARCHY)

The proof applies to arbitrary full-support binary laws with a stated Poincare constant; no Ising, product, commutation-of-native-residuals or global density-ratio assumption. The proposed Lean file proves only the scalar finite telescoping from hstep and hterminal; it does NOT establish those hypotheses from original-source probability operators.

## Cubic specialization / exact contraction mechanism

Write
f=c+sum_i a_i Xi+sum_{i<j} b_ij XiXj+sum_{i<j<k} c_ijk XiXjXk,
and assume E Xi=0. Let C_jk=E XjXk. Then

  E D_i f=a_i+sum_{j<k, j,k != i} c_ijk C_jk,
  E D_i D_j f=b_ij,
  E D_i D_j D_k f=c_ijk.

Thus

  Var_nu(f) <= A * sum_i (a_i+sum_{j<k} c_ijk C_jk)^2
             +2 A² * sum_{i<j} b_ij²
             +6 A³ * sum_{i<j<k} c_ijk².

Choosing a_i=-sum_{j<k} c_ijk C_jk cancels the entire mean-first-derivative contraction. For pure cubic + this linear correction, M1=M2=0 and

  Var_nu(f_corrected) <= 6 A³ sum_{i<j<k} c_ijk².

That is an exact dimension-free variance control on a law-adapted contraction-centered cubic subspace, not a general cubic variance-influence inequality; the correction can increase the function's norm and change its reference variance.

## Connected-chain failure and repair

On the connected zero-field (k+2)-spin Ising chain X0,Y1,...,Y(k+1), every edge correlation 0<r<1/2, take bounded cubic

  f_k=(X0/k)*sum_{j=1}^k Yj Y(j+1).

Independent Ising edge-bond factors give

  Var_nu(f_k)=r²+(1-r²)/k, Var_uniform(f_k)=1/k,
  Var_nu/Var_uniform=1+(k-1)r² -> infinity.

The contracted mean gradients detect the rank-one coherent contribution. Correcting all linear coefficients via a_i=-E_nu D_i f_k produces E_nu D_i f_corrected=0 for every site. With the classical Dobrushin Poincare A=(1-2r)^-1 and zero spin means, HIERARCHY gives

  Var_nu(f_corrected)<=6 A³/k.

The exact rational checker tests r=1/3 and k=2,3,4,5,6 using full joint distribution and original conditional influences. This mechanism is a representation correction, not a new cubically sharp coefficient or an unrestricted Q3 theorem.

## Reproducibility, verification and limits

Code: scripts/check_cubic_contraction_hierarchy_exact.py; scalar Lean source: research/nightfall/formalization/observability/CubicContractionHierarchyScalar.lean. The Python checker separately verifies the true-law Poincare inequality for every derivative of each tested polynomial, the k! counting, the complete hierarchy, the chain variance ratio, contraction cancellation and corrected bound. It is finite-instance evidence, not an all-n certificate.

Next fail-closed gates: (1) run exact-head pinned Lean for scalar recurrence and inspect named axioms; (2) independent proof of actual conditional-variance identity and ordered tuple counting; (3) source-level Lean law-to-recurrence theorem with no externally supplied recurrence; (4) compare exact centered cubic class against Götze–Sambale–Sinulis and Adamczak et al.; (5) only then attempt a boundedness/influence inequality for the centered cubic sector. Preserve this operator even if historical novelty fails.

Mechanism graph: dependent cubic covariance obstruction -> physical derivatives -> Poincare derivative recursion -> contraction-mean energy -> law-adapted Wick cancellation -> exact checker -> scalar Lean certificate -> unproved original-law Lean bridge -> possible Q3 transfer.


## v0.2: a second obstruction, after the Wick correction

The centered cubic sector fixes the **variance** comparison but does not make the **native influence** comparable to fair-product influence. This is an exact obstruction on the same connected Ising chain.

Let f_k^circle be the pure cubic above plus the full law-adapted linear correction a_i=-E_nu D_i f_k. The root derivative is

  D_{X0} f_k^circle = (1/k) sum_{j=1}^k Y_jY_{j+1} - r.

The conditional variance of the endpoint spin X0 given all other spins is exactly 1-r². The independent edge-bond representation yields

  I_{nu,X0}(f_k^circle) = (1-r²)²/k.

Under the uniform **independent fair-spin reference law mu**, the same physical polynomial has

  I_{mu,X0}(f_k^circle) = r² + 1/k.

Therefore

  I_{nu,X0}(f_k^circle) / I_{mu,X0}(f_k^circle)
    = (1-r²)²/(1+k*r²) -> 0

at every fixed 0<r<1/2, while the dependency matrix still has Dobrushin alpha=2r<1. The correction's supnorm remains bounded independently of k: the original cubic is bounded by 1, a_0=-r, and the absolute sum of other correction coefficients is bounded by a convergent geometric series times 1/k.

**Consequence:** the naive proposal "Wick-center the cubic, compare its variance to the fair-product variance, and then replace fair-product influences by true-law influences with a uniform factor" is INVALID. Variance correction and influence correction are distinct gates. A useful dependent-cubic proof must build a genuinely law-adapted derivative/influence reference (or avoid product-reference influence transfer entirely), not merely subtract mean contractions. This is a stronger, mechanistic reason for the open problem than numerical coefficient stalls. The exact Fraction checker now independently verifies both native root influence and fair root influence over k=2..6.

This is a classical elementary counterexample, not a claim of a new field-wide theorem or an unrestricted Q3 lower bound. Keep previous version statements and their limitations.


## v0.3: abstract operator-level Lean interface (separate from native-law theorem)

New source: research/nightfall/formalization/observability/CubicContractionOperator.lean.

For any type F of observables, finite index type of operators D_i:F→F, functions mean, variance, second:F→R and A≥0, suppose:

  second(g)=mean(g)^2+variance(g) for all g;
  variance(g)≤A*sum_i second(D_i g) for all g.

Define recursively DegreeZero(0,g) := variance(g)=0 and DegreeZero(k+1,g) := every D_i g satisfies DegreeZero(k). Define Cost(0,g)=0 and Cost(k+1,g)=A sum_i [mean(D_i g)^2+Cost(k,D_i g)].

The new Lean theorem variance_le_derivative_cost proves, by induction on k and without any supplied recurrence lemma,

  DegreeZero(k,g) => variance(g)≤Cost(k,g).

This is a genuine all-degree functional operator theorem for potentially noncommuting D_i, with the finite scalar telescoping theorem as a related alternative. **The law-level claim remains unproved in Lean:** a later finite binary specialization must prove from the original p(x) the actual Poincare-gradient comparison and that every length-d physical derivative of a degree-d polynomial has zero variance. The original-law two-atom variance/fiber comparison IS separately Lean-checked in CubicContractionBinarySource.lean, but the full high-level law application has not yet compiled.

The abstract operator proof is subject to exact current-head pinned Lean compilation and strict standard-axiom checks before any promotion. It cannot be cited as a kernel proof of unrestricted Q3, and its general iterative-Poincare character likely has strong preexisting literature antecedents.


## v0.4: dependency-corrected cubic top-cover exponent two — positive transfer

**Analytic theorem, conditional on an explicit established quadratic-coercivity premise.** This is a substantial, narrowly scoped positive dependent-law Q3 result, NOT unrestricted cubic exponent two and NOT original-priority certified.

Let nu be any full-support **zero-mean** finite binary law satisfying:
1. (P) For all g, Var_nu(g) <= A sum_i I_i^nu(g), A>0.
2. (U) Native single-site conditional spin variance w_i(x_-i)>=v>0.
3. (QC) **Quadratic anti-concentration**: for every coefficients b_jk, Var_nu(sum_{j<k} b_jk XjXk) >= beta sum_{j<k} b_jk² with beta>0.

Let c_ijk be an arbitrary finite symmetric triple coefficient tensor indexed by unordered three-distinct-site subsets. Let H be a set of coordinates meeting EVERY triple with nonzero c_ijk; let h=|H|. Define the law-adapted pure-cubic plus linear polynomial

  f°(x)=sum_{i<j<k} c_ijk XiXjXk
         -sum_i Xi * [sum_{j<k, j,k != i} c_ijk E_nu(XjXk)].

This is precisely the mean-physical-gradient contraction correction: E_nu D_i f°=0. Under zero means E Xi=0, the second derivative expectations also vanish (D_iD_j f° is linear in remaining spins). The exact all-degree Poincare hierarchy then gives

  Var_nu(f°) <= 6 A³ * sum_{i<j<k} c_ijk².      (1)

For each original physical coordinate i, D_i f° = sum_{j<k} c_ijk (XjXk-E_nu XjXk). By native single-site conditional variance,

  I_i^nu(f°)=E[w_i(D_i f°)^2]
            >= v Var_nu(D_i f°)
            >= v beta sum_{j<k} c_ijk².         (2)

Summing (2) over the top-degree vertex cover H (every cubic coefficient appears in >=1 gradient at an i∈H) gives

  sum_{i<j<k} c_ijk² <= h/(v beta) * max_i I_i^nu(f°).

Combine with (1):

  **Var_nu(f°) <= [6 A³ h/(v beta)] * max_i I_i^nu(f°).**

If additionally |f°|<=B pointwise (automatically some finite B), Var_nu(f°)<=B², yielding the requested exponent-two form

  **Var_nu(f°)² <= [6 A³ h/(v beta)] * B² * max_i I_i^nu(f°).**

This is dimension-free for families where A, v, beta and h stay bounded. It handles genuinely dependent and frustrated laws under those assumptions. Unlike an attempt to pass through fair-product influences, it uses the **native original-law gradient coercivity**, bypassing the exact counterexample in v0.2.

**Established Ising input:** Diakonikolas–Kane–Stewart–Sun, COLT 2021, arXiv:2102.02171 Theorem 4.2 proves Var[(X−z)^T Q (X−z)] >= c(M,alpha)*||Q||_F² for (M,alpha)-bounded Ising models, including signed couplings. For zero external fields z=0, choose Q_jk=b_jk/2 on distinct pairs, Q_jj=0. Then beta=c(M,0)/2 (or any smaller strictly positive uniform constant). The conventional Dobrushin Poincare bound supplies A=(1-delta)^−1 when delta=max_i sum_j tanh|J_ij|<1, and local finite interactions supply v>=sech²(max_i sum_j |J_ij|). This gives a dimension-free **signed/loopy Ising** corollary for uniformly high-temp coupling, bounded top-degree cover, and the explicit *contraction-centered pure-cubic+linear class*. The coefficient is NOT sharp, c(M,0) is externally provided and not presently a numerical Lean constant.

**Exact finite checker:** scripts/check_cubic_centered_cover_exact.py independently enumerates full signed, frustrated finite laws (n=4,5,6), forms the **complete** quadratic-covariance Gram, finds an exact rational beta with full LDL positive-definiteness (not random witnesses), checks native original-law influence for every site, centered derivatives, variance inequality and the squared-variance bound. This checks finite instances; it does not prove the external universal beta theorem, general Poincare, or a Lean terminal.

**Publication/novelty gate:** This follows by composing classical Poincare iteration and DKSS quadratic anti-concentration, so novelty is unresolved and likely largely classical. It is valuable as a **reusable theorem interface** and as a controlled dependent-cubic transfer; do not label it a globally new influence theorem, a source-only fully Lean-certified theorem, or a proof of unrestricted cubic exponent two. External theorem-level review and a true-law Lean composition are still required. Score against competing lower-degree decompositions and DKSS direct corollaries before promotion.
