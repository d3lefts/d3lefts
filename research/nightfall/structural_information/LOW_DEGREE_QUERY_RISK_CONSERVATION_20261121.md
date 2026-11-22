# Local moment conservation for bounded-degree decision-tree simulation
**NIGHTFALL research checkpoint v1.2 — 2026-11-21/22.** Status: complete short mathematical proof, exact rational regression below, NOT Lean-certified or priority-cleared.

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

## Theorem 1b: a precise if-and-only-if (the upstream structural characterization)

Fix finite n, nonnegative integers d and q, and set

    K = min(n, max(2d,d+q)).

For any two probability measures ν,Q on the same finite Cartesian alphabet, the following are **equivalent**:

(A) ν and Q have identical marginals on **every** coordinate subset of size ≤K.

(B) For **every** [0,1]-valued interaction-degree≤d function f and **every** deterministic depth≤q decision-tree function t with [0,1]-valued leaves, the mean squared errors are equal:

    E_ν[(f−t)²] = E_Q[(f−t)²].

The implication (A)⇒(B) is Theorem 1, with the bound saturated at the whole input if K≥n.

**Independent converse proof, with no pseudo-randomness or quantum assumptions:** Under (B), taking t≡0 yields equality of E f² for all [0,1]-valued degree≤d f. For any local atom indicators u and v on coordinate sets A,B with |A|,|B|≤d, u,v,(u+v)/2 all have degree≤d and lie in [0,1]. Since u²=u, v²=v, the identities

    E[(u+v)²/4]=(E[u]+E[v]+2 E[uv])/4

force equality of E_ν[uv] and E_Q[uv]. Every local atom event involving ≤2d coordinates splits as uv with |A|,|B|≤d, so all ≤2d marginals agree. Independently, taking f≡0 shows Eν t²=EQ t² for every depth≤q tree t. In particular taking t=v, the indicator of ANY local atom on |B|≤q coordinates (computed by nonadaptive queries), proves agreement of all ≤q marginals. Finally, for any local atoms u on ≤d and v on ≤q coordinates, use f=u, t=v in (B) together with their separately established squared expectations to derive equality of E uv from

    E[(u−v)²] = E[u]+E[v]−2 E[uv].

Every local atom involving ≤d+q coordinates factorizes as such uv. Hence ν,Q match all marginals through max(2d,d+q), capped by n. This establishes (B)⇒(A). QED.

**Quantitative converse (pointwise atom, not full marginal-TV):** If every such squared-loss expectation differs by at most η, the same polarization gives an absolute error at most 3η for each atom probability on up to 2d coordinates, and at most 3η/2 for each atom involving up to d+q coordinates. These are crude exact constants, not optimized; the first follows from E[(u+v)²/4] and both individual E[u], E[v] differences, the second from E[(u−v)²] and two individual terms. The constants are law-independent, but summing atom errors to total variation can incur alphabet-size dependence. This is a direct **certificate/checker implication**, not a dimension-free approximate transfer.

**Interpretation:** Theorem 1b characterizes universal degree-d, depth-q mean-squared-risk invariance by **finite marginal data**, without introducing any arbitrary complexity score. This is mathematically stronger than merely constructing a simulator. The underlying k-wise moment-matching mechanism is well known; novelty of this exact biconditional is unestablished and requires independent prior-art search.

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

## Theorem 3b: high-probability transfer with no Markov error rescaling

A stronger consequence conserves **higher loss moments** and transfers tail probabilities with a gap in the threshold, avoiding the second-moment Markov tolerance penalty.

Assume f,t:X→[0,1], f has interaction degree≤d and t has decision-tree depth≤q. Fix a positive integer m. If ν and Q agree on coordinate marginals through

    k ≥ K_m := max(2m d, (2m−1)d+q),

then the raw error Z(x)=(f(x)−t(x))²∈[0,1] has the **same first m raw moments under ν and Q**:

    E_ν[Z^j] = E_Q[Z^j], for all integers 0≤j≤m.

*Proof:* Expand (f−t)^(2j). Its pure f^(2j) term has interaction degree≤2jd; its mixed terms f^a t^(2j−a), 0≤a≤2j−1, have degree≤a d+q because t^b, b≥1, is still the same depth-q decision tree with leaf labels raised to the b-th power. Thus all nonzero terms have locality at most max(2jd,(2j−1)d+q). Coordinate-marginal matching transfers each expectation exactly. ∎

**Tail transfer theorem.** Fix 0≤a<a+γ≤1. Then

    Pr_ν[Z≥a+γ] ≤ Pr_Q[Z>a] + 1/(γ sqrt(m)).

*Certificate via positive Bernstein polynomial:* Let h:[0,1]→[0,1] be the ramp h=0 on [0,a], h(z)=(z−a)/γ on [a,a+γ], and h=1 above a+γ. Its degree-m Bernstein polynomial is

    B_m h(z)=Σ_{j=0}^m h(j/m) binom(m,j) z^j (1−z)^(m−j).

Because its expectation is a linear combination of raw moments through order m, E_ν B_m h(Z)=E_Q B_m h(Z). Moreover, for Y∼Bin(m,z),

    |B_m h(z)−h(z)|
      ≤ (1/γ) E|Y/m−z|
      ≤ (1/γ) sqrt(z(1−z)/m)
      ≤ 1/(2γ sqrt(m)).

Hence |E_ν h(Z)−E_Q h(Z)|≤1/(γ sqrt(m)). Since 1_{Z≥a+γ}≤h(Z)≤1_{Z>a}, the claimed tail inequality follows. All constants are explicit; nothing assumes independence, product structure, global density bounds or interval approximation outside [0,1]. ∎

Equivalently, for 0≤ε₀<ε₁≤1,

    Pr_ν[|f−t|≥ε₁]
      ≤ Pr_Q[|f−t|>ε₀]
        + 1/[(ε₁²−ε₀²) sqrt(m)].

For ε₀=ε/2, ε₁=ε, choose m≥16/(9 ε⁴ η²) to make the additive tail penalty ≤η. Here the marginal-order requirement is K_m=O(d/(ε⁴η²)+q). If Q is the original Route1 source law, this composes with its genuine depth-q decision tree after clipping its leaf labels. It can retain Q's original failure budget δ₀ (up to additive η), instead of scaling it by ε²δ as in the simpler MSE/Markov transfer. The price is substantially higher marginal agreement strength k. This is a **mathematical/paper-level transfer**, not yet a pinned Lean certificate or an efficiency claim for constructing the Bernstein polynomial.

**No direct Simon claim:** Simon and independent uniform outputs do not have exactly matching even two-entry marginals, so Theorem 3b does not produce a Simon simulator. The separate open problem is a quantitatively stable *approximate*-moment version controlled by a usable operator norm, rather than a naive coefficient count.

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
