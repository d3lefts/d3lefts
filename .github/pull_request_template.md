## Purpose and scope

<!-- What problem does this change solve? List affected paths and intended audience. -->

**Change type:** Documentation / Website / Checker / Formal proof / Research manuscript / Public release

**What changed:**

**What remains unchanged:** <!-- Include scientific claim statuses and any frozen artifacts. -->

## Scientific and attribution boundaries

- [ ] New or edited research statements have explicit assumptions, source dependencies, and limitations.
- [ ] Imported mathematical results, prior-author work, AI drafting and independent review are credited separately.
- [ ] Candidate, exact finite, conditional, Lean-checked sublemma, externally reviewed, and priority-cleared statuses are not conflated.
- [ ] No frozen witness, source hash, release asset, research history, or originality designation was silently overwritten.
- [ ] If this is documentation-only, no theorem, novelty, competition, or publication status was promoted.

## Computer-assisted formalization and independent reconstruction

<!-- Complete for finite enumerations, program-produced certificates,
or theorem proofs that import computational claims; otherwise mark N/A. -->

- [ ] The **exact paper/proof version**, all imported lemmas and the source-to-code version correspondence are frozen and linked.
- [ ] The mathematical specification, raw input bytes, expected coverage and stage DAG were frozen **before** independent implementation.
- [ ] At least one checker was independently constructed from the **specification**, without access to reference code or intermediate answers; code lineage and shared inputs are disclosed.
- [ ] Every stage has exact replay commands, SHA-256 input/checker/output hashes, canonical output, and a byte-for-byte differential result (or a documented alternative comparison proof).
- [ ] The differential manifest was audited by `scripts/check_formalization_differential.py --manifest ...`; its 16 negative controls passed with `--self-test`. The original producer programs were actually executed separately.
- [ ] Semantic formalization explicitly distinguishes **checker soundness**, finite-case **coverage/completeness**, and the **source-theorem bridge**, with named Lean receipts for each completed obligation.
- [ ] Missing formal obligations, code-independence review, external human review, and the theorem/novelty claims remain unpromoted.
- [ ] Correctness checks and performance measurements are reported separately.

**Source specification version / hash:**

**Stage and lemma coverage:**

**Independent checker lineage and deliberate information isolation:**

**Raw input, implementation and exact output hashes:**

**Open semantic/coverage bridges:**

## Reproducibility and quality checks

<!-- Mark N/A when irrelevant; record the precise source commit and CI run. -->

- [ ] Branch reconciled with current `main`, and full diff reviewed.
- [ ] Static source links and documentation: `python3 scripts/test_repository_docs.py`.
- [ ] Scholarly catalogue / paper navigation (if affected): `python3 scripts/check_research_archive.py --self-test`; claim IDs, exact source paths and dependency gates reconciled.
- [ ] No new `LICENSE` or external reuse rights implied without owner approval.
- [ ] Website integrity (if affected): `python3 scripts/check_site.py`, relevant browser/contrast tests, and CI.
- [ ] Exact witness/checker (if affected): source inputs, SHA-256, commands, independent checks and negative controls attached.
- [ ] Lean (if affected): named declarations, version, axiom report, source hash and **remaining theorem premises** documented.
- [ ] Publishing/disclosure approved where applicable. Public Pages/release checked after merge.

### Verification receipts

**Commit / source versions:**

**Commands actually run and outputs:**

**CI run(s):**

**Open limitations, counterexamples or review requests:**

> Passing CI verifies only the specified checks. It does not establish global mathematical validity, historic novelty, publication suitability, or competition eligibility.
