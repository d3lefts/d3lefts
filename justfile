# NIGHTFALL agent command contract. Existing checkers remain authoritative.
# All receipts are metadata-only. Lean is certified ONLY by its pinned kernel lanes.

default:
    @just --list

# Machine-readable allowlisted task catalogue.
tasks:
    @python3 scripts/nightfall_agent_tasks.py list

# Preserve the exact source-locked Proof Passport v2 validator.
passport:
    @python3 scripts/nightfall_agent_tasks.py run passport

# Checkout registry pins only; not a Lean kernel or installed-toolchain test.
compiler-lock:
    @python3 scripts/nightfall_agent_tasks.py run compiler-lock

# Independent differential-formalization mutation controls (not a proof).
differential-guards:
    @python3 scripts/nightfall_agent_tasks.py run differential-guards

# Metadata and provenance integrity (not a mathematical or priority check).
research-archive:
    @python3 scripts/nightfall_agent_tasks.py run research-archive

# Verify the canonical checked-in Lean import closure, not Lean compilation.
lake-manifest:
    @python3 scripts/nightfall_agent_tasks.py run lake-manifest

# Fail-closed program preflight; each dependency retains its own scope/receipt.
preflight: compiler-lock passport differential-guards research-archive lake-manifest
    @echo "NIGHTFALL orchestration preflight passed; mathematical certification unchanged."
