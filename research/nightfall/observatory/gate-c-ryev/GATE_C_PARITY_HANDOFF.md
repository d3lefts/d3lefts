# Vesper Gate C v1 — source-equivalent retrieval and protected blinding

Status: engineering preflight implemented; real controlled trials and independent scientific grading PENDING.

Vesper's original immutable task set (PR #32) is carried in frozen-vesper/. The separate early Ryev tasks.json and runner.cjs are exploratory drafts, never the official v1 comparison. Use parity_runner.cjs for the original six tasks.

The paired retrieval index reads original source bytes at commit df9511c622c309046180fd0e015aca88577c58ec. It verifies the locked Git blob ID and computes independent SHA-256. Initial retrieval uses the same task prompt, indexed source lines, query scoring, source line hashes and result bytes in both graph and flat arms. Subsequent --retrieve queries use the identical retrieval function and must be logged. Both arms receive the exact same claim node IDs, titles and statuses; only the graph arm receives typed edge IDs, endpoints and relation categories. Graph-only answer prose is prohibited.

TR-007 is quarantined in both arms: the historical frozen node declares a proof dependency where the graph edge identifies a shared analogy. Neither claim identity is altered. SP-01/02 assess detection of a missing uniform estimate; their primary files are proposals, not archived high-rank theorem witnesses. The owner's more recent public Mechanism Atlas is a separate baseline needing a new preregistration.

The seed 1729 fixes the task pairing and condition order. Each arm is limited to 2,000 real model input+output tokens, 20 tool calls and 30 minutes. Graph/index input tokens count toward the same model budget. Character/word estimates never stand in for actual provider usage metering.

For real blind grading, provide a fresh private GATE_C_BLIND_KEY (64 hex digits). This produces HMAC-masked task IDs. Keep the secret key and operator-jobs.json out of graders' access until grading is frozen. CI deliberately uses public development IDs and cannot count as a real model study. Freeze outputs contain only commitments suitable for early publication. Recorded raw model responses must carry exact model/configuration, usage events, timestamps and verbatim retrieval logs.

Use the blinded rubric in frozen-vesper/BLIND_RUBRIC_v1.json. Independent reviewers score a decisive executable next test, quantifiers and exact falsification conditions. score_original_v1.cjs refuses missing raw transcripts, missing masked grades, identical execution/reviewer identities and source-less rationales. Six pairs are too few for sweeping claims of discovery improvement.

At the repository root:

    node research/nightfall/observatory/gate-c-ryev/parity_runner.cjs --selftest
    node research/nightfall/observatory/gate-c-ryev/parity_runner.cjs --retrieve FF-01 "short-vector span count"

For real study operators (keep environment/key and output directory PRIVATE):

    export GATE_C_BLIND_KEY="$(openssl rand -hex 32)"
    node research/nightfall/observatory/gate-c-ryev/parity_runner.cjs --freeze /private/study
    node research/nightfall/observatory/gate-c-ryev/parity_runner.cjs --validate /private/study
    node research/nightfall/observatory/gate-c-ryev/score_original_v1.cjs /private/study

The last two commands require twelve genuine controlled model responses and twelve separately documented blind grades. No outcomes exist from this engineering campaign. Observatory Gate C remains pending; Gate D remains blocked.

## Provider-measured execution (additional Vesper Gate C safeguard, 29 October 2026)

The original v1 parity runner now **refuses raw outputs with merely caller-supplied counters**. Genuine study execution uses `run_metered.cjs` with `OPENAI_API_KEY`, an explicitly chosen `GATE_C_MODEL`, and the existing private `GATE_C_BLIND_KEY`. The script calls OpenAI's Responses input-token count endpoint on the *exact assembled input*, sets `max_output_tokens` to fit the 2,000-token ceiling, then makes the Responses request without model tools or source mutation. It captures response ID, HTTP request ID, raw returned `usage.input_tokens` and `usage.output_tokens`, full response JSON, exact prompt and source excerpts, and the preflight count response. The same model, instructions and retrieval interface apply to all twelve arms.

**The accounting validator rejects** a missing provider response, zero input tokens, mismatched count endpoint and response usage, incorrect declared totals, altered source excerpts, hidden graph-only answer hints, a changed prompt, excessive output allowance, an over-budget response, mismatched model configuration, and a fabricated answer detached from the raw provider output. Unit tests use explicitly synthetic fixture records and confirm these refusals, **without treating the fixture as an actual trial**.

Run only in a confidential operator environment (never inside untrusted pull-request CI):

    export OPENAI_API_KEY=...           # secret, never commit
    export GATE_C_MODEL=...             # one agreed model for all 12 arms
    export GATE_C_BLIND_KEY=...         # original confidential freeze key
    node research/nightfall/observatory/gate-c-ryev/run_metered.cjs /absolute/private/frozen/study

API calls can incur charges. The script demands provider credentials and a previously frozen secret allocation, writes restricted-permission intermediate output, and never invents results when these inputs are missing. It currently requires all twelve responses in one completed batch; an interrupted batch retains an explicit partial record and **cannot** count as a completed study.

**Trust boundary:** captured response usage is an actual provider-produced API field when this direct runner executes. A copied JSON trace is still user-editable and **is not a provider-signed attestation**. Independent adjudication should cross-check provider request IDs against service billing/log records when available, archive immutable raw HTTP data securely, and preserve null or failed runs. Source parity is an engineering invariant; measured research improvement awaits genuine trials and blinded grading.

**Reproducible negative controls:** `node research/nightfall/observatory/gate-c-ryev/test_metering.cjs` (synthetic fixture only). Current availability of a model API key has not been established inside this ChatGPT session; no real provider requests or trial results are claimed.
