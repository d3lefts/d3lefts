# The Convoluted Costs of Knowing — V2 technical/review handoff

**Version:** 2.0 working dissertation, 13 November 2026  
**Manuscript:** 47-page standalone LaTeX/PDF, authored and rendered in the current ChatGPT research session. Exact generated-file SHA-256: PDF \`e6e9a1d5cf235964a0f73cc16ce6230082337d2cefce2815692e1a6976e6aeff\` (**superseded by final typography revision**); final compiled PDF, editable \`.tex\` and exact checker are shared in the same session. Do not treat those container artifacts as present in this GitHub tree until explicitly uploaded.  
**Repository position:** This is a companion to PR #446, not a merger of the 47-page source, a final dissertation submission or an approved original contribution.

## Governing revision

The referee's **major-revision / do-not-submit-as-landmark** verdict is accepted. V2 moves from "multiple costs of knowing" toward the precise research target:

> Prove a non-subsumed, implementation-preserving conversion law on a **fixed base oracle, common target, common risk/soundness criterion**, while paying separately for selecting measurements, acquiring state and model information, performing inference, and checking a certificate.

The history of NIGHTFALL from September oversight and October Proof After Scarcity to November ANOVA/Lean is integrated as a longitudinal **case**, not a proof that our methodology causally improves scientific productivity.

## Revised central mathematics (with exact attribution)

### I. Classical interface conditioning (not a NIGHTFALL priority claim)

For finite-dimensional parameter \(\theta\), compact permitted linear measurement family \(\mathcal M\), linear target \(L\), and a full-dimensional interior parameter neighborhood, define
\[
\kappa_{\mathcal M}(L)
=\inf\{\sum_j |w_j|:L=\sum_j w_j m_j,\ m_j\in\mathcal M\}.
\]
Finite-dimensional polar duality yields
\[
\kappa_{\mathcal M}(L)=\max_{h:\sup_{m\in\mathcal M}|m(h)|\le 1} L(h).
\]
For sufficiently small adversarial per-query error \(\eta\), the exact local worst-case absolute estimation error is \(\kappa\eta\), **even with adaptive queries**; with independent mean-zero Gaussian error \(\sigma^2\) per ideal population observation, \(\lim_{N\to\infty}N R_N/\sigma^2=\kappa^2\) at fixed parameter dimension. Upper design allocates measurements proportional to \(|w_j|\); lower bound uses a dual direction and van Trees. This is a classical **optimal recovery / \(c\)-optimal design benchmark**, with direct antecedents Kiefer–Wolfowitz (1959), Studden (1968), Elfving.

**Source-to-application translation:** Disjoint known Walsh supports \(S_j\) with \(|S_j|=j\); \(|f_a|\le B\) from \(\sum\sqrt{a_j}\le B\); target \(a_d\).

- Homogeneous refresh measurement \(m_t(a)=\sum_{j=0}^d a_jt^j\): \(\kappa=2^{2d-1}\), Gaussian MSE coefficient \(2^{4d-2}\), classical Chebyshev optimum.
- Addressed measurement \(G_a(Q)=a_0+\sum_{S_j\subseteq Q}a_j\): \(\kappa=2\) when supports are known/disjoint, Gaussian coefficient \(4\).
- Same-family ideal Gaussian coefficient ratio \(16^{d-1}\). **Not an unconditional computational lower bound.**
- Full unknown lower-support spectrum, addressed subset-zeta responses \(G(Q)=\sum_{S\subseteq Q}a_S\): \(\kappa=2^d\), Gaussian coefficient \(4^d\), exact deterministic identification needs all \(2^d\) subset evaluations; standard Möbius inversion.

### II. Statistical-query and raw-sample correction (the required adverse control)

The homogeneous ideal population oracle is a **restricted SQ-like query family**, not the unrestricted labeled-example SQ model. For bounded \(|f|\le B\), a coupled pair statistic \(f(X)f(Y_t)/B^2\in[-1,1]\) expresses the homogeneous measurement as a bounded expectation query on a *coupled pair law*; the legal distribution and allowable query language must be declared.

With full i.i.d. labeled samples \((X,f_a(X))\) and **known** character \(\chi_{S_d}\), estimate
\[
\mu=\mathbb E[f_a(X)\chi_{S_d}(X)]=\sqrt{a_d};
\quad \widehat a_d=\widehat\mu^2.
\]
Hoeffding gives \(N\ge(8B^4/\varepsilon^2)\log(2/\delta)\) labeled examples for \(|\widehat a_d-a_d|\le\varepsilon\) with confidence \(1-\delta\): **no exponential degree factor**. The label/source capability is stronger and its cost is not zero in weaker query models. This refutes any universal raw-sample hardness extrapolation.

Mandatory comparison: Kearns JACM 1998/statistical-query origin (conference 1993), Feldman COLT 2017 query tolerances and statistical dimension, restricted SQ vs samples, optimal design, constrained Blackwell/Le Cam (van Rooyen, 31 Oct 2026).

### III. Exact Markov-contract offline/live theorem (INDEX is the comparator)

Latent independent fair coefficient signs \(A=(A_1,\ldots,A_m)\), pre-state data \(D\) produced from \(A\), fresh independent \(K\sim{\rm Unif}[m]\) and fresh fair \(Z_j\), target \(Y=A_KZ_K\). For post-state random coins \(U\):
\[
{\rm Law}(A,D,K,Z,U)={\rm Law}(A,D)\otimes{\rm Law}(K)\otimes{\rm Law}(Z)\otimes{\rm Law}(U).
\]
A fresh-state-only transcript \(T\) measurable from \((D,K,Z,U)\) obeys \({\rm Law}(A\mid D,K,Z,T)={\rm Law}(A\mid D)\): no leakage of model bits from the state transcript. With \(b_j=\mathbb E[A_j\mid D]\), exact risks are
\[
R_0(D)=1,\quad
R_1(D)=1-\max_j b_j^2/m^2,\quad
R_{\ge2}(D)=1-\frac1m\sum_jb_j^2.
\]
With \(q\) distinct **offline** coefficient queries and two state reads, minimum risk is \(1-q/m\). If live model calls are permitted after \(K\), optimal risk under expected call budget \(c\) is \(1-q/m-c\) for \(0\le c\le1-q/m\), achieved by targeting unknown \(A_K\). Exact prediction needs \(m+2\) offline-only calls/reads versus three calls/reads with one live targeted model call. This is a **restricted query benchmark**, not a new one-way communication/INDEX lower bound.

### IV. Genuine independent-product Q2 and the implementation invoice (conditional)

Exact ANOVA/refresh identity:
\[
G_f(Q)=\mathrm{Var}(\mathbb E[f\mid X_Q])
=\sum_{\varnothing\ne S\subseteq Q}\|f_S\|_2^2,\quad
\mathrm{Var}(f)=\sum_{S\ne\varnothing}\|f_S\|_2^2,\quad
I_i(f)=\sum_{S\ni i}\|f_S\|_2^2.
\]
A short finite-product author-analytic **candidate**, not a terminal certified theorem:
\[
\mathrm{Var}(f)^2\le C_2 B^2\max_i I_i(f),\quad
C_2=256(1+\sqrt3)^2,\quad |f|\le B,\quad \deg_H(f)\le2.
\]
Under this hypothesis on all actual positive-support posterior sections, ideal greedy reads \(\lesssim4C_2B^2/\eta\) state coordinates. A sampled oracle implementation with distinct model/state/sample interfaces bounds the reads by
\[
q=\min(n,\lceil32C_2B^2/(3\eta)\rceil)
\]
and charges \(\le2nqs+t\) model-value calls, with \(u=\eta/2,\ K=C_2B^2,\ \epsilon=u^2/(64K),\ \rho=u^2/(32KB^2),\ s=\lceil2B^4\epsilon^{-2}\log(2n/\rho)\rceil,\ t=\lceil2B^2/\eta\rceil\). This is polynomial **oracle-call** accounting, not generic succinct-model runtime.

**Current proof boundary:** main \`2dbfdf7a8f09\` has current-pin scoped merge/tower and real-source Jensen; PR #445 adds strictly compiled active-pin Hilbert vector Jensen (reported strict run 43503541740); PR #444 reports historical 4.33 source-observed greedy first-moment receipt; PR #443 holds a **provisional** owner/orientation identity. Terminal finite Q2 with no supplied matching/energy/amplitude/conditional-section budgets remains uncompiled on current pin; heterogeneous alphabet types, measurable lift, Grothendieck/bilinear subsumption audit and external human review separately open.

## The meta-thesis (from origin, not decorative)

September ASUA: evidence/fibre sufficiency, trust, compute and enforcement ceilings. October PAS: bounded checking resources and an adverse 8/20 retrospective against 11/20 simple baselines. Exact Erdős overlap: changing representation yields a rational finite witness and finite-to-continuum bridge, with distinct eligibility and priority boundaries. Finite-field phase retrieval: adaptivity and quotient representation change queries. Quantum operators: tensor structure creates nontrivial observation penalties and counterexamples. November Q2: a terminal proof needs the **same genuine source** across the matching, section and moment interfaces.

Consequently scientific cost is partly **endogenous to the choice of representations, instruments and proof architecture**. The system can also update its research operator selection policy; whether this improves verified scientific yield remains a **prospective empirical hypothesis**, not an achieved causal theorem.

## Manuscript architecture and status

The standalone V2 technical edition has ~47 pages and 12,492 whitespace-split LaTeX words; it contains **12 chapters + 4 appendices**: task model, prior-art translation, product convolution, classical conditioning, sharp restricted examples, SQ negative control, addressed Markov theorem, Q2 priced observer, epistemic warrant, NIGHTFALL longitudinal study, breakthrough contract, conclusion; appendices give referee response, evidence ledger, decisive experiment, and references.

A separate self-contained exact checker passed **1,108** test assertions (Chebyshev coefficients 36; Möbius 9 + 1,022 perturbations; addressed subtraction 8; Bayes 25; Walsh moments 8). These are finite regression checks, not independent specialist proof review.

**Publishing status:** major revision in progress. No FOCS/STOC/CCC / doctoral acceptance or novelty certificate. Historical predecessor is **separate archival source**, not 76 pages pasted into V2. Do not merge PR #446 as a publication or make a public "new universal law" claim.

## Reviewer lane updates

- **Vesper (editorial):** insist Chapter 4 is a classical **benchmark**, frontload Kiefer–Wolfowitz, Studden, Elfving, Kearns, Feldman and constrained deficiency; don't strip out the original sharp formulas to simplify rhetoric.
- **Axiom (construction):** seek one truly fixed-base, implementable oracle conversion theorem with a robust lower bound surviving the direct labeled estimator, and/or close Q2 terminal source under current exact pin; no supplied energy budgets.
- **Lemnis (adversary):** design independent SQ/INDEX/Blackwell reduction attacks first; try cheap labeled estimators and effect of revealing metadata. Audit all Markov conditional independence statements.
- **Ryev (verification):** reproduce the finite exact checker; print declaration types, axioms, exact source SHA and current pin for any new Lean claim. Historical old-pin receipts stay historical.
- **Tessera (prior art):** print explicit parameter-to-experiment translation and closest dated theorem numbers; separate original statements from inherited classical results and source priority.

This file is a **handoff and revision map**, not confirmation that each parallel session has executed an assigned task.