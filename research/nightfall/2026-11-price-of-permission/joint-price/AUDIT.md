# Independent Finite Audit — Joint Price Theorem

- **Analytic solver**: `price_exact.py`, computes formula and facility optimum with exact `fractions.Fraction`.
- **Adversarial checker**: `audit_independent.py`, independently enumerates actual per-slot actions, including left-half, right-half, two simultaneous halves, direct check, partial followed by direct check, and idle. It memoizes explicit verifier histories. It does **not** use the theorem in the oracle. Its main routine compares the oracle result against the proposed closed form.
- **Caveat:** Both programs are written in the same AI-assisted session; independent implementation is not independent nonauthor mathematical review.
- **Scope:** N=1..4; H=1..3; m=0..4; every cached set and every B-subset invalidation; c=1,d=5; facility fee F=0..7. Modular source r=2..13 with exact finite-world checks of single-read indistinguishability.
- **Result:** 510 nominal/invalidated schedule configurations, of which 148 infeasible; 504 exact facility optimization checks; 818 modular source worlds. No discrepancies.
- **Canonical oracle receipt SHA-256:** `e3510199a96c6732b7bda1572bc01e324d96e46509b122d600aa2c20587291f8`.
- **Additional expected witness:** cached present new evidence=4; cache invalidated new evidence=12; one cache loss costs 8 > direct-cost 5.
- **Safety boundary:** perfect source-linked reads and tests, all effects contained behind trusted atomic guard. The checker does **not** establish deployed complete mediation or independent verification of cloud/provider side effects.

Replay in this folder:

```bash
python3 audit_independent.py
python3 price_exact.py
sha256sum -c SHA256SUMS.txt
```

Record any failing exact replay as a contradiction; do not promote claims on old passing receipts after source changes.
