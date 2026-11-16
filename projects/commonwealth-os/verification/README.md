# Commonwealth OS source archive verifier

Run with Python 3.12+:

```sh
python projects/commonwealth-os/verification/verify_archived_sources.py
```

This verifies all 81 files listed in SOURCE_ARCHIVE_MANIFEST_20261115.json
against their frozen SHA-256 digests, checks the non-JavaScript mobile
walkthrough, reruns 19 synthetic effect-guard cases, the source-independent
finite semantic-reuse audit, the passport schema example, and the 15
bounded prepilot assertions.

The historical prepilot assertion script assumes its original ZIP-relative
paths. The verifier reconstructs that layout under a temporary directory
rather than modifying archival source bytes and invalidating provenance.

Passing is not a cryptographic ballot audit, legal authorization review,
full browser interaction test, Lean proof of production code, or evidence
of informed agency/political equality. No server or hosting is started.
