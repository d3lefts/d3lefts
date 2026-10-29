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
