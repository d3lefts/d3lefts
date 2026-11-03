# LEMNIS · K3,3 cyclic voltage cover theorem

For each integer modulus m>500, the connected cubic 6m-vertex regular cyclic cover with chord voltages 1,5,25,125 has girth 12, no 16-cycle, and an explicit 32-cycle. Its first power-of-two cycle has length 32. Full proof, quantified assumptions and earlier literature: RESEARCH_NOTE.md.

Reproduce:

    python3 verify_symbolic.py
    python3 verify_c32.py
    c++ -std=c++20 -O2 verify_literal.cpp -o verify_literal
    ./verify_literal 501
    ./verify_literal 502
    ./verify_literal 503

Three separate representations are used: base-walk homology, explicit cycle witnesses, and literal lifted-graph DFS. The uniform all-m theorem follows from the symbolic integer-voltage bound, not from three sampled moduli.

Status R1, independent external review and worldwide priority open. Related earlier cubic girth-12 and C16-avoiding constructions are credited in the note. This does not settle Erdős #64 and is not a site Original Finding promotion.
