# FUR audit: exact counterexamples to Boolean fiber/plain equality (2026-11-19)

**Status:** exact finite counterexamples, independently integer-replayed from explicit witnesses. This **refutes Approach A's universal equality conjecture**, not FUR. Neither FUR nor the mixture-simulation claim is proved. No Lean formalization and no external human referee review.

**Base:** branch `hellinger-bernstein-transfer`, commit `8640ce8a79544307aae306b4507db9708d8cd255` (Lemma S and FUR hand-off). These are separate results, preserved on this audit branch so the original collaborator branch is untouched.

## Definitions

For `f: {0,1}^n -> [0,1]`, define the **ordinary row cost** as the minimum `t` such that `a_i(x)>=0`, all ordered pairs satisfy
`|f(x)-f(y)| <= sum_{i:x_i!=y_i} a_i(x)`, and `sum_i a_i(x) <= t` for every `x`.

The **fiber row cost** is the same optimization with `a_i(x)=alpha_i(x_{-i})`, invariant when bit `i` is flipped. Denote these by `C_plain(f)` and `C_fiber(f)`.

## Counterexample 1: Boolean-valued, 3 bits, degree 3

Take `f(a,b,c)=(1-a)(1-bc)`. This is 1 exactly at 000, 001, 010. Then

`C_plain(f) = 2 < 5/2 = C_fiber(f)`.

**Plain upper bound 2:** At anchors with first bit 1, put ordinary weight 1 on coordinate 1 and zero elsewhere. At 000 use weights (1,1,0); at 001 use (1,1,0); at 010 use (1,0,1); at 011 use (0,1,1). All pair-cover constraints hold. Edge constraints at 001 (first and second bits) show `C_plain >= 2`.

**Fiber lower bound 5/2:** Let `u=alpha_2(0,0)`, `v=alpha_3(0,0)`. The ordered pair 000 -> 011 forces `u+v>=1`. Edge comparisons imply the fiber costs at 010 and 001 are at least `2+u` and `2+v`, respectively. Thus `C_fiber >= 2+max(u,v)>=5/2`.

**Fiber upper bound 5/2:** Set `alpha_1(b,c)` to (1,1,1,0) for bc in (00,01,10,11); set `alpha_2(a,c)` and `alpha_3(a,b)` both to (1/2,1,0,1) in the same order. Direct enumeration of all 64 ordered pairs verifies coverage, and maximum total row cost is 5/2.

This already disproves equality even for `{0,1}`-*valued* functions.

## Counterexample 2: real-valued bounded quadratic, 4 bits

Let `x=(a,b,c,d)` and define

`q(x)=-c+d-2ab+2ac-ad+bd+cd`, with `f(x)=(q(x)+2)/4`.

The integer polynomial `q` ranges from -2 to 2 on the 4-cube, so `0<=f<=1` and coordinate degree is at most 2. Its costs are **exactly**

`C_plain(f) = 7/4 < 15/8 = C_fiber(f)` (fiber/plain ratio `15/14`).

The adjacent coordinate differences at anchor `x=1101` total 7/4, giving the ordinary lower bound. An explicit 16-by-4 ordinary primal witness attains 7/4. An explicit 4-by-8 fiber primal witness attains 15/8. The fiber dual lower bound uses `kappa=1/2` at each of 1100 and 1101 and `lambda=1/2` on each of six directed pairs:

- 0101 -> 1101
- 1000 -> 1100
- 1001 -> 1101
- 1100 -> 0101
- 1100 -> 1111
- 1101 -> 1111

All fiber budgets hold: for each coordinate `i` and `i`-fiber `F`, the lambda mass assigned to pairs starting in `F` that disagree at `i` is at most `kappa(F)`. The six absolute `q`-differences sum to 15, so the dual objective is `(1/2)*(1/4)*15=15/8`. Exact primal equality proves the value is 15/8.

**Replay:** Run `python3 research/nightfall/mixture_aa/fiber_uniform_rows/FUR_BOOLEAN_QUADRATIC_COUNTEREXAMPLE_CHECK.py`. No dependencies. Its 256 ordered-pair checks, row maxima, edge lower bound and fiber dual budget inequalities are integer-only.

## Mechanism and scope

The fiber constraint couples an anchor's coordinate weight to a neighboring anchor's same-coordinate weight. The local ordinary LP can allocate weight separately; the fiber LP sometimes cannot. Hence the 17/18 empirical equalities in `FUR_PROOF_ATTEMPT_20261119.md` are not an identity, even at degree 2.

This does **not** supply a growing separation or contradict the polynomial `C(d)` asserted by FUR. A ratio of 15/14 at degree 2 is compatible with FUR. The paper-proved switching-time lemma (Lemma S) remains a separate, unreviewed claim; its max-inside-average issue remains.

## Research redirection

1. **Retire Approach A as stated.** Do not attempt to prove exact equality on all Boolean inputs. A revised quantitative constant-factor comparison could still be useful, but requires a new proof.
2. **Prioritize Approach E:** under the specific product anchor law `nu_bar`, try to bound `E_{nu_bar} sum_i alpha_i(X_{-i})` directly. Avoid imposing the false exact-equality sublemma.
3. **New test:** construct product-law-weighted fiber LPs for the quadratic witness, then optimize over product marginals (including rare-symbol skews). This discriminates between the weaker in-expectation target and the stronger pointwise FUR.
4. **Proof attack:** test any candidate E-bound against the explicit primal/dual witnesses here, one-hot mixtures, and the second-difference `sqrt(n)` obstruction described in the initial hand-off.

**Prior art screened (not exhaustive):** Lovett and Zhang, *Fractional Certificates for Bounded Functions*, ITCS 2023, proves small ordinary fractional certificates for bounded polynomials, https://doi.org/10.4230/LIPIcs.ITCS.2023.84 . The exact fiber-invariant strengthening is not established by that source. No novelty claim is made for this finite counterexample.

**Certification status:** arithmetic-exact, checkable finite counterexample. Mathematical implication is conditional only on the explicit definitions above. No peer review, Lean certification, or claim that FUR is false.
