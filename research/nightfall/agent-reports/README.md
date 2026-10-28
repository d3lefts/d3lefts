# Agent-generated verification reports

Each claim receives a separate directory containing agent scripts, reproducible evidence and one machine-readable verdict. An agent-authored narrative alone has no mathematical evidentiary force.

Recommended naming: `2026-10-28-<claim-id>-<agent-role>-<run-id>.json` plus `<run-id>.md` and source code. Archive the exact source/input hashes, method, complete commands, environment, result, scope and limitations.

**Verdicts:** `PASS` (specified check succeeded); `FAIL` (reproducible counterexample or check failure); `INCONCLUSIVE` (missing evidence / incomplete proof).

**Provenance distinction:** a fresh checker authored by an agent is still internal collaboration evidence until the entire input, exact code and outcome are separately reproducible from publicly frozen source bytes. Neither a majority of agents nor a CI badge certifies a general theorem.
