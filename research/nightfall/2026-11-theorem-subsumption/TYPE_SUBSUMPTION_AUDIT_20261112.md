# NIGHTFALL — theorem-type subsumption and representation-bridge audit

**Audit date:** 2026-11-12. **Source-of-record:** linked Lean declarations at immutable Git commits. **Status:** independently inspected static theorem statements and source-level proof dependencies; **not** an end-to-end Lean compilation of cross-repository imports, human mathematical review, or a worldwide priority certificate.

## Contract, scope and stopping rule

**Objective.** Decide which externally compiled theorems can be inherited, which require a proved change of representation, and which do not imply the NIGHTFALL target at their actual types. Test the source theorem rather than title or thematic analogy.

**Finite feasible scope.** Fifteen selected theorem comparisons covering: product influence and Efron–Stein degree, low-degree moments, conditional-section selection, model/state Bayes risk, sufficiency, interpolation, passive support, entropy/quantum observability, and Sidon/decision quotient, including Cramér–Wold measure identification. This is *not* an exhaustive audit of every named theorem in the 67-source NIGHTFALL registry or the five declarations in the paper-local PR #418.

**Source rules.** A subsumption verdict requires checking domains, law supports, boundedness, degree, rank, loss, oracle, quantifiers, dependence on constants, and compiler/toolchain. “Direct” means an already linked application in compiled NIGHTFALL source or a signature compatible by definitional simplification. A “representation bridge” is a mathematically explicit but **not necessarily compiled** map between types/definitions. “Not subsumed” means a missing essential premise or conclusion, even if the source is a powerful theorem. A date/priority verdict requires more than this audit.

**Strongest comparators.** Turturean’s physical-superintelligence/aaronson-ambainis at pinned source 2a6ceaef872ae993708950f951989134084b851a; Polarnova/FABL at 164f830312946ccac6e7fdc7bb9493f0149e820d; LeanInfoTheory at 2eb80d0e746688511618aaefc2624ffa4ae88f6e; Mathlib v4.35.0 at 56a005855ea17e0b0958f73ec801ae140b0a1679; General Courtade–Kumar at 68cd46b433a1003f06a5c3ee39df2af1a4a314e1; plus the exact other source coordinates below.

**Best already compiled NIGHTFALL statements.** The actual finite normalized arbitrary-product degree-two theorem in QuadraticHoeffdingBridge is the inherited exponent-5/2 baseline, not exponent two. The paper-local FixedObservationSelector has five strict Lean 4.35.0 declarations with an exact-type contract; its beta bound explicitly assumes the section budget. The arbitrary-law source-function global matching/amplitude inequality and terminal exponent-two implication are **not** compiled.

**Novelty threshold.** A theorem is not an original mathematical finding merely because NIGHTFALL re-proved it in Lean, changed representation, or transported it from another library. “Bridge needed” is a proof-engineering classification, not a claim of mathematical novelty. Novelty requires a same-scope dated literature check and a mathematically substantive new implication. No theorem is promoted here.

**Independent audit and stop rule.** Static signatures are checked against source blobs; deliberate counterexamples distinguish assumptions and nonimplications. There is **no cross-project kernel replay** in this audit. Stop after finding a decisive hypothesis mismatch rather than forcing a purported reduction; require a single-pin compiled exact-type bridge before changing any “candidate bridge” status to “compiled bridge”. Do not compile Courtade–Kumar’s approximately 45,500-module project merely to verify its already published typed statement.

## Claim-by-claim classification

| ID | NIGHTFALL target | External exact declaration / best prior art | Classification | Decisive type boundary |
| --- | --- | --- | --- | --- |
| T01 | Product-space exponent-5/2 influence | Turturean DetInequality/antipodal and level integration imported by ProductInfluence | **INHERITED + COMPILED BRIDGE** | NIGHTFALL already invokes its finite-product theorem; arbitrary coordinate weights and zero-mass atoms are transported, not a new exponent |
| T02 | Degree-two Efron–Stein to indicator-monomial baseline | NIGHTFALL EfronSteinDegree + ProductInfluence; external Hoeffding theory | **INTERNAL COMPILED BRIDGE** | Hoeffding component degree and algebraic indicator degree are not definitionally identical; the local iff theorem supplies the bridge |
| T03 | Quadratic exponent-two bound V² ≤ C₂B² max Iᵢ | Turturean/FABL/Mathlib low-degree results | **NOT SUBSUMED / UNCOMPILED TARGET** | Fifth-power inherited exponent, binary-only hypercontractivity or moment inequalities do not yield the arbitrary-law exponent-two matching estimate |
| T04 | Conditional-section fixed-q selector | NIGHTFALL FixedObservationSelector; classical sorted-tail algebra and Mathlib inequalities | **COMPILED CONDITIONAL ARITHMETIC** | Actual top-q choice, β(f), source L1 budget and ANOVA risk identity are not inputs constructed by that certificate |
| T05 | Arbitrary-law centered Hilbert fourth moment | FABL ReasonableProductPolynomials product fourth-moment recursion | **HYPOTHESIS MISMATCH; BRIDGE NEEDED** | The external recursion assumes zero third moment of the first coordinate, false for biased centered Bernoulli |
| T06 | Finite independent weighted product probability space | LeanInfoTheory PMF.finiteProduct, Mathlib PMF | **REUSABLE FOUNDATION; BRIDGE NEEDED** | Convert real table masses to ENNReal PMFs, common alphabet to dependent alphabets, and the product pointwise mass/expectation |
| T07 | Exact Bayesian model/state L² risk splitting | Mathlib condExpL2 orthogonal projection and tower; LeanInfoTheory Markov/conditional laws | **REUSABLE OPERATOR; BRIDGE NEEDED** | Fresh-state independence and nonanticipatory transcript sigma algebra must be constructed; Shannon sufficiency alone is not a square-loss identity |
| T08 | Family sufficiency and information preservation | LeanInfoTheory IsSufficientStatistic, common recovery channel, Fisher–Neyman | **INHERITABLE FOR SUFFICIENCY ONLY** | One shared recovery channel for every model parameter is not the same as task-relative low Bayes risk or bounded-query observation |
| T09 | Exact identification D_d evaluations and deterministic safety D_d lower bound | Finite evaluation functional/linear algebra; LeanInfoTheory Fano | **NEW FORMAL BRIDGE NEEDED; CLASSICAL MATHEMATICS** | A dimension/nullspace oracle lower bound assumes chosen exact-real function evaluations; Fano’s finite-alphabet information bound has different assumptions |
| T10 | Passive equality detection P(h ≠ 0) ≥ α^d | Mathlib MvPolynomial.schwartz_zippel_sup_sum and Reed–Muller distance | **NOT A DIRECT COROLLARY; GRID BRIDGE NEEDED** | Schwartz–Zippel controls zeros by d/size and does not directly give the sharp low-degree support floor α^d for arbitrary real functions of finite categorical variables |
| T11 | Noisy Boolean observability/information cost | General Courtade–Kumar final theorem | **INHERIT FOR ITS OWN MODEL; NOT SUBSUMPTION** | Uniform Boolean cube, binary-symmetric noise and mutual information in bits; not arbitrary product laws, adaptive coordinate MSE or query budgets |
| T12 | Quantum SLD local visibility and tensor sharpness | Lean-Quantum sandwiched Rényi DPI/SSA; Physlib quantum operations | **GEOMETRIC BRIDGE NEEDED** | Data processing for Rényi entropy is not the SLD inverse Jordan quadratic form Q_b(H)=Tr(H J_b⁻¹H); no verified Hessian/metric identification or tensor constant from this audit |
| T13 | Sidon (4,5) finite witness/forcing | Singer’s theorem formalized in Erdos30/SingerTheorem.lean | **INCOMPARABLE PREDICATES; NO SUBSUMPTION** | Modular Sidon pair-sum uniqueness is a construction theorem; NIGHTFALL (4,5) asks a separate finite largest Sidon subset / progression pattern predicate |
| T14 | Task-relative exact decision quotient / certification | Simas optimizer quotient and complexity programme | **PRIORITY COMPARATOR; EXACT LEAN TYPE UNREAD** | Published Lean artifact is in Zenodo bundles; exact source theorem not inspected here. The optimizer-quotient decision relation is not automatically the four oracle/loss tasks of NIGHTFALL |
| T15 | Identification of a probability law from halfspace measurements | EPFL Cramér–Wold cramerWold and cramerWold_parametric | **INHERIT ONLY FOR FULL HALFSPACE MEASUREMENT MODEL** | Equality on all closed halfspaces of a positive-dimensional real Euclidean space implies equality of probability measures; this does not give finite-coordinate oracle query complexity |

### T01–T03: the precise influence boundary

NIGHTFALL [ProductInfluence.lean](https://github.com/d3lefts/d3lefts/blob/90d839036b0fdffb4c609b68d7b0de1ae694ace9/research/nightfall/formalization/product_space/ProductInfluence.lean#L1337-L1350) states: nonnegative normalized coordinate masses pᵢ(a), |f|≤1, finite indicator-monomial degree≤d, positive product variance V; then ∃j, 3V⁵ ≤ 12500(π²d²)⁶ Iⱼ². It imports the external [Turturean antipodal, packing, and integration modules](https://github.com/physical-superintelligence/aaronson-ambainis/tree/2a6ceaef872ae993708950f951989134084b851a/AaronsonAmbainis). Its contributions are the explicit transport of the known proof mechanism to product weights and alphabets. The baseline is thereby *already inherited*.

[QuadraticHoeffdingBridge.lean](https://github.com/d3lefts/d3lefts/blob/90d839036b0fdffb4c609b68d7b0de1ae694ace9/research/nightfall/formalization/product_space/QuadraticHoeffdingBridge.lean#L86-L110) adds ESDegreeLE p f 2, permits zero variance, and uses the exact local equivalence to product degree in [EfronSteinDegree.lean](https://github.com/d3lefts/d3lefts/blob/90d839036b0fdffb4c609b68d7b0de1ae694ace9/research/nightfall/formalization/product_space/EfronSteinDegree.lean#L365-L390). This is a **compiled internal bridge**, not evidence of exponent two.

The proposed V² ≤ C₂B² max Iᵢ has a different variance exponent and arbitrary-law quantifiers. Neither Turturean's compiled fifth-power result nor the [FABL degree-k sign-cube Lq growth theorem](https://github.com/Polarnova/FABL/blob/164f830312946ccac6e7fdc7bb9493f0149e820d/FABL/Chapter09/ProductHypercontractivity.lean#L866-L891) implies it with constants independent of coordinate bias and alphabet. The source-to-matching parity/energy closure is still the decisive open implication. No PR or green support lemma changes that.

### T04: finite selector versus the function theorem

[FixedObservationSelector.lean](https://github.com/d3lefts/d3lefts/blob/90d839036b0fdffb4c609b68d7b0de1ae694ace9/papers/conditional-section-duality/lean/FixedObservationSelector.lean) proves the finite disjoint-block inequality

4 |S| ∑_(i∈T) aᵢ² ≤ (∑_(i∈S∪T) aᵢ)²

assuming S nonempty, aᵢ≥t on S, 0≤aᵢ≤t on T, S∩T=∅. With the **additional premise** β ∑aᵢ≤2d²B, it proves β²|S|∑_(i∈T)aᵢ²≤d⁴B². Exact-type receipts: [run 43285738660](https://github.com/d3lefts/d3lefts/actions/runs/43285738660).

**Unproved in this Lean source:** existence of top-q set S for actual influences; the true conditional-section L1 budget Σ E[sᵢ]≤2d²B; deducing βΣ√Iᵢ≤2d²B; and the actual ANOVA identity upper-bounding Bayes risk by the omitted Iᵢ. The *arithmetic* is compiled, the *source-function theorem* is not. Calling this an entirely new mathematical selector bound would be unsound without prior-art review.

### T05: exact obstruction to naïvely importing FABL fourth moments

[FABL product fourth-moment recursion](https://github.com/Polarnova/FABL/blob/164f830312946ccac6e7fdc7bb9493f0149e820d/FABL/Chapter09/ReasonableProductPolynomials.lean#L212-L236) requires both E[X]=0 and E[X³]=0 for the selected coordinate. A centered Bernoulli random variable Z=B−1/4 with P(B=1)=1/4 satisfies E[Z]=0 but

E[Z³]=(1/4)(3/4)³+(3/4)(−1/4)³=3/32≠0.

The exact rational equality was independently recomputed during this audit using Python Fraction. Thus no unrestricted arbitrary-law transfer of that *particular* FABL recursion is valid without an additional term or a replacement argument. Scalar hypercontractivity on a fair cube has a separate bias restriction. This is a **genuine representation/theorem-hypothesis obstruction**, not proof that the whole external FABL library lacks another applicable theorem.

### T06–T08: probability and information representation

[LeanInfoTheory PMF.finiteProduct](https://github.com/serhatemrecoban/LeanInfoTheory/blob/2eb80d0e746688511618aaefc2624ffa4ae88f6e/LeanInfoTheory/Probability/FiniteProduct.lean#L45-L90) constructs a product law on dependent finite alphabets, establishes product-atom identities and coordinate marginals. It is a stronger *representation* foundation than manually duplicating every real-mass product sum. To reuse it for NIGHTFALL, prove from pᵢ(a)≥0 and Σₐpᵢ(a)=1 that the ENNReal PMF family μᵢ has μᵢ(a)=ofReal(pᵢ(a)), and the Real coercion of μ.finiteProduct x equals ∏ᵢpᵢ(xᵢ). Then transport coordinate-averaging, resampling and conditional means. **No such cross-library bridge was compiled in this session.**

[Mathlib 4.35.0 condExpL2](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/MeasureTheory/Function/ConditionalExpectation/CondexpL2.lean) *defines* conditional expectation in L² as an orthogonal projection. This is the correct operator for our Bayesian model/state Pythagorean law. The bridge must build the joint law of (Θ,D,X,T), prove D independent of fresh X and T measurable with respect to D plus revealed X, establish the posterior-mean residual has zero conditional expectation, and specialize orthogonal projection to

E||f_Θ(X)−E[f_Θ(X)|D,T]||²
 = E_D U(D) + E||m_D(X)−E[m_D(X)|D,T]||².

The formula is classical conditional-variance orthogonality, but **the exact oracle filtration and source-model specialization have not been compiled**.

[LeanInfoTheory IsSufficientStatisticOf](https://github.com/serhatemrecoban/LeanInfoTheory/blob/2eb80d0e746688511618aaefc2624ffa4ae88f6e/LeanInfoTheory/Shannon/SemanticBridge/Sufficiency.lean#L55-L114) is the reverse Markov-chain condition Θ→T(X)→X, equivalent under finite value types to vanishing conditional mutual information. The [family-level Fisher–Neyman theorem](https://github.com/serhatemrecoban/LeanInfoTheory/blob/2eb80d0e746688511618aaefc2624ffa4ae88f6e/LeanInfoTheory/Shannon/SemanticBridge/Sufficiency.lean#L711-L731) characterizes a shared all-model recovery channel via factorization. **Inherit these sufficiency statements rather than reproving them.** However, parameter sufficiency is not a query-complexity upper bound, and preservation of one specified square-loss prediction is weaker than reconstructing the full model family.

### T09–T10: identification and the safety predicate

Our note's exact chosen-model-value oracle dimension is D_d=Σ_(|S|≤d)∏_(i∈S)(|Aᵢ|−1), with D_d evaluations necessary/sufficient for exact deterministic identification in the bounded real degree-d vector space. This follows from finite-dimensional evaluation rank and an all-zero transcript nullspace argument. **No inspected external declaration was a drop-in Lean theorem about this particular query model**; use Mathlib linear evaluation maps, quotient spaces and Finset rank, with an explicit basis/decoder. Fano bounds on finite-valued observations **cannot** directly prove a chosen exact-real-valued evaluation lower bound without a separate restriction on information per reply.

The equality-testing support claim P(h≠0)≥α^d (nonzero h on the product support, degree≤d, every supported atom≥α) is related to Reed–Muller distance and polynomial identity testing. But [Mathlib.schwartz_zippel_sup_sum](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/MvPolynomial/SchwartzZippel.html) is an *upper bound on the zero set* in terms of multivariate polynomial degrees and grid sizes. It does not directly provide this sharp α^d lower mass on arbitrary finite categorical product laws. Prove a categorical interpolation/section-difference bridge or the short direct induction. The violation indicator of a thresholded degree-one score can have full interaction degree n; one may not replace a degree promise on the **violation function** with a promise on the numerical score.

### T11–T15: genuine type nonimplications and priority threats

[General Courtade–Kumar](https://github.com/dpwoodru/general-courtade-kumar-lean/blob/68cd46b433a1003f06a5c3ee39df2af1a4a314e1/GeneralCK/Statement.lean#L12-L41) asserts, for every Boolean f on a uniform n-cube and binary-symmetric crossover p∈[0,1], I(f(X);Y)≤1−h₂(p). Its [final audit](https://github.com/dpwoodru/general-courtade-kumar-lean/blob/68cd46b433a1003f06a5c3ee39df2af1a4a314e1/FinalCheck.lean) checks the final statement and axioms. This is a complete result for *noisy Boolean mutual information*, not a statement about arbitrary product laws, conditional squared error or adaptive query budgets. No subsumption without a channel-to-observation/loss model theorem.

[Lean-Quantum's comparator challenge](https://github.com/Hayata-Yamasaki-Group/lean-quantum/blob/a1256b75b8df99c8b2112a771f5a470d5e06648e/ComparatorChallenges/Paper1.lean#L257-L297) states sandwiched-Rényi data processing for CPTP maps and SSA. Its challenge file contains deliberate statement-only sorry markers; inspect the **solution** and independent comparator records for proof status, not the challenge alone. These statements do not **directly** imply our proposed SLD inverse-Jordan simple-tensor inequality or the SLD-versus-geometric-metric tensor transfer. An operator-theoretic identification of an appropriate Hessian/metric plus exact normalization, Hermitian spectral orientation and product-state conditions would be required. Do not conflate quantum chi-square kernels and monotone metrics.

[Singer's modular Sidon theorem](https://github.com/d0d1/singer-theorem-lean/blob/0c890589afc58e8955a5d7c3a609daff6447da31/Erdos30/SingerTheorem.lean) proves existence of a modular Sidon set of size p+1 modulo p²+p+1 for prime p; it does not answer NIGHTFALL's finite (4,5) largest-subset predicate. Keep the construction as context, not a reproduced certificate of our finite objective.

[Simas's decision-quotient work](https://arxiv.org/abs/2603.14689) is a potentially **direct novelty and conceptual comparator**: exact decision-preserving equivalence and static/stochastic/sequential certification. However, the current research session accessed the manuscript metadata and Zenodo source-bundle description, **not the individual Lean declaration types in that ZIP** (the archive was inaccessible via available source fetch). Accordingly, no Lean-level subsumption judgment is made. A true audit must retrieve the dated source artifact, identify the exact quotient/factorization declaration and compare the optimizer-set quantifiers with our four task/oracle models. Treat the conceptual uniqueness claim as **priority at risk**, not as established original.

[EPFL Cramér–Wold cramerWold](https://github.com/epfl-lara/AutoformalizedProjects/blob/6f4606c1b9d51a158c8768613a65816b1f0a6eb0/CramerWoldTheorem/CramerWoldTheorem/MainTheorem.lean#L26-L45) is a complete Lean theorem on probability measures over nonzero-dimensional RealEuclideanSpace n: agreement on every closed halfspace entails μ=ν. The companion [cramerWold_parametric](https://github.com/epfl-lara/AutoformalizedProjects/blob/6f4606c1b9d51a158c8768613a65816b1f0a6eb0/CramerWoldTheorem/CramerWoldTheorem/MainTheorem.lean#L56-L69) converts normal/threshold measurements to the same conclusion. This is a **genuine measurement-identification comparator**, but observing all halfspace probabilities is not the finite selected-coordinate/value oracle model. Neither a q-query bound nor Efron–Stein interaction degree is present in its statement. The relevant next bridge would be an explicitly restricted finite measurement family with a quantitative error metric; do not infer it from the complete infinite-family theorem.

## Compiler compatibility and custody

| Source | Checked pin or revision | Reuse constraint |
| --- | --- | --- |
| NIGHTFALL active main | 90d839036b0fdffb4c609b68d7b0de1ae694ace9; Lean 4.35.0/Mathlib 4.35.0 (and separately historical 4.33.0) | Source identity and strict receipts must accompany any claimed proof |
| Turturean Aaronson–Ambainis | 2a6ceaef872ae993708950f951989134084b851a; Lean 4.33.0 | Already imported in some existing NIGHTFALL 4.33 proofs; 4.33.0 has known patched-kernel concerns; replay under ≥4.33.1 separately |
| FABL | 164f830312946ccac6e7fdc7bb9493f0149e820d; Lean 4.32.0 | Not a drop-in import to NIGHTFALL 4.35; port/prove adapter under one pin |
| LeanInfoTheory | 2eb80d0e746688511618aaefc2624ffa4ae88f6e; Lean 4.33.1 | Its finite PMF and sufficiency types can guide a 4.35 Mathlib adapter; cannot assert a same-workspace build |
| TCSlib | dead9dc88967b25c7aa2db950740ba7b2d74b67e; repo lean-toolchain 4.25.0 | Compare statements; port dependency if actually needed |
| Mathlib v4.35.0 | 56a005855ea17e0b0958f73ec801ae140b0a1679 | Same pin as current NIGHTFALL; preferred for foundational conditional expectation and algebra |
| General Courtade–Kumar | 68cd46b433a1003f06a5c3ee39df2af1a4a314e1; Lean 4.33.1 | Complete proof, different objective and very large build; avoid unnecessary rebuild |
| Lean-Quantum | a1256b75b8df99c8b2112a771f5a470d5e06648e; Lean 4.29.0-rc6 | Check challenge/solution boundary; metrics require fresh bridge |
| Singer theorem | 0c890589afc58e8955a5d7c3a609daff6447da31; Lean 4.29.0 | Different extremal predicate |
| EPFL Cramér–Wold | 6f4606c1b9d51a158c8768613a65816b1f0a6eb0; Lean pin not independently retrieved in this audit | Exact Euclidean-probability measure theorem, different measurement oracle |

Source file blob SHA-1s and exact names are available in each immutable linked file. Checked compiler pins are **read from repository toolchain declarations**, not inferred from theorem titles. Links are documentary verification; this session did not launch a cross-library build.

## Ordered, falsifiable next bridge experiments

**Priority 1 — PMF/product/conditional expectation interoperability.** Prediction: with actual nonnegative normalized pᵢ, the finite real product-mass and conditional expectation declarations agree with the Mathlib PMF product after a Real↔ENNReal adapter, including zero atoms. Checker: pin Lean 4.35.0/Mathlib 56a005..., exact-type contract; perturb p to include zeros and heterogeneous alphabets. Result: if compilation succeeds, de-duplicate many transport lemmas and standardize the observable semantics. Stop if coercion requires positivity not available at zero atoms; revise scope rather than assuming it.

**Priority 2 — source-specific Bayes orthogonality.** Prediction: the NIGHTFALL Bayesian model/state risk split is a corollary of L² orthogonal projection plus the nonanticipation law Θ ⫫ X | D. Alternative: online model queries destroy the fixed-D conditional independence; the signed-address construction is the adversarial test. Checker: compile the exact joint PMF and conditional expectation equality and compare exhaustive finite rational models. Stop on any hidden conditional-independence hypothesis.

**Priority 3 — sharp support lower bound.** Prediction: induction on nonzero section differences yields α^d, including heterogeneous weights and zeros outside support. Reject a proposed shortcut via Mathlib Schwartz–Zippel if it only obtains 1−d/|A| or implicitly assumes field-valued alphabet encodings. Checker: exact finite algebra and an explicit strict theorem type.

**Priority 4 — arbitrary-law fourth moment.** Keep FABL's hthird=0 case as inherited. Prediction: a general recursion has additional E[X³] terms; test centered Bernoulli 1/4 (3/32). Checker: symbolic expansion under arbitrary normalized p, then Lean 4.35 exact moment statement for Hilbert vectors. This is more useful than another fair-sign moment proof.

**Priority 5 — original quadratic endpoint.** After source-function Efron–Stein-to-matching and Hilbert budget bridges are compiled on one pin, check the exact variance-squared declaration. Do **not** promote an algebraically conditional matching statement as proof of the function theorem.

**Priority 6 — Quantum SLD.** First prove the metric identification between relevant finite-dimensional Jordan-inverse quadratic forms and the selected external monotone-information quantity under faithful average states; then test tensor products and Hermitian orientation. A paper-level similarity to a quantum DPI cannot replace this.

## Status and handoff

- **Verified from actual source signatures:** local exponent-5/2 and degree equivalence, selector with explicit budget assumption, FABL third-moment requirement, LeanInfoTheory product and sufficiency API, Mathlib L² conditional-expectation projection, Courtade–Kumar target, Singer target, quantum Rényi DPI comparator.
- **Independently falsified direct reduction:** biased centered Bernoulli third moment 3/32, so zero-third-moment FABL recursion cannot be imported unrestricted.
- **Source/infrastructure limitation:** external repositories differ in Lean and Mathlib pins; Simas Lean ZIP source not retrieved; no cross-repo exact-type project was compiled.
- **Mathematical conclusion:** none of the inspected external final declarations directly certifies the all-law exponent-two influence theorem, rank-r adaptive observation bound, or SLD tensor sharpness. This is a scoped negative *reduction audit*, not proof of global novelty or nonexistence of another theorem.
- **Next certification gate:** formal, source-exact PMF-to-real product transport under one pinned compiler; preserve the exact theorem type and independent source digest.

**No submission, research priority promotion or change to the current 67-source certificate registry is authorized by this audit.**