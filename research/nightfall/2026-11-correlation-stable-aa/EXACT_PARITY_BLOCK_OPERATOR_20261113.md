# Exact low-degree Dirichlet transfer with exponentially large global correlation ratio

**NIGHTFALL research advance | 13 November 2026 | Directed by Devin J. Wright; AI-assisted analytic proof**

**Status:** New author-derived exact operator identity and adaptive composition within NIGHTFALL; validated by 2,000+ exact rational model and posterior comparisons; **not** externally refereed, Lean-compiled at the new theorem type, or established globally novel. The construction combines classical parity tilts, low-degree Fourier orthogonality and the historical finite-product influence theorem.

## 1. The operator transition beyond global density perturbation

The [hereditary correlation theorem](HEREDITARY_CORRELATION_THEOREM.md) controls dependent sources using a **global density ratio** \(R\). If a system consists of m weakly correlated independent clusters, this ratio can grow exponentially in m and make that theorem nearly vacuous. We instead construct a law for which **restricted low-degree covariance and coordinate Dirichlet forms are exactly comparable** regardless of m.

Fix integers m,L>=1, a product fair-sign reference \(\mu\) on n=mL coordinates partitioned into m blocks \(B_b\) of size L, and \(\tau\in[0,1]\). Set

\[
\nu_{m,L,\tau}(x)=2^{-mL}\prod_{b=1}^m
\left[1+(1-\tau)\prod_{i\in B_b}x_i\right].
\tag{1}
\]

Each block is a mixture of uniform even-parity and ordinary fair-product inputs. Distinct blocks are independent. When \(0<\tau<1\), the global ratio to \(\mu\) is

\[
R_{\mathrm{global}}=\left(\frac{2-\tau}{\tau}\right)^m.
\tag{2}
\]

When tau=0, the law is singular and all original-coordinate conditional resampling influences of some nonconstant low-degree functions can be zero.

## 2. Theorem — exact low-degree covariance and influence operators

Let \(d\ge1\) and \(2d<L\). For every real function f and g of **uniform-product Fourier degree at most d**, one has

\[
\boxed{\operatorname{Cov}_{\nu_{m,L,\tau}}(f,g)
       =\operatorname{Cov}_{\mu}(f,g),}
\tag{3}
\]

and for every original coordinate i,

\[
\boxed{
I_i^{\nu_{m,L,\tau}}(f)
   =(2\tau-\tau^2)\,I_i^\mu(f).
}
\tag{4}
\]

Equation (4) is a quadratic-form equality on the entire low-degree function space, not just a single witness. For tau>0 the law may have an exponentially large global density ratio while the **actual coordinate-influence attenuation** stays at the fixed constant
\(a=2\tau-\tau^2>0\), independent of m. The same two equalities hold for every conditional section remaining after revealing any union of **complete blocks**.

### Proof

Expand the density in (1) into products of full-block parity characters:

\[
d\nu/d\mu=\sum_{A\subseteq[m]}(1-\tau)^{|A|}
\chi_{\cup_{b\in A}B_b}.
\]

Every nonconstant character in this density has Fourier degree at least L. Since f and g have degree<=d, fg has degree<=2d<L. Hence \(\mathbb E_\nu f=\mathbb E_\mu f\) and \(\mathbb E_\nu fg=\mathbb E_\mu fg\), proving (3).

For the influence identity, fix coordinate i in block b. The conditional distribution of Xi given X_-i assigns probability \(1-\tau/2\) to the sign completing even parity in b and \(\tau/2\) to the opposite sign. The conditional variance for the two values \(f_+(x_{-i}),f_-(x_{-i})\) is therefore exactly \(a/4\,(f_+-f_-)^2\), whereas under μ it is \(1/4\,(f_+-f_-)^2\). The distribution of the coordinates outside i has a fair marginal on the remaining L-1 coordinates *in its own block*, and parity-tilted independent distributions on the other blocks. The polynomial \((f_+-f_-)^2\) in the remaining variables has Fourier degree<=\(2(d-1)<L\), so its expectation under this marginal agrees with its expectation under the fair product marginal by the same parity-character orthogonality. This proves (4).

Conditioning on complete block assignments leaves the other blocks distributed independently by the same parity tilt. A section of a Fourier-degree<=d function has degree<=d on the remaining variables. Thus (3)-(4) are hereditary for complete-block conditioning. QED.

## 3. Theorem — adaptive block observation independent of attenuation

Assume \(0<\tau\le1\), \(2d<L\), and \(|f|\le B\). At each transcript formed by complete previously observed blocks, choose a *remaining fine coordinate i* that maximizes the **actual correlated heat-bath influence** \(I_i^\nu(f\mid H)\), then reveal its **whole block** of L coordinates at once. There is a deterministic policy with

\[
\boxed{
Q\le\min\left\{m,\
\left\lceil\frac{4d^7B^3}{c_*\eta^{3/2}}\right\rceil\right\}
}
\tag{5}
\]

block observations, or at most LQ original-coordinate readings, whose conditional-mean prediction has squared error <=η.

### Proof and cancellation mechanism

For every reachable complete-block posterior the exact operator identities give

\[
V_\nu=V_\mu,\qquad
T_\nu:=\sum_iI_i^\nu=aT_\mu\le adV_\nu,
\]

and the imported Lean finite-product theorem gives

\[
M_\nu:=\max_iI_i^\nu
=a\max_iI_i^\mu
\ge a c_*V_\nu^{5/2}/(B^3d^6).
\]

The exact dependent-law drift identity applied to observation of an **entire block** states that the expected sum of remaining fine-coordinate influences decreases by \(\sum_{i\in B}I_i^\nu\), which is at least the maximum fine influence \(M_\nu\) of the chosen coordinate. Put \(v_t=\mathbb EV_\nu(H_t)\), \(p_t=\mathbb ET_\nu(H_t)\). Then
\(p_t\le ad\,v_t\) and
\(p_t-p_{t+1}\ge a c_*v_t^{5/2}/(B^3d^6)\).

The factor **a occurs on both sides and cancels** in the dyadic potential descent. The result is exactly the same number of *block* observations as the independent-source theorem, irrespective of how small but positive tau is. The proof works for every m and has no global likelihood ratio factor. QED.

When tau=0, all fine-coordinate influences vanish, so this particular coordinate-influence selection policy does not apply. The broader [two-scale block-product theorem](TWO_SCALE_BLOCK_THEOREM_20261113.md) nevertheless provides the **same block-count guarantee** using macroblock influences, including tau=0. Thus the law class admits a sharp qualitative transition in the *fine-coordinate selection signal* without a phase transition in the existence of a block-level observer.

## 4. Meaning and limitations

This is a **representation-level improvement**, not a stronger numerical constant for the original cube inequality. The imported core is still the pinned \(c_*=\sqrt{3/12500}/\pi^6\). The result shows that the global density-ratio R is *not the intrinsic obstruction* to low-degree influence transfer. Low-degree covariance and the conditional Dirichlet operators may have exact, dimension-free comparison even when global R is exponential.

The result exploits a known, explicitly declared, parity-block factorization and whole-block observation. It does not handle arbitrary overlapping high-order interactions, unknown block boundaries, or certify efficient evaluation of the conditional influence maximizer. It does not prove maximum-coordinate influence for tau=0; that fails as in the one-block parity counterexample.

The idea to compare covariance and Dirichlet quadratic forms on a **restricted interaction subspace**, rather than bound all probability densities, is the transferable operator. A historically novel theorem would establish a verifiable analogous comparison for a much wider correlated family with overlapping dependencies or finite interaction separators.

## 5. Exact rational falsification

Run [check_parity_blocks.py](check_parity_blocks.py). On 25 combinations of block count, block length, interaction degree and tau; 75 randomly generated low-degree polynomial trials; the independent checker compares:
- 75 exact full covariance/variance identities;
- 570 exact individual conditional influence equalities;
- 864 exact conditional-section comparisons after one complete-block observation.

All arithmetic is rational. Distinct block mixtures include singular tau=0 cases. No random test can prove the all-dimensions statement or establish historical priority.

## 6. Independent criticism and originality gate

Known prerequisites: parity k-wise independence and Fourier orthogonality; variational covariance and Dirichlet forms; classical grouping of independent blocks; Turturean's kernel formalization and NIGHTFALL's heterogeneous finite transfer. The candidate novelty is the exact **low-degree operator transfer plus adaptive block-descent cancellation** for an exponentially nonuniform law family, not any one ingredient. It requires a direct dated prior-art search in Fourier analysis of blockwise parity-biased measures and Markov Dirichlet forms, and non-author reconstruction of all conditional sections. Do not promote its status before those gates pass.