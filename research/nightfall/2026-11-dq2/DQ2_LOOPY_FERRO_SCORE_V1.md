# DQ2 — Loopy ferromagnetic Ising Q2 via Lebowitz and conditional dual scores

**2026-11-17: provisional mathematical deduction.** Not independently reviewed, not Lean-certified, not novelty-cleared. External input: classical Griffiths (GKS) and Lebowitz four-point inequalities; finite original-source NIGHTFALL Q2 bound. Parallel tree PR #786 remains separate.

## Theorem (all finite ferromagnetic graphs, including arbitrarily many cycles)

Let ν be the strictly positive zero-external-field Ising law on any finite graph G=(V,E), with finite ferromagnetic couplings J_{ij}≥0. Define C_{ij}=E_ν X_i X_j≥0 (C_ii=1), S=max_i Σ_j C_ij, H_i=Σ_{j∼i}J_ij, and

v = min_i sech²(H_i),
D = max_i [cosh²(H_i)+(1/2)Σ_{j∼i}sinh(2J_ij) exp(2(H_i-J_ij))].

For f(x)=c+Σ_i a_i x_i+Σ_{i<j}b_ij x_i x_j bounded by |f|≤B everywhere and true-law conditional influence I_i^ν(f)=E Var(f|X_-i), the finite-product Q2 theorem with constant C2≈105.41624 implies

  (Var_ν f)² ≤ C2 S⁴(D/v) B² max_i I_i^ν(f).

No tree assumption, no upper bound on the number of cycles, and no S<2 restriction. The coefficient is dimension-free along a graph family with uniform bounds on S, D, 1/v. This is an author-derived combination of established inputs, NOT a novelty claim.

Equivalent exact rational budgets in t_ij=tanh J_ij∈[0,1): let P_i=∏_{j∼i}(1+t_ij)/(1-t_ij). Then

  v=min_i 4P_i/(1+P_i)²,
  D=max_i [(1+P_i)²/(4P_i)+P_i Σ_{j∼i} t_ij/(1+t_ij)²].

### Proof 1 — quadratic sector comparison on every ferromagnetic graph

By global spin-flip invariance, the linear and centered quadratic monomial sectors are orthogonal. The linear covariance matrix C has row-sum norm ≤S. For i<j and k<l set Γ_{ij,kl}=Cov(X_iX_j,X_kX_l). By GKS, Γ≥0 entrywise. The classical Lebowitz inequality gives

 Γ_{ij,kl} ≤ C_{ik} C_{jl}+C_{il}C_{jk}.

Repeated-index cases follow directly using X_i²=1 and nonnegative two-point correlations. Therefore

 Σ_{k<l} Γ_{ij,kl} ≤ Σ_{k≠l} C_{ik}C_{jl} ≤ S².

Schur's symmetric-matrix bound implies ||Γ||op≤S²; the linear block has ||C||op≤S≤S². Consequently

 Var_ν(f) ≤ S²[Σ_i a_i²+Σ_{i<j}b_ij²] = S² Var_μ(f),

where μ is the uniform independent-sign product law.

### Proof 2 — general signed-Ising dual-score lower covariance bound

This lemma also holds with signed J and arbitrary finite external fields h. Let m_i=E[X_i|X_-i]=tanh(h_i+Σ_j J_ij X_j), w_i=1-m_i², and define U_i=(X_i-m_i)/w_i. Then E U_i=0 and Cov(X_j,U_i)=1_{i=j}.

Let H_i=|h_i|+Σ_j|J_ij| and Q_{ij}=E U_iU_j. Conditional expectation shows Q_ij=0 for nonadjacent distinct sites, since U_j is measurable outside i; Q_ii=E(w_i^-1)≤cosh² H_i.

For adjacent i,j, condition on all spins except j:

 Q_ij=E{[U_i(X_j=+1)-U_i(X_j=-1)]/2}.

As a function of its local field y, U_i has derivative -exp(-2y) when X_i=+1 and -exp(2y) when X_i=-1. Therefore

 |Q_ij| ≤ (1/2)|sinh(2J_ij)| exp(2(H_i-|J_ij|)).

Define Dscore=max_i(cosh²H_i + (1/2)Σ_{j∼i}|sinh 2J_ij|e^{2(H_i-|J_ij|)}).
Each Q-row has absolute sum ≤Dscore, so ||Q||op≤Dscore. For any vector b, covariance duality and Cauchy-Schwarz give
  ||b||²=Cov(b·X,b·U)
          ≤sqrt(Var(b·X)) sqrt(bᵀQb)
          ≤sqrt(Var(b·X)) sqrt(Dscore)||b||.
Therefore Cov(X) ⪰ Dscore⁻¹ I, for any finite signed Ising law including nonzero external fields. This useful operator lemma is independently motivated but its originality against Fisher-information/Ising literature remains unverified. For zero-field ferromagnets Dscore=D above.

### Proof 3 — physical conditional influences

Write f(x)=h_i(x_-i)+x_i g_i(x_-i), where g_i=a_i+Σ_{j≠i} b_ij x_j. The actual-law conditional variance identity and the score bound imply

 I_i^ν(f)=E[w_i g_i²] ≥v E[g_i²]
         ≥(v/D)(a_i²+Σ_{j≠i}b_ij²)
         =(v/D) I_i^μ(f).

The penultimate inequality uses E X_j=0, Cov(X)⪰D⁻¹I, and D≥1. Apply existing finite uniform-product Q2 to μ and compose with Proof 1.

### Strong cyclic test family

For the uniform ferromagnetic cycle on n≥3 spins with t=tanh J=r∈(0,1), the exact row susceptibility is
  S_n=((1+r)/(1-r))*((1-r^n)/(1+r^n)) < (1+r)/(1-r).

Both D and v depend only on the two neighboring edges, not n. Thus all cycles admit a common size-independent Q2 coefficient at each fixed r<1. At r=1/2: S_n<3, D=61/9, v=9/25, yielding

  (Var_ν f)² ≤ 1525*C2*B² max_i I_i^ν(f)

uniformly for all n≥3. Unlike the previous diagonal-dominance candidate, this covers the eight-cycle with S=765/257>2.

For more densely loopy finite ferromagnetic graph families (e.g. high-temperature lattice boxes), uniform susceptibility S can follow established high-temperature correlation bounds. The present theorem is conditional on the explicit S, not on a claimed new susceptibility estimate.

## Audit / prior art / stop rule

Exact independent state-enumeration checks (Python standard-library Fraction) passed for triangle, square, pentagon, K4 and 3×3 grid: GKS sign, Lebowitz four-point bound (including overlaps), quadratic Schur row, actual-law site influences. Additional exact checks of dual-score identities, graph sparsity and local row budget passed on strong 4-,6-,8-cycles including S>2, K6, and a nonuniform loopy graph. These are finite tests, not global proof certification.

External source inputs checked 2026-11-17: Joel Lebowitz (1972), *More Inequalities for Ising Ferromagnets*, https://doi.org/10.1103/PhysRevB.5.2538 ; Lebowitz (1972), *Bounds on the Correlations and Analyticity Properties of Ferromagnetic Ising Spin Systems*, https://cmsr.rutgers.edu/images/people/lebowitz_joel/publications/jll.pub_90.pdf ; Koehler–Lifshitz–Minzer–Mossel (STOC 2024), https://arxiv.org/abs/2307.07625 ; Chen–Chen–Zhang (2026), https://arxiv.org/abs/2609.24687 . Source-specific novelty comparisons are **not concluded**.

Independent reviewer must attack: exact repeated-index four-point step, GKS positivity, covariance score duality, sparse off-diagonal formula, conditional influence normalization, and whether known literature already implies the bound. Lean proof needs two isolated gates: conditional score covariance lemma, and four-point inequality + product Q2 composition. Do not claim a fully kernel-certified ferromagnetic theorem if the classical correlation inequalities are only Lean premises.

Next structural transition: replace Lebowitz/GKS for signed interactions or nonzero external fields, or prove an unrestricted weak-mixing quadratic covariance row budget from cluster expansion. Do not polish C2 until novelty/validity gating is complete.

Discovery graph: dependent Q2 → algebraic quadratic spin functions → Lebowitz fourth-order operator bound and local dual conditional scores → restricted covariance and native influence comparison → all-graph dimension-free Q2 when susceptibility stays bounded → finite rational checks → limits (zero field, ferromagnetism, S budget) → transfer to loopy correlated sensing systems.
