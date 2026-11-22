# Independent audit of PR #995: continuous causal real phase retrieval needs 2n − 1 readings

*Auditor: Claude, a non-author of #995. 2026-11-22. Audited source: branch
`research/continuous-causal-phase-product-bu-20261122` at `03602051`, file `PROOF_PASSPORT.md` v0.2.
Probe: `independent_audit_probe.py`, written independently of `phase_collision_probe.py`.*

## Verdict

**The argument is correct.** I checked every step of §§1–5 line by line and found no gap. The
topological zero (§3) is a standard consequence of classical facts. The reachable-history bridge (§4)
is sound. The collision induction (§5) is exact. Subject to the usual further gates (Lean, a specialist
referee, priority), the theorem stands:

> **Theorem.** Let n ≥ 2. Consider a causal protocol of length m whose rows a_j depend continuously on
> the attainable previous transcript. If m ≤ 2n − 2, there are unit vectors u, v with
> T_m(u+v) = T_m(u−v). Hence m_cont(n) = 2n − 1. In particular m_cont(4) = 7.

There are three items below: small corrections (§A), a strictly more general theorem with the same
proof (§B), and a remark that answers the flagship memo's worry about "compact-cone embedding" (§C).
The prior-art position is in §D and a proposed Lean route in §E.

## Step-by-step check

**§1, model.** Consistent. The norm bound ‖a_j‖ ≤ 1 is unnecessary: the scale of a row only rescales
the reading. It can be dropped, together with the optional radial projection in §4. A zero row is
allowed and harmless.

**§2, virtual history.** I checked the induction directly.
- If h_{j−1} is invariant under u ↦ −u and v ↦ −v separately, then so is b_j = ã_j(h_{j−1}).
- At a U-stage, the appended entry (b_j·v)² is invariant, and g_j = b_j·u is odd in u and even in v.
- The V-stage is symmetric.
- Continuity of g in (u, v) follows from continuity of the extended rows ã_j and of squaring.

**§3, topological zero.** Let G = (ℤ/2)² act on S^{n−1} × S^{n−1} by separate antipodes. Let G act on
ℝ^r ⊕ ℝ^s by the characters (ε₁, ε₂) ↦ ε₁ on the first block and ε₂ on the second.
1. An equivariant map g is the same thing as a section of
   (S × S × (ℝ^r ⊕ ℝ^s))/G = L_U^{⊕r} ⊕ L_V^{⊕s} over B = ℝP^{n−1} × ℝP^{n−1}. Here L_U and L_V are
   the pullbacks of the tautological line bundles, because G acts on each block through the
   corresponding character.
2. By the Whitney product formula (Milnor–Stasheff §4), w_m(E) = w₁(L_U)^r·w₁(L_V)^s = α^r β^s.
3. By Künneth, H*(B; 𝔽₂) = 𝔽₂[α, β]/(αⁿ, βⁿ). So α^r β^s ≠ 0 exactly when r, s ≤ n − 1, which the
   colouring guarantees.
4. A bundle with a nowhere-zero section splits off a trivial line, so its top Stiefel–Whitney class
   vanishes (Milnor–Stasheff, Prop. 4.8). Hence g has a zero.

The representation-to-bundle link, the only point the passport flagged as unaudited, is item 1, and
it is correct as stated. Equivalently, this is the Fadell–Husseini index computation for separate
antipodal actions.

**§4, reachable-history bridge.** Correct.
- T_j is continuous on ℝⁿ: it composes continuous maps, since a_j is continuous on H_{j−1} with the
  subspace topology and T_{j−1} maps into H_{j−1}.
- So H_j^K = T_j(K) is compact, hence closed in ℝ^j.
- Tietze extends each coordinate of a_{j+1}|_{H_j^K}.
- Agreement on K follows by induction: for x ∈ K, T̃_j(x) = T_j(x) ∈ H_j^K, where ã_{j+1} = a_{j+1}.
- Nothing requires the full attainable set to be closed. This is the right fix for the danger of
  evaluating a policy at an unreachable virtual history.

**§5, collision induction.** Exact. At the zero, both true histories equal h_{j−1}, so both signals
use the row b_j. At a U-stage b_j·u = 0, and (b_j·(u ± v))² = (b_j·v)², which is the virtual entry.
For non-equivalence, x₊ − x₋ = 2v and x₊ + x₋ = 2u, both nonzero. The degenerate zero x₊ = 0 is
allowed and still gives a valid collision, between 0 and 2u.

**Edge cases.**
- n = 2: m ≤ 2 forces r, s ≤ 1, giving m_cont(2) = 3. This is consistent with #695, since n + 1 = 3.
- r = 0 or s = 0 is covered.
- Zero rows are covered.

## §A. Suggested textual corrections (no change to the mathematics)

1. Drop ‖a_j‖ ≤ 1 and the radial projection, or keep them but state that they are cosmetic.
2. In §3, replace "classical standard zero theorem for product spheres" with the four-line argument
   above and cite Milnor–Stasheff, *Characteristic Classes*, §§4, 6. The Chan–Chen–Frick–Hull citation
   is context, not a dependency.
3. State explicitly that x₊ = 0 or x₋ = 0 may occur at the zero and that the conclusion is unaffected.

## §B. A strictly more general theorem, with the same proof

**Theorem B.** Suppose stage j reads y_j = Φ_j(h_{j−1}, B_j(h_{j−1})x), where:
- B_j is a continuous k_j × n matrix-valued function of the attainable history;
- Φ_j is continuous;
- Φ_j is even in its second argument: Φ_j(h, −z) = Φ_j(h, z).

If the stages can be split into two groups, U and V, each with total rank Σ k_j ≤ n − 1, then there are
unit vectors u, v with identical transcripts for u + v and u − v. A greedy split shows this happens
whenever Σ_j k_j ≤ 2n − 1 − max_j k_j.

*Proof.* The proof is the same, with three changes.
1. At a U-stage put g_j = B_j(h)u ∈ ℝ^{k_j} and append Φ_j(h, B_j(h)v) to the virtual history.
2. Evenness gives Φ_j(h, B(u ± v)) = Φ_j(h, ±Bv) = Φ_j(h, Bv) at a zero.
3. The bundle becomes L_U^{⊕Σ_U k} ⊕ L_V^{⊕Σ_V k}.

For §4, extend Φ_j from the closed set H^K × ℝ^{k_j} by Tietze, then symmetrise in z to restore
evenness without changing the original values. ∎

This covers:
- the squared readings of #995;
- the even responses of the passport's §7, including |b·x|, saturating detectors and
  history-dependent nonlinearities;
- block intensity measurements ‖B(h)x‖² with continuously chosen rank-k blocks.

My probe tests Theorem B with mixed ranks (2, 1, 2, 1, 2) and (2, 2, 1, 2, 1) at n = 5, and with a
non-polynomial even Φ.

Caveat: if the blocks are specified as continuously varying *projections* P(h) rather than matrices,
the image bundle can be twisted and the top class need not be α^r β^s. Specify blocks by matrices.

## §C. The bound uses the sequential rank-one structure, not just topology

The flagship memo asks that the compact-cone embedding argument be kept separate from a genuinely
quadratic-causal lower bound. Here is why that separation is real.

The composite transcript x ↦ T_m(x) is a continuous even map ℝⁿ → ℝ^m. However, unrestricted
continuous even maps injective modulo ± need fewer outputs in general. For n = 4, ℝP³ ≅ SO(3) embeds
in ℝ⁵ (Hantzsche 1938). An even map e : S³ → ℝ⁵ inducing that embedding gives

x ↦ (‖x‖, ‖x‖·e(x/‖x‖)),

a continuous even map ℝ⁴ → ℝ⁶ that is injective modulo sign. So 6 outputs suffice topologically, while
continuous causal phase retrieval needs 7.

The 2n − 1 bound is therefore not an embedding-dimension statement. It comes from each reading being
an even function of a rank-one (or rank-k) projection of x, chosen continuously. More generally, the
same construction separates the two quantities whenever ℝP^{n−1} embeds in ℝ^{2n−3}. That is known for
many n; it fails when n − 1 is a power of two. Cite the exact embedding results before using this
beyond n = 4.

## §D. Prior art (dated, scope-level)

- **Ullrich, "A Borsuk–Ulam theorem for adaptive continuous measurements," arXiv:2610.33781
  (24 Oct 2026).**
  - Model: each functional is continuous in x, but the next functional may depend *arbitrarily* on
    previous outputs.
  - Result: 2^n ≥ m + 1 for distinguishing antipodes on S^{m−1}.
  - Phase retrieval and product-sphere (ℤ/2)² arguments are not discussed.
  - Relation to #995: a different model. #995 requires continuous dependence on the history and gets
    a linear, sharp count.
- **Krieg–Novak–Ullrich**, PAMS (to appear) and Forum Math. Sigma 2025: adaptivity with continuous
  measurements can give exponential speed-ups. #995 shows the opposite phenomenon for phase retrieval
  once the *row choice* must be continuous.
- **Fixed real frames:** 2n − 1 is necessary and sufficient (Balan–Casazza–Edidin 2006, via the
  complement property). #995 is exactly the continuous-adaptive lift of the complement-property
  argument, with topology replacing the linear-algebra split.
- **Headline:**
  - discontinuous adaptivity gives n + 1 (#695);
  - continuous adaptivity gives 2n − 1, no better than fixed frames.
  - So the entire adaptive saving of n − 2 readings is attributable to discontinuity.

  I found no source stating this. The search was limited, not a specialist review.

## §E. Suggested Lean route

Mathlib has Tietze extension but neither Stiefel–Whitney classes nor product Borsuk–Ulam. The
cheapest honest certificate has three parts.
1. Formalize §§2, 4, 5 and Theorem B in full: the virtual history, the parity induction, the Tietze
   bridge and the collision.
2. Take the §3 zero theorem as one named, explicitly stated hypothesis `ProductBUZero n r s`, so the
   conditional theorem is `ProductBUZero n r s → m_cont(n) ≥ 2n − 1`.
3. Separately, prove `ProductBUZero` for r = 1 or s = 1 from ordinary Borsuk–Ulam when that lands in
   Mathlib. The general case needs mod-2 cohomology of ℝP^a × ℝP^b.

## Probe results (`independent_audit_probe.py`, float64 solve, 80-bit transcript recheck)

| n | ranks | Φ | colouring | virtual residual | actual-transcript discrepancy |
|---|---|---|---|---|---|
| 3 | 1,1,1,1 | square | UUVV | 1.3e-16 | 1.3e-16 |
| 4 | 1×6 | square | UUUVVV | 6.7e-16 | 6.5e-16 |
| 5 | 1×8 | square | UUUUVVVV | 7.2e-16 | 1.8e-16 |
| 4 | 1×6 | cos(z²) + \|z\|³ | UUUVVV | 3.2e-16 | 1.2e-16 |
| 5 | 2,1,2,1,2 | ‖z‖² | UUVUV | 4.9e-16 | 7.8e-16 |
| 5 | 2,2,1,2,1 | non-polynomial even | UUVVV | 7.0e-15 | 1.2e-14 |

The policies are random tanh networks of the full history. The discrepancy is relative.

Negative control: for n = 3 and 4 with m = 2n − 1 and a fixed generic frame, every U/V split has a
full-rank block, so no virtual zero exists.

These runs are numerical evidence only. mpmath could not be installed in the audit environment, so the
transcripts were rechecked in np.longdouble rather than 60-digit arithmetic.
