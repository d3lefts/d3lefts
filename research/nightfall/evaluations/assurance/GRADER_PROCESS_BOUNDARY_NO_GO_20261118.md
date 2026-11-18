# NIGHTFALL — executed-grader false-perfect-score proof attack

**2026-11-18. Status: exact synthetic counterexample to the proposed trusted scoring boundary. NOT a blind model run, not an audit of the private DispatchQ grader, not proof that Docker itself is compromised.**

## Objective and exact version

This audit is stacked on [draft PR #841](https://github.com/d3lefts/d3lefts/pull/841), exact source head \`b4f64ab3e23f2ac3a6f140b3c7c242a525c641d7\`. That PR uses a trusted host to execute a **single-file Python grader** within Docker. It pins source/grader/container hashes and requires a clean exit plus one properly typed JSON score. However, the trusted grader uses the candidate code *within the same interpreter* (the test's scorer uses \`runpy.run_path\`), and the candidate can see the grader file mounted into that same process's container.

The preregistered assertion under attack is: "A score produced by the pinned grader process and accepted by \`capture()\` establishes that the pinned grader awarded the score, rather than executable candidate code fabricating it."

**That assertion is FALSE.** The existing wrapper verifies the identity of the Python file launched, not the identity of the code that printed the final JSON or called \`os._exit(0)\`.

## Two independent, intentionally WRONG patches

Both patches start from toy \`value.py\` containing \`ANSWER=0\`. The toy task contract is \`ANSWER==1\`. A separate independent source checker evaluates each submitted patch outside the grading environment. The original grader is a pinned single-file Python script that imports the candidate through \`runpy.run_path\` and awards 100 points only if \`ANSWER==1\`.

- **stdout termination/grade forgery:** The patched candidate emits a complete, syntactically valid perfect-score JSON using \`os.write(1,...)\`, then immediately invokes \`os._exit(0)\` before assigning \`ANSWER\`. The trusted grader never gets to check the task. Since the process exits successfully and stdout is properly shaped, the wrapper accepts 100/100. The independent source-side probe cannot obtain any \`ANSWER\` return value.
- **scorer-mount oracle:** The candidate defines \`ANSWER=1\` only when \`/opt/grader/score.py\` exists. It returns \`ANSWER=0\` on an independent invocation without the grader. Because the private scorer file is mounted inside the candidate's namespace, the wrapper awards 100/100 on this contract-breaking patch. The patch never reads or copies any secret file: a mere file-existence check is enough.

Both probes preserve the **identical frozen source tree, genuine grader byte hash, plan SHA, Docker image ID, declared grading denominator and accepted attempt ID**. No tampering of hashes, grader or plan is needed. This tests a distinct failure from the v2 forged-report issue that PR #841's \`join_grader_capture.py\` correctly blocks.

## Reproduction and evidence boundaries

\`audit_same_process_score_forgery.py\` creates its own toy seed, patches, scorer, frozen v2 plan and local Docker invocation, calls the actual \`trusted_container_grade.capture()\`, checks the published \`grade.json\` and \`capture.json\`, then separately invokes each wrong patch outside the grader environment. It **expects two accepted false-perfect scores** on this vulnerable version. Therefore, a green proof-attack CI is **a demonstrated grader-security failure, not a passing grader-safety audit**.

The CI workflow \`nightfall-grade-process-forgery.yml\` runs this toy source-exact probe under Python 3.10 and 3.13, pins the locally installed Docker image's SHA256 ID, writes an execution log and source manifest, and stores exact-head artifacts. It runs no real model, no private benchmark grader and no agent-authored patch. No private data is in this branch.

A local independent first-stage reproduction (not Docker): a toy scorer using the same \`runpy\` pattern accepted a fake 100/100 JSON and returned exit code 0 even though the wrong candidate never supplied its required contract value. The actual container behavior is **not certified until CI executes the pinned workflow**.

## Required repair before any real agent scores

**Do not promote #841 to "trusted grader execution" or use its scores as model-capability evidence until this failure is resolved.** A genuine fix must change process/trust boundaries:

1. Candidate-supplied code must **never share the process emitting authoritative grader scores**. A \`sys.exit\` or \`os._exit\` in candidate code must only terminate a *candidate subprocess/container*, not the scoring authority.
2. Candidate runtime must **not mount or be able to inspect the private scorer**, reference solution, hidden tests, or the trusted output channel. Run the grader as a separate trusted orchestrator outside the candidate runtime, with narrow, authenticated measurements returned to it. A separate process **inside the same mount namespace with the grader visible** is not sufficient to preserve holdout secrecy.
3. The grader must score observable behavior/contract invariants from outside the candidate process, never accept a complete score JSON authored by candidate code as authoritative.
4. Repeat both attacks as **expected rejects**, validate one correct alternate repair and one genuinely wrong honest repair, and independently verify raw process/score custody. Do not silently invert the meaning of a previously green vulnerability-reproduction workflow.
5. Only after that can the existing frozen-plan v2 and execution-join checks contribute to a real blind-agent comparison. Those checks are useful, but they cannot fix score origin once the trusted process is hijacked.

**Do not claim a successful external benchmark, sandbox attestation, new model capability result or general Docker vulnerability.** This is a deterministic, source-specific execution-boundary finding in NIGHTFALL's own synthetic grader capsule.

### Discovery graph

Frozen plan → source-hashed grader process → untrusted candidate imported in same interpreter → candidate-controlled stdout and termination / mounted scorer side channel → false-perfect score despite honest hashes → exact synthetic counterexample → require process-and-filesystem-separated scoring authority → retest with independent malicious patches → only then run real agents.
