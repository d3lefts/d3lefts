# Minimum Trusted Cost of a Change-Stable Safety Decision

Research note, 13 November 2026. Author: Devin J. Wright (NIGHTFALL Independent Research Programme), AI-assisted formulation and audits.

## Reproducible mathematical output

- `change_stable_safety.tex` — 6-page standalone theorem source; render a PDF locally with `pdflatex`.
- `change_stable_safety.tex` — editable LaTeX source (compile with `pdflatex` twice).
- `checker.py` — independently computes exhaustive update survival and transversal criteria, tests 53,608 small selected-subset/update-budget cases, and enumerates exact Pareto costs.
- `audit_results.json` — output of `checker.py`.
- `passport.json` — explicit synthetic proof passport. **Not authenticated real-world safety evidence.**
- `verify_passport.py` — synthetic version transport checker; rejects unknown edits, incomplete update notifications, and hazards outside the envelope.
- The original research bundle included a PDF and hash manifest; PDF is not checked into GitHub, and this repository CI verifies committed text and reproducible outputs instead.

## Commands

```bash
python checker.py
python verify_passport.py --update A
python verify_passport.py --update B
python verify_passport.py --update C
python verify_passport.py --update A B     # expected nonzero exit (invalid certificate)
python verify_passport.py --new-hazard h4  # expected fail-closed
python verify_passport.py --incomplete     # expected fail-closed
# This repository preserves text sources and results; PDF build hash is excluded.
```

## The theorem, and what it does not prove

Exact, within the specified finite evidence contract: after any **cumulative** change of at most k mutable components relative to the certified baseline, a certificate survives iff every hazardous witness has dependency transversal number greater than k. This gives a Pareto minimum of paid trusted evidence atoms and paid atom-verifier calls. It does **not** account for untrusted search, actual posterior/risk learning, application-specific source attestation, missing dependencies, policy changes, or hazard-envelope construction. Those need their own typed costs.

Computational analysis: general selection NP-hard already at k=0; verifying arbitrary-k robustness is coNP-complete; simple disjoint-support witnesses are sufficient but incomplete and can cost arbitrarily more trusted evidence. Strong emphasis: the underlying reductions, multicover, proof-carrying-code, and incremental dependency validation are known techniques; novelty is **not certified**.

## Research gate

Strongest checked prior art: classic proof-carrying code (Necula, 1997); certificate complexity (Kayal et al., 2026); multicover; incremental assurance (Diemert et al., 2023); SMT summary repair; Mukhopadhyay and Nalla (2026) on versioned assurance evidence. NIGHTFALL's own ASUA already states weighted sensor cover; PAS already tracks versioned proof dependencies. A publication-level claim would require a non-subsumed result and independent expert proof/priority review.

The cheapest decisive next experiment is a real, limited-scope guard with an authenticated change log, complete dependency accounting, measured source validation costs, and adversarial edits that share dependencies. Compare naive counting, transversal checking, and full re-verification against exactly the same safe-release condition. Report failures rather than promoting synthetic replay to deployed validation.
