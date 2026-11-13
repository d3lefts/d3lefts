# Q2 — strongest finite original-source analytic theorem and independent falsification ledger
**Version:** 2026-11-13 / A2 (analytical review pivot). **Status:** complete author-side analytic proof reconstructed; internal adversarial/falsification audit performed. Not an external non-author referee review, formal end-to-end Lean proof, historical priority proof, or publication approval.

## Objective and scope

Prove an **atom/alphabet/dimension-independent** variance-squared bound for arbitrary independent, finite, *heterogeneous* coordinate alphabets. Use only genuine source hypotheses. Identify the precise structural mechanism that could generalize to other influence/observability problems.

Let I be a nonempty finite coordinate set, each A_i a nonempty finite alphabet, and p_i(a) ≥0, Σ_a p_i(a)=1 (zero weights allowed). Let f:Π_i A_i→ℝ have genuine pointwise Hoeffding degree at most two and |f(x)|≤B for **all source words**, B≥0. Let X~⊗p_i, V=Var(f(X)), I_i(f)=E Var(f|X_{-i})=(1/2)E(f(X)−f(X^{(i)}))², and M=max_i I_i(f).

**Strongest supported analytic claim** (earlier in the merged v8 manuscript; stronger than the simpler 1910.81 Lean-closure target):

    V ≤ (10+2√2)(1+√3) B √M
    V² ≤ K₂ B² M
    K₂=(10+2√2)²(1+√3)²
      =432+160√2+216√3+80√6
      ≈1228.356323837226951...

This is an analytic theorem draft, **not** a claim that the theorem was independently refereed or new relative to all historical literature.

## Derivation from original source — no supplied section or moment budgets

1. Define canonical Hoeffding components by the actual p-product conditional expectations. Degree ≤2 gives **pointwise** f=m+Σ_i h_i(X_i)+Σ_{i<j}h_ij(X_i,X_j), with centered h_i and separately centered h_ij. Orthogonality under the *actual source* yields

    V=Σ_i A_i²+Σ_{i<j}E_ij,
    I_i=A_i²+Σ_{j≠i}E_ij,

   where A_i²=E_{p_i} h_i² and E_ij=E_{p_i⊗p_j}h_ij². The centered *original* section U_i(a;x_-i)=f(x_-i,a)−Σ_b p_i(b) f(x_-i,b) equals h_i(a)+Σ_{j≠i}h_ij(a,x_j), pointwise. This is not a supplied ANOVA table.

2. **Source sharp 8B section budget.** Fix a complete source x. For every coordinate choose its maximizing and minimizing replacements. Independently switch each coordinate to a chosen max replacement with probability t. The expected source f becomes a quadratic polynomial q_+(t) bounded by B on [0,1], with derivative at zero the total nonnegative gains. Exact degree-two formula q'(0)=−3q(0)+4q(1/2)−q(1) implies each total max gain and min loss ≤8B. Therefore Σ_i osc_a f(x_-i,a)≤16B. Weighted Popoviciu, valid even with zero masses, yields pointwise Σ_i ||U_i(·;x_-i)||_{L²(p_i)}≤8B. Hence u_i=E_{X_-i}||U_i|| obeys Σ_i u_i≤8B.

3. **Stronger source additive budget.** Let T_t=Π_i(E_i+t(Id−E_i)), which is a Markov contraction for t∈[0,1] and acts by t^k on genuine degree-k Hoeffding terms. For x,y, r(t)=T_tf(x)−T_tf(y)=ut+vt² satisfies |r(t)|≤2B. With s=√2−1, u=[r(s)−s²r(1)]/[s(1−s)], giving |u|≤4(1+√2)B. Since u=Σ_i (h_i(x_i)−h_i(y_i)) and the source alphabet is a full finite Cartesian product, osc(Σ h_i)=Σ osc(h_i). Weighted Popoviciu gives Σ_i A_i≤ **αB**, α=2(1+√2). This replaces the weaker additive-budget-through-Jensen route and changes K from ~1910.81 to ~1228.36.

4. **Source matching budget.** Define w_ij=max_{a,b}|h_ij(a,b)|. For any matching R of unordered coordinate pairs, separately centered h_ij permits an oriented four-corner rectangle Δ_ij≥w_ij. Give each matching pair either the even coupling [(a,b),(a',b')] or odd coupling [(a,b'),(a',b)] with probabilities 1/2. Each coordinate marginal is unchanged; because R is a matching, products of those couplings retain identical cross-block expectations of *all other* singleton and pair terms, even if the remaining graph is dense. The two expected values of the original bounded f differ by (1/2)Σ_{e∈R}Δ_e≤2B. Therefore Σ_{e∈R}w_e≤4B. No abstract external matching-mass premise enters.

5. **Generated greedy costs and unique owners.** Traverse all unordered pairs in decreasing w; retain each edge disjoint from previously retained ones. At both endpoints of a retained edge put cost equal to its weight; zero elsewhere. Any unretained pair shares an endpoint with an earlier edge of ≥ its weight. Consequently Σ_i c_i=2Σ_{retained}w≤8B and w_ij≤max(c_i,c_j). Assign each original unordered pair once to its higher-cost endpoint, with fixed tie rule. For each owner i, its owned neighbors N_i are distinct **original coordinate labels** (not independent synthetic duplicates). Owner neighborhoods for *different* owners need not be disjoint.

6. **Genuine owned energy and Hilbert fourth moment.** At fixed owner i define H_i(a;X_-i)=Σ_{j∈N_i}h_ij(a,X_j), s_i=EΣ_a p_i(a)H_i(a)^2, z_i=E sqrt(Σ_a p_i(a)H_i(a)^2). The individual vectors Y_ij=(sqrt(p_i(a))h_ij(a,X_j))_a are functions of distinct original independent coordinates X_j, separately centered in j, and bounded in norm by w_ij≤c_i. Independence eliminates second-moment cross terms, so s_i=Σ_{j∈N_i}E_ij. Every original pair has one owner: Σ_i s_i=Σ_{i<j}E_ij; since each owned pair contains i and is a nonnegative term of its true influence, s_i≤I_i≤M.

   Put v_j=E||Y_ij||². Expanding the original-source Hilbert fourth moment and using independence, ||Y_ij||≤c_i, and Cauchy–Schwarz gives
       E||H_i||⁴
       =Σ_j E||Y_ij||⁴+2Σ_{j<k}v_jv_k
          +4Σ_{j<k} E⟨Y_ij,Y_ik⟩²
       ≤c_i² s_i+3 s_i².
   Interpolate L¹/L²/L⁴: s_i^{3/2}≤z_i sqrt(E||H_i||⁴).
   Therefore s_i≤z_i(c_i+√(3M)), including s_i=0. Cauchy–Schwarz gives z_i≤√s_i≤√M. All moments are expectations under actual original source p.

7. **Actual conditional-projection Jensen.** For each owner i, condition the true centered section U_i(·;X_-i) on X_{N_i}. Exact source Hoeffding degeneracy integrates away non-owned pair terms, leaving
       E[U_i | X_{N_i}] = h_i + H_i
   pointwise on the source; this is not a conditional expectation assumed from an unrelated model. The real Hilbert-space Jensen inequality and the original product tower give
       z_i=E||H_i|| ≤ E||h_i+H_i||+||h_i||
          ≤ u_i + A_i.
   Consequently Σ_i z_i≤(8+α)B.

8. **Terminal arithmetic, with no auxiliary input.**
       V=Σ_i A_i²+Σ_i s_i
        ≤√M Σ_i A_i +Σ_i c_i z_i+√(3M)Σ_i z_i
        ≤α B√M+8B√M+√3(8+α)B√M
        =(8+α)(1+√3)B√M
        =(10+2√2)(1+√3)B√M.
   Squaring yields the asserted constant.

**Sharpness of variance exponent:** for m pairs of independent fair signs, f_m=(1/m)Σ_{k=1}^m X_{2k−1}X_{2k} has B=1, V=1/m and max influence M=1/m², showing no exponent smaller than 2 can hold universally at any dimension-free positive coefficient.

## Exact failure controls and prior-art blockers

- One-sided bilinear decoupling K_right(X,Y)=Σ_{i<j}h_ij(X_i,Y_j) has E K_right²=Var(f₂), **not** Var(f₂)=(1/2)E K_right². The factor 1/2 is correct for the symmetrized K_sym=K_right(X,Y)+K_right(Y,X). The two-fair-sign f₂=X1X2 falsifies the former.
- A categorical uniform root-influence sum bound is **false**: for an address variable A uniform on m symbols, independent fair signs Z_j, and f₂=Σ_j(1[A=j]−1/m) Z_j, ||f₂||∞<2 but Σ√I_i=(1+√m)√(1−1/m) diverges. Hence the *binary* Grothendieck proof's root-sum argument cannot be imported unchanged to categorical sources.
- Static owned-neighbor sets are distinct **within** each owner, not globally disjoint. The Doob differences of disjoint coordinate-reveal blocks are not generally independent for quadratic sources. Avoid replacing genuinely independent owner increments with martingale differences without proving the required fourth-moment theorem.
- Internal binary Grothendieck comparator already proven in prior literature and included in merged NIGHTFALL v8 (PR #392): V²≤16(K_G^R)²B²M<51B²M; **not new**.
- External comparators reviewed: de la Peña–Giné (1999) *Decoupling*; Pisier (2012) Grothendieck survey; Briët–Escudero Gutiérrez–Gribling (Quantum 2024); Escudero Gutiérrez (2023) homogeneous Fourier-completely-bounded polynomial theorem; Filmus–Hatami–Keller–Lifshitz (2016) total L¹ influences; Grimmett–Janson–Norris (2012) general product-space influence; Turturean (Nov 6 2026) Boolean-cube AA; Girish–Mittal–Nehoran–Raz (Sep 2026) biased/slice variant. The accessible source statements do not show an *explicit* categorical/zero-atom maximum-influence law with these exact hypotheses and exponent. **Not finding one does not establish novelty**. Full de la Peña–Giné book inaccessible in this session; a specialist must still check its detailed bilinear/factorization theorems and subsequent literature.

## Independent computational attack and provenance

An independently implemented pure standard-library Fraction test on 36 deterministic pseudo-random real-valued finite quadratic sources (seed 20261113; binary/ternary alphabets; heterogeneous biased and zero masses) passed:
- 950 pointwise ANOVA reconstructions;
- 9,772 exact genuine centered source-section identities;
- 9,772 exact conditional-projection identities onto generated owned neighbors;
- 116 exact actual-source influence Parseval identities;
- 116 exact owned second-moment-energy identities and inequalities;
- 116 exact Hilbert fourth-moment upper bounds and 36 matching cost bounds;
- 70-digit comparisons for additive/8B/Jensen/final coefficient;
- 20 exact exponent-sharp disjoint-pair identities.

## A concrete finite TCS consequence (conditional on the analytic theorem)

For any bounded degree-two g:Π_i A_i→[0,1], there is a deterministic adaptive whole-coordinate query policy which, for any δ,ε∈(0,1), predicts g to absolute error ε except with probability ≤δ after at most

    min(|I|, ceil(K₂/(δ ε²)))

queried source coordinates. This is not a new quantum-computing paradigm; it is the explicit whole-symbol consequence of the *strongest* analytic Q2 constant, and was already anticipated in v8. A one-query quantum acceptance-probability function is such a degree-two g under the usual whole-symbol oracle indicator-polynomial model.

Proof: For the bounded residual f=2g−1 at each observation node, let v=Var(f|node), P=Σ remaining I_i(f|node). Exact quadratic Hoeffding energies give P≤2v. The candidate Q2 theorem gives max_i I_i≥v²/K₂. Greedily query such i. Expected total remaining influence decreases by exactly its true resampling influence, so mean potential p_t satisfies p_t−p_{t+1}≥E(v²)/K₂≥p_t²/(4K₂). Reciprocal telescoping yields p_t≤4K₂/t; the squared conditional-mean prediction error for g is E(v)/4≤p_t/4≤K₂/t. Markov and the all-coordinates exact-recovery fallback prove the claim. Computational running time and policy size are not bounded. This implication is a genuine significance pathway, not a novelty certificate.

Local artifacts generated in the conversation working container:
- seven-page PDF **Q2_Law_Uniform_Quadratic_Influence_Analytic_Draft_20261113.pdf** (revised A2 with observation consequence); SHA-256 `aa4e11910c859d49df316009ca585a403a302c72da231578ec7caf93dea65260`. The A1 predecessor PDF hash was `d5866a975878c77b92d3bdf5467d08c464fd3207681fcc7fa4127db581d5ec05`.
- its revised LaTeX source SHA-256 `e942de03bec7822b50a36c16a8f72112f9ba0a49c55e6452d695b06ab2985ef4`; the A1 predecessor was `ac379cf8feeda2b94777be682b3c121e0a0d22f00d38a12d2b196f42fc11d5f7`.
- checker `q2_analytic_audit_20261113.py`, SHA-256 `558a6fa99521a8162214d87459d44ce1892917a38d10c6b108d4b16fa21cd131`.
Hashes describe generated session files; they **do not** imply those bytes are attached to this GitHub commit or persisted to GitHub. Reproduce using the conversation PDF/checker attachment or source code separately.

## Discovery graph, next gates and stop rule

**Problem → representation:** true finite product Hoeffding interactions indexed by 2-element supports.  
**Mechanism → operator:** positive four-corner rectangles + matching duality + deterministic greedy owner; local owner Hilbert fourth moment; genuine conditional projection; product-noise interpolation.  
**Construction → certificate:** explicit source-generated nonnegative costs c_i and exact original-law energy partition; complete paper proof; finite exact falsifier; Lean components orthogonal/parallel.  
**Limitations:** no independent specialist referee, categorical Grothendieck subsumption unsettled, no current complete Lean terminal Q2, no infinite-measurable extension proven here.  
**Transfers:** bounded-degree observer costs; source product Hilbert sections; adaptive whole-coordinate query descent.

**Highest-priority test:** seek expert counterexample/hidden assumption against the 8B source section, oriented global matching bound, canonical owner projection, or Hilbert fourth-moment identity; run a scope-matched *theorem-type* prior-art subsumption audit. The practical novelty/significance gate precedes optional Lean polish, per research program. Only if the proof and priority reviews succeed should this be promoted from a potentially original theorem to a defensible breakthrough or journal claim.
