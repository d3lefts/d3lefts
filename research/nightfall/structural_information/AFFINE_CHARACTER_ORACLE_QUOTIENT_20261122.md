# Affine-character quotient: exact oracle reduction and Wyner separation

**Date:** 2026-11-22. **Status:** algebraic *paper proof* (reproducible exact finite instance), not Lean-certified, not a priority or mathematical originality claim. Distinct from the conditional rank-free T2 inequality in PR #1068. Mechanism: remove redundant character labels only after restricting the *actual source* to a uniform affine subspace, and account for the fixed unitary sign.

## 1. Exact abstract reduction

Let V be a finite-dimensional F₂ vector space, H≤V* a linear subspace, and s be uniform on the affine coset s₀+H. Let R⊂V\\{0} be the allowed **classical original-label** queries; D=R∪{0}. A physical T-query *phase oracle* is

```
 O_s = Σ_{a∈D} (-1)^{<a,s>} Π_a
```

on a finite complex Hilbert space, where `Π_a` are pairwise orthogonal projectors summing to I, including `Π_0` (which may be zero). Let `K=H^⊥⊂V`, `\bar a=a+K∈V/K≅H*`, and `C=\{\bar a:a∈D\}`. Define

```
 P_c = Σ_{a∈D: \bar a=c} Π_a,
 S₀ = Σ_{a∈D} (-1)^{<a,s₀>} Π_a,
 Q_h = Σ_{c∈C} (-1)^{<c,h>} P_c.
```

Then `P_c` are orthogonal projectors summing to I; `S₀` is a fixed self-adjoint unitary, `S₀²=I`, and

```
 O_{s₀+h} = S₀ Q_h = Q_h S₀   (∀h∈H).                 (1)
```

**Proof:** group the original projectors by their characters on H. Labels within one class have the same restriction to H, so the original character factors into its known coset offset `(-1)^{<a,s₀>}` and the class character `(-1)^{<\bar a,h>}`. Orthogonality gives all projection/unitarity identities.

**Two-query circuit with arbitrary terminal effect.** Let ψ be unit length, U any fixed unitary, and 0≤E≤I any complex Hermitian effect. For s=s₀+h,

```
 φ_s = O_s U O_s ψ
     = S₀ [Q_h (U S₀) Q_h ψ].
 U' = U S₀,    E' = S₀ E S₀.
 <φ_s,E φ_s> = <Q_h U' Q_h ψ, E' Q_h U' Q_h ψ>.       (2)
```

The new circuit remains well-formed, is allowed noncommuting/nonprojective E, and uses **two quotient-character queries**, not four. Any T-query circuit similarly absorbs the fixed S₀ into surrounding input-independent gates; query count is exactly preserved.

**Classical original-oracle access.** Every nonzero class c∈C has some a∈R with `\bar a=c`. One original query returns `χ_a(s₀+h)`; multiply by the known sign `χ_a(s₀)` to get `χ_c(h)`. Zero-class characters are constants and cost no query. Thus *each classical query to a nonzero quotient label is implemented using exactly one actual original-label query*. This is a nonuniform reduction: source coset H,s₀ and the query model are known. It is not a method of discovering an unknown subspace for free.

Consequently **conditional on** the abstract binary-label rank-free T2 theorem from #1068, the latter applies on a *uniform affine source* with its K4 and M2 computed on **distinct nonzero quotient classes** `R'={\bar a:a∈R, \bar a≠0}` rather than raw R. This is a *formal consequence of a candidate*, not promotion of the candidate.

## 2. An exact separation of two structural resources

For any r≥3 let V=F₂^{2r}, H=F₂^r×{0}, and s₀=0. Use the distinct original labels

```
 a_i = (e_i,0),    b_i = (e_i,e_i),   i=1,...,r.
```

The raw 2r oracle symbols under uniform h∈H are the perfectly duplicated independent fair bits `(X₁,X₁,...,X_r,X_r)`. This distribution is highly dependent although the latent X is product. Its **Wyner common information is exactly**

```
 C_W(raw table) = r ln 2   nats.                       (3)
```

**Proof of lower bound (all latent spaces):** suppose W makes *all* raw coordinates conditionally independent. Since each duplicated pair is equal almost surely, for almost every W its two conditional Bernoulli distributions p,q are independent and satisfy `P(A=B|W)=1`. Therefore `p(0)q(0)+p(1)q(1)=1`; the only possibility is the same deterministic bit for both. Hence each X_i is a measurable function of W, so H(raw table|W)=0, and `I(W;raw table)=H(raw table)=r ln 2`. Achievability: choose W=(X₁,...,X_r), for which all coordinates are point masses. No zero-atom restrictions are needed.

But quotient-compressing the actual phase oracle gives exactly r independent fair character labels `e_i`. The primitive four-tuple and pair invariants of that quotient are

```
 K4(R') = 24,    M2(R') = 2  (r≥3),                  (4)
```

independent of r: over an independent basis each nonzero XOR has a *unique* basis-support; primitive four-slot counts are max of 4 (support 1), 12 (support 2), 24 (support 3), 24 (support 4). Pair multiplicity is 2. Note support-4 uses no zero slot; support-3 has one zero slot; they are equal maxima.

The candidate T2 theorem therefore predicts *constant query cost in r* for every fixed ε,δ despite `C_W(raw table)=Θ(r)`. **Independently of the T2 conjecture**, this particular family is covered by the existing *product-input* low-degree/quantum-acceptance simulation machinery after the exact quotient reduction; the resulting constant-depth-in-r statement is a paper-level deduction using the earlier AA simulation theorem. It is not a claim that generic arbitrary-source Wyner bounds improve, nor a quantum/classical query separation.

This is a precise falsifiable illustration that raw Wyner common information can *overcharge* classical simulation in the presence of source-deterministic label redundancies. A sharper information resource, if sought, must be **oracle-task-aware**, not simply `C_W` of the uncompressed input table. Raw source common-information and the quotient operator are different resources; combining them by taking a min of two valid upper bounds would be elementary, not a new theorem.

## 3. Independent exact instance and negative control

`scripts/check_affine_quotient_exact.py` uses V=F₂³, H=span(e₀,e₁), s₀=e₂, R={e₀,e₀+e₂,e₁,e₁+e₂}. The five frequency projectors are one-dimensional, U is a rational Householder unitary, ψ a rational unit vector, and E a rational rank-one projection **not commuting with S₀**. Sympy verifies (1), state identity (2), identical acceptance for each of the four secrets, exactly one-query representative conversion, and *nonzero mismatch when the indispensable fixed-effect conjugation is omitted*. A separate finite count checks r=1,...,5 duplicate-table supports of size 2^r. This test is an exact finite check, **not** a general Lean proof or certification of the rank-free quantum bound.

## 4. Status, transfer and next experiment

- **Established by algebraic argument in this note:** arbitrary-affine-source label quotient, exact circuit acceptance preservation and original-label query accounting; all-latent `C_W=r ln2` for duplicated fair-bit sources. Independent human proof review and Lean terminal are open.
- **Exact finite computation:** four-secret rational noncommuting-effect regression, deliberately failing omission-of-S₀ control, and 1≤r≤5 duplicate supports.
- **Conditional:** uniform-affine-source rank-free two-query simulation at K4(R'),M2(R'), until #1068's full Hilbert inequalities are certified.
- **Prior art:** elementary character restriction, projector grouping, and unitary conjugation are standard mathematical operators. No novelty claim for these ingredients or this illustrative duplicate family. Search against oracle restriction/compression literature before claiming a new joint theorem.
- **Cheapest decisive next research:** find a family with (a) *no source-deterministic duplicate labels*, (b) large raw C_W, (c) small **source-quotient** K4,M2, and (d) no existing product reduction. If impossible, prove the structural obstruction instead of another cosmetic example. Independently attack the fixed-S₀ absorption under arbitrary T and mid-circuit measurements.
- **Certificate target:** a Lean finite-character quotient lemma with projection algebra, followed by one kernel source-to-existing-Route1/AA interface for a standard phase oracle. Do **not** treat the symbolic test as that certificate.

**Source graph:** product AA/quantum degree (#858/#974) → source-affine character quotient (this note) → independent-character law and exact C_W separation → candidate generic T2 (draft #1068) → pending quantum Hilbert audit.


## 5. Canonical source-support quotient (strengthened representation theorem)

The oracle equality (1), and the exact two-query acceptance identity (2), **do not require uniformity**. More generally let `S⊂V*` be the nonempty actual support of *any* secret law, pick `s₀∈S`, and let `H=span_{F₂}{s+s₀:s∈S}` (the direction space of the affine hull). Then the same `S₀,Q_h` decomposition is exact for **every** s∈S with h=s+s₀, regardless of its law.

**Maximality / complete characterization.** For any two labels a,b∈V and any nonempty support S, the following are equivalent:

1. `χ_a(s)=σ χ_b(s)` for all s∈S, for some source-independent fixed sign σ∈{±1};
2. `χ_{a+b}(s)` is constant on S;
3. `a+b∈H^⊥`.

The sign is necessarily `σ=χ_{a+b}(s₀)`. Proof: divide the characters (same as multiply over ±1), evaluate at s₀ to fix σ, and test constancy on all differences s+s₀, which generate H. Thus `V/H^⊥` is the **coarsest quotient identifying exactly source-equivalent oracle characters up to fixed signs**, even when the source is nonuniform or not affine-uniform. Any different quotient that merges inequivalent classes changes at least one source-visible character and cannot preserve *all* phase-oracle projectors by this fixed-sign grouping.

For an arbitrary source law, exact circuit reduction and one-query representative access remain valid; **the T2 bound does not automatically transfer**, since the distribution of h may not be uniform on H and Walsh orthogonality can fail. Example: support S={0,e₀,e₁}⊂F₂² with the uniform *three-point* law has Eχ_{e₀}=1/3 rather than 0. The reduction identifies only deterministic equivalences, not a general correlated-distribution simulator. This separates representation validity from Fourier/measure assumptions.

The exact checker additionally tests all 16² pairs of four-bit labels on five support sets (singleton, affine, nonaffine and full-space cases), verifying all three character criteria and the fixed-sign formula; a deliberate nonaffine Walsh-orthogonality negative control passes. These tests are still finite, not a Lean proof.

**Novelty qualifier:** this maximality is elementary character-duality algebra, not claimed new prior art. Its operational value is an exact, support-aware preprocessing operator with zero extra oracle queries and an explicit failure boundary for source laws outside the uniform-affine setting.
