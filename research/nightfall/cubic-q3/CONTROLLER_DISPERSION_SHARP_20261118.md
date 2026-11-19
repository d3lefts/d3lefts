# Q3: sharp controller-dispersion certificate and constant-energy high-cover cycles

**NIGHTFALL | 2026-11-18 | status:** Author-side analytic theorem, independent-formula exact rational replay, not Lean kernel-certified, not externally reviewed, and not a priority/novelty claim. The unrestricted original-law degree-three exponent-two influence conjecture **remains open**.

## Objective, baseline and failure alternatives

The open gate following PR #857 is whether coordinate-resolved section energies can be globally controlled without illegally exchanging maxima and expectations. PR #857 proved the optimal per-controller transport comparison `T_j(q) <= 4 B^2 Inf_j(f)`, but that bound does not sum influence costs over an unbounded number of controllers. This checkpoint proves an exact additive transport-dispersion estimate, determines its best constant, and exhibits an equal-weight high-cover hypergraph whose energy transport vanishes.

Checked external reference: David Turturean, *A proof of the Aaronson–Ambainis conjecture* (2026), https://arxiv.org/abs/2611.09773. Its polynomial-degree bound has variance exponent 5/2 on the fair cube. Uniform fixed-degree exponent-two was already established by Defant–Mastyło–Pérez (2019), https://arxiv.org/abs/1706.03670. Neither establishes the unrestricted arbitrary-law cubic target. Classical inputs below are the Efron–Stein variance inequality, Popoviciu and Cauchy–Schwarz; no originality claim for their combination without dedicated prior-art audit.

## Theorem (sharp additive dispersion, arbitrary finite original product laws)

Let `X=(X_i)_(i in I)` and `W=(W_j)_(j in J)` be independent blocks of mutually independent variables, each with its **original** probability law, finite coordinate index sets and arbitrary alphabets (including zero-probability letters, interpreted essentially). Let

`f(X,W) = c(W) + sum_(i in I) u_i(X_i,W)`

with `E_(X_i) u_i(X_i,w)=0` for every supported controller configuration `w`, and `f` bounded with centered essential radius `B = (ess sup f - ess inf f)/2`.

Define `s_i(w)=||u_i(.,w)||_(L²(mu_i))`, `q_i(w)=s_i(w)^2`, and

`V_X = E_W Var_X(f | W) = sum_i E_W q_i(W)`,

`M_X = max_i E_W q_i(W) = max_(i in I) Inf_(X_i)(f)` (zero when `I` is empty),

`T_j(q) = (1/2) E ||q(W)-q(W^(j))||_1^2`, with `W^(j)` obtained by independently resampling coordinate `j` from its actual source law.

Then, **without a degree assumption**,

`V_X <= B sqrt(M_X) + sum_(j in J) sqrt(T_j(q)/2).`  **(D)**

The common prefactor `1/sqrt(2)` on `sum_j sqrt(T_j(q))` **cannot be lowered**, even for pure degree-three functions. This sharpness concerns the displayed dispersion coefficient, not a best possible universal cubic influence constant.

### Proof

1. Original-source independence of the anchors makes their conditional essential oscillations additive. Popoviciu bounds each `s_i(w)` by half of its own oscillation, and the conditional range of `f` is no more than `2B`. Hence `sum_i s_i(w) <= B` for all supported `w`.
2. Write `a_i=E_W s_i(W)`. Then `a_i <= sqrt(E_W s_i²) <= sqrt(M_X)` and `sum_i a_i <= B`. The exact decomposition is

   `V_X = sum_i a_i² + sum_i Var_W(s_i(W))`, with `sum_i a_i² <= B sqrt(M_X)`.
3. Original-product Efron–Stein, applied to each nonnegative scalar `s_i`, gives

   `sum_i Var_W(s_i) <= (1/2) sum_j E sum_i (s_i(W)-s_i(W^(j)))²`.

   Since `(a-b)² <= |a²-b²|` for nonnegative `a,b`, this is at most

   `(1/2) sum_j E ||q(W)-q(W^(j))||_1`.
4. Cauchy–Schwarz applied separately to each `j` yields

   `(1/2) E ||q(W)-q(W^(j))||_1 <= sqrt(T_j(q)/2)`.

Combining 1–4 proves (D). No scalar-energy substitution, moment assumption, or illegal `E max` / `max E` exchange occurs. The controller-only term `c(W)` does not enter `V_X` or anchor influences; **(D) is not automatically a bound on `Var(f)` if `c` is nonconstant**. In that case, `Var(f)=V_X+Var_W c(W)` by conditional total variance. Pure cubic families used below have `c=0`.

### Sharpness and necessary tensorization

Take independent fair anchor signs `X_1,...,X_n` and fair `Z`, with a categorical controller `Y` uniform on `[n]`. The pure cubic is

`h_n(X,Y,Z)=Z (X_Y-(1/n)sum_i X_i)`.

For `n>=3`, exact original-law values are

- `B=2(n-1)/n`, `V_X=V=(n-1)/n`;
- `M_X=(n-1)/n²`;
- `T_Y(q)=2(1-1/n)(1-2/n)²`, `T_Z(q)=0`.

As `n -> infinity`, `B sqrt(M_X) -> 0`, `V_X -> 1`, `sqrt(T_Y(q)) -> sqrt(2)`. Any proposed replacement coefficient `< 1/sqrt(2)` therefore fails.

**A maximum over controllers is impossible.** For `k` mutually independent copies of the above with disjoint variables, define `f_(k,n)=(1/k)sum_(j=1)^k h_n^(j)`. Exact identities are

`B=2(1-1/n)`, `V_X=(1-1/n)/k`, `M_X=(n-1)/(k² n²)`,

`T_(Y_j)(q)=2(1-1/n)(1-2/n)²/k⁴` and `T_(Z_j)(q)=0` for every j.

Choose `n=k⁴`. Then `V_X ~1/k` while both `B sqrt(M_X)=O(k^-3)` and `sqrt(max_j T_j(q))=O(k^-2)`. Consequently, **no universal C** can replace `sum_j sqrt(T_j(q))` by `C sqrt(max_j T_j(q))` in (D). This is a counterexample to that *proof shortcut*, not to the original influence conjecture: every `Y_j,Z_j` retains true source influence `(1-1/n)/k²`, and the global ratio `V²/(B² M)=1/[4(1-1/n)]` remains bounded.

The sum over controller *square-root* transport costs scales as `1/k`, exactly matching the additive independent-block variance. This is the correct tensorization scale for (D).

## Exact coefficient-one subclass at arbitrarily large fractional cover

If the section-energy vector `q(W)` is coordinatewise constant on the support, then every `T_j(q)=0`. The theorem gives

`V_X² <= B² M_X` (**coefficient-one anchor inequality**)

for **any degree and any number of controllers**; it does not demand disconnected supports, limited cover, or a bound on atom masses. To apply this directly to the full variance, require `Var_W c(W)=0` (as in the pure cubic example below).

Take `n>=3`, independent fair signs `X_1,...,X_n,W_1,...,W_n`, cyclic indices mod n, and

`F_n(X,W)=(1/n) sum_(i=1)^n X_i W_i W_(i+1)`.

This is a bounded pure original-law cubic. Exact identities for **every n**:

- `B=1`, `V=1/n`;
- `I_(X_i)=1/n²`, `I_(W_j)=2/n²`; therefore `M=2/n²`, and `V²/(B² M)=1/2`;
- `q_i(W)=1/n²` for all W, so **all transport costs vanish**, and `V²=B² M_X` is exact;
- The active ANOVA support hyperedges are precisely `S_i={X_i,W_i,W_(i+1)}`, each with equal nonzero Fourier coefficient `1/n`. They form a connected hypergraph with fractional vertex-cover `tau*=n/2`: a primal cover of weight `1/2` on every controller `W_j` covers each edge exactly; dual packing weight `1/2` on each hyperedge saturates each control vertex and respects every anchor capacity. Equal primal and dual totals prove the LP optimum.

This gives a **uniformly weighted, connected, arbitrarily high-cover, zero-dispersion family**. Unlike the weakly stitched cycle in PR #857, the cover cost is not generated by arbitrarily small coefficients. It directly separates combinatorial support complexity from the relevant geometric energy transport.

### Known limitations and next unresolved gate

(D) is valid with a potentially large `sum_j sqrt(T_j(q))`; replacing it with a function of `max_j Inf_j(f)` independently of controller count is *not established*. The `k`-fold selector construction shows why aggregating controller costs by a single maximum cannot work without additional structural or tensorization information. The proof is elementary and potentially anticipated by classical Efron–Stein/Banach-valued literature; mathematical priority requires an independent search. It does **not** prove unrestricted arbitrary-law cubic Q3, polynomial-in-degree exponent two, or the #803 mean-coupled replica inequality.

The next candidate gate is a **component-localized dispersion aggregation**: divide source-coupled controller interactions into tensorizable parts, charge shared coordinates only once, and show a bound of the form `V_X <= C B sqrt(M)` for degree-two controller sections. Any proposed aggregation must accept the `k`-fold selector and the connected constant-energy cycle without dependence on raw fractional-cover size. Strongest falsifier: a connected, high-cover, genuinely *nonconstant-energy* cubic with small original control influences relative to its aggregate dispersion.

## Reproduction and certification boundary

The standard-library exact rational checker `check_q3_transport_dispersion.py` directly enumerates the original physical source for 200 heterogeneous binary/ternary controller cases with cubic interactions, computes all fair-anchor influences from actual input flips, verifies every decomposition and Jensen/Poincare step, tests coefficient asymptotics with certified square-root lower/upper rational enclosures, and independently enumerates all fair input states of the high-cover family for `n=3,4,5,6`. Additional symbolic rational evaluations for `k=10,100,1000`, `n=k^4` demonstrate arbitrarily worsening failure of max-controller transport aggregation. This finite replay supports but cannot replace the all-n analytic proofs above.

**Checker command:** `python3 -I research/nightfall/cubic-q3/check_q3_transport_dispersion.py`.

**Status:** Scoped exact analytic certificate + exact finite-source regression; external theorem review, Lean formalization and novelty clearance not performed. Keep draft; no breakthrough or global conjecture closure claim.