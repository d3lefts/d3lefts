# NIGHTFALL — Sharp Influence and Adaptive Observation (standalone v2.0)

**Author:** Devin J. Wright  
**Date:** November 12, 2026  
**Scope:** Independent proof program for quadratic, covered cubic and quadratic-backdoor influence/observation; no reliance on Turturean's theorem.

## Files

- `Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.pdf` — 22-page complete mathematical manuscript, with full proofs and prior-art section.
- `Sharp_Influence_Quadratic_Backdoors_and_Cubic_Observation.tex` — compile-ready full source.
- `check_quadratic_models.py` — inherited exact checker from the independent degree-two manuscript.
- `check_structured_backdoors.py` — new independent direct-conditioning exact checker for 20 heterogeneous product models, cubic addresses, and parity distinction.
- `CHECK_QUADRATIC_EXACT.log`, `CHECK_STRUCTURED_EXACT.log` — replay outputs.
- `PROOF_PASSPORT.md` — scoped claim/certificate/limitations and independent audit queue.
- `SHA256SUMS.txt` — frozen checksum receipt for the deliverables.

## What changes from v1

1. Retains the direct quadratic matching and Hilbert fourth-moment proof, sharp variance exponent and spectral query theorem.
2. Adds the distinct **averaging-transversal** inequality at arbitrary interaction degree.
3. Introduces the stronger **sectional quadratic backdoor**, proving additive query overhead `t+O(r B²/η)`, including all covered cubic targets.
4. Incorporates the **independent-block cubic network** theorem with uniform influence and adaptive observation constants independent of the number of blocks and leaf alphabet sizes.
5. Supplies explicit parity and cubic-address separations guarding against overextending the weaker hypothesis.
6. Keeps Turturean's paper as properly credited background, **not as a proof input**. No all-degree Turturean-derived extension is included.

## Certification

All major claims are analytical, not end-to-end Lean-certified, independently refereed, or globally novelty-cleared. Numeric/exact tests cover only finite instances. Unrestricted cubic exponent two is **open**. No author-approved external submission is represented.

## Primary contextual prior art checked November 12, 2026

- [Turturean, *A proof of the Aaronson-Ambainis conjecture* (arXiv:2611.09773)](https://arxiv.org/abs/2611.09773)
- [Girish–Mittal–Nehoran–Raz, *Distributional Variants* (arXiv:2609.35327)](https://arxiv.org/abs/2609.35327)
- [O'Donnell–Saks–Schramm–Servedio, *Every decision tree has an influential variable*](https://arxiv.org/abs/cs/0508071)
- [O'Donnell–Zhao, *Polynomial Bounds for Decoupling* (CCC 2016)](https://doi.org/10.4230/LIPIcs.CCC.2016.24)
- [Filmus–Hatami–Keller–Lifshitz, *On the sum of the L1 influences of bounded functions*](https://doi.org/10.1007/s11856-016-1355-0)

This is a selective contextual check, not a complete global novelty adjudication.
