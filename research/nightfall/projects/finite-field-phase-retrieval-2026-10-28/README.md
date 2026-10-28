# Finite-field phase retrieval, 28 October 2026

Research lead: Devin J. Wright. Status: source-conditional exact tail certificate, with a pending independent mathematical review.

## Strengthened bound

For powered linear measurements over F_q, the revised research manuscript describes collision geometry, a systematic fourth-power LLL complete-list decoder, and a quantitative short-vector span bound.

For prime p congruent to 1 mod 4, with (delta, eta)=(0.999,0.501) and log2(q)>=3.69*k+9.2, it reports P_11(q)<2^-96. This is a 40-bit improvement against the prior 2^-56 estimate. **The conclusion depends on the manuscript's Gaussian short-vector span-count lemma; the checkers here validate its downstream algebra, not the lemma itself.**

The exact certificates retain the unique extreme support term's binomial weight one. Both independently designed checks passed locally on October 28.

## Reproduce

```bash
python3 verify_tail_A.py
python3 -m pip install sympy
python3 verify_tail_B.py
```

The first checker uses exact rational arithmetic. The second independently derives symbolic polynomials and tests finite direct-sum envelopes.

Original Library evidence still to mirror:
- `Finite_Field_Phase_Retrieval_Certificates_2026-10-28.zip`, SHA-256 `31b2a1a62ca1817d1268fca35c5cf21190ebcf873098abc3a0c4e6c03f0cf2e3`
- `Finite_Field_Phase_Retrieval_Research_2026-10-28.pdf`, SHA-256 `e1467750dc0f3bd9e5e25746f3ae95a73c9aa9770fd51b30fba4841cffe156a3`

Full end-to-end decoder verification and originality review are pending. The [older handoff excerpt](../finite-field-retrieval-handoff-excerpt.txt) remains in its original state.
