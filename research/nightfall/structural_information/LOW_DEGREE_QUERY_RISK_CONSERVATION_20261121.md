# Local moment conservation for bounded-degree decision-tree simulation
**NIGHTFALL research checkpoint v1.0 — 2026-11-21/22.** Status: complete short mathematical proof, exact rational regression below, NOT Lean-certified or priority-cleared.

## Objective and source-reconciliation

Find a structural transfer mechanism upstream of density domination and static Simon grouping. Claim: a source and target distribution may be globally mutually singular or have exponentially large max-density ratio, while every depth-q decision tree incurs **exactly the same squared error on every interaction-degree-d target**. Deliver exact conditions and sharpness tests; do not define a tautological 'complexity measure' and call it a theorem.

References/credit: elementary k-wise independence / orthogonal-array Fourier moment matching; decision-tree indicator expansions; existing NIGHTFALL merged Route1/Wyner PR #970, density domination and Simon failure analysis in PR #987. Related prior art: *Fooling Near-Maximal Decision Trees* (APPROX/RANDOM 2025, https://drops.dagstuhl.de/storage/00lipics/lipics-vol353-approx-random2025/html/LIPIcs.APPROX-RANDOM.2025.35/LIPIcs.APPROX-RANDOM.2025.35.html), elementary pseudorandomness lecture notes (https://www.cs.columbia.edu/~rocco/Teaching/S24/Scribe/2024-02-27-scribe-notes.pdf), dual distance/k-wise code equivalence (https://victorlecomte.com/notes/k-wise-uniformity.html), and orthogonal arrays and factorial-design aliasing literature. Novelty remains UNKNOWN; this is a synthesis of elementary facts with an explicit source-calibrated simulator transfer. Independent reviewer needed.

## Formal representation

Let I be a finite set of n queried coordinates, each with an arbitrary finite alphabet A_i. Two PMFs ν and Q on the full product X=prod_i A_i **agree through order k** if for every S⊆I with |S|≤k and every assignment a to S,

   ν(X_S=a) = Q(X_S=a).

No independence or full support is required of either law. 'Interaction degree ≤d' means a function f:X→ℝ can be written as a finite sum of local functions f_J depending on at most d original coordinates, with no restriction on their coefficients and no orthogonality assumption.

A deterministic query tree t observes at most q original coordinate values along every input path and emits a real leaf label. Repeated queries are allowed but do not increase the set of observed positions. The leaf-path indicator is a cylinder function depending on at most q coordinates; every t is a sum of leaf labels times these indicators. Squaring t changes its leaf labels, NOT its depth. This distinction is central: t² needs order q, not 2q.

## Theorem 1: exact L² conservation at the sharp locality threshold

For *any* laws ν,Q on X that agree through order k, every interaction-degree-d f and every depth-q deterministic decision tree t,

   k ≥ max(2d, d+q)  ==>  E_ν[(f−t)²] = E_Q[(f−t)²].

The equality is pointwise in the choice of f and t. Therefore, with the query budget fixed, the full achievable squared-risk profile of degree-d targets is identical under ν and Q:

   inf_{depth(t)≤q} E_ν[(f−t)²]
       = inf_{depth(t)≤q} E_Q[(f−t)²].

It holds for arbitrary within-coordinate finite alphabets and arbitrary, possibly dependent ν,Q; it is not restricted to unbiased Boolean products or to a particular simulator.

**Proof:** Expand f=Σ_{|J|≤d} f_J and t=Σ_ℓ c_ℓ 1_{C_ℓ}, where each leaf cylinder C_ℓ tests at most q positions. Then

- f² is a sum of products f_J f_K, each depending on at most 2d positions;
- ft is a sum of f_J c_ℓ 1_{C_ℓ}, each depending on at most d+q positions;
- t²=Σ_ℓ c_ℓ² 1_{C_ℓ}, because exactly one leaf is reached; each summand depends on at most q positions.

Moment/marginal agreement transfers the expectation of every listed term exactly. Combine E[f²−2ft+t²]. Since k≥q, the three pieces match. No density-ratio bound, spectral norms, finite-size constants, or stochastic approximations enter. QED.

**Bayes-optimal fixed-coordinate corollary:** For every fixed S⊆I with |S|≤q, the exact conditional means E_ν[f|X_S] and E_Q[f|X_S] agree on every S-assignment of positive probability, because numerator E[f 1_{X_S=a}] uses at most d+q positions and denominator Pr(X_S=a) uses |S|. Their average conditional variances agree exactly, since f², the cross term, and conditional-mean square agree. This does not assert identical conditional means after arbitrary >q-coordinate observations.

**Classical randomized trees:** for a randomized mixture of depth-q trees with input-independent random coins, apply the equality separately for each coin outcome, then average. The random bits must be independent of the sampled input law; input-correlated algorithm advice is outside scope.

## Theorem 2: both threshold terms are individually necessary (worst case)

The threshold max(2d,d+q) cannot be uniformly weakened, already for Boolean signs and bounded functions f,t in [0,1].

**Necessity of 2d:** Let 2d distinct sign coordinates be constrained to product_i X_i=+1, and let Q be uniform independent signs. The conditioned law ν agrees with Q on every proper subset (k=2d−1). Partition the coordinates into disjoint A,B each of size d. Set f=(2+χ_A+χ_B)/4 ∈[0,1], and t≡0 (a depth-zero tree). The difference of squared-error risks is E_ν f²−E_Q f² =1/8, since the only nonmatched term is χ_A χ_B=product of all 2d signs. Thus even q=0 does not permit k=2d−1.

**Necessity of d+q when q>d:** Take n=d+q distinct signs with even total parity, so k=n−1. Take disjoint sets A,B of sizes d,q, respectively. Let f=(1+χ_A)/2 and let the depth-q tree t=(1+χ_B)/2 (query B and compute its parity). On ν the parity relation forces χ_A=χ_B, so E_ν[(f−t)²]=0; on independent Q the two signs are independent, giving E_Q[(f−t)²]=1/2. Here k≥2d if q>d, but k<d+q. Hence that term cannot be reduced either.

For q=d the thresholds coincide. For q<d, 2d controls. These examples prove **worst-case sharpness of the sufficient order**, not an optimal query bound for any given law.

## Theorem 3: transferring actual high-probability Route 1 simulators

Suppose f:X→[0,1] has degree≤d and the merged Wyner Route 1 theorem produces a depth-q deterministic tree t for law Q with

    Pr_Q(|f−t|>ε₀) ≤ δ₀.

Clip t leaf labels to [0,1]; this cannot increase error against any f∈[0,1]. Hence E_Q[(f−t)²] ≤ ε₀²+δ₀. If ν and Q agree on k≥max(2d,d+q) marginals, Theorem 1 yields the identical squared risk under ν, and Markov gives

    Pr_ν(|f−t|>ε) ≤ (ε₀²+δ₀)/ε².

For desired (ε,δ), take ε₀=ε sqrt(δ/2), δ₀=ε²δ/2, so the RHS is ≤δ. This is a full **paper-level** simulation transfer from any source Q to moment-matched ν, with NO density ratio, at a cost of strengthened input tolerances and the explicit k≥d+q self-consistency requirement.

If Q is a mixture of M product measures, the **same** merged source theorem has s> C_W(Q) and one can set s=ln M+1. If Q is one product law, M=1. The original Route1 constants A_d(τ), B_d(τ) and τ must be substituted at (ε₀,δ₀) to obtain the explicit q; nothing here replaces or re-proves them. Do not claim a Lean kernel certificate for this composition until the tree-degree proof and marginal law bridge are formalized.

**Caveat:** the threshold transfers squared loss **exactly**, not the event probability itself. The [0,1]-clipping plus Markov conversion is essential. Example: the even-parity law on 3 signs agrees with uniform law through k=2, and f=(3+X₁+X₂+X₃)/6 has degree1; E_ν f²=E_Q f²=1/3 but Pr_ν(f>1/2)=1/4 while Pr_Q(f>1/2)=1/2.

## Theorem 4: arbitrarily large global density cost with exactly zero local risk distortion

Partition n=rL fair sign coordinates into r disjoint groups of L≥2 signs. Let Q be fully independent uniform and ν be Q conditioned on even parity in **each** group. The ν support has size 2^(r(L−1)), and pointwise ν=2^r Q on its support and 0 elsewhere; hence D∞(ν||Q)=r ln2 and the optimal pointwise factor for THIS Q is R=2^r.

Every set of ≤L−1 coordinates misses at least one coordinate in each L-element group, so its marginal law under ν is identical to its marginal under Q. Thus ν and Q match through order k=L−1. If L>max(2d,d+q), Theorem 1 gives

    sup_{degree(f)≤d, depth(t)≤q} |E_ν(f−t)²−E_Q(f−t)²|=0,

for all r≥1. In contrast, a density-only transfer with Q would pay 2^r. With L,d,q fixed while r increases, this is an **unbounded exponential-in-r quantitative improvement in the transfer coefficient** for this explicit class. The support is edge-free, so its Wyner common information on original coordinates is H(ν)=r(L−1)ln2, also linear in r, by PR #987's support theorem (prior-art caution). This shows global C_W and D∞ alone cannot measure the difficulty of every *low-degree, shallow-query* task.

**Independent checker:** scripts/check_route1_moment_conservation_exact.py, fixed-seed but all arithmetic Fraction/integer. Exhaustively compares the two laws over small parity-block systems for randomly generated low-degree f and arbitrarily adaptive depth-q trees, independently audits exact k-wise marginals, both sharpness constructions, biased product tilts, and the tail-event failure. Finite checks cannot prove universal theorems.

## Limitations and next decisive research experiment

- Novelty status: theorem built from standard bounded-independence/fooling facts; treat as an exact transfer checkpoint, NOT a new scientific discovery absent dated, specialist prior-art review. Full Lean formalization and independent non-author audit remain pending.
- This does NOT yet solve Simon: its output marginals are only approximately independent, not exactly matching uniform (even two-coordinate equality probabilities differ: 1/(N−1) vs 1/N). A quantitative theorem must control how small local moment errors affect **the Gram operator of degree-d functions against depth-q path cylinders**, without multiplying naively by the potentially exponential number of leaf paths or Fourier coefficients.
- Strongest check before a novel claim: find a structural norm/certificate, computable from low-order law data, that controls
    sup_{bounded degree-d f, depth-q tree t} |E_ν(f−t)²−E_Q(f−t)²|,
  with constants superior to raw total-variation or coefficient-L1 estimates, and produce a counterexample when that is impossible. Independent adversarial checks should target rare Simon collision patterns and almost-moment matching that fails in relative risk.
- Stop condition: do not claim high-probability error equality, a universal quantum simulator, classical runtime bounds, or a Simon complexity characterization from moment matching. Do not merge without independent review of exact scope and pinned source interfaces.
