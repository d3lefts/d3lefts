# Task-Relevant Distinctions: A Systems-Engineering Synthesis of NIGHTFALL

**13 November 2026 | Research synthesis v0.1 | Devin J. Wright / NIGHTFALL | AI-assisted manuscript construction**

**Purpose.** Apply the research thesis "The cost of justified knowledge is governed not by how completely a system is represented, but by the minimum task-relevant distinctions that must be observed, computed, and certified—and maintained as the system changes" to the **actual** NIGHTFALL portfolio. Identify a common mechanism while preserving different logical quantifiers and model assumptions. Derive a concrete certificate-maintenance theorem, give a falsifier, and prioritize the next potentially original doctoral contribution.

**Status.** The unifying definitions and first lemma are classical (information-based complexity, deterministic test cover, abstraction verification). The Erdős sparse-update theorem below is a complete author-side exact arithmetic derivation, independently tested against direct full recomputation for 1,540 artificial models/44,660 signed-lag comparisons; it has NOT been replayed against the complete frozen 131,072-cell public witness here, is NOT a new upper bound, and is not yet a worldwide-original algorithm. Existing code and tests are archived in this branch. Portfolio-specific larger theorems retain their original evidence tiers; this synthesis does NOT promote them.

## 1. The structure we can use without inventing a universal law

A typed information task comprises (Theta, T, O, L, V, c, Delta):
- Theta: feasible latent states/models with explicit support and provenance.
- T: decision target (value, optimum, prediction, universal proposition).
- O: feasible adaptive experiment/channel; queries have timing constraints.
- L: error/accuracy and quantified confidence, including exact deterministic tasks.
- V: explicit independent verifier and its accepted evidence type.
- c: resource vector (physical reads, model calls, posterior samples, arithmetic, proof verification).
- Delta: admissible model versions/changes and evidence-invalidating dependencies.

The correct frontier is Pareto in resource units. A 100,000-value submission cap, an unknown source distribution, and a Lean import are different constraints; none is erased by calling the output "certified."

**Task distinction:** x ~T y iff T(x)=T(y) for exact deterministic tasks. For a deterministic nonadaptive query family Q, x ~Q y iff every query in Q answers identically on x,y. Then:

**Elementary exact observability lemma.** All tasks T on Theta can be answered without error from the Q transcript iff x~Q y implies x~T y. Proof: the output must be constant on every transcript fiber; if a fiber contains distinct T values, any answer fails on at least one. Conversely define the answer by the fiber's common value.

**Weighted decision-distinction cover.** For finite Theta, queries q with deterministic responses and nonnegative costs c_q, define D_(x,y)={q:q(x)!=q(y)} for every T(x)!=T(y). The minimum total cost of a fixed, nonadaptive exact task-observation set is precisely

    min sum_q c_q z_q
    subject to sum_(q in D_(x,y)) z_q >= 1
    for every pair x,y with T(x)!=T(y), z_q in {0,1}.

This is the classical test-cover/hitting-set equivalence, not an original NIGHTFALL theorem. Adaptive policies are not covered by this equality and can cost less. Statistical and quantum measurement interfaces need different distinguishability metrics; collapsing them into equality classes would be invalid.

The portfolio's recurring *method*, not a universal novelty claim, is:
 
    Problem -> task quotient -> interface -> representation
    -> remaining adversarial completions/posterior fibers
    -> information-selection operator -> costed construction
    -> certificate and independent checker -> update footprint.

## 2. Cross-program transfer ledger: the same method, different mathematics

| Original problem and exact artifact | Task-relevant distinction | Certifier and actual claim status | What transfers to systems engineering; what does NOT |
| --- | --- | --- | --- |
| Four-shuffle: N4=20, 19-length avoiding witness, 302 length-20 graph walks | Only local order comparisons forced by 8-windows; comparisons not determined by the path stay UNKNOWN | Two independently implemented complete finite graph/matching/exact-cover checkers; draft PR #464; global priority and human review still pending | Universal **completion-robust** certificate: every concrete permutation compatible with abstract path has a 12-shuffle; transfer model checking over incomplete states, not a generic probabilistic read bound |
| Sidon 30-point weak (4,5) set, h(B)=17 and 28 critical AP edges | Arithmetic-progression hyperedges, not all possible pairs of integers | Exact 7,801-state proof DAG; independent integer checkers; tau(H)=13 and tau(H-e)=12 for all 28; reader's 5/9 asymptotic pre-exists | Critical evidence dependency: each of 28 constraints is indispensable for THAT explicit no-18 certificate under that edge-oracle, but arbitrary arithmetic sources may infer the same constraint elsewhere |
| Erdős overlap upper witness, mainline frozen 131,072 cells, exact maximum 0.380856370118029325... | All possible signed relative shifts, including off-grid continuum via piecewise-linearity | Mass/box/lag checks, exact rational CRT public release, some rejected Arena submissions; NOT proof of global optimum nor eligibility of all witnesses | Witness-vs-universal-theorem distinction, exact active-shift margins, proof-carrying sparse updates; later 65,536-cell files may be stronger but must be source-identified before claiming current record |
| Degree-2 heterogeneous Q2: Var(f)^2<=C2 B^2 max_i I_i, C2≈1228.3563 | Actual coordinate influence: informative state distinction, not model identifier | Complete author-analytic manuscript and finite rational audits; sublemmas Lean; NO terminal Q2 Lean, human review, or categorical Grothendieck subsumption clearance | An **existence theorem** for an informative coordinate conditional on Q2; NOT an efficient algorithm for finding it or source-visible cost proof |
| Finite heterogeneous all-degree product influence c* Var^(5/2)/(B^3 d^6) | Product Hoeffding interaction and source coordinate resampling | Histor­ically pinned Lean finite statement, depends on Turturean; measurable/infinite and new correlated consequences author-analytic | Transfer only with exact conditioning/source assumptions; never represent imported deep cube machinery as original |
| Posterior-actionable influence | Cross-posterior signal I_i(m_D) versus model uncertainty J_i-I_i(m_D) | Exact conditional-expectation identity; conditional adaptive rates rely on uncompiled Q2, source posterior-call assumption | Distinguish value of sensor for prediction from uncertainty about the model; price posterior calls and state reads separately |
| Group-oracle task revelation A2 (PR #450) | Shared-cost group probes and which future task support will matter | Author-analytic asymptotic KL information-cover primal/dual and finite tests; novelty against sequential design unsettled | Dual information-price certificates; EARLY vs LATE task disclosure changes minimal paid observations, unlike a fixed entropy count |
| Quantum SLD/Jordan comparison | Distinguishable operator directions and noncommutative measurement geometry | Exact condition-number coefficient and physically realized ternary extremizers; analytic proof, two rational finite checks; no world priority clearance | Quantitative price of converting local visibility into global scalar Bayes gain; cannot substitute classical influence/commutative ANOVA |
| Correlation-robust influence / parity camouflage (PR #457) | Actual conditional heatbath influence vs low-order moment agreement | Author-analytic transfer, parity exact obstruction and scripts; no new Lean endpoint | Pairwise correlations can underdetermine actionable sensing; dependence certificate must survive conditioning |
| Recoverable tree innovations and Ising path (PR #461) | Independent edge increments rather than correlated vertex states; physical query recovers path products, not necessarily edges | Sharp additive proof and exact tests; path DP original-to-program, strong overlap with Krause–Guestrin optimal HMM observation | Representation can avoid global likelihood cost, but sensor interface must not be strengthened secretly; no blanket worldwide-first claim |
| Tree-convex and exceptional evidence (PR #456) | Changed trusted dependencies, robust safety margin, minimal trusted receipts | Author-analytic combinatorial safety proof; finite tests; no authenticity of physical provenance from checker alone | Explicit lifecycle dependency graph and exception parameter s; cannot assume signed authentic data or global safe operation |
| Finite-field adaptive phase retrieval | Queries separating signals modulo declared phase equivalence | Analytic finite-field construction and small exact check; no Lean/historical clearance | Another task quotient example; algorithms' arithmetic/measurement interfaces differ fundamentally from stochastic state prediction |

The **unifying invariant** is task-specific distinguishability under a *declared* interface. The **nontransferable elements** are exact-vs-probabilistic quantifiers, model-prior vs realized-state access, global optimality vs feasible construction, and source-law assumptions. Each row is a separate mathematical object with its own certificate.

## 3. New exact lifecycle construction on the Erdős signed-lag certificate

Consider N equal cells on [0,2], rational integer heights A_i/D in [0,1] (0<=A_i<=D), and, when certifying a normalized feasible witness, sum_i A_i=(N/2)D (N even). For integer signed lag k with |k|<N, set

    J_k = {i in {0,...,N-1}: 0<=i-k<N},
    F_k(A) = sum_(i in J_k) A_i (D-A_(i-k)).

The normalized objective is max_k F_k(A)/((N/2)D^2). The continuous-shift supremum equals the discrete maximum because the overlap of equal-width step functions is affine between consecutive grid shifts. This is the original grid-to-continuum lemma, NOT new here.

### Theorem: exact sparse update and stable-maximizer receipt

Suppose an admissible modified witness is A'=A+delta, where delta is supported on S, |S|=m and, when needed, sum delta_i=0. For every signed k,

    F_k(A')-F_k(A)
      = sum_(i in J_k) delta_i(D-A_(i-k))
        - sum_(i in J_k) A_i delta_(i-k)
        - sum_(i in J_k) delta_i delta_(i-k).

Thus the exact update takes O(m) integer arithmetic per k (read changed i and their +/-k neighbors), and ALL 2N-1 signed scores can be updated in O(mN) integer arithmetic, versus O(N^2) for straightforward full direct recomputation. With exact convolution/NTT available the actual strategy should take min(O(mN), O(N log N) plus bit/CRT work); no comparison to a state-of-the-art FFT implementation is claimed.

Let H=sum_i |delta_i|, J=max_i|delta_i|. For every k,

    |F_k(A')-F_k(A)| <= (2D+J) H =: E.

Hence the exact optimum normalized score changes by at most E/((N/2)D²).

If k* is the UNIQUE old maximizing signed lag and

    F_(k*)(A) - max_(k!=k*) F_k(A) > 2E,

then k* remains the unique maximizing signed lag for A'. This is a sufficient stable-peak certificate; if it fails, nothing negative is proved and the exact sparse score update can determine the new winner.

**Proof.** Expand each product (A_i+delta_i)(D-A_(i-k)-delta_(i-k)) and collect terms. Each linear sum has magnitude <=D H because 0<=A_i<=D; the mixed term has magnitude <= J H. For the peak, every score moves by at most E, so every old peak/nonpeak gap shrinks by at most 2E. The grid-to-continuum lemma then yields the updated continuous certificate. QED.

**Falsification evidence.** A separately implemented complete O(N²) integer scorer was compared against the O(m)-per-lag update on 1,540 artificial finite source models (N=2..28) across **44,660 signed lags**, including a mass-preserving example and all cases of the sufficient peak-gap rule; PASS, using Python standard library integers. This is a finite regression of the universal algebraic identity, not a replay of actual frozen heights and not a globally novel dynamic-correlation algorithm.

**Engineering significance.** This is a worked theorem for lifecycle assurance with a costed update operator and an exact old-proof compatibility condition. Model update delta -> unchanged source assumptions -> updated lag evidence -> revalidated scalar bound -> changed proof passport. No new competitive score, full optimum proof, or Arena eligibility is implied.

### Independent audit source

- check_sparse_overlap.py in this directory implements a full direct signed-lag scorer, a separate incremental-update scorer, and safe gap condition.
- The test intentionally does NOT import any earlier Erdős optimized witness or hidden binary; it asserts no new 131,072-cell SHA or latest numerical record.
- To apply to a real frozen witness: load the exact source file by SHA; check N, D, mass, bounds, scoring shift orientation; replay every old lag score; apply authenticated delta; compare changed-lag arithmetic; verify the unique peak or find new ties; freeze new file and source hash. A small unverified "best.json" numerical value must never replace a complete signed-shift certificate.

## 4. Portfolio-level theorem and stronger originality target

The portfolio yields an **observability/certification taxonomy**, not yet a worldwide-new universal information law. An effective doctoral claim needs one theorem that simultaneously handles:

1. A specified physical measurement/experiment interface (not an unpriced influence oracle).
2. A task-specific abstraction and an upper bound for selecting the needed distinctions.
3. A matching lower bound under the **same** oracle, state/model prior, chronology, and accuracy.
4. A certificate checked under an independent source model.
5. A local update rule whose correctness and amortized cost are proved across model versions.

**Proposed signature theorem (OPEN, NOT CLAIMED):** For a structurally restricted class of partially observed, dynamically changing systems, characterize an end-to-end Pareto boundary of (state reads, model evaluations, arithmetic, proof checks, update cost), with a dimension-free (or structural-width-dependent) upper bound and a matching oracle-matched lower bound; certificates remain sound when authenticated changes are restricted to an explicitly computed dependency slice. Show a contrasting family where no such bound holds.

The most useful operator family to attempt is **certificate-preserving refinement of a structural observation quotient**, together with source-local dependency influence bounds. Avoid an unrestricted general-systems claim: chain optimal information selection, CEGAR, Blackwell/Le Cam sufficiency and incremental analysis slicing already have deep prior art.

## 5. Build the dissertation around independent results, not a spurious omnibus

**Dissertation working title:** *The Convoluted Costs of Knowing: Structural Observability, Information Acquisition, and Lifecycle Assurance in Complex Systems*.

- **Core Paper I — Structural access and impossibility.** Exact product/conditional ANOVA and correlated-block/increment representations; prove which interactions remain task-observable, report parity camouflage; finish Q2 certification/subsumption before using its sharper exponent. Strongest current imported Lean finite product theorem explicitly credited.
- **Core Paper II — Information cost at one declared oracle.** Exact A2 KL group-cover law as a strong author-side candidate; posterior-actionable distinction and noise; run same-oracle lower/upper tests, compare closely with sequential design and constrained deficiency.
- **Core Paper III — Proof-carrying lifecycle assurance.** Tree-convex proof certificates and dynamic sparse score certificates; establish evidence dependency authenticity and source-exact verifier contracts, with at least one new general lower/upper theorem about revalidation cost, not merely classical incremental computation.
- **Research case studies, *not* claimed as one unified mathematical proof:** four-shuffle's 302 universal completion certificates, 28 essential Sidon edges, exact Erdős signed-lag witness and derivative, quantum SLD direction-dependent Bayes gain, finite-field phase retrieval equivalence classes. These demonstrate both shared structure and exact boundaries.

**An examiner should be able to remove a whole case study without making the signature theorem false.** Each paper must stand on its own quantifiers, proof, source, verifier and novelty claim. No paper earns originality by placing other valid theorems beside it.

## 6. Independent prior-art gate and no-go tests

Checked primary comparators:
- Blackwell (1953), Le Cam and Traub–Woźniakowski information-based complexity: decision value and information operators are classical.
- Clarke et al., CEGAR: refinement of abstractions and certificate validity are established.
- Krause–Guestrin, IJCAI 2005 and JAIR 2009: exact optimal sensing in chains and hardness in polytrees; do not claim first optimal Ising path sensing.
- van Rooyen, *Beyond Blackwell: Constrained Data Processing Inequalities*, 31 October 2026, arXiv:2611.00510: constrained experiment comparison is actively advancing.
- Liu–Tyszberowicz–Beckert, *Analyses as First-Class Citizens in Model-Driven Development*, FASE 2026: explicit analysis dependency slices and selective recertification predate the portfolio synthesis.
- Turturean 2026: imported full cube AA proof; categorical decoupling prior art still threatens Q2 novelty.
- Dynamic convolution/FFT and elementary maximum-gap perturbation bounds predate the sparse Erdős update; our new application must not be advertised as inventing them.

Mandatory adversarial fixtures:
- An off-grid shift (must collapse to the nearest grid endpoint envelope, not a numerical sampled peak).
- Different lag orientation (must not silently change score).
- A shifted maximum that changes after sparse edit (stable-peak test must reject if gap inadequate).
- Posterior influence with m_D=0 but J_i>0 (must not conflate model energy with actionable signal).
- Parity camouflage (same low-degree moments can conceal zero conditional influence).
- Ising nonadjacent endpoint reads (full Bayes risk can improve without reconstructing an individual innovation).
- Deletion of any one Sidon AP edge (must produce an 18-element survivor), and a four-shuffle partial comparison unfilled by abstract path (must never be guessed).
- A different or stronger oracle (must be priced, not smuggled into an impossibility comparison).

## 7. Novelty/significance/verification ledger

- **Proved within finite mathematical scopes:** 4-shuffle threshold through complete independent computation; Sidon 30 certificate and 28-edge criticality; integer sparse-update identity; exact conditional and finite quantum spectral identities under their stated hypotheses. None thereby gains an external world-priority verdict.
- **Lean kernel receipt for the historical finite theorem:** heterogeneous product all-degree influence, with Turturean credited. Scoped receipts for Q2 sublemmas do not imply a terminal Q2.
- **Author-analytic candidates:** all-alphabet Q2, various source-matched oracle A2 and correlation/quantum extensions; no external expert proof/priority authorization.
- **Numerical record integrity:** distinguish exact complete signed-shift mathematical witness, an eligible competition submission, a leaderboard screenshot, and a historical ranking. Do not claim the frozen 131,072-cell file is necessarily the globally latest as of this note; later candidate files are not reconciled.
- **This synthesis:** demonstrable improvement in research communication, traceable transfer operators and one exact elementary lifecycle algorithm. The overarching jointly optimal oracle-and-maintenance theorem is an **open research target**, not a certified new mathematical law.

**Stop rule:** no further omnibus expansion without an independently new theorem or a comparative experiment that rejects at least one stronger alternative. Preserve this synthesis and its exact source; revise when novelty or validity gates change.
