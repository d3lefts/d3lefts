# Working Proof Passport v1 — Test, observe, identify, certify

**Checkpoint:** 2026-11-12. **Scope:** dissertation Chapter 5; **supplementary dossier only** — not a thirteenth active claim and not part of the frozen historical Proof Passports. **Status:** self-contained analytic arguments and one small exact replay, no standalone global novelty/external referee or end-to-end Lean.

## Four different information games

TEST: oracle value access to arbitrary bounded h with sample/hybrid access, decide closeness to a class. OBSERVE: known f and μ, coordinate queries on a *fresh random unknown input*. IDENTIFY: unknown f in a promised model class, freely chosen complete-input model value queries. CERTIFY: exact universal safety under a specifically stipulated black-box, coherent quantum or trusted-source/certificate access model. A cost in one game cannot be silently transferred to another.

## Exact addressed model and certificate

Let K uniform on [n], Z_i iid fair ±1, θ∈{±1}^n unknown. Put f_θ(K,Z)=θ_K Z_K. It is bounded by 1 and has Hoeffding degree ≤2, since

$$f_\theta=\sum_j\frac{\theta_j}{n}Z_j+\sum_j\theta_j(\mathbf1_{\{K=j\}}-1/n)Z_j.$$

With θ known, exact OBSERVE requires two coordinate queries: first K then Z_K. A full-input model value query at address k reveals exactly θ_k. Under uniform prior on θ, the posterior Bayes risk after q distinct model queries is (n−min(q,n))/n; choosing q distinct addresses attains it for every θ, hence the exact **minimax** squared-L² IDENTIFY risk is

$$ R_q=1-\frac{\min(q,n)}n. $$

This example has exponentially many constant-separated models: ||f_θ−f_φ||²=4d_H(θ,φ)/n, and a binary greedy code of relative distance >1/4 has at least 2^{(1−H₂(1/4)−o(1))n} members. Each exact value response remains a single sign bit. This strengthens the separation's precision interpretation but **does not make it a novel flagship theorem**; the construction is addressing plus standard coding bounds.

A one-sided family membership tester uses 2 full-input queries: sample K uniform and independent Z,Z', set G=Z_Kh(K,Z) and G'=Z'_Kh(K,Z'), reject when GG'<1. For |h|≤1, writing m_k=E_Z Z_k h(k,Z), the random L=2(1−GG') lies in [0,4] and E L=2n^{-1}∑(1−m_k²)≥dist²(h,H_n); therefore P(reject)≥dist²/4. At squared-distance ε, 2⌈(4/ε)ln(1/δ)⌉ model-value queries yield rejection at least 1−δ. This TEST checks membership in *this family*, not merely low degree.

### Independent exact finite replay and proof level

The [committed Python checker](../2026-11-information-cost-dissertation/check_addressed_family_exact.py) exhausts all 3^8=6,561 trivalent functions on the n=2 domain, calculating distance and rejection by direct loops. A **separately implemented JavaScript integer enumeration** in the 12 November authoring session checked all 6,561 cases directly: 0 failures; minimum exact inequality slack 0; 64 equality cases. Its code is deposited as [a second-source checker](check_addressed_family_independent.cjs); rerun it in CI before calling the committed file independently reproduced. Finite checks are not an all-n proof.

## General finite-class identification (classical method)

For |h|≤B and a finite model class H of M≥2 hypotheses with pairwise squared-L² separation Δ>0, q i.i.d. μ-distributed full-input model queries distinguish the correct h from every rival with failure probability ≤(M−1)exp(−qΔ/(4B²)). Thus q≥(4B²/Δ)(ln(M−1)+ln(1/δ)) yields exact identification probability ≥1−δ. With a finite answer alphabet a≥2, deterministic exact identification requires q≥⌈log_a M⌉; Fano gives the corresponding randomized uniform-prior lower bound.

Packing alone does not imply a matching worst-case upper: on one uniform categorical coordinate [n], n point functions need n−1 membership queries, while n threshold functions are learned by binary search in ⌈log₂n⌉; both have degree ≤1 and packing n at scale 1/n. A *hereditary response splitting* condition with each response fiber at most (1−γ)|V| yields ⌈ln M/[−ln(1−γ)]⌉ queries. Such a γ cannot follow from degree or packing alone. These are elementary classical-learning deductions, not a new structural classification theorem.

## Degree testing and exact certification are different

For bounded |h|≤B and independent inputs, random 3-way coordinate partition with an 8-value alternating hybrid cube gives

$$E(\Delta_3h)^2=8\sum_{|S|\ge3}\left(1-3(2/3)^{|S|}+3(1/3)^{|S|}\right)\|h_S\|_2^2\ge16W_{\ge3}/9.$$

Since |\Delta_3 h|≤8B, a function at squared-L² distance ≥ε from degree ≤2 is rejected with probability ≥ε/(36B²) per 8-query trial. No citation-priority conclusion is made before comparing low-degree/mixed-difference property testers; the model assumes whole random inputs and hybrids can be generated.

For an unrestricted N-point black-box exact property, a hidden single-input violation costs Ω(N) classical queries or Θ(√N) coherent quantum queries to find with bounded error. Exhaustive access still permits certification; this is a *sub-exhaustive oracle lower bound*, not an absolute impossibility theorem.

## Audit gates and dissertation decision

The first open claim is not "packing classifies identification": the counterexample forbids it. A possible new theorem must impose a concrete query-splitting/interaction-geometry condition not satisfied by point functions. Do not require such a theorem to begin the dissertation.

**PASS for a finite replay** must be independent and record full source bytes and run; **theorem correctness** requires argument review; **novelty** requires a dated same-oracle literature study; **Lean end-to-end** is absent. Departmental choice controls the prominence of AgentDojo and ASUA, not whether they can substitute for a mathematical proof.

See [the complete Chapter 5 note](../2026-11-information-cost-dissertation/CHAPTER5_FOUR_COSTS_v1.md), [the dissertation checkpoint](../2026-11-information-cost-dissertation/README.md), and the [active claim ledger](../../../docs/active-proof-passport.json). Classical Fano, decision-tree search, coding, property testing and Grover/BBBV are credited background.
