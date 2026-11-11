# Proof Passport · NF-KACZMARZ-LOGFREE-20261111

**Version:** 1.0 (2026-11-11) · **Lifecycle:** NULL FIELD / active research  
**Research lead:** Devin J. Wright · **Claim class:** analytic best-iterate theorem  
**Publication status:** internal proof and finite exact check; **independent mathematical referee, global originality, and author confirmation pending**. Not an Original Finding, not in the frozen 11 historical passports.

## 1. Claim and quantifiers

For any consistent real system `Ax*=b` with nonzero `A`, greedy max-normalized-residual orthogonal row projections from `y0` produce, among the first `K>=1` iterates, a vector `y_t` (`0<=t<K`) obeying

    ||Ay_t-b|| <= (||A||_F/sqrt(K)) ||y0-x*||.

Hence for `A` with `n` columns and `delta=epsilon ||A||op>0`, `K=ceil(n/epsilon^2)` suffices. Number of **performed projections before this successful iterate is <= K-1**. Starting at 0 in the invertible square case gives `||Ay_t-b||<=epsilon||A||op||x*||` and `||y_t||<=2||x*||`.

The claim is **existence of one successful iterate**, not necessarily a bound for the final iterate of a predetermined randomized schedule. Row-selection effort is not counted in the projection complexity metric.

## 2. Mechanism and certificate

**Projection Pythagoras → weighted max dominates mean → telescope → best prefix iterate.**

Define `e_t=y_t-x*`, `r_t=Ae_t`, `W=||A||_F^2`:

    ||e_t||²-||e_(t+1)||²
    = max_i |(r_t)_i|²/||a_i||²
    >= ||r_t||²/W.

Sum and use `||e_K||²>=0` to obtain `sum_{t<K} ||r_t||² <= W||e_0||²`.

**Mathematical checker:** the stepwise equality/inequality and telescoping proof are written in [PROOF.md](PROOF.md). **Executable falsifier:** [exact_audit.py](exact_audit.py) checks 240 rational test systems, 2,880 greedy updates, algebraic identities and sharpness negative control. No formal Lean proof or external human proof review was performed.

## 3. Four independent certification dimensions

| Dimension | Finding | Outstanding gate |
| --- | --- | --- |
| Validity | Elementary exact proof supplied, including all quantifiers, zero rows and `K` edge cases | Independent non-author mathematical proof attack |
| Reproducibility | Replayed exact rational Python checker (240 systems / 2,880 steps), added to CI | Independent implementation, toolchain and source-hash record |
| Originality | Not established. Greedy max-distance Kaczmarz and energy identities are classical | Dated exhaustive priority review, explicit author confirmation |
| Significance | Removes `log(1/epsilon)` for existential projection **count** in the author's stated model | Check whether already recorded as a corollary; no runtime or fixed-final-iterate claim |

## 4. External comparators

- Stefan Steinerberger, [Some Open Problems, updated 2026-03-31](https://faculty.washington.edu/steinerb/openproblems.pdf), heading *Approximate Solutions of Linear Systems* (TOC index 52, PDF rendered section number 53).
- Steinerberger, [*Approximate Solutions of Linear Systems at a Universal Rate*](https://arxiv.org/abs/2207.03388), SIAM J. Matrix Anal. Appl. 44 (2023), 1436–1446, DOI 10.1137/22M1517196, states `2n epsilon^-2 log(1/epsilon)`.
- Nutini et al., [*Convergence Rates for Greedy Kaczmarz Algorithms*](https://www.cs.ubc.ca/~schmidtm/Documents/2016_UAI_greedyKaczmarz.pdf), UAI 2016. Greedy rule is pre-existing and credited.

**Checked on 2026-11-11:** source problem and published 2023 theorem, targeted searches for prior log removal. This is **not** comprehensive prior-art clearance; inaccessible/unindexed precedents may exist. No discussion with the author is claimed.

## 5. Independent audit plan

1. Reproduce the theorem from the precise linear-algebra premises without reading the proposed proof; verify the projection count `K-1`, starting-point stability and normalized row selection.
2. Search older greedy-Kaczmarz and steepest-coordinate-descent literature for the summed-residual inequality or implicit `O(n/epsilon^2)` corollary.
3. Distinguish current best-iterate/first-hit bound from fixed-time high-probability and algorithmic runtime variants. Attempt adversarial singular, nearly inconsistent, near-zero-row and badly conditioned tests within stated conditions.
4. If an independent referee agrees, ask the problem's author to confirm interpretation and priority before any publication-level status change.

## 6. Provenance, stops and status logic

Original user-requested proof packet SHA-256: `0245feee6e886cbfff2eb717d33ecbf8dd1d8bc8efc055713bd4ba64325a5587`. This is a **chat artifact hash**, not a GitHub commit receipt; the GitHub versions at this path are an editorially normalized publication copy. Git commits and GitHub CI are the repo provenance and replay receipts.

**Stop rule:** no novel/solved/externally-certified badge until both independent proof review and dated priority review succeed. No speculative transfer into arbitrary inconsistent systems or general nonorthogonal projections.

**Claim dependency graph:** Original Kaczmarz projection identity (classical) → greedy weighted maximum (classical) → telescoping best-iterate construction (written proof) → exact checker (finite falsifier) → unresolved external referee and originality gates.