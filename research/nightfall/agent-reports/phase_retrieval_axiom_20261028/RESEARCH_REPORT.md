# AXIOM / NIGHTFALL — Issue #3: fixed-field Frobenius lifting and LLL audit

**Date:** 2026-10-28. **Research owner:** Devin J. Wright. **Research contributor / executable audit:** Axiom (GPT-6). **Provenance:** local Python 3.13.5; 3 scripts and 3 result logs in this package. **Scope labels:** analytic theorem manuscript under audit; finite test results independently reproduced by separately written arithmetic implementations; novelty unconfirmed. **No external expert acceptance claimed.**

## 1. Source-frozen contract and observed baseline

- Existing systematic fourth-power LLL handoff: `research/nightfall/projects/finite-field-retrieval-handoff-excerpt.txt` (GitHub blob `a44b19eeb08671e592616e7bbb8061e51326de7b`). Claims uniform all-signal recovery over sufficiently large fields under plain certified LLL.
- October 28 improvement: `research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md`, together with `verify_tail_A.py` (blob `62d8a3178ccb536c87d243cdfbee7a7cae5089aa`) and `verify_tail_B.py` (blob `fb3c5fd9d049f29ecd776854153b79eee19949ac`), claims a downstream tail of `<2^-96` *conditional* on the Gaussian short-vector span-count lemma.
- Gap: Neither the original LLL uniform proof nor the conditional Gaussian span-count lemma has received a fresh, independent full proof reconstruction in this session. The exact integer parameter check `4000000**12 < 32*2997599**12` is true, without establishing the entire LLL argument.
- New experiment: independent algebraic construction over fixed fields, then adversarial finite verification. **Significance:** if the uniform guarantee survives review, eliminate the need for field size exponential in signal dimension, paying an increased constant number of measurements. An older extension-field kernel branch in the handoff is potentially related and must be compared before any priority claim.

## 2. Candidate theorem (uniform, nonadaptive powered sensing over fixed fields)

Fix a prime `p`, integer `r>=2`, `q=p^r`, `k>=1`, integer `s>=1` and `m>=ceil(3*r*k/(r-1))+s`. Draw all `m` sensing vectors `a_j` independently uniformly from `F_q^k`. For each signal `x in F_q^k`, record `y_j=(a_j · x)^(p-1)`. Define the `m x (2k)` linearization matrix

`M_x[j] = (a_j1^p,...,a_jk^p, -y_j*a_j1,...,-y_j*a_jk)`.

Then

`Pr_A[ for every nonzero x, ker_Fq M_x = F_q*(x^p,x) ] >= 1 - p^(-(r-1)*s)`.

On this event, the same sensing matrix uniquely identifies *every* signal up to scalar multiplication by `mu_(p-1)`, with a Gaussian-elimination decoder. For `p=5,r=2`, we get `q=25`, **`m>=6k+s`**, failure at most `5^-s`. For fixed `p`, the algorithm has polynomial arithmetic and expected polynomial bit complexity in `k,log q`, using a standard finite-field root-finding subroutine. With variable `p`, listing `p-1` representatives necessarily costs at least `p-1`, so the honest runtime is polynomial in `k,p,log q` rather than uniform in `log q` alone.

**Status:** written elementary proof below; independent algebraic peer audit open. Do not label a field-wide novelty record.

### Proof

1. For every `x`, `((a · x)^p, a · x)` satisfies `a^p · x^p = (a · x)^(p-1)(a · x)` (Frobenius). Hence `w_x=(x^p,x)` is in the kernel of each row.
2. Fix `x != 0`. For a candidate `(u,v)` define `P_{x,u,v}(a) = sum_i u_i a_i^p - (sum_i x_i a_i)^(p-1) sum_i v_i a_i`. This homogeneous polynomial has total degree `p`.
3. Choose an invertible `F_q`-linear coordinate change with first coordinate `z_0=a · x` and remaining coordinates `z_1,...,z_(k-1)`. Frobenius transforms the first sum into `U_0 z_0^p + sum_(i>=1) U_i z_i^p`; the second is `z_0^(p-1) (V_0 z_0 + sum_(i>=1) V_i z_i)`. The distinct monomial coefficients force `U_i=V_i=0` for all `i>=1` and `U_0=V_0` when this polynomial is identically zero. Equivalently, `(u,v)` lies on the one-dimensional line `F_q*(x^p,x)`. The same conclusion holds for `k=1`.
4. Consequently, for any candidate outside the planted line, `P` is a nonzero polynomial with total degree `p < q`. The Schwartz–Zippel bound gives `Pr_a[P(a)=0]<=p/q=p^(-(r-1))` for a uniform sensing row. Independent rows give at most `(p/q)^m`.
5. For any fixed nonzero `x`, exactly `q` pairs `(u,v)` belong to its planted line, leaving `q^(2k)-q` alternatives. There are `q^k-1` nonzero signals. The union bound yields

   `Pr[failure] <= (q^k-1)(q^(2k)-q)(p/q)^m < q^(3k)(p/q)^m = p^(3*r*k-(r-1)*m) <= p^(-(r-1)*s).`

6. On the complement, every nonzero signal produces a one-dimensional kernel. Pick any nonzero generator `(u,v)` from that kernel. Find `t` satisfying `t^(p-1)=u_i/v_i^p` at any coordinate with `v_i != 0`, and set `x=t*v`. All `p-1` roots give exactly the unavoidable global phase orbit. Verify candidate against original measurements. An all-zero reading implies the zero signal, since a nonzero signal with zero readings would have a kernel larger than the planted line (including the `k=1` degenerate case). Done.

The proof is self-contained conditional only on the standard finite-field facts and the stated polynomial zero bound. A second mathematician/proof formalizer must check its universal quantifiers and complexity model before it is promoted.

## 3. Executed independent tests and outcomes

- A: `frobenius_decoder.py` implements `F_25 = F_5[z]/(z^2-2)` as packed integers and Gauss–Jordan reduction. Recovered exact 4-phase orbit for **120/120** deterministic-seed trials (`k=1..4`, `m=10,16,24,30`). Exhaustively checked complete-row-span rank `3` for all **624** nonzero `k=2` signals using **625** possible sensing vectors.
- B: `independent_attack.py` implements the same field with **tuple coordinates**, a distinct incremental-span algorithm, a fresh random test generator, and independent all-signal injectivity checks. It repeated the exhaustive 624-signal rank check; tested 197 nontrivial polynomial alternatives (`k=1,2`), with largest observed number of zeros `121` out of `625` against the `125` theoretical bound; and found `6/8` uniformly full-rank 4-measurement `k=2` designs, `8/8` for each of `m=6,8,12,16`. This illustrates that the union-bound constant 6 is conservative.
- C: `general_prime_check.py` implements generic quadratic extension fields by a nonsquare polynomial and a separately coded incremental rank algorithm. Tested all **80** nonzero 2-vectors over `F_9` (81 complete sensing rows), then 30 sampled nonzero 2-vectors each over `F_25` (625 rows) and `F_49` (2401 rows). All predicted rank 3.
- **Discovered and corrected implementation error:** the first A implementation used a Python floor division expression that corrupted finite-field additive negation; the initial exhaustive rank test failed spuriously. Replaced the negation formula, reran A, B, C, and retained this correction record. An invalid early run is not evidence against the theorem.

## 4. Audit verdict and next discrimination

- **PASS — scoped finite computations:** A/B/C execution and the exact inequality. Script SHA-256 manifests in `MANIFEST.sha256`; raw output in `*_results.json`.
- **INCONCLUSIVE — existing LLL theorem:** full source and Gaussian span-count lemma still require independent proof scrutiny. The downstream exact-tail bound is conditional.
- **INCONCLUSIVE — general candidate theorem status:** coherent written proof plus independent small-instance tests; no independent mathematical referee or formal kernel check.
- **INCONCLUSIVE — novelty:** original October extension-field kernel work must be compared first, followed by dated external primary-source search. Existing literature includes Király–Ehler (2014) on algebraic inversion at identifiability thresholds; Bartusel–Führ–Oussa (2023) on affine-group frames over prime fields; and classical Schwartz–Zippel/PIT plus Frobenius methods. These are adjacent mechanisms, not evidence that this exact guarantee is unprecedented.

**Next decisive experiment:** audit the old extension-field kernel proof text and compare sensing model, field-size regime, and fixed-field success guarantees; then reconstruct the Gaussian span-count lemma independently. Separately, sharpen the `6k` uniform sample constant by proving an upper bound for zero-probabilities of structured Frobenius polynomials that improves `p/q`, or by exploiting their simultaneous rank geometry. A sub-`6k` bound counts as a substantive gain only with a fresh independent proof.

**Scientific status:** new fixed-field proof *candidate*, verification artifacts complete for finite checks, not a certified novel theorem.