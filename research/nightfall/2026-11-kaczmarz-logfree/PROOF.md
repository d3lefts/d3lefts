# Universal log-free Kaczmarz projection count — theorem checkpoint

**NIGHTFALL / 2026-11-11 / research lead: Devin J. Wright**

**Claim status:** elementary mathematical proof; exact-rational finite replay; independent mathematical referee and originality review **open**. This is a conditional publication candidate, not an externally established novel theorem, a competition record, or a result about *fixed-time* randomized Kaczmarz.

## Original question and reference checked

Stefan Steinerberger's [Some Open Problems](https://faculty.washington.edu/steinerb/openproblems.pdf), updated 2026-03-31, asks whether the `log(1/epsilon)` factor in the existential bound for compositions of orthogonal row projections can be eliminated. The table of contents calls it item 52; the rendered March 2026 PDF's section heading calls it 53. To avoid numbering ambiguity, identify it by the heading **Approximate Solutions of Linear Systems**.

Original: S. Steinerberger, *Approximate Solutions of Linear Systems at a Universal Rate*, SIAM Journal on Matrix Analysis and Applications **44** (2023), 1436–1446, [doi:10.1137/22M1517196](https://doi.org/10.1137/22M1517196), [arXiv:2207.03388](https://arxiv.org/abs/2207.03388). Existing bound for invertible square A: at most `2 n epsilon^(-2) log(1/epsilon)` row projections, residual `||Ay-b|| <= epsilon ||A||op ||x*||`, with `b=A x*`.

Greedy maximum-distance Kaczmarz and its Pythagorean decrease were studied well before this checkpoint; for example, J. Nutini et al., *Convergence Rates for Greedy Kaczmarz Algorithms, and Faster Randomized Kaczmarz Rules Using the Orthogonality Graph*, UAI (2016), [paper](https://www.cs.ubc.ca/~schmidtm/Documents/2016_UAI_greedyKaczmarz.pdf). The result below is a short consequence of that classical mechanism; **global priority unverified**.

## Theorem — log-free best-iterate guarantee

Let `A in R^(m x n)` be a nonzero real matrix and `A x*=b` be consistent. Ignore zero rows, for which consistency forces `b_i=0`. Start from `y_0` and repeatedly choose a row `i_t` maximizing the squared *normalized* residual `|<a_i,y_t>-b_i|^2/||a_i||^2`, then project orthogonally onto `<a_i,y>=b_i`. For every integer `K>=1`,

    sum_(t=0)^(K-1) ||A y_t-b||_2^2 <= ||A||_F^2 ||y_0-x*||_2^2,
    min_(0<=t<K) ||A y_t-b||_2 <= (||A||_F/sqrt(K)) ||y_0-x*||_2.

For any `delta>0`, setting `K=ceil(||A||_F^2/delta^2)` provides a valid iterate among `y_0,...,y_(K-1)`, reached after **at most K-1 projections**, with `||Ay-b||<=delta||y_0-x*||`. Each iterate remains within `||y_0-x*||` of `x*`.

Specializing to `delta=epsilon ||A||op`, and using `||A||_F^2<=rank(A)||A||op^2<=n||A||op^2`, gives the `ceil(n/epsilon^2)` best-iterate bound. For the original setting `y_0=0`, this is precisely the requested existential residual guarantee and yields `||y||<=2||x*||`.

**No** full-column-rank assumption is required for the best-iterate theorem, only consistency.

## Proof — deterministic projection energy telescope

Write `e_t=y_t-x*`, `r_t=A e_t`, and `W=||A||_F^2>0`. Orthogonal projection gives the exact identity

    ||e_t||^2-||e_(t+1)||^2
        = max_(i:||a_i||>0) |(r_t)_i|^2/||a_i||^2
        >= sum_i (||a_i||^2/W)(|(r_t)_i|^2/||a_i||^2)
        = ||r_t||^2/W.

The inequality is merely "maximum >= nonnegative weighted average." Sum the inequality over `t=0,...,K-1` and telescope; the final squared error is nonnegative. Divide by `K` to get the minimum residual. Norm contraction is immediate from the same projection identity. All constants and index ranges are explicit.

**Important scope:** the successful iterate is a *best prefix iterate* or *first-hitting iterate*, not necessarily the K-th/latest unstopped iterate. Nor does this argument give constant per-step computational cost: choosing the maximum normalized residual generally entails inspecting many rows. The theorem concerns **number of orthogonal projections only**, matching the original existential question.

## Second route — randomized expected hitting time (same mechanism)

Under classical row-norm-squared random sampling (`P(i)=||a_i||^2/W`),

    E[||e_t||^2-||e_(t+1)||^2 | history] = ||r_t||^2/W.

For `E0=||e_0||>0`, let `tau=inf{t>=0:||r_t||<=delta E0}`. Before `tau`, the conditional decrease exceeds `delta^2 E0^2/W`. Stopping at `tau∧T`, summing expected decreases, and applying monotone convergence yields

    E[tau] <= W/delta^2.

This is **expected first-hitting time** only, not a high-probability fixed-iterate guarantee. The argument reuses the known randomized Kaczmarz energy identity; it is not a separate independent proof of originality.

## Exact reproduction

Checker: [`exact_audit.py`](exact_audit.py), Python 3 standard library, `fractions.Fraction`, fixed seed 20261111. Command from repository root:

    python3 research/nightfall/2026-11-kaczmarz-logfree/exact_audit.py

The script checks **240** exact-rational consistent systems, **12** greedy steps each, together with the Pythagorean equality, weighted maximum, telescoping prefix inequality and a one-dimensional sharpness/negative control. Total **2,880** verified projection updates, zero counterexamples (finite screens do not prove the theorem). Input matrices include zero rows and possibly rank-deficient cases.

Earlier source packet supplied in chat (not the same byte sequence as this edited source): `steinerberger_log_removal_proof_packet.zip`, SHA-256 `0245feee6e886cbfff2eb717d33ecbf8dd1d8bc8efc055713bd4ba64325a5587`; earlier proof file SHA-256 `2f5576ef9e5cbc0b127ffd1983a73d34fc1c1d768541b8478eb60814ec80a4b3`, checker SHA-256 `e437ee9f789168bf006177c00ef126d59c61b6cad3992ccb9c2d3e79fd6d0524`. The primary, replayable GitHub-source version is the committed file at this path and its Git blob identity.

## Audit gates and significance

- **Validity:** written derivation is elementary and covers arbitrary consistent real systems; formal Lean proof and independent human referee review not conducted. Review the quantified best-iterate interpretation and exact count, especially `K=ceil(W/delta^2)` and `y_0=0`.
- **Reproducibility:** finite exact checker is available and rerunnable in repository CI. It verifies implications but is not a non-author proof review.
- **Originality:** the key greedy selection/Pythagorean method is classical; no comprehensive negative prior-art search or author response. The problem is labeled open in the author's March 2026 list but a listed open question does not itself certify a novel solution.
- **Significance:** log-factor removal for *existence of a successful projection sequence*, within the original question's quantifiers. **Not** a faster end-to-end arithmetic runtime or a constant-cost row-selection theorem.
- **Independent challenge:** try published greedy-Kaczmarz analyses, reconstruct a direct earliest-priority citation for this corollary, test variants requiring a fixed schedule or last iterate, and request an external referee/author assessment before any publication or "solved problem" claim.

**Attribution:** original open question and 2023 bound — Steinerberger; classical randomized/greedy Kaczmarz framework — earlier numerical-analysis literature including Nutini et al.; NIGHTFALL derivation and source packaging — research led by Devin J. Wright, AI-assisted, with no independent external mathematical certification.