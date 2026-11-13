# The Convoluted Costs of Knowing
## Information Conversion, Adaptive Access, and the Mathematics of Justified Inference

**NIGHTFALL doctoral monograph — integration draft 0.1, 13 November 2026**

**Research lead:** Devin J. Wright / NIGHTFALL. **Status:** Working dissertation source for cross-instance criticism and composition; **not** a defended thesis, novel contribution certification, or publication. Mathematical statements are qualified individually. The manuscript records AI-assisted research and writing and reserves scholarly review, authorship and submission decisions for the human research lead.

> A fact may be true, a system may encode it, and an observer may still be unable to extract it. A correct prediction may be affordable while identifying the model that made it is expensive. And an algorithm may find an answer that no available certificate can justify. The missing object is not “information” alone. It is the cost of converting the information one possesses into the particular knowledge one needs.

### Abstract

Information is often treated as if its presence were equivalent to its use. In statistical decision theory, computer science, and epistemology, this equivalence fails for different reasons. A representation may preserve all information relevant to a task yet conceal a computationally inaccessible answer; an efficient adaptive observation protocol may not identify an unknown model; a successful test may not produce a universal proof; and a formally verified proof may not be novel or apply to the system its author intended. We study the **task-relative cost of converting information across typed access mechanisms**. A common formal language distinguishes model-value queries, queries of a fresh hidden state, experimental tests, representation changes, and proof-producing or proof-checking operations. Their costs form a vector of resources, not a universal scalar measure of information.

The mathematical spine is the interaction decomposition of independent product systems. Coordinate-refresh conditional expectations commute, allowing a precise Hoeffding decomposition; support-union convolution records how local interactions are assembled, while cancellation and orthogonal projection explain why syntactic support alone is not observability. For bounded degree-two observables, NIGHTFALL's ongoing quadratic influence program seeks a distribution-free bridge from source interaction energy to local observable influence. Existing component-level Lean receipts and source-exact finite audits are substantial evidence, but the terminal arbitrary-law theorem, its rank-sensitive Hilbert extension, and its full adaptive implementation are **not** asserted here to be one end-to-end certified theorem. Alongside this high-risk analytic program, an exact addressed family gives rigorous separations among observation, identification, and testing, with oracle types and loss functions fixed. Certification then adds another independent burden: the cost of carrying evidence sufficient for a particular claim, not merely producing a plausible answer.

This dissertation's prospective original contribution is not a slogan that information has a cost. Information-based complexity, comparison of experiments, statistical decision theory, active learning, and epistemic logic already established that. The original research question is whether **structural interaction constraints yield new, tight and composable quantitative bounds on the conversion between distinct task-specific oracle capabilities**, with certificates that expose the precise boundary of each conversion. The written synthesis and known examples are valuable even if the flagship analytic conjecture is revised; claims of general new theorems require separate proof and priority gates.

---

# Part I — What does it mean to know?

## 1. The mistake of treating access as understanding

Suppose a scientific observer possesses the entire specification of a complex system. The output of interest is mathematically determined. Nevertheless, three questions remain unanswered: which features must be inspected to predict the output of one newly sampled state; which experiments identify an unknown member of a model family; and what evidence proves that the system satisfies an exact universal property? The answers are not interchangeable. Model knowledge may simplify prediction while being unavailable in identification; a state observation may reveal the answer at a point yet prove almost nothing about the model on points never observed. Even a valid proof needs a checker, a type-correct chain of dependencies, and an explicit statement of its scope.

The claim is not that information theory has missed these facts. Rather, the intellectual task is to **keep the access models and conversions visible at every theorem boundary**. A statement about one query model is not silently transported into another by reusing the word “observe.”

Five questions organize the investigation:

1. **What is the question?** Which worlds and outputs are distinguishable by the task's loss?
2. **Where is the relevant structure?** What representation exposes the interactions on which the answer depends?
3. **What access is available?** Which observations are physically or algorithmically admissible, and how can one oracle simulate another?
4. **When should we ask?** Which observations become valuable only after earlier responses, and what must be paid to choose them?
5. **What justifies the answer?** Which evidence establishes the conclusion, and what may a proof checker actually certify?

The five questions are an editorial architecture, **not** a claimed new five-law theorem. The central epistemological insight is operational: truth, implicit determination, practical acquisition and explicit justification are distinct predicates. Classical work on logical omniscience already makes this distinction unavoidable; our task is to supply mathematically priced instances rather than decorate epistemology with algorithmic metaphors.

## 2. Typed knowledge games

Fix a class of admissible worlds \(\mathcal W\), a task target \(Y(w)\), a decision space \(\mathcal A\), loss \(\ell:\mathcal A\times\mathcal Y\to[0,\infty)\), and a family of permitted actions. An action has a **type** and a resource charge. Four primary types recur:

- **TEST**: query an unknown model \(h\) to distinguish a null class from alternatives separated in a specified metric.
- **OBSERVE**: with \(f\) and the input law already known, query coordinates of one fresh hidden state \(X^\star\) in order to predict \(f(X^\star)\).
- **IDENTIFY**: query unknown \(h\in\mathcal H\) at chosen inputs to recover \(h\), its parameters, or an estimator to specified loss.
- **CERTIFY**: produce or check evidence for an exact proposition under an explicitly chosen black-box, white-box, symbolic or formal system.

Model-value calls \(V_h(x)\), fresh-state coordinate reads \(S_{X^\star}(i)\), random-sample draws, computation steps and proof-checking steps are **different capabilities**. A single phrase such as “one query” is meaningless unless it declares which capability is charged. For each algorithm \(\pi\) define a resource vector
\[
\mathbf c(\pi)=(q_{\rm model},q_{\rm state},q_{\rm sample},
              t_{\rm computation},b_{\rm communication},t_{\rm checking}).
\]
Its feasible risk set under access signature \(\mathcal O\) is
\[
\mathfrak R(\mathcal T,\mathcal O)
=\{(\mathbf c(\pi),R(\pi;\mathcal T)):\pi\text{ admissible under }\mathcal O\}.
\]
The **Pareto boundary** of this set is more informative than replacing all resource types by an arbitrary exchange rate. A scalar information cost becomes meaningful only after fixing prices, an accuracy convention and an access model. For prediction we commonly use expected squared error; for property testing a separate error probability \(\delta\) accompanies a fixed distance parameter \(\varepsilon\). Neither may be substituted for the other without an explicit reduction.

A **conversion operator** is a fully specified simulation or transformation from one representation/access interface to another, together with a risk guarantee, cost bound and scope. Its record includes the direction, the required background knowledge, the source of randomness, and the type of evidence preserving its conclusions. Composable conversions give composable *upper bounds* on resources; they do not automatically supply equality, an inverse conversion, or a novel minimum-cost theorem. This distinction is essential: many attractive diagrams of knowledge are merely notation until accompanied by strict inequalities or obstruction examples.

### Proposed central research problem (open)

For a structurally restricted class of independent product observables, determine **when** a cheap model-access or interaction certificate can be converted into a cheap adaptive fresh-state observation protocol, and characterize the extra computational and proof cost of making that conversion executable and certifiable. More strongly, seek restrictions under which matching lower bounds survive changes of representation and oracle signature. This is a prospective original problem, not a theorem proved by definitions.

## 3. Philosophical bridge: from implicit truth to warranted capability

An ideal reasoner who knows all axioms might be described as knowing every logical consequence. Real human and machine reasoners require time, representation, search, computation and evidence. The logical-omniscience objection, algorithmic knowledge and justification logic supply established conceptual foundations. Here a claim of knowing \(P\) should always answer three separate questions: *what is true in the model?*; *what can this observer compute from its interface within a resource bound?*; and *what certificate could a skeptical checker accept?* A YES to the first is not a YES to the others.

This does not reduce epistemic justification to a Lean build. Compilation checks the submitted formal statement relative to a trusted kernel and its axioms; mathematical interpretation, model appropriateness, novelty, dependency identity and consequences for real systems remain separate. The discipline is to carry the exact statement, source identity, assumptions, checker receipt, failure cases and prior-art status alongside each advertised result.

---

# Part II — Why convolution is more than a title

## 4. Interaction as conditional refresh

Let \(X=(X_1,\ldots,X_n)\) have independent coordinate laws \(\mu_i\), and let \(f\in L^2(\bigotimes_i\mu_i)\). Define coordinate refresh
\[
(R_i f)(x)=\int f(x_{-i},z_i)\,\mu_i(dz_i).
\]
These operators are self-adjoint orthogonal projections in \(L^2(\mu)\), satisfy \(R_i^2=R_i\) and commute for independent coordinates. For \(S\subseteq[n]\), the Hoeffding projection is
\[
D_S=\left(\prod_{i\in S}(I-R_i)\right)
    \left(\prod_{j\notin S}R_j\right),\qquad
f=\sum_{S\subseteq[n]}D_S f,
\]
with pairwise orthogonal components. Thus interaction order is not an intuition based on the number of variables appearing in a formula: it is an operator-defined, distribution-dependent decomposition. The degree of \(f\) is the largest cardinality \(|S|\) with \(D_Sf\ne0\), modulo almost-sure equivalence.

**Convolution** appears in at least three precise, nonidentical senses. First, the product-law integration above is a coordinatewise averaging or refresh operation. Second, the combinatorial union-convolution
\[
(a\star_{\cup}b)(U)=\sum_{S\cup T=U} a(S)b(T)
\]
is a legitimate bookkeeping law for the *possible coordinate supports* created when terms indexed by \(S\) and \(T\) are multiplied. It is **not automatically an equality of Hoeffding energies**: recentering, cancellation, and marginalization can move or erase lower-order projections. Third, experiment channels compose as stochastic kernels; their ordering and available intermediate representations matter when conversions incur different resource charges. We must never claim that these three operations are the same algebra. Their shared lesson is narrower and stronger: useful information often depends on what an operation preserves, destroys or makes observable.

The finite union-convolution identities in \`research/nightfall/formalization/swansea_v5/SwanseaV5UnionConvolution.lean\` have a separately reported Lean kernel route in the repository. They support the formal mechanics of the second sense; they do not by themselves prove new observability bounds.

## 5. Influence is an operational quantity, not just a derivative

For real \(f\) with finite variance let
\[
V(f)=\operatorname{Var}_{\mu}(f),\qquad
I_i(f)=\mathbb E[(f-\mathbb E_i f)^2],\qquad
M(f)=\max_i I_i(f).
\]
Here \(\mathbb E_i\) averages only coordinate \(i\). For the Hoeffding expansion,
\[
V(f)=\sum_{S\ne\varnothing}\|D_Sf\|_2^2,\qquad
I_i(f)=\sum_{S\ni i}\|D_Sf\|_2^2.
\]
These are exact identities, not an influence lower bound. Their importance lies in assigning local conditional uncertainty to genuine interaction supports under the actual product law, including zero-mass atoms in finite categorical models.

For a degree-two observable, every nonconstant component is a singleton or a pair. A local score therefore measures energy incident to a vertex of an interaction graph. The challenge is global: can all that energy be concentrated in so many weak interactions that no individual coordinate is useful? Boundedness of \(f\) supplies constraints on simultaneous interactions, but those constraints must be connected to the **same** source law and conditional sections. A proof that assumes the matching, energy or amplitude budgets it needs has not solved this task.

### The flagship analytic bridge — exact status

The current NIGHTFALL program studies finite heterogeneous categorical product laws, \(|f|\le B\), Hoeffding degree at most two, and the target
\[
\boxed{V(f)^2\le C_2B^2\,M(f).}\tag{Q2}
\]
An author-side source-level analytic candidate gives \(C_2=256(1+\sqrt3)^2\) under its stated assumptions. Other drafts seek sharper constants. The repository now contains separately compiled matching, section, greedy ownership, orthogonality, Parseval and moment ingredients, including later 13 November additions. **No universally source-only terminal declaration with all of those hypotheses discharged, under the upgraded current Lean compiler, has been independently established by the source and run checks used for this draft.** Nor has the candidate been established as historically novel. A failure of this gate would affect the strength of the adaptive upper bound, but it would not invalidate the exact separation game in Chapter 7.

The dependency graph that must close is specific:
\[
\text{actual bounded source}
\longrightarrow
\text{canonical pair supports}
\longrightarrow
\text{global matching/8B section constraint}
\longrightarrow
\text{greedy distinct ownership}
\longrightarrow
\text{actual conditional section energies}
\longrightarrow
\text{independent Hilbert increments}
\longrightarrow
\text{fourth moment}
\longrightarrow
(Q2).
\]
The output certificate must include source hashes, the real proof statement with no supplied endpoint budgets, a strict kernel run, a named-declaration/axiom audit, an independent mathematical proof attack, and a same-scope dated literature comparison. New compilation of a sublemma does not automatically promote the chain.

---

# Part III — When observation becomes an algorithm

## 6. From visibility to an adaptive policy

In the **OBSERVE** game the model and input distribution are known. The observer receives no access to the fresh target value \(f(X^\star)\) except through selected coordinates of \(X^\star\). After a transcript \(T\), the optimal squared-loss estimate is the posterior mean \(\mathbb E[f(X^\star)\mid T]\); the residual Bayes risk is the posterior variance.

For a degree-two \(f\), conditional resampling on a revealed coordinate has a precise effect on the remaining degree-weighted ANOVA energy. If the sharp scalar inequality (Q2) holds for every posterior section, an idealized greedy policy can repeatedly choose an influential coordinate to reduce expected uncertainty. Its state-read complexity can be dimension-free at fixed accuracy, but this sentence hides a second bill: how does the algorithm know *which* coordinate is most influential?

The repository's **oracle-implementable** observer explicitly estimates the influence scores from independent model-evaluation samples, chooses the largest estimate, then approximates the posterior mean. Under the assumed Q2 bound and exact sampling/value oracles it yields a cap of \(O(B^2/\eta)\) fresh-state coordinate reads and a polynomial number of model-evaluation calls in the dimension and accuracy ratio. Its source notes specify concentration constants and a conditional expectation calculation. This is a **conditional analytic algorithm**, not a fully certified general running-time theorem: exact real outputs, arbitrary distribution sampling and model evaluation have their own costs.

Thus the proposed cost-of-knowing theorem cannot report only the number of state reads. It must display the *conversion invoice*: model evaluations used to estimate influence, fresh-state reads, random samples, computational work, and verification of the structural assumptions. This is the most direct place for the dissertation's epistemic principle to become a quantitative TCS statement.

### Rank and vector-valued observation

If a target is Hilbert-valued, variance has a covariance spectrum. A rank-sensitive observer can aim to predict the leading \(r\) directions while paying a residual spectral tail \(\tau_r\). Author-side analyses propose risk \(\le\tau_r+\eta\) with state reads scaling as \(O(rB^2/\eta)\), once the scalar quadratic and conditional Hilbert steps hold. This is a programmatic theorem candidate, **not** a substitute for its missing end-to-end proof or for a quantum measurement theorem. It illustrates why output rank, task accuracy and observation type must be carried as separate parameters.

---

# Part IV — Four costs are not one cost

## 7. A single model family, four different bills

Fix \(n\ge2\). Let \(K\) be uniform on \([n]\), and let \(Z_1,\ldots,Z_n\) be independent fair signs. For an unknown sign vector \(\theta\in\{-1,+1\}^n\), define
\[
f_\theta(K,Z)=\theta_K Z_K.
\]
This function is bounded by one, centered, of variance one, and Hoeffding degree at most two: the indicator \(1_{\{K=j\}}\) and sign \(Z_j\) interact only in pairs.

**Known model, fresh-state observation.** If \(\theta\) is known, query the *fresh* state's address \(K\), then the indicated sign \(Z_K\). Exactly **two state-coordinate reads** recover the output with zero squared risk.

**Unknown model, value-oracle identification.** If instead \(\theta\) is unknown, a full-input model-value query at address \(k\) reveals only \(\theta_k\). With \(q\) adaptive model queries and any real-valued \(L^2\) estimator, the exact minimax mean squared error is
\[
R_q=1-\frac{\min(q,n)}{n}.
\]
To prove the lower bound, draw the unknown sign vector uniformly: each unqueried coordinate sign remains an independent fair bit and therefore contributes one conditional unit of squared error at its address. The upper bound queries distinct addresses and predicts zero on the others. Exact identification requires \(n\) value queries. A two-read **state observer cannot be used as an \(n\)-parameter identification oracle** without changing what is known in advance.

**Membership testing.** For an arbitrary bounded \(h:[n]\times\{-1,+1\}^n\to[-1,1]\), draw one address \(K\) and independent sign vectors \(Z,Z'\); query \(h(K,Z)\) and \(h(K,Z')\). Set \(G=Z_Kh(K,Z)\) and \(G'=Z'_Kh(K,Z')\). Reject if \(GG'<1\). On every member \(f_\theta\) the tester accepts with certainty. If \(h\) has squared \(L^2\)-distance at least \(\varepsilon\) from the family, the rejection probability of one two-query trial is at least \(\varepsilon/4\); hence \(O(\varepsilon^{-1}\log(1/\delta))\) trials suffice. This is an elementary consistency tester, **not a claim of a new property-testing technique**.

**Exact certification.** On a wholly unrestricted \(N\)-point black-box domain, any nontrivial universal property that can fail at one hidden point may require \(\Omega(N)\) classical queries to detect with fixed success probability. A concise source-level proof may bypass this bound, but only by supplying a different, privileged evidence type. “Certified from source” and “certified from black-box samples” are distinct claims with different soundness guarantees.

The family is intentionally simple. Its role is to falsify the idea that interaction degree, output rank, model entropy or information content alone determines all four costs. It does **not** prove that the separation is previously unknown. Its exact finite checker already exists at \`research/nightfall/2026-11-information-cost-dissertation/check_addressed_family_exact.py\` and is a reproducibility target.

## 8. Representation, entropy and the geometry of useful questions

A large hypothesis set does not uniquely determine the cost of learning its unknown member. Consider the point indicators \(p_i(x)=1_{x=i}\) and thresholds \(t_i(x)=1_{x\le i}\) on \([n]\). Both give \(n\) possible binary models and have Hoeffding degree one on a single categorical coordinate. Under deterministic exact membership queries, the point family can require \(n-1\) worst-case queries; thresholds require \(\lceil\log_2n\rceil\). The difference is not Shannon entropy or cardinality but the **geometry of admissible splits** of the current version space.

This observation suggests a stronger research target than a general claim about the number of information bits: characterize structural restrictions under which interaction geometry forces balanced query splits, or prove explicit families that violate every proposed restriction. Standard generalized binary search and adaptive submodular methods already study when greedy selection performs well; the dissertation must cite them and isolate an assumption not already covered.

---

# Part V — Why checking is a different form of knowing

## 9. The evidential cost of a conclusion

A successful model prediction is not proof that the model's whole specification is correct. A probabilistic tester's accepted result is not a universal certificate. A finite computational search is not an infinite theorem. A Lean compilation is powerful evidence of a typed formal result, but it does not establish novelty, correct application to an intended informal mathematical problem, or that the claimed theorem was the declaration actually compiled.

NIGHTFALL's provenance practice therefore distinguishes five gates: conjecture, reproducible numerical candidate, source-bound formally checked construction or declaration, independent proof review, and dated prior-art comparison. Each result must carry its exact assumptions, proof dependencies, compiler version, source hash, command/run receipt and known limitations. This is **research-methodology and governance**, not a new axiomatization of truth.

The deeper question is computational: which claims admit short certificates verifiable with an inexpensive checker, and which access restrictions force expensive evidence acquisition? Proof complexity, interactive proofs, proof-carrying code and algorithmic knowledge supply existing theories. Our potential contribution is a case study or a theorem of *typed certificate acquisition* for a restricted class of observability tasks—not an unsupported claim that those theories lacked certification costs.

## 10. The synthesis: an information-conversion frontier

The dissertation's unifying object is the feasible region of **costed, typed transformations**:
\[
\boxed{
\mathcal F(\mathcal T,\mathcal O)
=\{(\mathbf c,R,E):\text{a permitted policy attains risk }R
\text{ with resource vector }\mathbf c
\text{ and evidence type }E\}.
}
\]
A transition between representations or oracle interfaces changes this region. Some transitions decrease the number of fresh-state observations but increase simulation calls; some give a succinct verified proof but demand trusted source access; others replace a hard model-identification task by an easy prediction task, which is not a valid reduction because the target has changed.

A substantive new theory would establish one or more of the following under explicitly checkable hypotheses: a strict optimal conversion law, a separation between two attainable frontiers that survives matching task and guarantee, a structure-sensitive simulation theorem with a matching converse, or a reusable proof certificate that connects a genuine source-level inequality to an executable adaptive policy. Without such a result, the present formula is a **definition and organizing framework**, not a landmark theorem.

This is the promised meaning of *convoluted*: the route from information to knowledge can require several transformations that preserve different invariants. The mathematics of the route, rather than the rhetoric of complexity, is the subject.

---

# Part VI — Limits, research program and conclusion

## 11. Boundaries worth defending

Three boundaries must remain visible. First, distribution-free scalar results on finite product alphabets do not automatically extend to arbitrary measurable products or rank-sensitive Hilbert outputs. Second, query bounds in a model with unit-cost exact evaluation/sampling do not imply polynomial-time algorithms for a succinct or physically implemented model. Third, independent finite audits and successful local Lean receipts do not combine themselves into a new end-to-end theorem or establish originality.

The optional quantum operational-ANOVA case can serve as a **stress test** of the framework in an appendix: it concerns Bayesian gain from fixed subsets of registers under a specified physical measurement model, rather than the same adaptive classical state-oracle task. Any inclusion must state the changed model and compare existing quantum statistical decision theory before claiming a universal law. Agent safety and oversight examples likewise belong where they establish a genuine type mismatch or certificate bottleneck, not as decorative applications.

## 12. What would count as a genuinely new doctoral contribution?

The first goal is a source-derived degree-two finite-product influence theorem with no assumed energy/amplitude budgets, a fully closed same-pin compilation, non-author proof review and a same-quantifier prior-art comparison. The second is an **access-priced adaptive conversion** that includes both state reads and the model-evaluation cost of finding good questions. The third is an impossibility/structural characterization showing when conversion to identification, testing or certification is impossible or must be expensive. Success need not mean proving all three: a single significant new theorem with the others as rigorous limits can support a coherent thesis.

If the quadratic upper-bound theorem fails or is subsumed by earlier work, the dissertation should not camouflage this. Its tested conversion examples and typed-oracle framework may still support an original narrower project, particularly a matched upper/lower access-conversion theorem. If every proposed central theorem is subsumed, the document remains an ambitious research synthesis rather than a claim of new mathematical discovery.

## Closing argument

Knowledge is not the largest collection of truths an observer might in principle derive. For a resource-bounded human or machine, the relevant question is more exact: *which distinctions can this observer obtain, from which interface, at what cost, and with what justification?* Convolution, conditional projection and adaptive observation illuminate how structure can be exposed; query lower bounds show where access cannot be cheaply substituted; formal proof and prior-art discipline explain why evidence must travel with an assertion. The deepest possibility is a mathematics of **costed conversion between these modes of knowing**. The dissertation's task is to prove enough of that mathematics to make the possibility more than a metaphor.

---

# Sources, priority and reproducibility note

This bibliography is a **first-pass map**, not an exhaustive historical novelty audit. Reference titles and links should be checked before thesis submission.

**Established external foundations**

- Packel and Traub (1987), *Information-based complexity*, Nature: https://www.nature.com/articles/328029a0. Related work of Traub, Wasilkowski, and Woźniakowski on radius/cost of information.
- Packel, Traub, Woźniakowski (1992), *Measures of uncertainty and information in computation*: https://www.sciencedirect.com/science/article/pii/002002559290123P.
- Blackwell comparison and Le Cam deficiency: Torgersen, *Comparison of Statistical Experiments*, https://www.cambridge.org/core/books/abs/comparison-of-statistical-experiments/preface/96468C12284FF301F64B262B15DF62CE.
- Golovin and Krause (2011), *Adaptive Submodularity*, https://mlanthology.org/jair/2011/golovin2011jair-adaptive/.
- Hébert and Woodford (2017), *Rational Inattention and Sequential Information Sampling*: https://www.nber.org/papers/w23787.
- Fagin, Halpern and Vardi, computational/epistemic boundaries: https://plato.stanford.edu/entries/logic-epistemic/index.html.
- Halpern and Pucella, *Dealing with Logical Omniscience*: https://www.cs.cornell.edu/info/people/halpern/papers/pragmatics.pdf.
- Classical Hoeffding/Efron–Stein product decomposition, decision trees, property testing, generalized binary search, coding bounds, proof complexity and proof-carrying verification: must be credited specifically at the relevant lemmas in the referee edition.

**NIGHTFALL primary source boundaries**

- \`research/nightfall/2026-11-information-cost-dissertation/README.md\`: prior dissertation design, explicit tasks, and status.
- \`research/nightfall/2026-11-information-cost-dissertation/CHAPTER5_FOUR_COSTS_v1.md\`: addressed family and formal cost separations, with proofs.
- \`research/nightfall/2026-11-information-cost-dissertation/check_addressed_family_exact.py\`: finite exact tester.
- \`research/nightfall/2026-11-quadratic-law-free-audit/Q2_CERTIFIED_MAIN_CHECKPOINT_20261113.md\`: source-matched subproof coverage and open theorem edges.
- \`research/nightfall/formalization/observability/QUADRATIC_E2E_CERTIFICATION_STATUS.md\`: terminal theorem's changing proof boundary; **cross-check against newer source and CI**.
- \`papers/sharp-influence-backdoors/ORACLE_IMPLEMENTABLE_OBSERVER_20261112.md\`: conditional implementable observer and separate model-evaluation charges.
- \`papers/quantum-operational-anova/COST_III_Observability_Recovery_Complexity.md\`: optional distinct-access-model stress test.
- \`docs/lean-certificate-provenance.json\`: historical source-matched ledger, **not** certification of new unregistered modules.

**Review protocol:** Preserve failed proof attempts and numerical counterexamples. Do not infer correctness, novelty, authorship, scientific priority or dissertation eligibility from a green CI badge or from AI agreement. No publication, institutional submission or claims of independent review are authorized by this draft.
