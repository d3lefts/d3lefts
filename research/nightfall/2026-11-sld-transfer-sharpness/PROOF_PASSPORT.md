# NIGHTFALL SLD tensor sharpness — proof passport (2026-11-11)

**Program:** Devin J. Wright / NIGHTFALL, AI-assisted mathematical construction and code audit.  
**Status:** Author-side analytic proof with independently represented finite falsification checks. **NOT** Lean kernel certified, non-author refereed, globally originality cleared, or publication approved.  
**Source of record:** [SLD_Exponential_Separation.tex](SLD_Exponential_Separation.tex).  
**Checker:** [check_sld_separation.py](check_sld_separation.py), run using Python 3 and NumPy.

## Exact claims and certificates

### A. Physical ternary exponential hiding (explicit closed form)

Let d>=1; X_i independent uniform in {0,1,2}; omega a primitive cubic root of unity; p in (1/2,1), q=1-p. Encode x into the pure qubit
rho_x = [[p, sqrt(pq) omega^{-x}], [sqrt(pq) omega^x, q]].
Take the bounded real pure-order-d target
f_d(x)=Re omega^(x_1+...+x_d).
With local average b=diag(p,q), SLD Jordan superoperator J_b(H)=(bH+Hb)/2 and centered local contrast map T, the smallest eigenvalue of K=T* J_b^{-1} T is a=2pq, attained twice.

**Proven formulas in the TeX source:**
- Var(f_d)=I_i(f_d)=1/2 (resampling influence);
- all proper-subset optimal scalar quantum Bayes gains are zero;
- every terminal gain Delta_i=G*([d])-G*([d]\{i})=(pq)^d/(p^d+q^d);
- Delta_i/(a^d I_i(f_d))=2^(1-d)/(p^d+q^d).

At fixed p=3/4 and local visibility a=3/8, this ratio equals 2^(d+1)/(3^d+1), asymptotic to 2(2/3)^d. Thus a polynomial-in-d replacement of the *additional* SLD transfer factor is impossible under these local-preparation assumptions.

**Exact sharpness of the universal constant:** for every fixed d, p tending upward to 1 gives a ratio approaching 2^(1-d). Every p<1 has a faithful average b and strictly positive K; the limit has a tending to zero. This distinction must accompany the claim.

**Certificate:** root-of-unity exact arithmetic (d=1,...,8) and a separately represented direct density-matrix SLD calculation (d=1,...,6). Numeric matrices are tolerance checks, not exact interval arithmetic.

### B. No extra SLD penalty for Hermitian simple tensors

For faithful b_i and Hermitian H_i, define Q_b(H)=Tr(H J_b^{-1}(H)).
The analytic lemma establishes:
Q_(tensor b_i)(tensor H_i) >= product_i Q_(b_i)(H_i).

**Mechanism:** expand in local spectral bases; absolute-squared Hermitian matrix entries are invariant under reversing each ordered index pair. Average the global denominator D over independent pair reversals. Since E[D] = 2^(1-d) product_i(lambda_{i,j}+lambda_{i,k}), convexity of 1/x yields the stated inequality with coefficient one. Equality occurs for maximally mixed b_i, so this coefficient is best possible.

**Consequence:** every centered local L2 space of a nontrivial binary classical source is one-dimensional. Each Hoeffding component is a real multiple of a simple Hermitian tensor under local encoding. Therefore gamma_S >= (product_{i in S} a_i) ||f_S||^2 and, when a_i >= a in (0,1], Delta_i >= a^d I_i(f) for degree at most d.

**Certificate:** complete symbolic Jensen proof in TeX; 600 independently sampled Hermitian tensor models test implementation, but sampling is not proof.

### C. The baseline a^d cannot be removed

For independent uniform sign inputs, f(x)=product x_i and commuting qubit encodings rho_x=(I+x sqrt(a) sigma_z)/2 with 0<a<1, the local K_i=a and terminal gain is exactly a^d while I_i(f)=1. This is a separate *commuting* sharpness construction. Thus binary inputs remove the additional 2^(1-d) penalty but do not provide polynomial-in-degree loss at fixed a<1.

## Scope and boundary conditions

Finite independent classical sources; locally prepared finite-dimensional states; faithful *average* local states; positive local Gram visibility; optimal single-copy scalar Bayesian mean-square gain under unrestricted joint POVMs. The conditional pure qubit states need not themselves be full rank. **Not** an adaptive quantum observation protocol, a single-register-from-scratch gain, an unconditional quantum AA theorem, or a statement about entangled local-input preparation.

The existing repository [quantum ANOVA bridge](../../papers/finite-product-influence/QUANTUM_ANOVA_BRIDGE_20261111.md) uses a **geometric** local visibility Gram (Omega_b^{-1}) and condition-number floor for its quadratic result. This dossier instead uses **SLD** K=T*J_b^{-1}T. These local parameters are **not interchangeable**. The v8 squared-variance influence inequality is neither assumed nor reproved here.

## Reproduction and provenance

Command (from repository root):
    python3 research/nightfall/2026-11-sld-transfer-sharpness/check_sld_separation.py

Requires NumPy. The checker compares exact rational formulas, numerical density matrices, and randomized complex Hermitian tensor cases. Run CI for this branch's exact source; avoid citing local results as CI until that run finishes.

Source package originated in the 11 November 2026 NIGHTFALL SLD addendum attached to the research conversation. Author-side source hashes for that attached package were SHA-256:
- TeX: 4118de4fac6af47307b1ea9c9f61b9de0b8d98fc0e18c7e95951729438a7545c;
- Python checker: 76b8bdf97e5fb60a7e114695eabc63aa193831fa82aee041a0a176747079db68.

The repository checker file was manually transferred and should be checked against its own Git blob; this passport does not assert that the repository TeX matches the attached TeX byte-for-byte. Preserve the prior artifact and any differences instead of silently conflating revisions.

## Historical priority and independent review

The proof uses Personick's quantum estimation/Symmetric Logarithmic Derivative framework and the product-average ANOVA structure from the associated NIGHTFALL manuscript. Adjacent prior art: Cao–Lu (2019), Hirche–Rouze–Stilck França (2022), other quantum chi-square tensorization. No claim of global firstness is established. Independent quantum-information specialist should attack (i) supermodular energy identification, (ii) physical p-to-1 sharpness quantifiers, (iii) Hermitian orientation/Jensen argument, (iv) equivalence of local Gram notion across papers, and (v) prior art.

## Next decisive test

Seek an exact noncommuting d=2 or d=3 instance that violates the Hermitian simple-tensor statement; no such counterexample was found in 600 reproducible seeded tests. This falsification search cannot prove the theorem. Separately compare geometric and SLD local visibility floors on the trine construction, because reusing the geometric coefficient in an SLD statement would be an invalid transfer.

**Promotion policy:** No manuscript replacement, main-branch merge, site headline, arXiv submission, or claim status elevation without independent proof review and human authorization.
