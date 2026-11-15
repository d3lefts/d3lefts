# Q2 C96.5735201305: independent-Hilbert theorem certification attack

**2026-11-15 UTC — PROVISIONAL, NOT AN UNCONDITIONAL LEAN CERTIFICATE**

## One precise missing theorem

For arbitrary finite independent centered real-Hilbert increments `Y_i` with
`||Y_i|| <= c` and arbitrary fixed shift `H`, set `Z=H+sum Y_i`,
`e=E||Z||²`, `u=E||Z||`. The proposed missing inequality is

```text
e <= 2*u*u + c*u.
```

It is **unproved for arbitrary n and arbitrary asymmetric product laws**.
If established, `beta=(sqrt(3)-1)/4` and the exact identity

```text
(sqrt(3)*u + beta*c)^2 - (2*u*u+c*u) = (u-beta*c)^2
```

give `sqrt(e) <= sqrt(3)*u + beta*c`. The implication is **already
Lean-certified** by `Nightfall.Q2Shifted.C5MomentBridge.first_second_sos`
and `c5_from_first_second_comparison` in
`research/nightfall/formalization/q2_shifted/ShiftedC5MomentBridge.lean`.
Do **not** call that conditional proof an independent-Hilbert theorem.

Using the certified source-section budget `sum_i u_i <= 2(1+sqrt(2))*B`
and the greedy owner budget `sum_i c_i<=8B`, the desired all-source Q2
coefficient would be exactly

```text
C96 = [2(1+sqrt(2))*sqrt(3) + 2*(sqrt(3)-1)]²
    = 4*((2+sqrt(2))*sqrt(3)-1)²
    = 96.5735201305411...
```

**No end-to-end original-source `C96` theorem has passed Lean.**

## Independent analytic facts checked here

**One increment:** for `Z=H+Y`, `EY=0`, `||Y||<=c`, put
`a=||H||`. Pointwise `||Z||<=a+c`; hence `e<= (a+c)*u`.
Jensen gives `a=||EZ||<=u`, so **`e<=u²+c*u`**. This
is an analytic proof, not a new Lean receipt.

**Necessity of the coefficient 1:** take a scalar centered one-increment
family with `P(Y=1)=1/(k+1)`, `P(Y=-1/k)=k/(k+1)`,
`H=1/k`, `c=1`. Then exactly
`u=1/k`, `e=(k+1)/k²` and
`(e-2u²)/(c*u)=1-1/k -> 1`. Thus **any** all-law inequality
`e<=2u²+lambda*c*u` must have `lambda>=1`.
This establishes necessary sharpness only, not sufficiency.

The same law gives a lower bound on any uniform additive correction
`sqrt(e)<=sqrt(3)*u+beta*c`:
`beta >= (sqrt(3)-sqrt(2))/2 = 0.158918622597891...`,
by optimizing the one-increment rare-event probability
`p=(sqrt(3)-sqrt(2))²`. This is a rigorous *lower bound* on the
all-n optimum, not a new 92.82224 universal theorem.

## Counterexample search — exact finite grid

```bash
python3 research/nightfall/2026-11-quadratic-law-free-audit/check_c96_first_second_exact.py --max-n 4
```

The standalone checker enumerates **746,493 distinct grid tests** over
`n<=4`, individual two-point centered laws with zero-mass atoms and
heterogeneous probabilities in `{0,1/16,1/8,1/4,3/8,1/2}`, independent
sign orientations, and rational shifts `H=k/8` for `-16<=k<=16`.
It verifies centeredness/normalization/amplitude, computes `e,u`
and checks the proposed inequality with exact `fractions.Fraction`,
then audits a fixed SHA-256 of all individual case receipts.

**Results:** no counterexample in the finite grid; exact digest
`66ce3536894ef434e61fc37195683c763e950796f31b96dd2670b04adb8a314b`.
A finite search **never** proves the universal conjecture.

## Stronger shifted variance conjecture and exact equality family

Independent optimization suggests the **strictly stronger** all-n conjecture

```text
e + ||H||² <= 2*u² + c*u
```

equivalently `Var(||H+sum Y_j||) <= (sum_j E||Y_j||²+c*u)/2`.
The stronger bound implies the C96 first/second comparison, but **neither
version is universally proved**. A second independent exact checker,
`check_c96_strong_shift_exact.py`, exhausts the same 746,493 rational
scalar cases using the stronger margin and reproduces SHA256
`ebf32717e180e587a9822a39286bbeffa38942a6c316757ec745b74b8e6be175`.
Again: finite-grid checks are NOT kernel theorems.

The strengthening has an informative **exact equality class for every n**:
choose any `c>0` and `t_j in [0,c]`, independently let
`Y_j=c` with probability `t_j/(c+t_j)`, otherwise `Y_j=-t_j`,
and set `H=sum_j t_j`. Every increment is centered and bounded by c;
`S=H+sum Y_j>=0`, so `u=ES=H` and
`e=H²+sum Var Y_j = H²+cH`. Hence
`e+H²=2u²+c*u` **with equality**. For normalized c=1, exact rational
examples with `t=(1/2)`, `t=(1/3,1/4)`, and
`t=(1/8,1/4,3/8)` are replayed in the second checker.

This is useful for independent Bellman-function or induction attacks:
the candidate cannot be improved by a positive uniform slack term.
It is **not** a derivation of the inequality for arbitrary laws or Hilbert outputs.

### Two-replica angular-versus-radial decomposition

There is an exact geometric reformulation of the stronger conjecture.
Let `S=H+sum_jY_j` and `S'` be an independent copy, and write
`F=||S||`, `u=EF`, `a=||ES||=||H||`. By independence,

```text
A = E_{S,S'}( ||S||*||S'|| - <S,S'> ) = u²-a² >= 0.
```

The stronger comparison `e+a²<=2u²+c*u` is **equivalent** to

```text
Var(||S||) <= A + c*u.
```

Thus the new burden is to bound **radial dispersion** by the
independently sampled **angular misalignment** plus a sharp one-jump
amplitude tax. This uses the exact identity
`||S-S'||² = (||S||-||S'||)² + 2(||S||||S'||-<S,S'>)`.
For scalar `S`, `A=4*E(S_+)*E((-S)_+) `: mixed-sign mass
pays the angular term, while the all-n nonnegative equality family
pays the linear amplitude term. This is an operator hypothesis,
**not** a proof of the needed variance inequality.

## Alternative operator and exact obstruction

For `V=sum_i ||Y_i||²`, `W=sqrt(V)`,
`W_{-i}=sqrt(V-||Y_i||²)`, define `d_i=W-W_{-i}`.
Then `0<=d_i<=c`, and `sum_i d_i<=W`, so one-sided Efron–Stein
gives **`Var(W)<=c*E(W)`**, equivalently
`EV<=(EW)²+c*EW`. This self-bounding energy lemma is valid,
but converting `EW` to `u=E||H+sum Y||` without inflating the
linear term is the outstanding difficulty.

The exact pseudo-moment from PR #563,
`a=2/5, s=21/25, c=5/4, e=1, u=5/12, q=59/10`,
satisfies the existing relaxed Holder/fourth-moment constraints yet has
`2*u²+c*u = 125/144 < 1`. It is **not** a real independent law.
It rules out deriving C96 solely from those old constraints.

## Literature boundary and recommended certification

The Latała–Oleszkiewicz sharp `L1/L2` comparison for independent
Rademacher sums is a relevant antecedent, but **does not resolve**
the arbitrary **asymmetric** independent-Hilbert law. See IMRN
`Stochastic Dominance and Weak Concentration for Sums of Independent
Symmetric Random Vectors` (2020):
https://academic.oup.com/imrn/article/2020/23/8997/5144009

**Next decisive experiment:** formally prove or refute the displayed
first/second moment theorem as a standalone all-n original-product Lean
declaration, with a separate *independent* proof review, then compose
it with existing source-generated owner/section certificates.
Do not promote C96 before both steps pass.

Research handoff: PR #564 comment
https://github.com/d3lefts/d3lefts/pull/564#issuecomment-6888745687
