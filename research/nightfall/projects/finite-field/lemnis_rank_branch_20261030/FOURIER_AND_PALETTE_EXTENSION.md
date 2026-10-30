# Lemnis — Rank–palette decision-tree bound and a Fourier 7-sign bottleneck

**30 October 2026 · NIGHTFALL/Constellation · R1 internal proof candidate**  
**Provenance:** Lemnis independent mathematical extension to Lemnis [PR #264](https://github.com/d3lefts/d3lefts/pull/264), reviewing Vesper [PR #256](https://github.com/d3lefts/d3lefts/pull/256) and Axiom [PR #266](https://github.com/d3lefts/d3lefts/pull/266). Axiom independently originated the dimension-eight no-go and 38-profile/78,125-row exact finite census; the new Fourier replacement belongs to this review. **Do not conflate AI-to-AI reviews with external human refereeing.**

## Objective, fixed model, and acceptance gates

- **Objective:** derive an explicit all-dimension rank-sensitive lower-bound operator for *arbitrary adaptive* powered-linear queries, then independently audit Axiom's k=8 exceptional branch without 78,125-case enumeration.
- **Exact oracle:** K=F_q, q odd, h>1 divides q−1, H=\{z∈K×: z^h=1\}. Each query chooses a K-linear form a after seeing past outputs and returns (a·x)^h∈K. Recover every x∈K^k up to a single global H phase, including zero, counting all queries. For numerical conclusions use q=9, h=2, L=5 possible powered outputs.
- **Previously best verified construction:** Vesper's two-round coordinate-square/basis-sign decoding upper bound k+ceil((k−1)/2) for F9, all supports. Axiom's original k=8 signed-projective sharp 14-bucket census is a separate preceding result.
- **Falsifiers:** an adaptive branch with fewer compatible orbits than our formula, a legal 7-sign coefficient row with all five squared-output buckets ≤13, or a failed all-signal upper-bound decoder. Proof status R1, original-publication and human referee gates open.
- **Checker:** `rank_palette_bound.py`, `fourier_certificate.py` (standard-library Python, exact integers, no probabilistic source assumptions). Stop after all dimension-13 lower-bound closes and symbolic k8 census elimination; no random search.

## Theorem 1 — universal adaptive rank–palette bound

Let t≥1 and m≥t be integers, t≤k, and put L=1+(q−1)/h. Every hypothetical legal adaptive decision tree has a reachable transcript of length t containing *at least*

    min_{1≤r≤t} ceil(h^(r−1) / L^(t−r)) q^(k−r)

signal H-orbits. In particular, if this minimum exceeds L^(m−t), no depth-m decision tree separates all H-orbits.

**Proof.** Discard a deterministic initial zero form if present, since it gives the constant observation 0. For the first nonzero linear form, the adversary prescribes a nonzero powered output 1 and fixes its nonzero raw root to 1 as a canonical representative of each global H-class. Maintain the current rank r of the queried linear forms, and the set S of compatible H-relative raw-value patterns on an independent row basis; write N=|S|. All raw representatives of each pattern form an affine fiber of size exactly q^(k−r), and they are in distinct global H-classes because the anchored first raw value remains 1.

If the next query is independent of prior forms, prescribe powered output 1; the augmented linear map is onto K^(r+1), so each old pattern has exactly h distinct raw lifts, each of size q^(k−r−1). Hence N→hN and r→r+1.

If the next query is dependent, its raw value is a fixed linear function of the current independent-basis raw values. Its powered output partitions S among at most L observable values. The adversary chooses a largest nonempty part, hence N→N'≥ceil(N/L), with unchanged rank and full q^(k−r) affine fibers. No unpowered measurements are revealed to the algorithm; the roots are a counting device.

After the first step, N=1,r=1. If the chosen t-step branch finishes at rank r, it had r−1 independent extensions and t−r dependent observations. By induction on these two updates,

    N ≥ ceil(h^(r−1)/L^(t−r)).

Indeed multiplying the inductive lower bound by h cannot fall below the new ceiling, and applying ceil(·/L) to a ceiling is the same as one ceiling after division. Thus that transcript retains at least N q^(k−r) distinct global H-classes. Every remaining length-(m−t) subtree has at most L^(m−t) leaves even with early stopping, proving the claim. QED.

**No rank-history enumeration is required.** The formula is valid for *whatever* rank r the adaptive choices create, not only coordinate-first or preselected rows. It strictly refines the predecessor's dichotomy of fully independent versus at least one dependent row.

### Exact F9 deductions

| k | ruled-out m | witness prefix t | minimum retained classes (over all ranks) | available leaves | known adaptive upper | result |
|---:|---:|---:|---:|---:|---:|---|
| 6 | 8 | 4 | 648 | 625 | 9 | A_9(6)=9 (prior Lemnis) |
| 9 | 12 | 3 | 2,125,764 | 1,953,125 | 13 | A_9(9)=13 (prior Lemnis) |
| **11** | **15** | **7** | **413,343** | **390,625** | **16** | **A_9(11)=16 (new)** |
| **13** | **18** | **13** | **3,321** | **3,125** | **19** | **A_9(13)=19 (new)** |
| 14 | 19 | 5 | 6,198,727,824 | 6,103,515,625 | 21 | A_9(14)≥20 (upper21) |

At k=11, t=7, the *minimizing* rank is r=6: the phase-palette lower is ceil(2^5/5)=7, giving 7·9^5=413,343. At k=13,t=13, the minimizing rank is r=11: ceil(2^10/5²)=41, giving 41·9²=3,321. These inequalities cannot be defeated merely by inserting a dependent query earlier.

## Theorem 2 — complete symbolic 7-sign F9 bucket obstruction

For **any seven coefficients** c_1,…,c_7 in the additive vector space V=F3², the map on 64 simultaneous-sign-orbits

    (ε_1,…,ε_7) modulo overall ±  →  ±(Σ ε_i c_i) in V/±

has a fiber of size at least **14**. There are exactly 5 possible output classes (zero and four nonzero antipodal pairs). The constant 14 is sharp: one zero coefficient and pairs of coefficients on each of three distinct projective directions give bucket sizes **14,14,14,12,10**.

**Proof without occupancy enumeration.** Let z be the number of zero coefficients, n_j the number on the jth of the four projective lines in F3², so z+Σn_j=7. In the group algebra of V, the raw signed-sum distribution is

    P = ∏_{i=1}^7 (δ_{c_i}+δ_{−c_i}).

For any nonzero additive character χ of V, a factor has Fourier value 2 if χ(c_i)=1 and −1 if χ(c_i)≠1, since ω+ω²=−1. The two characters in the jth dual projective direction have common eigenvalue

    λ_j = (−1)^(7−z−n_j) 2^(z+n_j).

Fourier inversion over V yields the **five squared-output orbit buckets** (up to a permutation of their four nonzero labels):

    b_0 = (64+Σ_j λ_j)/9,
    b_j = (128−Σ_i λ_i + 3 λ_j)/9    (j=1,...,4).

They are nonnegative integers adding to 64. Suppose all five were at most 13. The *only* five nonnegative integers summing to 64 under that ceiling are {12,13,13,13,13}. Therefore |b_i−b_j|≤1 for any two nonzero buckets, so |λ_i−λ_j|≤3 for all projective directions.

Writing e_j=z+n_j∈{0,...,7}, the eight possible eigenvalues are

    e=0...7:   −1, 2, −4, 8, −16, 32, −64, 128.

Two *different* exponents yield eigenvalues at distance ≤3 only for the exponent pairs {0,1} or {0,2}. If all e_j coincide, the identity z+4(e−z)=7 forces either (z,e)=(3,4) or (7,7). Their zero-output buckets are respectively b_0=0 and b_0=64, contradicting {12,13}.

If exponents are mixed, they must all belong to {0,1} or to {0,2}; in both cases z=0. The first yields Σn_j≤4, contradicting Σn_j=7; the second makes Σn_j even, another contradiction. Therefore the maximum fiber is ≥14. The displayed configuration gives equality. QED.

**Generalization that travels:** for arbitrary n and r, the Fourier coefficient of the n-fold ± signed-sum distribution on F3^r at a nonzero character χ_w is

    (−1)^(n−z_w) 2^z_w,

where z_w counts input coefficients lying in the kernel hyperplane of χ_w. Thus a signed-cube collision problem becomes a finite *hyperplane-incidence-spectrum* problem. The k8 sharp count follows by elementary eigenvalue spacing in r=2, without checking 38 occupancy profiles or 78,125 coefficient rows.

## Corollary — independent analytic proof of Axiom's k=8 no-go

Consider a hypothetical 11-query F9 square oracle decoder on F9^8. After the first eight outputs, Theorem 1 yields at least

    ceil(2^(r−1)/5^(8−r)) · 9^(8−r)

candidate global-sign classes for some rank r∈1,...,8. For r=1,...,6 or r=8 this exceeds 5³=125. At r=7, the lower bound is only 13·9=117. There is exactly one dependent query among the first eight. If it follows j of the six later independent queries (j=0,...,6), the final phase palette is at least 2^(6−j) ceil(2^j/5). For j=0,...,6 these bounds are **64,32,16,16,16,14,13**. Consequently the only history that can leave ≤13 phases is seven independent nonzero queries followed by one dependent query. Before that final dependent query the surviving 64 relative-sign classes are separated by a squared sum of seven coefficients. Theorem 2 raises the dependent surviving phase count from 13 to at least 14, so the resulting node retains at least 14·9=126>125 classes. Contradiction. Therefore **A_9(8)≥12**; Vesper's constructive upper bound 12 yields the candidate exact optimum 12.

**Attribution:** Axiom's PR #266 previously discovered the dimension-eight no-go with finite projective enumeration. This Fourier proof is an *independent analytic reproof and methodological generalization*, not an original discovery of the k8 theorem.

## Independent code audit, prior art, novelty and continuation

- `rank_palette_bound.py`: exact integer capacities for k=6,8,9,11,13,14, plus 2^8 forced rank-history negative checks and output-alphabet mutation. Asserted exact witness inequalities.
- `fourier_certificate.py`: group-ring/character calculation independently cross-checked against all **330** labelled GF9 occupancy profiles by direct enumeration of 2^7 sign vectors, plus **37** GF27 held-out configurations, all exact integers. The proof of the 14-bucket bound itself does not depend on those counts.
- Same-oracle literature check remains **incomplete**: classical Fourier transforms and signed-sum convolution are prior art; Axiom's 38-profile certificate establishes the same k8 inequality before this note; Borello–Schmid–Scotti (JCTA 214, 2025) concerns fixed intersecting codes; other adaptive finite-field/projective-search sources could subsume exact bounds. No worldwide-first claim.
- **Audit:** Axiom should attack the adaptive fiber-to-palette update when dependent forms interleave independent ones; Ryev should reimplement rank-spectrum formula and Fourier inversion; Vesper should reconcile #256/#266 prior results and dated external literature. No public-site promotion or submission until human authorization and review.

**Discovery operator:** observation quotient → rank-conditioned affine fibers → online phase palette → exact rank-only minimax → character-spectrum collision obstruction → finite tight query bounds. Transfer targets: other small fields and higher-r hyperplane-incidence spectra, with failures and counterexamples tracked rather than assuming universality.