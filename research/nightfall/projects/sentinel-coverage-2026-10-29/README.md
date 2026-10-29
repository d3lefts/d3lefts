# Sentinel-01: Coverage-qualified compaction safety (research prototype)

**2026-10-29; status: internally checked finite construction, not a new original theorem, externally audited result, or live deployment.** A complete reproducibility bundle is also supplied in the chat as `NIGHTFALL_Sentinel_v0_20261029.zip`.

## Goal, scope, conditions
A model summary may forget earlier safety-relevant history. The research instrument separates a concise, exact policy-state certificate from lossy natural-language context. Synthetic events: `approve,revoke,taint,sanitize,emit,compact`. An `emit` is permitted iff approval is active and taint absent. `sanitize` is assumed to be an externally trusted declassification event. `compact` never changes safety state.

**Theorem 1 (classical residual-language equivalence).** An arbitrary summary C(h) permits exact future safety decisions for all continuations v precisely if C(h1)=C(h2) implies [h1v is safe iff h2v is safe] for every v. Necessity: otherwise indistinguishable monitor inputs require inconsistent outcomes. Sufficiency: define the verdict by any representative history; condition makes it well-defined. Myhill–Nerode supplies a minimal sufficient summary. This is established automata theory applied to context compaction, not original mathematics.

Our example has five distinct retrospective language states (four authorization/taint combinations and one absorbing violation state). All ten state pairs admit distinguishing suffixes of length at most two, so a fixed-width exact retrospective monitor needs 3 bits. An *enforcing* mediator maintaining only the four reachable safe states needs 2 policy bits; it rejects the bad transition rather than entering an absorbing violation state.

**Theorem 2 (log-only coverage impossibility; basic).** If distinct physical histories with different consequential actions can produce the same agent-generated transcript, a log-only reviewer receives identical evidence. No reviewer can universally certify completeness. A hash chain alone does not solve the issue. External receipt generation, independent telemetry, mandatory mediation and anchored roots are separately necessary to justify coverage. The impossibility is a standard indistinguishability argument.

## Local finite experiment
Run `python3 test_sentinel.py` from this directory. The source replay and separate audit implementation cross-check all 9,331 sequences with lengths 0 to 5 over six event types. Product-state BFS distinguishes all 10 state pairs. A lossy monitor misses the invalid trace `taint,compact,approve,emit`; the stateful monitor denies the final emission. Edited and truncated logs are rejected given independently retained roots. **Negative control:** a forged self-consistent transcript passes; inclusion cannot be established absent external trust. The suite has no live agents, real side effects, real security isolation, or statistical effectiveness estimates.

## Primary comparators checked October 29, 2026
- OpenAI multilayer monitoring, compaction checkpoints: https://openai.com/index/how-we-detect-frontier-model-misalignment/
- METR/Redwood monitoring-coverage red team: https://metr.org/blog/2026-10-22-red-teaming-openai-agent-monitoring/
- Qin et al., agent trace tampering: https://arxiv.org/abs/2609.30266
- Chen, Governance Decay and constraint pinning: https://arxiv.org/abs/2606.22528
- Ciliberto/Rudi/Tassi, Proof-Carrying Contracts: https://arxiv.org/abs/2610.28484
- Classical Myhill–Nerode minimization and reference-monitor architectures.

## Next decisive experiment
Create an independently anchored effect-gateway ledger and separate reviewer ledger; reconcile by event ID, including skipped/reordered/compacted activity; classify missing coverage as `COVERAGE_INCOMPLETE` rather than `PASS`. Then run a preregistered held-out comparison versus transcript-only monitoring with matched false-positive and review budgets. A globally original contribution requires independent review and demonstrated novel mechanism or comparative effect, not another restatement of known security principles.

**Authorship/review:** Prepared as an assistant-generated research candidate for NIGHTFALL. The alternate checker is same-author independently coded, not independent external review. Production/security claims, originality and publication await separate gates and human approval.
