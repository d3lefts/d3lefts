# NIGHTFALL Xi — Unified Research Dossier

Prepared 26 October 2026. Scope: separate, rigorously distinguish heat-Hankel, reciprocal-Hankel, eventual-shift and isolated-zero statements. This is a synthesis, **not** a new rank theorem or priority claim.

## I. Objects and non-equivalences

For the completed xi function, define the heat trace W(t)=1/2 sum_rho exp(t(rho-1/2)^2), c_j(t)=(-1)^j W^(j)(t), and parity Hankel matrices H_n^eps(t)=[c_(i+j+eps)(t)] for eps=0,1. Separately define F(u)=xi(1/2+i sqrt(u))/xi(1/2), -F'/F=sum_(k>=1) S_k u^(k-1), and reciprocal Hankel matrices M_(n,alpha)=[S_(alpha+i+j)] where defined. Heat positivity, its Gamma/Mellin transfer, and reciprocal positivity are distinct propositions: any transfer must specify exact normalization, domain, kernel and convergence and may not be inferred from scalar parameter checks alone.

## II. Result ledger (incommensurable regimes)

1. **118,365,000,000 — reported all-time/all-shift heat rank candidate.** The immediate prior conversation identifies exact-rational scalar gates passing. The full primary certificate and inherited analytic lemmas were not located or rerun for this dossier. Classification: **reported, not independently certified**. In particular it is not valid to promote the gate calculation to an unconditional xi theorem.
2. **12,363,153,437,138 — eventual-exponent reciprocal-Hankel rank.** The recovered Oct 25 theorem note reports an unconditional *existential* high-shift argument using a finite set of certified real zeros and spectral gap to the remaining zero set. The shift threshold is not numerically evaluated. Classification: **source-reported proof, awaiting external review and source-level audit**. It does not cover all alpha, and cannot be compared numerically as an improvement to the all-shift candidate.
3. **103,400,000,000 — earlier reported eventual-exponent rank certificate**, superseded in rank within that restricted regime, not the current all-shift baseline.
4. **4,000,000,000,000.8222591471419102 < gamma < 4,000,000,000,000.8222591471419104** — isolated critical-line zero existence via independent mpmath.iv and MPFR interval engines and explicit Riemann–Siegel error bounds. The attached original ZIP contains its raw intervals, code, and hashes. This is **not** a rank theorem, not a proof of uniqueness or simplicity, and not verification of all zeros to this height.

## III. Mathematical core of eventual-exponent positivity

For fixed rank m, choose m distinct real verified zero nodes with reciprocal values x_j=gamma_j^(-2)>0, strictly larger in modulus than the reciprocal nodes of every remaining zero. The positive low-node Gram matrix of polynomial evaluations is positive definite. If the rest of the spectrum has maximum reciprocal modulus q<min_j x_j, then its contribution to the shifted quadratic form is O(q^alpha), while the low-node Gram lower bound scales at least as (min_j x_j)^alpha. Thus for sufficiently large alpha, the matrix is positive definite. This yields positivity at **eventual** exponents for each fixed finite rank, with a rank-dependent threshold. It gives no uniform all-alpha theorem and cannot exclude off-line zeros above the verified height.

**Important verification obligation:** the actual choice of zero nodes, strict separation, multiplicities, zero-sum convergence, and the numeric rank 12,363,153,437,138 must be checked against the primary theorem's explicit counting bounds; the argument here proves only the general finite-rank implication under its stated spectral-gap premises.

## IV. Pole-shield reduction

For beta>0, U in R^(n x k), p !=0 and tau>=0, set H_tau=beta I+tau pp^T-UU^T, G=U^T U, b=U^T p, d=p^T p. Then some tau yields H_tau positive definite iff B=beta I-G+bb^T/d is positive definite. If B>0, the exact criterion is tau > beta*(b^T B^(-1)b-d)/d^2, with tau>=0. This is a classical Woodbury/Schur complement identity, valuable for retaining the correlations of four defect bands. To apply it to Xi, independently enclose the actual four-band Gram data and residual operator norm; the generic algebra alone does not certify an Xi rank.

## V. Dependencies and open proof gate

The missing global implication is degree-uniform coercivity for the genuine arithmetic/theta quadratic forms (or an equivalent all-rank positivity theorem), not an improvement in decimal precision. Priority verification must examine the exact Weil–Guinand normalization, near-time Hermite/Christoffel–Darboux estimates, interpolation/tail bounds, and the Gamma–Mellin reversal. All claims of all-alpha reciprocal transfer remain conditional until those lemmas are proved with correct constants and domains.

## VI. Reproducibility and independent tests

The bundled four-trillion certificate includes scripts to rebuild the main-sum intervals and independent MPFR intervals. Its hash manifest was verified in the current session. Run the archive's REPRODUCE.sh with the specified dependencies; externally validate the Gabcke remainder and theta asymptotic conventions.

No 118.365B primary numerical certificate or 12.363T original checker has been attached to this dossier. Their absence is recorded rather than replaced by invented calculations.

## VII. Research priority

(1) Obtain the exact 118.365B primary coefficient files and inherited analytic lemmas; (2) reconstruct the full analytic-to-scalar proof dependency graph and run an independent rational checker; (3) compare with the 12.363T high-shift theorem only within explicitly matched exponent ranges; (4) attempt four-band operator compression with outward interval Gram enclosures; (5) publish a new rank only after strict proof and numerical certification.

## VIII. Provenance

- NIGHTFALL Oct 25 theorem note, Library `THEOREM_NOTE(20261026-030627).md` (eventual 12.363T and pole-shield theorem).
- NIGHTFALL Oct 25 candidate and session discussion (118.365B figure; full certificate unavailable here).
- NIGHTFALL original and refined four-trillion zero witness, bundled refined ZIP.
- Platt–Trudgian, *The Riemann hypothesis is true up to 3·10^12*, Bull. Lond. Math. Soc. 53 (2021), 792–797, endpoint 3,000,175,332,800.
- Gabcke (1979) explicit Riemann–Siegel remainder; Brent (2019) theta-function asymptotic error.

## IX. Integrity

This package does not imply RH, new published priority, a verified 118.365B rank, or an unconditional global reciprocal transfer. Its numerical claims are explicitly assigned to distinct regimes.