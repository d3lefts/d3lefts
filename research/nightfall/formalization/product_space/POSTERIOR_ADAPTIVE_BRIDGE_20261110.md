# NIGHTFALL — Posterior-to-adaptive bridge, 10 November 2026

**Scope:** finite, independent product laws with strictly positive marginal atom masses. **Proof status:** complete mathematical argument under a uniform fractional-certificate cost bound; a substantial Lean 4.33.0 chain is kernel-checked on [PR #303](https://github.com/d3lefts/d3lefts/pull/303), but the full posterior-state instantiation and conditional Hoeffding identity have not yet been jointly compiled into one final declaration. **Novelty:** not established. The inherited antipodal theorem is David Turturean's (2026), and the measure-decomposition/decision-tree tools are classical. Distinguish theorem validity from historical priority.

## Objective and concrete result

Fix a finite set of coordinates `J`, finite nonempty coordinate alphabets (common alphabet in the current Lean interface), and normalized strictly positive probabilities `p_i`. Let `X` have their independent product distribution, and let `g(X)∈{0,1}` be nonconstant with finite interaction degree `≤d`, `d≥1`. Let `λ^x_i≥0` be globally valid fractional-certificate rows:

`sum_{i:x_i≠y_i} λ^x_i ≥1` whenever `g(x)≠g(y)`.

Assume `sum_i λ^x_i≤K` for every input `x`, with `K≥1`. A partial observation assignment `s` fixes a subset of coordinates; `g_s` is the function obtained by substituting those known symbols. At any nonconstant state, restrict the original certificate rows to free coordinates and define

`V_b(s)=E[1_{g_s=b}/||λ_s^X||_1]` and
`P_i(s)=E[1_{g_s=1}λ_s^X(i)/||λ_s^X||_1²]`,
`Q_i(s)=E[1_{g_s=0}λ_s^X(i)/||λ_s^X||_1²]`.

Let `S_s=sum_i sqrt(P_i(s)Q_i(s))` and use the **certificate-overlap policy**
`π_s(i)=sqrt(P_i(s)Q_i(s))/S_s`.
The procedure samples `i` from `π_s`, reveals `X_i` according to its (unchanged) marginal `p_i`, and updates `s`. Constant states are absorbing.

**Finite-product adaptive-recovery theorem (mathematical proof):**
For the predictor `m_t=E[g(X)|first t observations]`, the expected squared error satisfies

`E[(g(X)-m_t)²] ≤ d Var(g(X)) (1-1/(dK²))^t
                    ≤ d Var(g(X)) exp(-t/(dK²)).`

All coordinates are whole-symbol queries; neither the bound nor the algorithm's query count depends on the ambient number of coordinates. Computing `π_s` may be exponentially expensive and is **not** claimed to run in polynomial time. When all coordinates are known, prediction is exact. The stated bound is useful when `d,K` are controlled independently of dimension. The zero-variance/constant case is trivial and exits immediately.

## Mechanism and proof

**1. Rows survive conditioning.** For `s:J→Option α`, define `pin_s(x)` by replacing observed coordinates with their stored values. Set `g_s(x)=g(pin_s(x))` and `λ_s^x(i)=λ^{pin_s(x)}_i` for unobserved `i`, zero otherwise. Any pair `x,y` on which `g_s` differs yields an opposite pair `pin_s(x),pin_s(y)` whose disagreement set lies entirely in the free coordinates and is a subset of the disagreement of `x,y`. Consequently the restricted row still certifies every opposite pair; its cost does not exceed `K`. The restriction cannot increase interaction degree, since pinning any coordinate in an interaction term supported on `S` leaves a term depending on a subset of `S`. The relevant Lean declarations are `restricted_row_is_product_row`, `restricted_row_cost_le`, and `interaction_degree_under_pinning`.

**2. Product sampler gain.** For a nonconstant `g_s`, row costs are positive by the opposite-pair requirement. Put `I_i(s)=Pr[g_s(X)=1,g_s(X^{i←Y_i})=0]`, where `Y_i` is a fresh independent marginal draw. PR #298's localized two-sided theorem gives

`V_1(s)V_0(s) ≤ sum_i sqrt(I_i(s)P_i(s)Q_i(s))`.

PR #300's weighted Cauchy lemma and `S_s²≤V_1V_0` give the sharper gain

`E_{i~π_s} I_i(s) ≥ [V_1(s)V_0(s)]²/S_s²
 = V_1(s)V_0(s)/B_s² ≥ Var(g_s)/K²`,

where `B_s²=S_s²/[V_1(s)V_0(s)]≤1`. The final inequality uses `1/||λ_s^x||≥1/K` and `Var(g_s)=Pr[g_s=1]Pr[g_s=0]`. Observed coordinates have `P_i=Q_i=π_i=0`. The new `concrete_product_overlap_sampler` discharges the generic localization premise directly from #298.

**3. Exact posterior influence decrement.** For any free coordinate `j`, define total influence `T_s=Σ_i I_i(s)`. Conditional on observed `X_j=a`, every other coordinate remains independently distributed according to its original marginal. Therefore for every `k≠j`,

`E_{a~p_j}[I_k(g_s|X_j=a)]=I_k(g_s)`.

The observed coordinate has influence zero in the restricted function. Summing over all coordinates,

`E_{a~p_j} T_{s∪{j=a}} = T_s - I_j(s)`.

This is a finite Fubini/partition identity, **not** an ANOVA approximation. Lean declarations `posterior_edge_mean`, `posterior_total_mean`, and `conditional_mass_one` prove the exact generic finite-measure statements. `concrete_product_one_step` instantiates their edge observables with `edgeCross` and obtains

`E_{j~π_s,a~p_j}[T_{s∪{j=a}}] ≤ T_s - V_1(s)V_0(s)`,

once the actual product posterior is identified with the posterior of the pinned function. That final identification at all partial assignments is not yet one compiled Lean declaration.

**4. Energy controls potential.** Let `g_s=Σ_A h_A` be its orthogonal Hoeffding decomposition with interaction energies `e_A=E[h_A²]≥0`. Since degree `≤d`, `e_A=0` for `|A|>d`. Standard orthogonality gives

`Var(g_s)=Σ_{A≠∅}e_A`, `T_s=Σ_{A≠∅}|A|e_A`.

Hence `Var(g_s)≤T_s≤d Var(g_s)`. Lean declaration `anova_degree_energy_budget` certifies the elementary nonnegative-energy conclusion, while the actual function-to-energy decomposition remains an explicit formal interface.

**5. Iterate through an actual transition kernel.** Combining the preceding points:

`E[T_{next}|s] ≤T_s -Var(g_s)/K²
               ≤ (1-1/(dK²))T_s`.

The transition kernel is `P(s,s')=Σ_{j,a:next(s,j,a)=s'} π_s(j)p_j(a)`, with absorbing terminal states. The proof of `query_kernel_mass_one` verifies normalization, `query_kernel_expected` verifies Fubini, and `certificate_guided_adaptive_decay` derives expected-potential contraction for all times from the per-state hypotheses. Since `Var(g_s)≤T_s`, the stated prediction-error bound follows.

## Sharper structural corollary: degree-free certificate-overlap rigidity

The earlier provisional `B_s²≥1/(dK²)` bound is **strictly superseded**; it did not use the strongest available inequality. For every Boolean `g_s`, independent product resampling satisfies

`I_j(g_s)=E[Var(g_s|X_{-j})]≤Var(g_s)`,

by total variance. Consequently, the localized certificate inequality yields

`V_1(s)V_0(s)≤sqrt(Var(g_s)) S_s`.

For `V=V_1V_0>0`, it follows that

`B_s²=S_s²/V≥V/Var(g_s)≥1/K²`,

**with no interaction-degree assumption** and no dependence on coordinate count, alphabet size or marginal bias. It also bounds the maximum improvement from the sampler's overlap factor by `B_s^{-2}≤K²`.

**Exact sharpness at degree one.** Take three independent unbiased bits, let `g(x)=x_1`, and choose rows with total cost exactly `K≥1`:
- when `g(x)=1`: `λ^x=(1,K−1,0)`;
- when `g(x)=0`: `λ^x=(1,0,K−1)`.

They are valid fractional certificates because any opposite pair differs in the first coordinate and each row assigns weight one to that coordinate. Their loads satisfy `P_1=Q_1=1/(2K²)`, `P_2=(K−1)/(2K²)`, `Q_3=(K−1)/(2K²)`, with all other class-load components zero. Hence `V_1=V_0=1/(2K)`, `S=1/(2K²)`, and **`B²=1/K²` exactly**, while `I_1=Var(g)=1/4`. Exact rational arithmetic reproduced equality for `K∈{1,2,3,7,100}`. The example uses deliberately nonminimal rows; optimizing row cost reduces K and changes the profiles. Thus sharpness concerns *arbitrary valid rows of maximum cost K*, not an optimal-certificate uniqueness claim.

The Lean declarations `anova_coordinate_energy_le_variance` and `certificate_overlap_degree_free` address the pure finite-energy and numerical implications, conditional on the actual product probability identities. **Dated historical originality and expert review are outstanding.** The degree-dependent lemma is retained as a superseded, weaker predecessor with its exact hypotheses and proof receipts.

## Independent adversarial checks and remaining formal gates

The separate Python exact-fraction checker `check_posterior_adaptive_exact.py` enumerates all 268 nonconstant Boolean functions on 2 and 3 nonuniformly biased independent bits, 6,984 partial assignments, and 13,884 posterior responses. It calculates actual conditional laws and influences independently of the Lean implementation, reconstructs Hoeffding energies by Möbius inversion, and propagates a full finite-state adaptive process. There are no numerical tolerance comparisons.

The key pending Lean gates are:

1. Bridge the concrete posterior numerator in `posterior_total_mean` to the *actual successor pinned function* after a coordinate revelation, with normalized product marginals, including terminal states.
2. Connect `HasInteractionDegreeAtMost` to the actual finite-product Hoeffding energy identities for `g_s`, not just the abstract `anova_degree_energy_budget`.
3. Formalize the deterministic state-to-certificate sampler `s↦π_s`, absorbing transition for constant states, and instantiate `certificate_guided_adaptive_decay` with those constructions to obtain one unconditional Lean `finite_product_adaptive_recovery` declaration.
4. Independently review the mathematical proof, compare against OSSS, decision-tree and low-degree learning literature, and classify historical novelty. No claim of an improved general `(2,4)` squared-influence exponent.

## Provenance and scope

David Turturean's antipodal determinant result (arXiv:2611.09773) and upstream Lean implementation are imported; Claude's localized weight-removal proof, the NIGHTFALL finite-product two-draw transfer, and the certificate-overlap sampler remain separately credited. The Hoeffding--Efron--Stein decomposition, conditional-expectation identities and finite Markov recursion are classical in their basic forms. The assembled theorem is a derivation, not an established globally original mathematical result. Preserve direct proof receipts and the exact run IDs on PR #303. No merge or publication authorized.
