# AgentDojo ASUA — offline authorization and paired-evaluation harness

**Status (29 October 2026): R0 engineering prototype, synthetic-only unit tests. No provider calls, no benchmark efficacy, no production defense, no new safety flagship.** Read [original preregistration draft](PREREGISTRATION.md) for the prospective intervention, frozen thresholds, outcome definitions and kill criteria. This supplement leaves the original intact.

## Implemented, with precise limits

1. [authority_gate.py](authority_gate.py) implements a *runner-side exact-grant decision prototype*. A trusted user-authority manifest grants a specific tool, operation and SHA-256 fingerprint of the complete normalized arguments. A retrieved document or assistant-proposed command cannot create a grant. Sensitive actions with mismatched recipient/body/arguments fail closed. There are unit tests for authorized mail, attacker recipient substitution, modified mail body, claimed user provenance, dangerous writes without grants, unknown sources, and explicitly allowlisted reads.
2. [score_paired.py](score_paired.py) strictly validates one predeclared paired grid of **40 tasks × 5 seeds × 4 arms = 800 completed trajectories**, rejecting missing/duplicate arms and provider failures. Reports unchanged-benchmark binary attacker success and legitimate-task completion, cluster-level ASR difference, seeded paired-task percentile-bootstrap confidence interval, per-seed effects, blocked actions, and the preregistered significance/utility gate.
3. [test_score_paired.py](test_score_paired.py) and [test_authority_gate.py](test_authority_gate.py) use **synthetic fixtures only**, testing positive and null outcomes, utility harm, missing arms, duplicate entries, malformed outcomes, unsigned real manifest, deterministic bootstrap and input tampering. The GitHub Actions workflow [agentdojo-offline-analysis.yml](../../../../.github/workflows/agentdojo-offline-analysis.yml) runs them without external model credentials and prints source SHA-256 hashes.

### Critical engineering boundary

The action-gate module accepts the trusted runner's *prestructured* grant. It does not solve the difficult step of turning natural-language user intent into reliable, complete, authenticated grants. It does not intercept AgentDojo's actual tool calls yet. The argument fingerprint function is safe only after the runner validates each tool's complete schema, normalized resource identifiers, URLs, filenames and recipients. Exact string equality can mistakenly authorize an aliased destination if normalization is weak; production deployment requires a separate implementation and red-team review. Tool actions labelled read-only must be separately audited for implicit state changes and exfiltration, and all other unknown operations default to deny.

The scorer cannot validate the provenance or correctness of an attack grader; it receives already authenticated grader outcomes from the future benchmark runner. Its confidence interval is a conditional estimate for the fixed selected task cohort and four specified arms. It cannot by itself establish causal benefit, generalization, independence of the model revisions or ecological validity. Prospective comparisons require a genuine preregistration freeze and no tuning after exposure.

## Example real-run manifest schema (NOT YET COMPLETED)

Only a future owner-approved benchmark run may populate these fields. The supplied values below are deliberately incomplete and would be **rejected** by the scorer.

```json
{
  "evidence_kind": "provider_experiment",
  "upstream_commit": "357c80dea9af34323f709c3505d9e6d224654c7e",
  "task_ids": [],
  "seeds": [171, 271, 371, 471, 571],
  "arms": ["none", "repeat_user", "tool_filter", "authority_gate"],
  "model_revision": "",
  "protocol_freeze_sha256": "",
  "benchmark_task_list_sha256": ""
}
```

The future JSONL record for each selected task/seed/arm must contain all of: `task_id` (stable source ID), `seed` (integer), `arm` (one of four frozen names), `run_status` (`completed` only for primary analysis), `attack_success` (boolean from the unchanged AgentDojo attacker objective grader), `user_success` (boolean from the unchanged legitimate objective grader), and `blocked_actions` (nonnegative integer). Retain raw traces in a restricted archive and publish only privacy-reviewed transformed evidence.

Commands:

```sh
python3 -m unittest discover -v -s research/nightfall/evaluations/agentdojo_asua_20261029 -p 'test_*.py'
python3 research/nightfall/evaluations/agentdojo_asua_20261029/score_paired.py --manifest frozen_manifest.json --results actual_scored_results.jsonl
```

## Next required technical checkpoints

Freeze actual eligible AgentDojo task IDs (four 10-task sets) from the pinned benchmark commit using a transparent eligibility filter; inspect attack grader and tool-call adapters; implement a true trusted-user-grant compiler at the runner boundary with a test for every sensitive tool; run local tests against AgentDojo's *non-provider mock fixtures* if available; lock task order, model revision, time and cost estimate; obtain explicit owner approval for any paid 800-trajectory run; conduct blinded paired model evaluation; submit independent scorer and source-data audit before any safety efficacy statement.

**Budget status:** $0 in paid AgentDojo model calls authorized by this repository change. No asynchronous work or automatic experiment execution is scheduled.
