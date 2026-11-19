# Proof Passport — Mira exact Latin-square sampling / independent theorem audit
Version: **2.2**, 2026-11-19. Status: **PARTIAL AUTHOR-SIDE THEOREMS + EARLIER FINITE LEAN LEMMAS; MAIN CLAIM UNVERIFIED**.

## Original source, ownership, objective
- External source: **Mira Cult, _Exact uniform sampling of Latin squares_**, immutable [Mira-Cult/math@30ddaaad27b48df2002225c3e3f40cffd02c5253](https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling). Mira's source credits six GPT-6.2 Astra instances for mathematical development. NIGHTFALL does **not** claim to have independently discovered her proposed sampler, nor joint authorship or collaborator approval.
- Original claim under audit: a perfect, exactly uniform labeled Latin-square sampler for all orders n, with expected fair-bit work **O-tilde(n^25)**. The reference program does *not* implement the revised theorem-scale algorithm.
- Objective: independent theorem-level verification of Mira's difficult analytic dependencies, conditional kernel algebra, fair-bit implementation, and expected bit complexity.
- Feasible scope for this checkpoint: finite regular bipartite boards, exact permanent moments, dense fixed-complement-degree asymptotics, count-lower reduction. No claim of a completed polynomial-time sampler.
- Strongest external dependency checked this session: Greenhill–Kim–Wormald, *Hamiltonian decompositions of random bipartite regular graphs*, Corollary 1.1 Eq. (1), fixed-degree contiguity of U_c and conditioned unions of c uniform matchings (c fixed, >=3): https://users.monash.edu.au/~nwormald/papers/hambip.pdf . Also Göbel–Liu–Manurangsi–Pappik, *Perfect sampling from rapidly mixing Markov chains*, https://arxiv.org/abs/2410.00882, background on exact matching. The latter does not supply a NIGHTFALL-certified n^21 bit clock.

## Claim graph and exact status

| ID | Claim / mechanism | Status | Certificate / limit |
|---|---|---|---|
| MIRA-ALG-25 | Full exact uniform Latin sampler, expected O-tilde(n^25) **bit work** | **UNVERIFIED** | Requires actual forward/reverse program, all-target mean cover, count lower, fair-bit bit clock |
| MIRA-MEAN | sup over Latin S of E_{R_S} log(R_S/Q_S) <= sum_d log m_d + O(1) | **UNPROVED INDEPENDENTLY** | Source coverage-v2, lookahead-cubic, calibration-v2, analytic appendix; major dependency |
| MIRA-COUNT | For c_*>0, |L_n| >= c_* product_d m_d | **CONDITIONAL ONLY** | New theorem below reduces to the bulk chi-square budget, given external fixed-c contiguity |
| MIRA-ORB-EXACT | Exact permutation cycle-type orbit formula for E_{U_d} per(A)^2 | **AUTHOR-SIDE PROVED** | Independent combinatorial double count; exact checker all n<=5 |
| MIRA-CYCLE-EDGE | Exact pair completion count is NOT a function only of shared-edge count | **CERTIFIED FINITE COUNTEREXAMPLE** | n=4,d=3: C_(2,2)=4, C_(4)=2 although both have zero common edges |
| MIRA-DENSE-LAWFREE | Universal, source-law-free near-complete log-permanent comparison for **arbitrary** distributions on d-regular boards, including uniform U_d, greedy Q_d, and any fixed-target row-subset law | **AUTHOR-SIDE THEOREM, NOT LEAN; EXPLICIT CLASSICAL INPUTS** | The same uniform Bregman/vdW permanent interval used for growing-defect TV, new simultaneous mean-cover transfer; no middle-degree coverage |
| MIRA-DENSE-GROW | Explicit high-density bound t_(n-r) <= [exp((r/n)log(2*pi*n)+1/(3n))-1]/2 for d=n-r>=n/2; summed o(1) for r<=o(sqrt(n/log n)) | **AUTHOR-SIDE PROVED, NOT LEAN** | Classical van der Waerden / Bregman / Stirling sandwich; independent of Poisson route; still not full dense strip |
| MIRA-DENSE-FIXED | For every fixed r, sup_{A in G(n,n-r)} |per(A)/n! - exp(-r)| -> 0, so t_(n-r)->0 | **AUTHOR-SIDE PROVED** | Uniform fixed-k factorial moments of forbidden hits plus Bonferroni; no growing-r conclusion |
| MIRA-ENDPOINT | Fixed-c endpoint lower-tail for F_c and R_c ~ product_{i=0}^{c-1} m_(n-i) | **AUTHOR-SIDE DERIVED WITH PUBLISHED INPUT** | GKW mutual contiguity (c fixed >=3), Brégman / van der Waerden + Stirling |
| MIRA-CHI-BUDGET | Sum_{d=c+1}^{n-c} sqrt(chi^2(Uhat_d||U_d)) <= 1/4 for one fixed c>=3 | **UNPROVED** | Alternative sufficient bulk certificate; may be strictly stronger than Mira's original TV objective |
| MIRA-CUBIC | Raw cubic-head moment Z*_3/(n!)^3 <= C n(4/3)^n | **AUTHOR-SIDE PROVED, NOT LEAN** | Prior v1 independently reconstructed proof; checker exact n<=13 |
| MIRA-WDENSE | Dense weighted-permanent log estimate, explicit <=4K^2/s (K<=s/8) | **AUTHOR-SIDE PROVED, NOT LEAN** | Prior v1 independent switching argument |
| MIRA-FLAT-FINITE | 14 finite likelihood/soft-gate/telescope lemmas | **LEAN KERNEL-CHECKED** | Dedicated pinned PR #900 run 44573134450, only propext, Classical.choice, Quot.sound |
| MIRA-LATIN-REP | Latin iff ordered edge-disjoint perfect-matching rows | **LEAN KERNEL-CHECKED** | 2 named declarations in same run |
| MIRA-TV-FINITE | Finite cap loss = TV and cumulative mass survival budget | **LEAN KERNEL-CHECKED** | 7 named declarations in same run |
| MIRA-MIX-TARGET | Finite latent-product Latin target normalization under explicit kernel hypotheses | **LEAN KERNEL-CHECKED AS CONDITIONAL ALGEBRA** | 2 named declarations in same run; NOT program semantics |

**Important:** 25/25 existing Lean declarations cover only finite probability/combinatorial identities, *not* the analytic asymptotics, exact runtime or executable sampler. This v2 work has NOT been Lean-certified.

## New unconditional theorem 1: exact cycle-type second moment
Let G_(n,d) be n-by-n labeled d-regular boards, N_d its count, W(A)=per A, m_d=E_U W. For a relative permutation pi let C_(n,d)(pi) count boards containing identity matching and pi. This depends on the entire cycle type lambda of pi, not just fixed-point count; write z_lambda=product_j j^{a_j} a_j! for lambda=(1^{a_1}2^{a_2}...). Then:

    E_U W^2 = (n!/N_d) sum_{pi in S_n} C_(n,d)(pi)
            = ((n!)^2/N_d) sum_{lambda |- n} C_(n,d)(lambda)/z_lambda.
    chi^2(Uhat_d || U_d) = E_U W^2/m_d^2 - 1.
    t_d = TV(U_d,Uhat_d) <= (1/2) sqrt(chi^2).

*Proof:* expand W(A)^2 as ordered pairs of perfect matchings; fix the first matching and relabel its columns to identity; conjugation fixes identity and classifies the second by full cycle type. Divide by N_d and invoke Cauchy–Schwarz for the last inequality.

*Adversarial witness:* for n=4 and d=3, complement of identity union relative pi is the allowed missing matching graph. If pi type (2,2) its complement consists of two K_(2,2) blocks (4 missing matchings); if pi type (4) its complement is one 8-cycle (2 missing matchings). Both pi share exactly zero identity edges. Consequently any **exact** j-only replacement is false. This is an audit constraint, NOT a counterexample to Mira's claimed *asymptotic* sparse expansion.

## New unconditional theorem 2: dense fixed-defect permanent
For every *fixed* r>=0, uniformly over all A in G_(n,n-r),

    per(A)/n! -> exp(-r), and TV(U_(n-r), Uhat_(n-r)) -> 0.

*Proof:* put B=all-ones-A, an r-regular forbidden board. A uniform permutation hits X forbidden cells. For fixed k the count R_k(B) of k nonattacking forbidden cells obeys

    product_{j=0}^{k-1}(rn-(2r-1)j) <= k! R_k(B) <= (rn)^k,

uniformly for n sufficiently large (r>=1). Thus E binom(X,k)=R_k(B)/(n)_k -> r^k/k!, uniformly in B. Odd/even Bonferroni sums squeeze P(X=0)=per(A)/n! to exp(-r). Average over A and divide to obtain Uhat/U->1 uniformly. For r=0 the result is exact. **Not** a growing-deficit or full dense-strip theorem.

## Stronger author-side theorem 2.1: explicit growing-defect dense tail
For every n>=2 and integer 0<=r<=n/2, put d=n-r. For every d-regular board A, the classical van der Waerden and Bregman bounds give L=n!(d/n)^n <= per(A) <= U=(d!)^(n/d). Stirling with positive remainder 0<eps_k<1/(12k) yields the exact deterministic estimate

    log(U/L)
      = 0.5[(n/d)log(2*pi*d)-log(2*pi*n)] + (n/d)eps_d - eps_n
      <= (r/n)log(2*pi*n) + 1/(3n).

Consequently, uniformly over every such board,

    n log(1-r/n) <= log(per(A)/n!)
      <= n log(1-r/n) + (r/n)log(2*pi*n) + 1/(3n),
    t_(n-r) <= 0.5[exp((r/n)log(2*pi*n)+1/(3n))-1].

Since the biased-to-unbiased Radon–Nikodym ratio is per(A)/m_d, and both per(A) and m_d lie in [L,U], this TV estimate is immediate from the ratio bound. For any growing R_n=o(sqrt(n/log n)),

    sum_{r=0}^{R_n} t_(n-r)
      <= (R_n+1)/2 * [exp((R_n/n)log(2*pi*n)+1/(3n))-1]
      = o(1).

Likewise if R_n=o(sqrt(n)), the uniform log sandwich yields per(A)/(n! exp(-r)) -> 1 uniformly for 0<=r<=R_n. This independently strengthens and cross-checks the earlier fixed-r Bonferroni theorem, without assuming a spectral event. **This covers only the near-complete high-density tail, not the whole dense strip from d ~ sqrt(n) polylog(n) upward.** These inequalities follow from classical permanent bounds and carry NO novelty claim; the combination is an author-side proof contribution to this source audit.

The v2.1 manuscript contains the full derived inequality and sum, and the fixed-defect checker additionally verifies both classic permanent inequalities in exact integer arithmetic for all 2,292 finite instances.


## Author-side theorem 2.2: law-free near-complete log-permanent transfer

Let d=n-r>=n/2 with integer n>=2 and 0<=r<=n/2, and set

    epsilon_(n,r) = (r/n)*log(2*pi*n) + 1/(3n).

For **arbitrary probability laws** P,Q supported on the finite set G_(n,d) of labeled d-regular bipartite boards, and m_d=E_(U_d)per(A),

    |E_P log per(A) - E_Q log per(A)| <= epsilon_(n,r),
    |E_P log per(A) - log m_d| <= epsilon_(n,r).

For the union T_d(S) of a uniformly selected d-subset of any fixed Latin square S's rows, its induced law is supported on G_(n,d), so in particular

    sup_(S in L_n) |E log per(T_d(S)) - log m_d| <= epsilon_(n,r).

The same statement holds for Mira's sequential-uniform-matching residual Q_d, *without requiring* Q_d to be near U_d in total variation or to be spectrally healthy. Consequently, if R_n=o(sqrt(n/log n)),

    sum_(r=0)^(R_n) sup_(S in L_n)
      |E log per(T_(n-r)(S)) - log m_(n-r)| = o(1),

and simultaneously

    sum_(r=0)^(R_n)
      |E_(Q_(n-r)) log per(A) - log m_(n-r)| = o(1).

**Proof:** By van der Waerden and Bregman, all d-regular boards obey
L=n!(d/n)^n <= W(A) <= U=(d!)^(n/d). Stirling with explicit
positive remainders gives

    0 <= log(U/L)
       <= (r/n)log(2*pi*n)+1/(3n).

Hence log W(A) lies in a deterministic interval of length at most
epsilon_(n,r), regardless of how A is distributed. Every expectation
of log W lies in that interval, as does log E_(U_d)W, since the latter
is the log of a mean of values in [L,U]. Their pairwise difference is
therefore <= epsilon_(n,r). The row-subset T_d(S) and greedy residual
are d-regular by the Latin-square/factorization invariant. Sum the
bounds: for R_n=o(sqrt(n/log n)),
sum_r epsilon_(n,r)
= [R_n(R_n+1)/(2n)]log(2*pi*n)+(R_n+1)/(3n)=o(1).
No measure-concentration, Markov chain, or numerical simulation is
needed. This transfers the already classical deterministic permanent
inequalities to a **new audit use**, not a claimed original permanent theorem.

**Limit:** The range d=n-o(sqrt(n/log n)) is only a thin near-complete
tail. The full dense comparison from d~sqrt(n)*polylog(n) through
d~n/2 is still open independently, as are the low/intermediate
grades of Mira's mean-cover. This theorem adds no certificate to the
overall O-tilde(n^25) sampler claim.


## One explicit conditional theorem isolating the bulk gap
Fix c>=3. Assume the published GKW fixed-c mutual contiguity. Define rho_(n,d) exactly by the cycle-type expression in theorem 1, i.e., rho=chi^2(Uhat||U). If for all sufficiently large n>2c,

    sum_{d=c+1}^{n-c} sqrt(rho_(n,d)) <= 1/4,

then there exists c_*(c)>0 such that |L_n| >= c_* product_{d=1}^n m_d.

*Proof sketch with all dependencies exposed:* Cauchy–Schwarz makes total TV loss <=1/8. The two caps at each marked-incidence step lose <=2 sum t_d <=1/4, and preserve domination by the next uniform degree law. GKW fixed-c contiguity implies for epsilon=1/8 there is delta(c)>0 with U_c(F_c<delta R_c/N_c)<epsilon eventually; hence endpoint removal loses <=1/4, leaving >=1/2 mass. Count paths and their >=(delta R_c/N_c)^2 ordered completions. Brégman and van der Waerden imply R_c/(product_{i=0}^{c-1}m_(n-i))=1+O_c(log n/n). Exact marked incidence N_d m_d=N_(d-1)m_(n-d+1) completes the constant-factor lower bound. A valid c_* is delta(c)^2/4 for sufficiently large n.

**Warning:** This chi-square criterion may be stronger than the original summed TV target. Failure to prove it would not refute Mira's count-lower proposition. The actual summable bulk regular-board estimates remain open.

## Reproducibility and external review
- Author-side v2 source/PDF and two exact scripts are delivered in this conversation; external upload to GitHub is not claimed for those binary PDF bytes.
- Cycle-moment exact checker: independently enumerates all G_(n,d) for n<=5 and evaluates second moments both directly and from cycle-class completion counts; verifies exact 4t_d^2<=chi^2.
- Fixed-defect checker: independently replays rook inclusion-exclusion and every Bonferroni partial sum for 2,292 regular-board instances, n<=5, r<=2.
- Local SHA-256 (Python scripts): cycle checker `90ddc702982eb26107839c4d1b27eb300b7d8f191852bb3765bf60e92fed4aca`; fixed-defect checker `73c4b52f529c2e9a34a52417bfba75cfb3b4973c32285936fffef40a34a11798`.
- Local SHA-256 (paper source): `fe516447a52495b5d86a518b685ee0d77d506d5f9c9fbffc5bb19ce1cc3df58c`.
- Historical Lean receipt (source-specific; current source state may differ): run [44573134450](https://github.com/d3lefts/d3lefts/actions/runs/44573134450), artifact `14556285027`, digest `sha256:1a286b7611445e0ee2e65db4d1c010534c976bea026ae5002d287c7d0aa04d23`; **does not include v2**.
- Independent human referee: **none**. Novelty/priority screen: **not completed**; the fixed-defect Poisson mechanism is classical in character. Peer review and coauthor consent: **not obtained**.

## NIGHTFALL experiment registration: next cheapest decisive test
- Prediction: a uniform (or suitably averaged) sparse/medium relative-cycle completion estimate yields a summable bound for t_d, possibly through the exact cycle-class chi-square representation.
- Alternative: chi-square has a long tail even if TV remains small, so the new sufficient criterion fails while Mira's original direct TV argument can still work.
- Discriminator: independent derivation, uniformly over the relevant d range, of either (a) summed t_d <=1/8 after choosing fixed c; or (b) the stronger sum sqrt(rho)<=1/4. Audit all constants and degree cutoffs.
- Cost/stop: run exact finite tests first; stop any misleading overlap-only simplification immediately on n=4,d=3 witness; if asymptotic second-moment bounds require unsupplied external lemmas, record those as imported hypotheses. Do not claim theorem-level main sampler until both count and mean-cover plus cost close.
- Transfer: cycle-type rather than overlap-only orbit sums apply to all random regular bipartite permanent second moments; bounded-defect Poisson avoidance applies to other permutation-avoidance sampling problems.
- Next transition: sparse two-planted matching enumeration uniform in cycle type -> bulk TV; separately independently prove fixed-target mean cover, then exact matching fair-bit implementation.

## PR policy
[PR #900](https://github.com/d3lefts/d3lefts/pull/900) was closed without merging; retain its historical Lean receipts without implying that its draft PR is open. A passing Lean check of finite lemmas is never certification of the proposed O-tilde(n^25) full sampler. Preservation of mechanism, claim limits and Mira's credit is mandatory.

## Reproduction in this repository

Run `python3 scripts/check_mira_latin_cycle_second_moment.py` and `python3 scripts/check_mira_latin_fixed_defect.py`; the source and results are reproduced in the new isolated theorem-audit PR. Neither exact finite test proves the asymptotic theorem. The paper-level v2 PDF/TeX source, full trace and hashes were delivered as a separate downloadable research packet, not represented as committed GitHub binaries.
