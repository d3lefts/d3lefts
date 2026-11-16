# Replay and certification scope

Run (Python 3.11+):

```sh
python -m unittest discover -s tests -v
python archive_v0_3/audit_semantic_reuse_independent.py
python archive_v0_3/dap_finite_audit.py
sha256sum -c SHA256SUMS.txt
```

Reference guard checks are *synthetic*. A passing test only checks code's modeled predicates. It cannot verify truthful legal inputs, real effects, valid anonymous election cryptography, tamper-resistant devices, accessibility or societal legitimacy. The finite DAP theorem requires complete mediation and genuine source provenance. Human review, independent legal and security audit, IRB review when appropriate and institutional authorization are separate release gates.

Source version: GitHub `main` commit 17571cf14e49a76c599b0e7f98a769699b1314d9, checked 2026-11-15 18:35 EST. DAP v0.3 archive source copied byte-for-byte from the current conversation artifact, not claimed to be already merged to main.
