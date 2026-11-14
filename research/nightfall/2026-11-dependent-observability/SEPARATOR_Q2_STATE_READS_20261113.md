# Dependent observability via a small observed separator (2026-11-13)

**Status:** source-level author-analytic research note, conditional on finite heterogeneous-product Q2. This is a restricted structural transfer and a matching-order state-read lower bound, not a general connected-Gibbs theorem, a terminal Lean certificate, or a priority determination. Two independent exact-rational checkers and a connected-model stress-test are retained in the associated conversation artifact (not copied to this PR). AI-assisted mathematical construction and testing.

## Source hypotheses

Finite strictly positive factor-graph law on `V`. The submitted, locally checkable separator `S` has size `s`, and all connected components `B_1,...,B_m` after deleting `S` have size <=`k`. For each observed separator assignment `z`, the conditional law on the blocks is an independent product. Observable `f` satisfies `|f|<=B` pointwise and algebraic site interaction order <=2:
`f(x)=a+sum_i u_i(x_i)+sum_{i<j} v_ij(x_i,x_j)`.

**Imported Q2 premise:** For independent heterogeneous block variables and bounded block-Hoeffding degree <=2:
`Var(g)^2 <= C2 B^2 max_b I_b(g)`, `C2=(10+2sqrt(2))^2(1+sqrt(3))^2`.
The repository's author-analytic source proof is `research/nightfall/2026-11-quadratic-law-free-audit/Q2_SOFT_OWNERSHIP_SOURCE_NOISE_BRIDGE_20261113.md`.

## Theorem A: separator-mediated observation

Read `S` first. For any realized `z`, grouping original coordinates into the independent residual blocks cannot increase algebraic interaction degree. Q2 therefore applies to `f` considered as a block observable, with boundedness preserved. Let `I_b^h=E[Var(f|X_{-b})|h]` and `P(h)=sum_{b unread} I_b^h`. Product block ANOVA yields `V(h)<=P(h)<=2 V(h)`. Q2 supplies `max_b I_b^h >= P(h)^2/(4 C2 B^2)`.

If the observer reads a maximizing whole block, the tower law gives the **exact source potential drift**
`E[P(next)|h] = P(h)-I_b^h`.
Taking expectation, Jensen and reciprocal telescoping imply `E P_q <= 4 C2 B^2/q`, until the `m` blocks have been exhausted. The conditional mean predictor has squared error <=`eta` with at most

`N_state <= s + k min(m, ceil(4 C2 B^2/eta))`

actual coordinate reads. **There is no global Dobrushin assumption and no global exponential dependence penalty.** The supplied separator is not found for free.

### Local implementation

For strictly positive finite factors `psi_F`, a primal-graph check certifies that after fixing the *actually observed* `S=z`, no factor links two residual components. Normalize a component's factors by summing at most `a^k` configurations, where `a` is the maximum local alphabet. Only the realized separator assignment is processed; no `a^s` enumeration is needed in this *observation* model. Source authenticity, degree-two representation, and a global uniform bound `B` are separate trust/certificate premises.

## Theorem B: site influence of independent dependent blocks

If the original law is independent over blocks of size <=k and each within-block law has local Poincare factor `lambda>0`:
`Var_block(g) <= lambda^-1 sum_{i in block} E Var(g|X_{block\i})`,
then grouping into blocks and applying Q2, followed by that local inequality on the **actual dependent source**, gives

`Var_mu(f)^2 <= (k C2/lambda) B^2 max_i I_i^mu(f)`.

The `1/lambda` factor is unavoidable in order. For a correlated Ising dimer
`nu_t(x,y)=(1+txy)/4` with `0<=t<1`, `lambda=1-t`, `f=(x+y)/2`:
`Var(f)=(1+t)/2`, `I_x=I_y=(1-t^2)/4`, hence `Var(f)^2/(B^2 max I_i)=(1+t)/(1-t)`.
This also demonstrates that immediate prediction gain from observing `x` need not equal conditional heat-bath influence: the gain is `(1+t)^2/4`, much greater as `t->1`.

## Theorem C: genuinely dependent same-interface lower bound

Let `Z` be a fair sign; conditional on `Z=z`, the `2m` leaves are independent with mean `t z` for fixed `0<t<1`. This is a strictly positive **star-graph Gibbs law** with pairwise leaf correlation `t^2`. Let

`f=(1/m) sum_{j=1}^m X_{2j-1} X_{2j}` (bounded by 1, algebraic order 2).

`Var(f)=(1-t^4)/m`. Even granting the hub `Z` for free, after `r` distinct adaptive leaf reads at least `m-r` independent pairs have never been touched. Each contributes residual variance `(1-t^4)/m^2`. For any randomized adaptive observer,
`E residual risk >= (1-t^4)(m-E r)/m^2`.
Thus reaching `eta=(1-t^4)/(2m)` requires `E r>=m/2=(1-t^4)/(4eta)`. This gives the `Omega(1/eta)` state-read lower bound **under the same coordinate-read oracle** on an actually dependent distribution with a one-site separator.

## Posterior-cost bridge (conditional on Q2 and declared oracle)

If hidden model `Theta` is independent of fresh `X` conditional on `D`, each `f_Theta` meets the preceding source promises and a posterior-value call at `x` independently returns `f_tildeTheta(x)`, then four such calls on a **shared** refreshed block-state pair yield an unbiased block influence estimator for `m_D=E[f_Theta|D]`. With `q=min(m,ceil(32 C2 B^2/(3eta)))`, `epsilon=eta^2/(256 C2 B^2)`, `rho=eta^2/(128 C2 B^4)`, `r=ceil(8 B^4 epsilon^-2 log(2m/rho))`, `t*=ceil(2B^2/eta)`, the existing approximate-greedy recurrence yields risk <=`R_model+eta`, actual reads <=`s+kq`, posterior-value calls <=`4mqr+t*`, and synthetic block samples <=`mqr(m+1)+mt*`. This is not a generic bit-runtime bound. Approximate posterior TV error `delta` contributes the risk floor `(sqrt(eta)+2B delta)^2` above `R_model`.

## Negative controls and exact tests

- Parity-biased full-support measure has every proper marginal independent while `f=x_1` has variance 1 and max site influence `4epsilon(1-epsilon)->0`; proper-marginal tests are not a valid dependence certificate.
- Two-source exact rational dimer/product checker: **869** assertions, 34 random finite dimer-product quadratic models.
- Separately implemented correlated-star checker: **17,415** assertions covering all partial leaf histories through 3 pairs.
- Connected weak-Ising path/cycle stress-test: **1,314** exact assertions across 18 finite graph/coupling cases. No failure found in that finite search; **no general high-temperature result follows.**
- Original local checker SHA256: `9f915a2c447bd4047b803bc6f3a22abc046c36f5df67df9c1a68d877948b48f5`.
- Star checker SHA256: `2eefae62dc10126fe29cad6989bf8768ea483d43b26fd91bdb5d8f5991e43a8e`.
- Weak-Ising checker SHA256: `3857f860ee42059cd8c88ba051d0e8ce59874001614e06b765d2d9a5b5de3cf6`.

## Prior art / scope

Classical **cutset conditioning** (Mateescu--Dechter, IJCAI 2005), **mixing-measure influences** (Koehler--Lifshitz--Minzer--Mossel, STOC 2024), and **variance tensorization/spectral gap** (Chen--Feng--Yin--Zhang, SIAM J. Comput.) are the primary comparators. This source-preserving Q2 transfer is a restricted synthesis; it is not yet an independently verified novel contribution. **The next decisive theorem** must treat connected weakly coupled components with a locally certified approximation error and oracle-matched lower bound, without smuggling global dependence into a free simulator.

## Reproduction boundary

The companion full six-page TeX/PDF, two independent exact checker scripts, connected-Ising search script, exact run JSON logs, and SHA256 manifest are in the downloadable research bundle created in the same conversation. This text-only PR does **not** claim those binary artifacts are committed to GitHub. Authoritative present-branch scope is this analytic note only.
