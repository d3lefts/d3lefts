# NIGHTFALL: exact 22–24-copy qutrit Werner inequalities

**Checkpoint:** 2026-10-28. **Status:** exact rational certificates conditional on published low-copy theorems and the archived 7–21-copy source certificates. Mathematical proof review by an outside author, novelty review and human authorship approval remain pending. No unrestricted four-copy endpoint result is claimed.

## Objective and audited claims

For a matrix `C` of rank at most two on `(C^3)^{⊗k}`, let

\[
Q_k(t,C)=\sum_{J\subseteq[k]}(-t)^{|J|}\|\operatorname{Tr}_J C\|_F^2.
\]

The following exact rational identities establish the listed sufficient bounds, conditional on the published source inequalities:

| k | t | margin m in Q_k(t,C) >= m ||C||_F² | rows | smallest weight |
|---|---|---|---|---|
| 22 | 3611/10000 = 0.36110 | 1.4578513792302353e-7 | 22 | 3.766999957852631e-9 |
| 23 | 351/1000 = 0.35100 | 3.792128233225445e-7 | 23 | 1.0877661981748144e-8 |
| 24 | 17/50 = 0.34000 | 9.795040030014149e-7 | 24 | 7.781144522437512e-9 |

Each decimal above is illustrative; the canonical values are the exact numerator/denominator strings in the certificate JSON files. Every new interval extends past the qutrit PPT boundary `t=1/3`. For `k=22` the previous conservative analytic guarantee was only `1/3 + 2.3655e-15`; for 23 and 24 it was exponentially smaller.

The 22-copy statement also improves the published-source-conditional 21-copy threshold to `0.36110` by padding with a normalized traceless rank-one matrix on the extra copy.

## Source cone and proof

Write formal `z^g` for the contraction polynomial associated with the unnormalized maximally entangled projector on a group of `g` paired local factors. Algebraic multiplication represents disjoint tensor-product blocks, followed by averaging over permutations of the site groups. For any `k`, the coefficient vector of the Werner target is that of `(1-t z)^k`.

The certificate identity is

\[
(1-t_k z)^k=m_k+\sum_i w_i p_i(z),\qquad w_i>0,\quad m_k>0.
\]

Every `p_i` is a symmetrized, disjoint-site positive quadratic form from one of the following **audited admissible types**:

1. `CAP`: `2-z^j`, from the rank-two trace bound.
2. `PSD`: a tensor product of positive operators `P_g`, `I+P_g`, and `I-P_g/3^g` acting on disjoint site groups. Here `P_g=|Ω_{3^g}><Ω_{3^g}|`, with an unnormalized vector. `P_g` is positive; the other two factors are positive and separable across the Alice–Bob cut.
3. `I2`: `(2-z^a-z^b+z^{a+b}/2)` from the sharp universal two-block rank-two inequality, multiplied only by allowed separable spectators.
4. `GROUP`: a sharp universal three-copy source at `t=1/2`, four-copy source at `79/160`, or five-copy source at `9/20`, applied to disjoint groups of arbitrary positive sizes. Unequal group dimensions can be zero-padded to the same dimension before application. Products use separable spectators only.
5. `ARCHIVED`: the original exact `k=7,...,21` qutrit source inequalities, used in their zero-margin form `(1-t_j z)^j`. In particular, the new certificates **do not import** the very small positive margins of the archived sources. The archive checkers nevertheless verify those margins as a stronger input check.

A rank-two source inequality tensored with an Alice–Bob separable positive operator remains nonnegative: writing the spectator as a positive sum of local product operators reduces the evaluation to positive multiples of rank-at-most-two compressed source matrices. Group-permutation averaging preserves the result. Since every `w_i` and `m_k` is strictly positive, the polynomial identity proves each stated qutrit `k`-copy inequality. The Costa Rico reduction then gives `k`-copy undistillability of `rho(3,-t_k)`; the usual monotonicity argument extends the sufficient threshold to every smaller nonnegative `t`.

## Reproduction and attack paths

Run `sh CHECK_ALL.sh`. The verifier uses its own sparse-polynomial implementation in exact `fractions.Fraction`, without importing any numerical construction code. For all source certificate files `k=7,...,21`, it checks positive source coefficients and exact polynomial equality using only the listed basic source theorems. It then checks every coefficient of the new target against a reconstructed sum of the displayed rows. The three results have 23, 24, and 25 exact coefficient identities, respectively. Every checker includes an adversarial test ensuring an entangled projector cannot enter as a spectator of a rank-two source inequality.

The construction stage used a numerical LP **only to choose a basis**. The basis was reconstructed by separate rational Gaussian elimination. Numerical feasibility alone was never used as a theorem. `RESEARCH_NOTE.md`, certificate JSON data, and all upstream JSON files carry the reproducible exact witness. `SHA256SUMS` freezes inputs and checkers.

## Four-copy endpoint attack

The concurrently examined complementary-syndrome route at `k=4,t=1/2` reaches exact restricted classes, yet yields no unrestricted theorem. The aligned-coset witness `|0000><0000|+|0001><0001|` has `16Q_4=0` despite its two individual pieces contributing `1+1`; the interference term is `-2`. Thus any global positivity proof must retain rank-two correlations across colliding syndrome pairs. This run supplied no new unrestricted four-copy endpoint claim.

## Comparators, provenance, scope

- Tejasvi Singh Tomar, *Undistillability of Werner states from three, four and five copies*, 2026, DOI 10.5281/zenodo.23604343: published sharp three-copy theorem, universal four-/five-copy sources, qutrit four-/five-copy sources, and general many-copy constructions.
- Kishor Bharti, Rishikesh Gajjala, Tobias Haug, *Two-copy nondistillability of Werner states: sharp partial-trace inequalities and finite-copy extensions*, arXiv:2607.24479: sharp two-copy rank-two inequality.
- Archived NIGHTFALL certificates for copies 7–21 included under `upstream/`. The external source theorems remain assumptions of the new statements. The 22–24-copy identities are newly computed in this session. The archive stores reproducibility evidence, not human referee approval.

**Research labels:** exact downstream source-conditional constructions; independent exact checker passed; external proof audit and priority comparison open. **Next mechanical target:** apply the same certificate-cone operator at 25 copies, then seek a new source inequality that raises 24 copies well beyond `0.34`. The four-copy endpoint requires a separate rank-sensitive cross-coset argument.
