# Mixed-character product-sphere obstruction: exact binary criterion

NIGHTFALL checkpoint, 2026-11-22. **Status:** exact algebraic theorem and reproducible
standard-library checker. External classical topology is NOT Lean-certified.
No originality or priority claim. Linked: merged #1010, #1012, #1003.

## Statement

Let n≥1, r,s,t≥0. In R_n=F₂[α,β]/(αⁿ,βⁿ), define
P=αʳβˢ(α+β)^t. Then

P ≠ 0 **if and only if** there exists an integer i with
0≤i≤t, r+i<n, s+t−i<n, and (i & t)=i
(where & denotes binary bitwise AND).

This covers r pure first-sign characters, s pure second-sign
characters, and t mixed sign characters, each of which flips
under either factor's antipode.

**Exact proof.** Expand by the binomial theorem:
P=Σ_(i=0)^t C(t,i) α^(r+i) β^(s+t−i).
Distinct i give distinct exponent pairs and cannot cancel.
Monomials survive the truncated ring precisely under both strict
exponent inequalities. In characteristic two,
(α+β)^(2^k)=α^(2^k)+β^(2^k).
The binary expansion of t thus shows the coefficient C(t,i) is
odd exactly when every set binary bit of i is a set bit of t.
This establishes the stated necessary and sufficient criterion.

Specializations: t=0 and r,s≤n−1 recover the unknown-norm
product-sphere obstruction. t=1, r=n−1,s=n−2 yields the
known-norm mixed-character class α^(n−1)β^(n−1)≠0.

## Explicit negative control: two mixed characters

For n=2,r=s=0,t=2, P=(α+β)²=α²+β²=0.
In fact, a continuous mixed-equivariant map
F:S¹×S¹→R² that **never vanishes** exists:
F((a,b),(c,d))=(ac−bd,ad+bc), the complex product.
Negating either input negates both outputs.
Its squared norm is
(ac−bd)²+(ad+bc)²=(a²+b²)(c²+d²)=1.
Consequently a blanket character-rank rule based only on
the domain dimension or number of outputs is FALSE.
This does not refute the pure-character theorem or the t=1
known-sphere derivation; it blocks a careless generalization.

## Exact scope and topology

The associated product-projective representation bundle has
top Stiefel–Whitney class P. Its nonvanishing forces zeros of
continuous equivariant maps by the classical nonzero-section
obstruction. This classical implication is a paper-level external
dependency, NOT an imported or kernel-proved Lean fact here.
Vanishing of P does **not** generally imply existence of a
nowhere-zero section; the criterion is exact for nonvanishing
of this specific top characteristic class, not a complete
classification of equivariant zero existence.

Primary source for product-sphere topology:
Chan–Chen–Frick–Hull (2019),
https://arxiv.org/abs/1902.00935.
Lucas's binary parity identity is classical.
Specialist prior-art comparison for coupled-character sensing
is not complete; make no new-theorem priority claim.

## Checker

Run:
python3 research/nightfall/continuous-phase-norm-threshold-20261122/check_mixed_character_obstruction.py

The checker compares independent coefficient supports from repeated
mod-two polynomial multiplication, exact integer binomial parity,
and the binary-subset test. It separately tests the complex-product
negative control on exact rational circle points. Finite testing is
not the proof of the universal algebraic statement.

## Transfer, limits, and next gate

For general sensing with pure and coupled character constraints,
compute the full character polynomial before applying an
equivariant-zero argument. Simple scalar-output counts and total
block rank are not sufficient to determine this obstruction
once mixed characters enter.

Next: define a Fin t-indexed mixed-character block in Lean,
prove the finite ring identity and binary support criterion,
and connect the algebra to product-sphere topology without
a new theorem-shaped axiom. Do not count algebra-only CI as
topological certification.

Discovery graph: actions → character representation →
truncated polynomial → Lucas parity → zero-obstruction test →
topological dependency (unformalized) → causal collision transfer.
