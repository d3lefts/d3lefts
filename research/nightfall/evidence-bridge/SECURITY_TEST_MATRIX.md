# RYEV Evidence Bridge — refusal and integration matrix

**PR:** #36. **Code:** core.js and test.cjs in this directory. **Observed CI:** GitHub Actions run 40813336183, success; independent website run 40813336186, success. **Scope:** first-party/local finite arithmetic; external mathematical refereeing remains open.

| Test | Required behavior | Recorded assertion |
|---|---|---|
| Real 30-point Sidon receipt | Preserve finite input and independent local recomputation; unreviewed stage | PASS; canonical fingerprint and 17-point maximum |
| Real 16-cell overlap receipt | Exact signed shift, denominator, negative controls; unreviewed stage | PASS; first-party exact recomputation |
| Real Werner exact receipt | Only fixed four-qutrit engine v1; no global theorem label | PASS; local result recomputed |
| Real F25 exact receipt | Only exhaustive F25 v1; no all-signals guarantee | PASS; local result recomputed |
| One-character witness change | Refuse stale input SHA-256 | INPUT_HASH |
| Forged independently_checked | Refuse reviewer authority metadata | AUTHORITY_SPOOF |
| Claim a finite Sidon result improves global asymptotic bound | Refuse cross-scope claim field | AUTHORITY_SPOOF |
| Unsupported receipt version | Refuse implicit schema conversion | VERSION |
| Mismatched Referee producer code version | Require exact first-party engine v1.0.0 | CODE_VERSION |
| Mismatched declared receipt ID | Require canonical input fingerprint identity | RECEIPT_ID |
| Tampered exact finite proof state count | Refuse mismatch with independently rerun first-party checker | RESULT_REPLAY |
| Tampered negative control | Refuse false adversarial check outcome | NEGATIVE_CONTROLS |
| Forged theorem/proof verdict | Refuse mismatch with recomputed status | VERDICT |
| Nested fake reviewer approval | Refuse untrusted authority fields anywhere in JSON | AUTHORITY_SPOOF |
| Unsupported Exact Tools version | Refuse non-allowlisted engine | CODE_VERSION |
| Modified F25 number of phase orbits | Refuse changed result arithmetic | RESULT_REPLAY |
| Duplicate finite input | Refuse previously staged canonical source ID | DUPLICATE |
| Preview before consent | Current browser workspace identical byte-for-byte | Chromium PASS |
| Cancel preview | No localStorage mutation | Chromium PASS |
| Approved append | Full backup downloaded first; one unassigned tested record appended | Chromium PASS |
| Save and reload | Existing manually labeled claim persists, and approved experiment persists | Chromium PASS |
| Duplicate import after reload | No second attachment, local workspace unchanged | Chromium PASS |
| Independent-language arithmetic | Separate Python implementation confirms genuine Sidon and overlap receipts | Python PASS |
| Python tamper negative | Changed witness with stale digest rejected | Python PASS |
| Invariant-preserving exact overlap | Reversal and complement lag covariance for all signed shifts | Invariant Forge PASS |
| Invariant-preserving affine Sidon | Three translations/scalings/reflection preserve finite max and AP structure | Invariant Forge PASS |

All refusal conditions return a human-readable reason. The JSON receipt cannot execute scripts, overwrite the Claim Lab workspace, attach to a canonical public claim, or modify an evidence-status label.

**Limitations:** The browser can prove only that first-party programs agree with declared finite inputs. A valid hash is a fingerprint, not a digital signature. The local backup download event and readback were exercised in Chromium; disk persistence beyond the browser download subsystem is not asserted. Independent external peer review and Observatory Gate C's actual matched-budget model experiment remain pending.

**Reproducible evidence:** Workflow test fixtures were uploaded as a time-limited GitHub Actions artifact named ryEV-evidence-bridge-security-receipts. Its output includes accepted and rejected receipts with refusal explanations. Run the tests from README.md to regenerate them.
