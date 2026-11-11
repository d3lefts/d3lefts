# Log-Free Greedy Kaczmarz Best-Iterate Note

**Status:** Elementary written analytic argument plus exact finite falsifier; non-author review and historical priority remain unresolved. Not a claim of a faster fixed-last-iterate algorithm.

**Primary proof:** [PROOF.md](../../research/nightfall/2026-11-kaczmarz-logfree/PROOF.md) · [Proof Passport](../../research/nightfall/2026-11-kaczmarz-logfree/PROOF_PASSPORT.md) · [exact rational checker](../../research/nightfall/2026-11-kaczmarz-logfree/exact_audit.py).

In a consistent real linear system, greedy max-normalized-residual row projection decreases squared solution error by at least `||Ay-b||²/||A||_F²`. Telescoping across `K` steps gives an existential iterate with residual `<=||A||_F ||y0-x*||/sqrt(K)`, and the square invertible normalization yields a projected-iterate bound of order `n/epsilon²` without the extra logarithm appearing in Steinerberger's stated question. The output is a **best-iterate/existence** bound; greedy row selection cost and runtime are not included.

A proof based on classical projection Pythagoras may be an already known corollary of the greedy Kaczmarz literature. The publication-critical task is a dated source-to-source audit against Nutini and earlier greedy projection/coordinate-descent analyses, followed by an independent reviewer and author interpretation check. Do not label this an original open-problem solve until those gates close.
