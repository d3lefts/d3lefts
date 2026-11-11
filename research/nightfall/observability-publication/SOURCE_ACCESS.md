# Principal quadratic observability — public source-access inventory

**Editorial checkpoint:** 2026-11-11. **Status:** manuscript-level claims, incomplete public proof release. This inventory is not a theorem or certificate.

## Public directory

The folder `research/nightfall/observability-publication/` contains `PRINCIPAL_PAPER.md` (53-line editorial synopsis), `COMPANION_PAPER.md`, `CUBIC_OBSTRUCTION_NOTE.md`, `HIGHER_ORDER_MATCHING.md`, and `README.md`. The full original proof archive is referenced by filename, not published in this directory. **A synopsis is not a complete proof PDF.**

| Named source in original ZIP | Public publication-folder status | Required gate |
| --- | --- | --- |
| `main.tex`, `matching-core.tex`, `queries.tex`, `categorical.tex` | Not checked in here | Publish original unchanged source, compile paper, inspect proof |
| `nightfall-rank-appendix.md` | Not checked in here | Audit Hilbert/rank lift |
| `matching-audit.py`, `finitealphabet-audit.py` | Not checked in here | Run, independently reimplement, and log failures |
| `exact_replay.txt`, `SHA256SUMS` | Not checked in here | Record immutable hashes and independently audit arithmetic |
| Independent human referee report | Not recorded for the principal theorem | Non-author proof review |
| Dated comprehensive priority study | Not recorded as complete | Scope-matched comparison and novelty decision |

## Dated source baseline

- Aaronson and Ambainis, *The Need for Structure in Quantum Speedups* (2014): https://www.theoryofcomputing.org/articles/v010a006/
- David Turturean, *A proof of the Aaronson–Ambainis conjecture* (2026-11-06): https://arxiv.org/abs/2611.09773 and https://github.com/physical-superintelligence/aaronson-ambainis
- Blanc, Docter, Strassle and Tan (2026-11-08) exposition: https://arxiv.org/abs/2611.11626
- Efron and Stein (1981), variance/ANOVA foundations: https://pdodds.w3.uvm.edu/files/papers/others/1981/efron1981a.pdf

The original Aaronson–Ambainis question, the fair-cube proof, and imported antipodal/certificate ingredients are prior work. Flip influence and resampling conditional-variance influence must be normalized before constant comparisons. This is an initial comparison, not a comprehensive priority certificate.

## Next decisive reviewer actions

1. Deposit the original complete archive with `SHA256SUMS`; record immutable revision and exact inputs. Do not silently rewrite source proofs.
2. Compile the actual LaTeX, replay checkers, rederive computations with independent code.
3. Attack matching extraction, off-matching boundedness, rank-sensitive posterior descent, lower constructions, and edge cases.
4. Keep correctness, reproducibility, novelty, significance and review attribution separate. Report PASS/FAIL/INCONCLUSIVE with assumptions and source hashes.

Do not label the quadratic result independently refereed, end-to-end Lean-certified or globally novel until the corresponding gate is met.
