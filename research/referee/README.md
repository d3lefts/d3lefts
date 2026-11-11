# Independent Mathematical Referee Desk

**11 November 2026.** This is a **request for independent criticism**, not a record of completed human referee reports. An internal model, second implementation or green CI run is not equivalent to an outside specialist.

## Prioritized assignments

### A. Universal product-space observability — primary full-chain audit

**Claim:** [principal paper](../nightfall/2026-11-principal-observability/PRINCIPAL_THEOREM.md).  
**Foundation:** [finite kernel proof passport](../nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md).  
**Full argument to attack:** [analytic proof supplement v1](../../papers/universal-observability/PROOF_SUPPLEMENT_v1.md), [exact posterior/Hilbert tester](../../papers/universal-observability/checks/check_posterior_hilbert_exact.py), [PSD sign-mgf stress](../../papers/universal-observability/checks/check_psd_log_stress.py). These are internal analytic and computational artifacts, not outside refereeing.

**Review target:** Confirm exact finite indicator-product degree assumptions; reconstruct finite-to-arbitrary measurable product approximation, with countable active support and null-set handling. Independently audit the PSD Gaussian mgf and sign scalarization. Then justify the *actual* posterior ANOVA total-influence identity, measurable greedy choice, stopped-potential bound, and spectral-tail projection. Examine `d=0`, variance `0`, zero-mass atoms, infinite coordinate sets, and nonattainment of influence maxima.

**Reject any reasoning** that imports an abstract stopping theorem while assuming the very posterior progress relation it is meant to derive.  
**Status:** full theorem analytic, not end-to-end formal or externally reviewed.  
**Decisive result:** non-author reconstruction under exact hypotheses, or concrete counterexample/minimal missing lemma.

### B. Quadratic matching and consequence — most critical stronger exponent

**Claim:** [quadratic synopsis](../nightfall/observability-publication/PRINCIPAL_PAPER.md).  
**Missing source:** [source inventory](../nightfall/observability-publication/SOURCE_ACCESS.md).  
**Review target:** Retrieve *original unchanged* `main.tex`, `matching-core.tex`, `queries.tex`, and `categorical.tex` and checksum manifest. Audit disjoint-pair extraction under arbitrary heterogeneous laws, off-matching boundedness, the conditional fourth-moment inequality, and the passage to `Var(f)<=16(1+sqrt(3))B sqrt(M)`. Independently test rare atoms and arbitrary alphabets. Only then audit adaptive rank-`r` and fixed categorical lower constructions.

**Stop:** no external certification while original source is unavailable, and do not use the finite `5/2` Lean theorem as an `V^2` proof.

### C. Cubic link frontier — attack the structural obstruction

**Source:** [restricted covered-cubic note](../nightfall/2026-11-cubic-leaf-alphabet-free/PROOF_NOTE.md) and [corrected pair formula](../nightfall/2026-11-spectral-observability/REVIEW_GATES.md).  
**Review target:** determine whether an overlapping-core or conditional link-energy inequality can control dense repeated pairs without alphabet dependence. Try exact rational counterexamples and independent proof operators. Distinguish falsifying a maximal-inequality shortcut from falsifying the full cubic influence conjecture. A conditional reduction is **not** an unrestricted theorem.

### D. Finite exact evidence and computational provenance

- [Sidon witness](../nightfall/projects/sidon-finite-30/witness_30.txt) and [standalone exact verifier](../nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py): reproduce all 27,405 four-point tests and the 13-vertex minimum progression hitting set.
- [Erdős witness and release custody](../nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md): independently verify frozen height file hashes, both signed lags and continuum-to-grid reduction; competition accepted bytes are a distinct gate.
- [Werner conditional certificates](../nightfall/projects/werner-final-4-25/README.md): check imported two-/three-copy inequalities and the isotropic-twirling correction, not just rational multiplication.
- [Kaczmarz best iterate](../nightfall/2026-11-kaczmarz-logfree/PROOF.md): reconstruct the greedy telescope and conduct a dated historical search for existing best-iterate corollaries.

## Reviewer deliverable

A report should contain (1) claim ID from [registry](../catalogue/CLAIMS.json); (2) immutable source commit and exact files; (3) independent reviewer identity/credit subject to consent; (4) scope and quantifiers; (5) PASS, FAIL or INCONCLUSIVE with the specific statement checked; (6) exact reproduction commands and inputs/hashes; (7) explicit imported external premises; (8) minimal counterexample, if any; (9) valid/novel/significant/reproducible verdicts **separately**; (10) affected dependent claims and the next decisive experiment.

Open a [verification issue](https://github.com/d3lefts/d3lefts/issues/new/choose) or a topic PR with that receipt. An issue is an invitation, not an assigned or completed specialist report. Preserve conflicting results, and resolve them by source-specific reproducible checks.
