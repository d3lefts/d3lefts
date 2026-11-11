# Spectral observability: review gates, external precedent, and next experiment

Checkpoint: 10 November 2026 (America/New_York). All references below are public links checked in this session or identified in the supplied v3. No claim of complete novelty search.

## Closest primary and adjacent references

1. David Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773, posted 6 November 2026: scalar influence lower bound Var(f)^(5/2) / d^6 on the UNIFORM BOOLEAN CUBE. The NIGHTFALL finite quadratic arbitrary-product and categorical/Hilbert observation claims are logically distinct and require independent novelty assessment. https://arxiv.org/abs/2611.09773
2. Guy Blanc, Jordan Docter, Carmen Strassle, Li-Yang Tan, *Proof of the Aaronson–Ambainis Conjecture: An Exposition*, arXiv:2611.11626, posted 8 November 2026: exposition and Boolean/quantum-query consequences, explicitly credits Turturean, PSI, and AI-assisted derivations. https://arxiv.org/abs/2611.11626
3. Thomas Huffstutler, David Miloschewsky, Supartha Podder, *A short proof of the Aaronson–Ambainis Conjecture via the completion framework*, arXiv:2611.12795, posted 9 November 2026: deterministic query bound for partial Boolean functions through the completion/adversary framework. This is not a verified precedence for arbitrary-alphabet Hilbert whole-coordinate observation, but it belongs in the direct adaptive-query comparison. https://arxiv.org/abs/2611.12795
4. Filmus, Hatami, Keller, Lifshitz, *On the sum of the L1 influences of bounded functions*, Israel J. Math. 214 (2016): source of Bernstein–Markov oscillation mechanism; the supplied v3 explicitly disclaims priority for that mechanism.
5. O'Donnell–Zhao, *Polynomial bounds for decoupling, with applications*, CCC 2016; Dinur–Friedgut–Kindler–O'Donnell, Fourier-tail paper 2007; Bačkurs–Bavarian, L1 influences 2014; Bansal–Sinha–de Wolf CCC 2022; Escudero Gutiérrez arXiv:2304.06713: Boolean-cube and bounded-polynomial precedents already recorded in v3.
6. Grimmett–Janson–Norris, *Influence in product spaces*, arXiv:1207.1780; Potapov, *On the number of relevant variables for discrete functions* (2025); Kressner–Ni–Uschmajew, volume-sampling vector approximation (2025): adjacent input and output generalizations; not validated as identical theorems.

## Newly detected source correction: Proposition 5.3

The v3 manuscript states for the explicit four-bit bounded degree-three function, without restricting p,

    ||f_12||_infinity + ||f_34||_infinity = 8(1-p)^3.

That formula is FALSE on 1/2<p<1 because the maximizing pair symbol switches from (1,1) to (0,0). The valid all-p equality is

    ||f_12||_infinity + ||f_34||_infinity
      = 8(1-p) max(p,1-p)^2.

For example p=3/4 gives 9/8, whereas the v3 formula gives 1/8. The original three exact-rational replay points p=1/10, 1/100, 1/1000 all miss the error. The original stated limiting obstruction as p->0 remains valid. This is a **scope correction, not a refutation of the obstruction or the quadratic matching theorem**.

Independent analytic formula: f_12(a,b) = 4(1-p)(a-p)(b-p), and f_34 is symmetric. See selector_pair_symbolic.py for independent exact all-four-symbol ANOVA coefficient checks and rational boundary cases.

## New quantitative improvement in selector theorem

The supplied v3 bound has log(e+3B^2/M). For f=sum Y_k g_k with degree(g_k)<=2, the total *X-coordinate* influence P=sum_j,k I_j(g_k) is at most **2W**, not 3W. The factor 2 is sharp for a one-leaf pure quadratic selector. Thus the same existing argument proves log(e+2B^2/M) with unchanged outer constant. The general exponent-alpha form is in SELECTOR_LIFT_V4.md.

## Certificate and reproducibility gates

- **Verified this session:** original source ZIP SHA256SUMS; four supplied exact-Python arithmetic tests; new independent exact-polynomial code on four-bit obstruction; analytic derivation of selector influence-budget tightening.
- **Not verified:** global originality; external non-author mathematical review of all spectral/adaptive proofs; Lean formalization of the v3/v4 end-to-end claims; production efficiency of query policies; universality of a cubic fourth-moment certificate.
- **No promotion:** do not label the rank-adaptive quadratic theorem, categorical minimax theorem, or general selector lift as peer-reviewed or kernel-checked. Passing the exact finite checker cannot certify those infinite/all-law claims.
- **Source policy:** this branch archives a curated derivative and exact checker. The original PDF and ZIP are identified by hashes in README but have not been attached to the public Git tree. Avoid claiming a downloadable original archive asset exists.

## Pre-registered next decisive test

**Target:** establish or refute universal constants K,kappa and assignment sets A_i in v3 Theorem 5.5 for all bounded degree-three scalar product functions.

**Prediction:** top-degree triple matching alone does not control assigned pair/link fourth moments; any successful route must account for degree-three cancellation of pair sections.

**Competitor:** skewed two-bit-pair configurations with cubic links defeat bounded assignment-cost; either explicitly produce a growing lower bound in family size or exhibit uniformly bounded cost.

**Cheapest test:** exact finite polynomial/LP instance with four and six coordinates, several skewed rational laws, and explicit candidate assignments; force exact post-verification of any floating solver witness. Do not confuse local optimizer failure with counterexample.

**Stop rule:** if the 4-/6-coordinate searches give no structural separation, avoid repeated parameter sweeps; switch to a hypergraph-link duality/operator proof. A complete dimension-independent (K,kappa)-certificate plus independent check would satisfy the mathematical next gate; a handful of finite successes would not.

Mechanism -> scope -> certified check -> failure mode -> transfer should remain in versioned history. Preserve v3 as source, this correction as v4, and any later supersession with explicit reason.
