# NIGHTFALL — universal Werner bounds at 17–23 copies

**Research checkpoint:** 2026-10-28. **Status:** exact rational source-theorem-conditional constructions, checked by a separate pure-Fraction verifier. Independent external mathematical review and full priority clearance remain outstanding.

## Objective and external comparator

Strengthen sufficient undistillability thresholds for local dimension `d>=3`, at copy counts `17<=k<=23`, beyond the published many-copy benchmark `56/(25k)`. Also test whether our existing cone can materially strengthen the five-copy qutrit, six-copy qutrit and eight-copy all-dimension bounds.

External source: Tejasvi S. Tomar, *Undistillability of Werner states from three, four and five copies* (posted 2026-10-23), https://www.mefyi.com/papers/werner-states-copies/ , DOI 10.5281/zenodo.23604343. For the two-block trace inequalities consult Pablo Costa Rico, *New partial trace inequalities and distillability of Werner states*, Letters in Mathematical Physics 115 (2025). Published two-copy and sharp three-copy theorems are also imported. Every new result is conditional on these sources being correctly interpreted.

## Verified new construction

For a complex matrix `C` of rank at most two on `(C^d)^(tensor k)`, `d>=3`, write `Q_k(t,C)=sum_(J subset [k])(-t)^|J| ||Tr_J C||_F^2`. Each JSON certificate proves exactly

`Q_k(t_k,C) >= M_k ||C||_F^2`, with `M_k>0`,

by an identity in averaged partial-trace profiles. The `z` variable in the source-polynomial rows is **formal notation for averaged trace norms**. Its products mean symmetrized disjoint-site operator constructions, not a numerical product of profile values.

| k | Published 56/(25k) | New exact rational t | New decimal t | Gain | M_k approx. | NPT use begins at d |
|---:|---:|---:|---:|---:|---:|---:|
| 17 | 0.131764706 | `2647/20000` | 0.132350000 | +0.000585294 | 2.1126111916e-05 | 8 |
| 18 | 0.124444444 | `12499/100000` | 0.124990000 | +0.000545556 | 7.96342081097e-05 | 9 |
| 19 | 0.117894737 | `74/625` | 0.118400000 | +0.000505263 | 0.000177677748638 | 9 |
| 20 | 0.112000000 | `281/2500` | 0.112400000 | +0.000400000 | 0.000888863442232 | 9 |
| 21 | 0.106666667 | `7493/70000` | 0.107042857 | +0.000376190 | 0.000933325038901 | 10 |
| 22 | 0.101818182 | `11239/110000` | 0.102172727 | +0.000354545 | 0.000977775388871 | 10 |
| 23 | 0.097391304 | `22477/230000` | 0.097726087 | +0.000334783 | 0.00102222158338 | 11 |

A larger `t` means a stronger undistillability sufficient condition for the state `rho(d,alpha)` when `alpha >= -t`. For dimensions below the final column, the same inequality holds, although its interval lies inside the PPT sector.

## Certificate mechanism and proof dependencies

For each k, the JSON certificate contains a strictly positive rational constant `M_k` and strictly positive rational coefficients `w_i`, with the polynomial identity

`sum_(j=0)^k binom(k,j) (-t)^j z^j = M_k + sum_i w_i R_i(z)`.

Each `R_i` comes from exactly one source inequality on disjoint site groups:

1. A nonnegative partial-trace norm profile (`z^j`) or rank-two trace cap (`2-z^j`).
2. The published five-copy, dimension-uniform inequality, `prod_(r=1)^5 (1 - (9/20) z^(g_r))`, with positive group sizes.
3. The sharp two-block trace-difference inequality `2+z^a-z^b-(1/2)z^(a+b)` (with both signs permitted).
4. A product of factors `1+z^s` representing **separable positive spectators**, using disjoint copies and a complete copy-budget audit.

The generated certificates use only those rows; they require **no numerical slack inferred from Tomar's rounded SDP tables**. The checker independently reconstructs every row from its label, verifies site budgets, exact equality coefficient by coefficient, exact rational positivity, and invalid-spectator negative controls. The proof uses standard rank-two contractions through separable spectators. Full source-to-target operator semantics remain an explicit referee checklist.

## Exact dual-method obstruction: five, six, eight copies

For the enumerated finite source cones in `records/basis_*.json`, I derived rational dual vectors `y` with `y_0=1`, `y·R_i >= 0` for every enumerated row, and `y·P_k(t)<0` at the targets below. Thus a decomposition with a nonnegative constant margin in that **specific cone** is impossible at those parameter values. This is an obstruction to the method, **not** an upper bound on the true physical undistillability threshold.

| Scope | Attempted target | Number of audited source rows | First exact certified exclusion onward* |
|---|---:|---:|---:|
| Qutrit five-copy | 0.480000 | 254 | t >= 0.471893 |
| Qutrit six-copy | 0.460000 | 551 | t >= 0.448193 |
| All-dimension eight-copy | 0.300000 | 423 | t >= 0.279744 |

*The exact dual pairing is negative at each rational starting point and its derivative is strictly negative throughout that interval up to `t=1/2`. The derivative sign is certified using rational Bernstein coefficients. All three checks run in `check_monotone_dual.py`.

The five-/six-copy qutrit cones import numerical margins read from Tomar's rounded displays. These dual statements are conditional on those imported values. A different valid source inequality, independently reproduced larger upstream margin, or a direct semidefinite proof can escape the cones. The eight-copy cone uses published source-theorem statements without numerical SDP margins.

## Experiment registry and errors

- **Operator A: exhaustive enumerated source cone at low copies.** k5, k6, k8. Outcome: exact dual obstructions; no material numerical gain. Failure mechanism: source-cone limitation, not a physical counterexample.
- **Operator B: positive-spectator sparse expansion of the five-copy theorem plus trace-difference rows.** k17...23. Predicted close approaches to `9/(4k)`; every new certificate verified. The source family is sparse enough to reproduce on a CPU.
- **Operator C: high-copy floating linear programming.** k24 and k25 candidates near `9/(4k)-0.0001` appeared numerically feasible, yet the LP support was rank-deficient under exact reconstruction. Neither candidate is a certified bound; both are excluded from this result table.

No improvement to the five-copy, six-copy or universal eight-copy thresholds is claimed in this iteration. Numerical gains at k17...23 are generally between 0.0003 and 0.0006. Global optimality and external record priority are open.

## Reproduction

```bash
python independent_verify.py records
python independent_dual_verify.py
python check_monotone_dual.py
sha256sum -c SHA256SUMS
```

The two exact checkers use independent formulations of the polynomial rows; neither imports the LP generator. Source rules remain a distinct, auditable mathematical assumption. `RESULTS.csv` links each integer threshold to the exact certificate filename. All reported numbers trace to rational fields rather than rounded transcriptions.

## Session handoff

**Best new result:** seven exact all-dimension inequalities for copies 17–23, certified conditional on published source theorems. **Unresolved:** richer rank-sensitive source inequalities for the five-/six-copy qutrit and eight-copy all-dimension cones; exact reconstruction at 24+. **Decisive experiment:** explicit duals show the existing low-copy cones have essentially exhausted their numerical potential. **Next operator:** derive a new physical rank-two moment inequality, then test whether its coefficient vector pairs negatively with these stored duals before launching larger optimizations. **Stop:** three families examined; further retuning of the same finite cones has low discovery value.
