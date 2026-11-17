# DQ2 structural transition: generic residual-degree collapse and finite-regime mixture transfer

**Status:** 2026-11-17, author-derived, exact arithmetic verified; **not Lean-certified, externally peer-reviewed, novelty-cleared, or merged as a proven NIGHTFALL catalogue claim**. All named components rely on the independently source-checked product C2 theorem at its exact stated hypotheses. The mixture theorem is a mathematical corollary, not a new product-space theorem.

## Objectives and scope
Find a mathematically valid notion of degree for dependent coordinate laws and a dimension-free actual-law influence theorem. Two decisive findings: the naive genuine-residual triple condition is generically degenerate; degree defined relative to finitely many product regimes admits a useful dependent-law inequality with a necessary latent-variance correction and a necessary linear regime-count factor. No universal dependent-law Q2 is claimed.

## Theorem A — 4-spin Ising-chain residual-degree rigidity

For x in {-1,1}^4 and 0<|r|<1, define
p_r(x) = (1/16) product_{j=0}^2 (1 + r x_j x_{j+1}).
All 16 atoms are positive and sum to 1. Set
Q_i f = E_{p_r}[f | x_j, j != i], R_i=Id-Q_i.
If R_i R_j R_k f = 0 for **every ordered triple of pairwise distinct** i,j,k, then f is constant. Conversely constants satisfy this condition.

**Exact certificate.** With 4-bit states a=0,...,15 (bit i encodes x_i=+1, else -1), define A_i = 2R_i for endpoints i=0,3 and A_i = 2(1+r^2)R_i for interiors i=1,2. Rows of A_i map e_a^T to c_i(a,r)(e_a^T-e_{a xor 2^i}^T), with
c_0=1-r x_0x_1, c_3=1-r x_3x_2,
c_1=1+r^2-r x_1(x_0+x_2), c_2=1+r^2-r x_2(x_1+x_3).
Select the 15 rows indexed by:
- (0,1,2,a) for a in {0,2,4,6,8,10,12,14};
- (0,1,3,0), (0,1,3,2);
- (0,2,1,0), (0,2,3,0);
- (1,2,3,0), (2,1,0,0), (3,2,1,0).
Drop state column a=0. The resulting integer-polynomial 15x15 matrix H(r) has

det H(r) = -2^26 r^17 (1+r^2)^9 (r-1)^18 (r+1)^5.

Each row polynomial degree is at most 3 + the number of interior operators in its triple; their total is 45+27=72. The determinant identity is therefore certified by **73 exact integer evaluations** (r=-36,...,36) using fraction-free Bareiss elimination. An independent full-joint-law rational construction verifies the equivalent original-residual minor

det H_R(r) = - r^17 (1-r)^18 (1+r)^5 / [2^19(1+r^2)^18]

at r=1/2,1/3,-1/2,1/100. The formula never vanishes for 0<|r|<1. Because the residuals annihilate constants, their combined rank is exactly 15. At r=0, ordinary independent ANOVA degree<=2 instead has dimension 1+4+6=11. The degree space thus jumps discontinuously under arbitrarily small nonzero interaction.

**Interpretation:** This theorem invalidates any attempt to define useful intrinsic dependent quadratic degree solely by vanishing of all ordered third-order genuine conditional residuals. It does **not** refute dependent Hoeffding/oblique degree notions.

## Theorem B — generic collapse on n>=4 binary coordinates

For each fixed finite n>=4, for Lebesgue-almost-every strictly positive probability vector p on {-1,1}^n, the simultaneous kernel of all ordered triple genuine residual products is exactly the constants.

Proof. The fixed 15x15 rational minor above is nonzero at a positive 4-site probability vector. After clearing positive marginal denominators, its nonvanishing defines a nonempty Zariski-open full-measure subset G of the 4-spin probability simplex. Fix any four sites A and any assignment z to the other coordinates. The conditional law p(X_A|X_{-A}=z) depends rationally on the global positive atom vector. Its minor numerator is not the zero polynomial, since p = p_r on A times any positive product law on -A gives the positive witness. Hence the exceptional set for that (A,z) has measure zero. There are finitely many such pairs; outside their union every conditional 4-site fiber is rigid. For f annihilated by all ordered triples, fixing the outside coordinates and restricting the residuals to each 4-site fiber forces f constant across that fiber. Each original site lies in a 4-set, hence f is independent of every site, and thus constant on the hypercube.

This proves generic rigidity in every finite dimension >=4 without requiring explicit n-site determinants. Dense-open genericity also shows failure of stability arbitrarily close to a strictly positive independent-product law. No uniform quantitative lower bound on the smallest singular value is claimed; it necessarily degenerates at r=0.

## Theorem C — latent-regime Q2 transfer (provisional analytic corollary)

Let ν = sum_{z=1}^m p_z μ_z, with m finite, p_z>0, and each μ_z an arbitrary independent product probability law on the same index/alphabet system (finite or infinite). Suppose |f|<=B ν-a.e. and f has Efron–Stein degree<=2 in L2(μ_z) for every z. Let V=Var_ν(f), H=Var_Z(E_{μ_Z} f), and I_i^ν(f)=inf_{h measurable outside i} E_ν[(f-h)^2]. Then

(V-H)^2 <= C2*m*B^2*sup_i I_i^ν(f),

where C2=(2(1+sqrt(2))*sqrt(3)+11901/6250)^2 approx 105.41624 is the previously certified product theorem coefficient.

Proof: V-H = sum_z p_z Var_{μ_z}(f). For each z, Var_{μ_z}(f)^2 <= C2 B^2 M_z with M_z=sup_i I_i^{μ_z}(f). By Jensen, (V-H)^2<=C2 B^2 sum_z p_z M_z. For every i, variational minimization gives
I_i^ν(f) = inf_h sum_z p_z E_{μ_z}[(f-h)^2] >= sum_z p_z I_i^{μ_z}(f).
For finite m, sum_z p_z sup_i I_i^{μ_z}(f) <= sum_z sup_i (p_z I_i^{μ_z}(f)) <= m sup_i I_i^ν(f). The inequality is valid even when component measures are mutually singular. If all component means coincide, H=0 and the actual-law V^2 Q2 inequality follows.

**Important:** this degree hypothesis is relative to the product components, not the degenerate intrinsic actual-law triple residual condition. The latent count m is structural and a dimension-free bound needs control of H.

## Theorem D — m factor is necessary, even with full support

For m>=2, let latent Z be uniform on {1,...,m}. Conditional on Z=z, draw two observed categorical labels L1,L2 independently, each equal to z with probability 1-δ and otherwise uniformly among the remaining m-1 symbols, for 0<δ<=1/(4m). Independently draw m fair signs Y_1,...,Y_m. Set f=Y_{L1}. Each component law is a full-support product, |f|=1, E[f|Z]=0, and f has product Efron–Stein degree<=2 because f=sum_j 1_{L1=j}Y_j. Under the actual mixture, Var(f)=1, I_{L2}=0, and each I_{Y_j}=Pr(L1=j)=1/m. The variational choice h=Y_{L2} gives I_{L1}<=E[(Y_{L1}-Y_{L2})^2]=2Pr(L1 != L2)<=4δ<=1/m. Consequently max_i I_i^ν(f)=1/m and V^2/(B^2 max I)=m, **exactly**. The linear dependence on m is unavoidable (although C2 is not asserted sharp). Exact finite enumerations pass for m=2,3,4,5 at δ=1/(8m).

## Theorem E — latent mean term is necessary

For m=2 let Z be a fair sign, and conditional on Z let X_i be iid signs with E[X_i|Z]=aZ, 0<a<1. For f=n^{-1} sum_i X_i, |f|<=1, f is product degree one in each component. Then Var_ν(f)=a^2+(1-a^2)/n, H=a^2, but for every original site I_i^ν(f)<=1/n^2, by the conditional variational characterization. Thus no universal dimension-free full-variance bound can hold for the class with H uncontrolled, even when every pairwise observed correlation a^2 is arbitrarily small. No claim is made that f has vanishing actual-law triple residuals.

## Independent audit / priority / scope

Author-side exact rational checks and the polynomial certificate are not an independent human mathematical review or Lean proof. The checker must be audited as a certifying algorithm; row selection, orientation of R_iR_jR_k, factor formula, and determinant degree bound are proof dependencies. The direct-law construction independently verifies the analytic transition formulas. A 2nd reviewer should reproduce the polynomial certificate without using the same code, then formalize the finite rank theorem in Lean. The mixture corollary uses a kernel-checked product inequality but its mixture comparison, infinite product sigma-algebra and regime-count steps are not separately formalized.

Closest known work: Il Idrissi et al., *Hoeffding decomposition of functions of random dependent variables*, J. Multivar. Anal. 2025, https://doi.org/10.1016/j.jmva.2025.105444 ; Chastaing et al., EJS 2012 https://doi.org/10.1214/12-EJS749 ; Bardet–Capel–Rouzé, *Approximate Tensorization of the Relative Entropy for Noncommuting Conditional Expectations*, 2022 https://arxiv.org/abs/2001.07981 . These develop existing dependent decompositions and noncommutative-projection machinery; this dossier does **not** claim novelty after an exhaustive priority search. Product source catalogue: ../2026-11-priority/Q2_PRIORITY_DOSSIER_20261117.md . Separate unmerged integrated source gate #776 is not silently promoted.

**Cheapest decisive next experiment:** an independent implementation of the 15x15 polynomial determinant and its full support measure interpretation; then formalize one exact finite-rank theorem in Lean. After that, construct a new nondegenerate dependent-degree operator using oblique projections or latent-reference degree, not triple residual vanishing.

**Proposed reusable mechanism:** operator-word rank rigidity under noncommuting conditional projections, plus variance splitting through a hidden product-mixture index. Record this as a representation-level structural transition rather than a claimed globally novel Q2 theorem.
