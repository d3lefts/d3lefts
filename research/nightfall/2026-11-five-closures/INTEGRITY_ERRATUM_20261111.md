# Provenance erratum — Five-Closure v1.1 ZIP (11 November 2026)

**Original ZIP:** `NIGHTFALL_Five_Closure_Audits_v11_20261111.zip`, SHA-256 `0d9f2b9bc6c4183394173987c30b225ca1c4675f7307efa05c563e531a096bd4`.

**Independent defect reproduced:** on fresh extraction, `sha256sum -c SHA256SUMS` reports **six missing files**, all `artifacts/render_v11/page-[1..6].png`. An included log, `artifacts/manifest_verify.txt`, incorrectly reports those files as present and verified. No other manifest-listed files failed hash validation. The report's claim that the *distributed v1.1 ZIP* was fully verifiable was therefore incorrect; this is a packaging issue, not a retraction of the mathematical PDF/source.

**Repaired v1.2 ZIP:** `NIGHTFALL_Five_Closure_Audits_v12_INTEGRITY_REPAIRED_20261111.zip`, SHA-256 `28e61af840605eb3b652cdb52bfeaa3a154f9d966b43ce69128c616b6ba30123`. The regenerated manifest lists **21 actual files**, all of which pass an independent fresh `sha256sum -c SHA256SUMS` replay. Missing render entries and the stale verification log were removed; an explicit package erratum was inserted. The compiled PDF and original TeX source remained byte-identical; PDF SHA-256 `9d085350ec6c010c27f9c9618e31346871ec9949a1afd360754680901e5b9266`.

The repaired ZIP remains a conversation artifact, not a GitHub binary asset. Neither a manifest nor a passing finite checker certifies an arbitrary-product theorem, unrestricted cubic exponent two, a Lean declaration, or historical novelty. Retain both original and repaired ZIP hashes as distinct archive versions.
