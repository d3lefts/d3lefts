# NIGHTFALL — public release scope and archive disclosure gate

**Status:** 2026-10-28, pre-publication review required for the two frozen mathematical research ZIPs. This policy concerns public disclosure; mathematical proof validation has its own independent gates.

## Observed scope conflict

The [September expansion inventory](SEPTEMBER_EXPANSION.md) lists `PHASESHIFT_Quantum_Interference_Referee_Draft_20261027.pdf` among its ten recovered original files. The [research index](README.md) currently excludes the Xi/critical-line and prime-frequency research lines from the public *text tree*. The frozen ZIP and its textual GitHub mirror have different disclosure boundaries. Excluding a file from navigation does **not** remove it from a downloadable ZIP.

The filename-level conflict is established by the published inventory. The archive's actual member bytes, PDF contents, and nested bundles have **not** been inspected during this repository-only audit. The existing frozen SHA-256 digests cannot establish privacy, confidentiality, security, license compliance, or suitability for public disclosure.

## Required pre-publication gate

1. Inspect the **actual** 214-entry and 226-entry frozen archives, including nested ZIPs, original PDFs, logs, prompt transcripts, and auxiliary files.
2. Run the offline **advisory** scan on local copies:

   ```bash
   python3 scripts/audit_release_scope.py \
     NIGHTFALL_GitHub_Release_2026-10-27.zip \
     NIGHTFALL_Expanded_Research_2026-10-28.zip
   ```

3. Review every flagged path manually. Examine skipped binary content separately; the scanner is deliberately limited to filename rules and small plain-text members. Confirm that all files are authorized for publication and contain no credentials, private logs, account data, or third-party restricted material.
4. Confirm the scope decision explicitly. **Full original frozen release:** knowingly authorize every included item and preserve the recorded archive hashes. **Curated public release:** build a distinct filtered archive, assign a new filename and SHA-256, publish its full manifest, and preserve the original frozen archives privately as historical records.
5. After the chosen assets are available, test anonymous downloads and rerun checksums, CRC, exact witnesses, and source-dependency checks.

A hash-preserving redaction is impossible: deleting even one archive member changes the archive bytes and digest. Do not relabel a curated derivative using an original frozen SHA-256.

## Verification boundaries

- Passing GitHub Actions **after publication** cannot undo public disclosure. Pre-publication review must happen before an owner uploads the files.
- The scanner returns exit code 2 when it spots a sensitive filename, a restricted research path, a token-like string, or invalid ZIP structure. Exit code 0 means **no matches in inspected material**, not a clean confidentiality certification.
- Files skipped due to binary formats, size, or nesting limits remain listed for manual inspection. The script never uploads content to a remote service.
- SourceBound's [separate public release](https://github.com/d3lefts/d3lefts/releases/tag/ai-safety-review-2026-10-28) is already published and carries its own digest; this review does not alter that archival event.
- The source-scope decision is separate from claims of originality, mathematical correctness, external peer review, and competition eligibility.

## Open tracked dependencies

- [Issue #5](https://github.com/d3lefts/d3lefts/issues/5): host and verify the selected source archive assets.
- [Issue #6](https://github.com/d3lefts/d3lefts/issues/6): recover the distinct accepted Arena submission payload.

**Owner release sign-off:** pending review of actual archive bytes and explicit approval of the chosen public scope.
