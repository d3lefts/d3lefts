# NIGHTFALL — Source-to-baseline authority refinement, v0.2

**Research direction:** Devin J. Wright / NIGHTFALL; AI-assisted proof analysis, implementation and adversarial testing. **Date:** 15 November 2026 (UTC). **Authority:** actual local Unix-socket JSON effect service, not AWS or a physical actuator.

## New source-to-baseline custody finding

Previously, advancing the source hash and version rotated the authority epoch, but retained the old baseline template and its hash. A newly signed ticket could reference the NEW source hash and epoch while the effect verifier still compared the candidate against the OLD baseline. Rejection of stale tickets therefore did not guarantee freshness of newly issued evidence.

Define Certified(s) to mean both that the source hash saved with the baseline equals the service's current source hash, and that the source version saved with the baseline equals the service's current version.

## Conditional invariant theorem

Suppose: (A1) initialization and baseline recertification are performed by an authenticated trusted issuer and accurately bind a baseline to the named source; (A2) every relevant source change is registered before a new commit; (A3) the single trusted service serializes and atomically persists effects as specified; (A4) the independent effect checker is sound for its local-artifact policy; (A5) all protected effects are mediated by the service.

Then every successful promotion uses a baseline certified for the same source hash and version as the current authority state, uses a matching nonrevoked epoch, and passes the independent effect checker. No promotion can succeed between a source advance and a fresh valid rebaseline.

**Proof.** Trusted initialization establishes Certified. Every source advance clears both baseline source-binding fields, even if a caller repeats identical source hash/version strings. Other operations cannot restore the binding. A successful rebaseline checks the current source identity, validates the supplied baseline with the existing verifier, saves the current binding, and increments the authority epoch, invalidating outstanding tickets. Before every promotion, the service tests Certified and all existing source, policy, epoch, nonce, and candidate-hash guards. A successful promotion consequently preserves the claimed binding and effect policy. This establishes the induction over service transitions, conditional on the assumptions above. QED.

The new public status field baseline_certified reports the binding; persisted state from an older service version without the new fields fails closed pending refresh. The new signed rebaseline operation increments the epoch and clears its nonce ledger. Revoked authority cannot recertify.

## Exact audit and reproducibility

- test_source_baseline_binding.py exercises 12 independent unittest cases against the actual code, including a forked Unix-socket server with a persisted fsynced JSON artifact; source-version race; source refresh; stale tickets; invalid baseline; forged signature; unauthorized UID; replay; harmful signed template; source hash repetition; lost-response reconciliation; policy changes.
- independent_source_binding_audit.py writes a separate independent HMAC and canonical-hash oracle and enumerates 256 promotion-control truth cases plus 64 baseline-refresh cases. It requires denied operations to leave state unchanged and permits exactly one valid combination in each truth table.
- The fast source-matched GitHub workflow uploads its log, source hashes and checker outputs.

Replay from research/nightfall/right-to-act-promotion:

    python3 -m unittest -v test_source_baseline_binding
    python3 independent_source_binding_audit.py

## Crucial scope limitation

The service cannot prove that the baseline supplied by its trusted issuer was *actually generated from the attested external source snapshot*. The existing check_baseline checks narrowly specified CloudFormation content; it does not establish source/template correspondence. A compromised issuer, missing change channel, bypassed effect capability, or incorrect actual AWS semantics remains outside the theorem. This patch is a concrete fail-closed custody improvement, NOT an end-to-end physical-safety certificate or globally novel general theorem.

The next open proof obligation is to connect the new rebaseline operation to an independently authenticated source snapshot and a source-matched, independently replayed synthesizer output, then reject deliberately mismatched source-template attestations before actual promotion. The infinite-state and arbitrary-agent safety questions remain open.

**Prior work:** NIGHTFALL merged PR #554 (semantic-fencing service), #576 (finite optimal recertification); classical transactional snapshot/TOCTOU and reference-monitor methods. No external human review or worldwide priority certification is claimed.


## Concrete proof-to-service policy refinement (separate finite example)

This directory now includes the archived finite belief-game solver, a four-state source-epoch model, and an INDEPENDENT exhaustive history-dependent policy enumerator. States encode an initial certified epoch-1 source, an epoch-2 source with invalidated baseline, an epoch-3 source after certified refresh, and a completed local JSON promotion. The initially hidden state is one of the first two. Trusted operations are status, baseline refresh, and promotion attempts; the symbolic costs are respectively 1, 1, and 2.

The solver and independent checker establish exact worst-case mission cost 4 for the restricted finite action-and-observation contract. The certified optimal first action is status, after which the policy either promotes directly (nominal path cost 3), or rebaselines and then promotes (cost 4). The independent checker enumerates ALL loop-free history-dependent policy candidates for every nonempty belief, not just the solver's preferred strategy, and verifies the entire certificate.

The source-specific regression test_source_epoch_game_refinement.py executes both possible optimal accepting paths using the ACTUAL authority_service transition function and the unchanged independent CloudFormation effect verifier. A source change inserted between the initial status and the proposed effect makes the stale ticket fail closed. The pre-commit source race is deliberately outside the simplified no-concurrent-changes four-state game's completeness assumptions, so the full real-world trace-simulation claim is NOT made.

Run from the service directory:

    python -m unittest -v test_source_epoch_game_refinement

Run from THIS directory:

    python synthesize.py source_epoch_game.json --out source_epoch_game_certificate.json
    python independent_game_audit.py source_epoch_game.json source_epoch_game_certificate.json

The costs are illustrative rationals, not measured financial, timing, or operational expenditure. The game treats mission completion as a terminal decision and makes no claim about the service's post-completion behavior. These checks validate two concrete traces and the exact finite synthetic model, not a full bisimulation of every possible external operating state, Linux schedule, agent intervention, source attestation, or protected physical effect.
