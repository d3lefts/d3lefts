# Exact frangible-wheel residue counts, 4 ≤ h ≤ 82

**NIGHTFALL research packet, 2026-11-22.** Source paper: M. J. Mossinghoff and T. S. Trudgian, [*Frangible prime gaps*, arXiv:2610.34525v1](https://arxiv.org/abs/2610.34525). **Status: exact finite calculation, paper proof, separate algorithms and machine replay; no outside referee, specialist novelty clearance or submitted contribution.** No theorem about unconditional frequencies of actual prime gaps.

## Result and source boundary

The original paper defines the residue set Ω(h) by requiring both endpoints b and b+h to be coprime to the primorial P(h) and every interior offset b+j to have a divisor among primes smaller than h. It gives **exact** |Ω(h)| in Table 1 only through h=46 and **bounds** for even 48≤h≤64 in Table 2. This packet gives candidate **exact integer** values for every even 4≤h≤82, stored in [results.json](results.json), including **18 exact extensions** at 48,50,...,82. The implementations agree on all 40 counts.

| h | |Ω(h)| |
|---:|---:|
| 46 | 3,066,631,938 (published exact checkpoint) |
| 48 | 270,657,148,848 (published bounds only) |
| 64 | 870,323,053,429,248 (published bounds only) |
| 82 | 438,759,487,817,609,368,326 (beyond paper's table range) |

Published Table 2 bounds for h=48: 270,434,770,380 to 279,846,011,304; for h=64: 869,625,166,376,736 to 913,579,931,068,704. Every overlapping computed count lies within the source bounds. One source paper not supplying a value does **not** establish worldwide originality.

## Mathematical counting mechanism

For even h≥4 let J={2,4,...,h−2}. For odd prime q<h choose one CRT residue r_q mod q avoiding r_q≡0 and −h (mod q). The number of allowed residues is A_q=q−2+1_[q divides h]. Prime 2 forces b≡1 (mod 2); thus covering J suffices.

Split the odd primes into S={q≤h/2−2} and L={h/2−1≤q<h}. After any S-residue assignment, let U⊆J be the un-covered even offsets. Every q in L covers at most **one** element of U. Every such q except possibly q0=h/2−1 can cover every element of U. If q0 is prime, it cannot cover the boundary offsets 2,h−2.

For B⊆L not containing q0, define

\[
T_B(k)=\sum_{v=0}^k(-1)^v\binom{k}{v}\prod_{q\in B}(A_q-v),
\qquad T_B(-1)=0.
\]

If no exceptional q0 exists, the number of large-prime residue assignments covering U is T_L(|U|). Otherwise let k=|U|, s=|U∩{2,h−2}| and B=L\{q0}; the exact count is

\[
(A_{q0}-(k-s))\,T_B(k)+(k-s)\,T_B(k-1).
\]

**Proof:** Every large prime hits at most one remaining even offset because two such offsets differ by at most h−4 and 2q≥h−2. Every nonexceptional prime has exactly one allowed residue to hit any specified offset. Inclusion-exclusion yields T_B(k) without duplicate assignments. The exceptional prime either chooses one of A_q0−(k−s) non-covering residues or one of k−s covering residues, yielding the two terms. CRT identifies each full tuple of local residues with one class modulo P(h). Sum over the S-assignments, aggregating identical uncovered masks. No prime-gap frequency theorem is inferred from this finite identity.

## Arithmetic constant and rigor

The paper defines c_h=|Ω(h)| / ∏_(2<q<h) (q−2) and c=2𝔖∑_(h≥2)c_h, where 𝔖=∏_(q>2)(1−(q−1)^−2). Exact rational arithmetic gives

\[
S_{82}=\sum_{\substack{4\le h\le82\\h\ {\rm even}}}c_h=
\frac{178998434470844807631353017}{86203290204933715490551875}
=2.0764687060703409\ldots .
\]

The omitted c_h terms are nonnegative. [rigorous_lower.py](rigorous_lower.py) multiplies prime Euler factors through 10^7 using 48-digit downward-rounded Decimal arithmetic and bounds the omitted factors by (10^7−1)/10^7, using the telescoping integer product. Its certified decimal lower bound is **c>2.7416104**; the source paper states c>2.741609817. This improves a defined arithmetic constant, not the unconditional frequency theory of primes; the Dickson–Hardy–Littlewood interpretation remains conditional.

## Replay and source custody

From the repository root, execute:

    cd research/nightfall/frangible-gaps-20261122
    bash replay.sh

This compiles C++17 [count_surjection.cpp](count_surjection.cpp) and [count_inclusion_exclusion.cpp](count_inclusion_exclusion.cpp), independently evaluates all 40 even h through 82, matches every entry in results.json and the paper's exact/bounded source tables, and reruns the rational/rigorous-Decimal constant certificate. The two programs share the small-prime mask representation but implement **different** large-prime combinatorial counts. They are separate computational checks, not separate human reviews.

**Direct local replay on 2026-11-22:** the original archive's nine tracked source SHA-256 sums matched the supplied manifest; both counters agreed on h=46,48,64,82 and the lower checker printed 2.74161044500211520... and passed. The source files in this new branch have small header/portability edits and are **not** represented as byte-identical to the archived ZIP. A separate source-pinned GitHub CI run is needed to certify the repository revision itself.

## Modulo-four pattern: conjecture, not theorem

For every tested even 6≤h≤82,

\[
|\Omega(h)|\equiv2\pmod4
\quad\Longleftrightarrow\quad
h=8\ \text{or}\ h/2\ \text{is an odd prime};
\]

otherwise |Ω(h)|≡0 (mod 4). At h=4, the count is 1. **This is finite evidence only**, possibly explained by existing wheel reflection symmetries. Seek an orbit proof or counterexample rather than indefinitely extending the table.

## Limits and attribution

- Mossinghoff–Trudgian supplied the problem, notation, exact/bounded baseline, and constant formula; Gafni–Tao are the cited antecedent. CRT, inclusion-exclusion and wheel symmetries are classical.
- Independent specialist priority work, source version check and non-author mathematical review remain open. No author contact, public paper or leaderboard submission is authorized by this archival change.
- One bounded independent replay and modulo-four proof/counterexample attempt are permitted; then park unless the method transfers or a genuine general theorem emerges.
- **This is not NIGHTFALL's flagship.** See the separate [research decision](../FLAGSHIP_DECISION_20261122.md).
