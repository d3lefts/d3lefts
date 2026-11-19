# Independent proof audit: latent-product strong simulation (2026-11-19)

**Scope.** Review of the paper arguments in PR #893, not a kernel certificate, peer review, novelty certification, or claim of an arXiv submission. Main outside references consulted: BDST, arXiv:2608.19158v1 (Theorem 1); Girish–Mittal–Nehoran–Raz, arXiv:2609.35327v1 (Proposition 3.6 and Remark 3.5).

## The margin discrepancy

GMNR's base gadget encodes a target biased bit using `p`-biased source bits; the largest source string probability is bounded by `(1-a)^m`, producing `2^(-am)`. When the source bits are **uniform**, the maximum block atom is exactly `2^(-m)`. Thus a direct dyadic uniform-base encoding has no intrinsic `1/c` cost in block length. This observation is elementary and its novelty is **not established**.

## Required repairs to Lemma 3

1. **State the oracle model.** Each original oracle query must return one finite-alphabet symbol coherently in the standard value-oracle model. An encoding block of `m` uniform bits permits reversible computation of the symbol with at most `2m` bit-oracle queries and two parallel rounds per original round. Account for alphabets of at most `1/c` symbols.
2. **Construct the event approximator.** Clip classical leaf outputs to `[0,1]`; then `z=f-T\in[-1,1]`. For `0<epsilon<=1/2`, `0<eta<1/2`, let `k=ceil((2/(9 epsilon^4)) log(1/eta))` and `r=floor(5k epsilon^2/2)`. Define
   `phi(z) = sum_{j=r+1}^k binom(k,j) (z^2)^j (1-z^2)^(k-j)`.
   This is a polynomial of degree at most `2k`, satisfies `0<=phi<=1` on `[-1,1]`, is at most `eta` for `|z|<=epsilon`, and is at least `1-eta` for `|z|>=2epsilon`. The last two inequalities follow from Hoeffding on `Binomial(k,z^2)`; check endpoint/tail rounding explicitly. It is sufficient to use this less-sharp `O(epsilon^-4 log(1/eta))` construction: its degree is inside a logarithm in the encoding length.
3. **Interpolation under finite alphabets.** Let `gamma=max_(i,a)|p_i(a)-p'_i(a)|<=2^-m`, with each `p_i(a)>=c`, and require `gamma<=c/2` so `p'_i(a)>=c/2`. The segment `p'_i+s(p_i-p'_i)` consists of distributions on `s\in[-c/(2gamma),1+c/(2gamma)]`. For any bounded degree-`h` function `G\in[0,1]`, its expectation `H(s)` is degree at most `h` and Bernstein gives
   `|H'(s)| <= h / (2 sqrt((s+c/(2gamma))(1+c/(2gamma)-s))) <= h gamma/c`, `0<=s<=1`.
   Thus `|E_P G-E_(P') G|<=h gamma/c`. If `gamma=0`, the shift vanishes.
4. **Degree bookkeeping.** The acceptance probability has coordinate degree at most `2t`, the deterministic output tree has degree at most `D`, and `G=phi(f-T)` has degree at most `h=2k(2t+D)`. Therefore choose `2^-m <= c eta/h`.
5. **Remove the circular definition of `m`.** The tree depth `D=D(m)=S(2mt,2d,epsilon,eta)` depends on `m`. State and prove existence of an integer satisfying
   `m >= log2(2h(m)/(c eta))`.
   Under the BDST bound, `h(m)` is polynomial in `m` for fixed `d`; exponential decay `2^-m` wins. Provide an explicit upper bound `m=poly(d)\,O(log(t/(c epsilon eta)) + loglog(1/eta))` with constants calibrated to the simulator parameters. Do not state `m=log(deg/(delta c))+O(1)` as if `deg` were independent of `m`.
6. **Derandomization.** For `X\sim P'`, independently draw one latent block `Y_i\sim U({0,1}^m\mid g_i(Y_i)=X_i)` for each coordinate, keeping it consistent across all adaptive bit queries. The assembled `Y` is uniform. Average over seeds, then fix one seed: this yields a deterministic `X`-query tree with the desired average failure under `P'`.
7. **Strong error transfer.** Under `P'`, `E phi(f-T) <= Pr(|f-T|>epsilon)+eta`. Under `P`, `Pr(|f-T|>2epsilon) <= E phi(f-T)+eta`. Interpolation contributes at most `h 2^-m/c <= eta`. If the uniform simulator fails with probability `eta`, the final failure is at most `4eta`. Reparametrize `eta=delta/4`. The extra accuracy factor of two must be reflected in the downstream mixture theorem.

## Lemma 1 audit

- In Step 3 explicitly demand the concentration centers `u,v\in[0,1]`, or replace `epsilon+delta` by an appropriate range-dependent bound. Tree outputs should be clipped to the unit interval.
- The weighted overlap step is sound conditional on the small-gap expectation bound: `Delta sum_x min(P_L(x),Q_L(x)) <= E_P[bad_P]+E_Q[bad_Q]`.
- The `|L|>K` branch tensorizes Bhattacharyya coefficients. For transcript-conditioned tests, choose a single joint set of possible pairwise queries *at the end of the preliminary simulations*, not after conditioning on the outcomes of previous duels.
- The theorem's 5-epsilon final accuracy needs consistent internal accuracy conventions: Lemma 3 currently outputs within `2epsilon`. Invoke it at accuracy `epsilon/2` before running component identification at `epsilon`.
- The original 1,200-instance empirical TV test was vacuous on all 148 separated cases if its RHS exceeds one. Add a nonvacuous exact test (below).

## Exact, nonvacuous example

Take `n=9`, `P_i(1)=9/10`, `Q_i(1)=1/10`, `f=1[sum_i x_i >=5]` (coordinate degree at most 9), `u=1`, `v=0`, `epsilon=1/10`. Both failure probabilities are exactly `22273/25000000 = 0.00089092`. Their full-coordinate overlap is `22273/12500000 = 0.00178184`. With `Delta=1-3epsilon=7/10`, the bound `2delta/Delta=0.002545485714...` is **strictly less than 1** and is satisfied. This example is a valid nonvacuous test of the overlap inequality, not a general proof.

## Status and promotion gate

- Component lemma: plausible paper argument; **not Lean checked**.
- Strong biased-product lemma: independently inspected mathematical construction; **needs explicit polynomial and fixed-point proof and full test**.
- Conditional mixture theorem: weighted conditional tournament proof still needs a formal write-up; **not independently certified**.
- Publication headline: may describe the **proposed theorem, with provisional status**, but must not replace the previously Lean-certified general poly(1/delta) result as an established fact until full audit and review.

**Cheapest decisive next checks:** (i) evaluate nonvacuous exact examples; (ii) discharge binomial-step approximator and fixed-point inequality; (iii) formalize finite weighted overlap and Hellinger branch; (iv) run the complete pinned Lean build; (v) obtain non-author review.
