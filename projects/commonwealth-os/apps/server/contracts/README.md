# Synthetic v0.4 interoperable contracts

OpenAPI 3.1 and JSON Schema 2020-12 describe the **synthetic** API and record envelopes. The published types are contracts, not proof that a deployment satisfies them. The `commonwealth.example.invalid` schema ID is a non-routable label, not a source site.

- `portable-evidence-v2.schema.json`: portable signed evidence required fields; cryptographic and semantic replay validation MUST use `verify-v2.mjs` with an independently trusted pinned public key.
- `procedural-policy.schema.json`: typed threshold, abstention basis, optional rational quorum. Cross-field rational inequality is checked at runtime.
- `synthetic-source.schema.json`: explicitly refuses real-world URLs.
- `command.schema.json`: transition API envelope. Actor authority is never accepted from client data.

No third-party validator is bundled. `tests/contracts.test.mjs` checks structural shape; a production JSON Schema validator, independent compatibility implementation and external portability audit remain separate release requirements.
