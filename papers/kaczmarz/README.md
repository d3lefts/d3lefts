# Log-Free Greedy Kaczmarz Best-Iterate Note

**Status:** Elementary written analytic argument plus exact finite falsifier; non-author review and historical priority remain unresolved. Not a claim of a faster fixed-last-iterate algorithm.

**Primary proof:** [PROOF.md](../../research/nightfall/2026-11-kaczmarz-logfree/PROOF.md) · [Proof Passport](../../research/nightfall/2026-11-kaczmarz-logfree/PROOF_PASSPORT.md) · [exact rational checker](../../research/nightfall/2026-11-kaczmarz-logfree/exact_audit.py).

In a consistent real linear system, greedy max-normalized-residual row projection decreases squared solution error by at least `||Ay-b||²/||A||_F²`. For **Steinerberger's unscaled Theorem 1 residual target** `||Ay-b||<=epsilon||y0-x*||`, this gives a first successful iterate using at most `ceil(||A||_F²/epsilon²)-1` projections. The paper's bound is `2 log(||A||op/epsilon)||A||_F²/epsilon²`; the `n/epsilon²` form is only the abstract's scaled specialization. This is a valid elementary comparison, not a historical-priority claim. The output is a **best-iterate/existence** bound; greedy row selection cost and runtime are not included.

A proof based on classical projection Pythagoras may be an already known corollary of the greedy Kaczmarz literature. The publication-critical task is a dated source-to-source audit against Nutini and earlier greedy projection/coordinate-descent analyses, followed by independent mathematical and priority review (no outreach planned). Do not label this an original open-problem solve until those gates close.
