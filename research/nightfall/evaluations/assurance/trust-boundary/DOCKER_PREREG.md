# Preregistration: separate-origin Docker counterexamples

**Objective:** Test two specific failure mechanisms from independent scorer-origin proof attack PR #843 against a replacement architecture with authoritative assertions outside the container and no grader/source files mounted inside the candidate runtime.

**Assumptions and limits:** Runner is GitHub-hosted Ubuntu with Docker and a recorded `python:3.13-slim` image ID; an ephemeral container gets only a single synthetic `target.py` directory via read-only mount; no network; no privileges; read-only root filesystem; nonroot account; bounded CPU/memory/PIDs. This is a synthetic proof attack, not execution of external agent patches. Docker image may be pulled immediately before the run and was not precommitted to a digest in this first experiment, so image supply-chain identity is logged but not independently frozen upstream.

**Predictions, before any execution:**

| Fixture | Candidate behavior | Authoritative outcome |
|---|---|---|
| Correct control | `ANSWER=1` | completed, 100 |
| Incorrect control | `ANSWER=0` | completed, 0 |
| Score forgery | print `score:100` JSON then exit before returning task value | **blocked_protocol, score null** |
| Grader-path probe | return correct value only if `/opt/grader/score.py` is visible | **completed, 0** |

**Discriminating alternatives:** Forgery accepted => candidate controls authoritative stdout; grader-path probe earns 100 => private scorer remains visible. Run-level failure without scores means blocked infrastructure, not success. CI must report observed values, source hashes, locally obtained image ID, host Python and return status. Do not suppress failures or treat a negative-model score as a successful coding-agent result.

**Budget/stop:** Four cases × one launch each, 30s per launch, abort on missing Docker image; no retry or result-selection. Avoid secrets, Docker socket mounts, host network, scorer/reference mounts and model inference. Exact experiment is CI on Python 3.10 and 3.13 (host) with Python 3.13 container.

**Certificate ceiling:** Passing all four cases demonstrates resistance to these two attack mechanisms under the stated setup. It does NOT prove a secure production container, side-channel freedom, protection against kernel/container escapes, complete task-contract grading, or independent reviewer approval. Process separation without filesystem isolation (private v0.4 local scorer) remains insufficient for real agents.