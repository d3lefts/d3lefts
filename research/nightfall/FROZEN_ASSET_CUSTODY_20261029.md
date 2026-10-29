# NIGHTFALL frozen-archive custody checkpoint — 2026-10-29

**Status: original bytes recovered and privately staged; no public GitHub Release assets uploaded.** This record documents file custody only, and does not upgrade any mathematical evidence label.

## Frozen original archives

| Original | Bytes | Entries | SHA-256 | Post-transfer check |
| --- | ---: | ---: | --- | --- |
| NIGHTFALL_GitHub_Release_2026-10-27.zip | 20,981,017 | 214 | `77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb` | hash and complete ZIP CRC pass |
| NIGHTFALL_Expanded_Research_2026-10-28.zip | 22,753,993 | 226 | `fca5dba595475783e3482d72d5e4888e76b91c38052a0589577f0fde578b8275` | hash and complete ZIP CRC pass |

**Transfer:** both original files were located in the owner's ChatGPT Library, transferred to an owner-private Google Drive research release-review folder on October 29, read back from Drive, and independently hashed/ZIP-tested again. No byte changes. These private copies are **not** public binary mirrors.

## Supplementary staged archives

- `NIGHTFALL_Erdos_Sidon_974_20261029.zip`, 26,467 bytes, SHA-256 `cbbc71a4051058054420d18ebdb10ed351b34063677025dd83b24b3423e1531b`.
- `NIGHTFALL_EA36_LOWER_AGENT_AUDIT_20261028.zip`, 5,492,486 bytes, SHA-256 `a3dba636f60d0fdde354b322acaa86c4e7d3744cb6a9b9969eedf707ef1bb57d`. Imported analytic/source-interval dependencies remain conditional.
- `AXIOM_F25_Independent_Proof_v2_20261028.zip`, 9,671 bytes, SHA-256 `450500410991abefca39bc3157f6bdc0f75833faa82adf06e50c3f32758bd491`.

These are private staging copies, with ZIP integrity checked at source; supplementary Drive transfers were confirmed by filename and byte size.

## Advisory prepublication audit

The 226-entry expanded archive was recursively opened through nested ZIPs (to depth four); its 25 PDFs had extractable text scanned, along with 692 text-like members. No key-pattern hit (GitHub/OpenAI/AWS/Google API key regexes and PEM private-key header patterns) was found in that examined text. The broad privacy-phrase scan flagged 12 text members (16 occurrences). Binary files, fonts/images and any unparsable or sensitive content still require manual review. A token-pattern miss is **not** proof that release is safe.

**Known disclosure conflict:** `research/nightfall/supplement/originals/PHASESHIFT_Quantum_Interference_Referee_Draft_20261027.pdf` is present in the expanded bundle, while the public research text index excludes that research track. The master includes nested research materials beyond the public article list. Preserve their existing public/private scope unless the owner explicitly approves disclosure. See [publication scope](PUBLICATION_SCOPE.md).

## Remaining blockers

1. Review private/unpublished source scope, documents, nested bundles, third-party rights and sensitive material; authorize whole original release **or** construct a separately named curated public derivative with a new hash.
2. GitHub connector supports repository text commits, but no GitHub Release binary-asset upload endpoint. No release asset upload was performed in this session. Completing the GitHub Release requires an upload-capable browser/client workflow.
3. Anonymous download, matching checksums and independent replay remain pending. Keep [issue #5](https://github.com/d3lefts/d3lefts/issues/5) open.
4. Accepted Arena submission #2628 remains a **distinct unrecovered payload** under [issue #6](https://github.com/d3lefts/d3lefts/issues/6).

**Integrity label:** Private custody / archive byte identity verified; public publication pending; scientific proof status unchanged.
