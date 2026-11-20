# Independent proof attack: Route 1 reference-star coupling and the M-free crux (v1.0)

Date: 2026-11-19 · Reviewer: assistant-side mathematical audit of author proof at immutable Git commit `ac8b92df211b946bcd32cb6ed734ecb9b41368ee`, blob `198e843be77d946fbc88c80b88499ae06490270f`. **NOT an independent human/referee review, Lean kernel certificate, novelty clearance, or authorized publication.**

## Verdict and changes

**Key lemma: author proof survives an independent mathematical check, with a strictly simpler coupling.** The external Kleinberg–Tardos/Holenstein all-pairs correlated-sampling result is **not needed at all**: choose exact *pairwise maximal couplings to a common reference*, condition on that reference, and take their product. Because the proof compares each latent component only to the common reference, no simultaneous pairwise component-to-component guarantee is required.

The resulting key lemma needs only the already-certified **full fractional row** theorem, elementary maximal coupling, switching interpolation, and elementary KL/Hellinger inequalities. The separate product-block oscillation theorem is likewise avoidable. No FUR hypothesis, coordinate count, atom floor, mixture-size parameter, or unrestricted distributional row is introduced.

Important constants: `SWITCHING_FOOLING_20261119.md` proves a loose `8d² max_j q_j` from the *uncentered* `product_block_inequality`, whereas `ROUTE1_PROOF_20261119.md` writes `4d² max_j q_j` without mentioning the necessary affine rescaling `f -> 2f-1` for `[0,1]`-valued functions. The sharper constant is recoverable with that rescaling. **This audit instead proves a self-contained row-only switching lemma with constant `2K`**, valid for any f possessing full rows of cost K. Keep this normalization explicit in the author source.

## Theorem 1: exact finite *reference-star* maximal coupling

Let `Θ` and `Σ` be finite and `π` any probability on `Θ`, zero weights allowed. For every `θ` let `p_θ` be a distribution on `Σ`, and put `q = Σ_θ π_θ p_θ`. There is ONE finite probability space `U`, ONE common reference map `B:U->Σ`, and maps `Y_θ:U->Σ` such that, for every `θ` simultaneously,

`Law(B)=q`, `Law(Y_θ)=p_θ`, and
`Pr[B != Y_θ]=TV(p_θ,q)` **exactly**, including zero atoms.

**Constructive proof.** For fixed `θ`, define `r_θ(b)=min(q(b),p_θ(b))`, `q'_θ=q-r_θ`, `p'_θ=p_θ-r_θ`, and `t_θ=TV(q,p_θ)=Σ q'_θ=Σ p'_θ`. If `t_θ>0`, set the joint probability

`R_θ(b,y)=1[b=y] r_θ(b)+q'_θ(b)p'_θ(y)/t_θ`.

If `t_θ=0`, use `R_θ(b,y)=1[b=y]q(b)`. Both marginals are exact and the mismatch is `t_θ`: at every `b`, `p'_θ(b)q'_θ(b)=0`, so residual mass contributes no diagonal. For all `b` with `q(b)>0`, set the conditional kernel `C_θ(y|b)=R_θ(b,y)/q(b)`; for `q(b)=0`, choose any probability kernel (these `b` have zero reference mass).

Sample `B~q`; conditional on `B=b`, sample **all** `Y_θ` independently according to `C_θ(·|b)`. This produces one finite `U=(B,(Y_θ)_θ)` with all desired pairwise reference marginals. There is no all-pairs coupling requirement. Use independent such seeds `U_j` for different input coordinates `j`; `Θ` is sampled independently of all seeds.

For each original product component `μ_θ=⊗_j p_{θj}`, the map `h(θ,(u_j))=(Y_{θj}(u_j))_j` has law `μ_θ`. The reference map `h̄(u)=(B_j(u_j))_j` has the product of mixture marginals `q̄=⊗_j q_j`, and `Pr[Y_{θj} != B_j]=TV(p_{θj},q_j)`.

**Caution:** `Y_θ` and `Y_{θ'}` need not be pairwise maximally coupled. The proof requires only the triangle inequality via `B`; this is the key simplification.

## Theorem 2: row-only switching bound

Suppose `f:∏_j Σ_j->[0,1]` has a feasible **full pairwise** nonnegative row `a^z` of total cost at most `K` at EVERY input `z`. Put

`osc_j(z) = max_{b,c∈Σ_j}|f(z^{j<-b})-f(z^{j<-c})|`.

For any fixed `z`, the full row at `z` gives each
`|f(z^{j<-b})-f(z)| ≤ a^z_j`, hence `osc_j(z)≤2a^z_j`, and thus

`Σ_j osc_j(z)≤2K` **pointwise**.

If `(X_j,Y_j)` are independent over `j` (the pair within a coordinate may be arbitrarily coupled), and `q_j=Pr[X_j !=Y_j]`, assign independent continuous uniform switching times to coordinates. Conditioning on the switching time for `j`, the remaining coordinates are independent of the `j`-th mismatch event; `osc_j` depends only on the remaining coordinates. Telescoping the jumps and averaging yields

`E|f(X)-f(Y)| ≤Σ_j q_j∫_0^1 E osc_j(Z_t)dt ≤2K max_j q_j`.

The switching times appear only in a PAPER argument, not in the eventual finite seed space to which product AA is applied; they can also be replaced by a uniform random permutation of the n coordinates for a completely finite switching proof.

**Discrete permutation alternative (requires an explicit beta-binomial averaging identity):** choose a uniformly random permutation `σ` of coordinates and switch them successively. For fixed `j` and a subset `S⊆[n]\\{j}`, the probability that precisely S precedes j is `|S|! (n-1-|S|)!/n! = ∫_0^1 t^{|S|}(1-t)^{n-1-|S|}dt`. Consequently the law of the other coordinates just before switching j is a common mixture, over `t∈[0,1]`, of coordinatewise Bernoulli-t switches. Because `osc_j` ignores coordinate j, summing over j may be done at a COMMON fixed t, where `Σ_j osc_j(Z_t)≤2K` pointwise. Independence of the j-th pair from other coordinate pairs gives the mismatch factor `q_j`. The integration identity can alternatively be proved by factorial counting; the switching experiment itself uses only a finite permutation. Merely saying “uniform random permutation” without this common-mixture identity would not justify interchanging the sum and the pointwise row bound.

## Theorem 3: strengthened M-free label fooling

At a mixture posterior with `q_j=Σ_θ π_θ p_{θj}`, define

`I_j=I(Θ;X_j)=Σ_θ π_θ KL(p_{θj}||q_j)`, `I_* = max_j I_j`,
`φ_{θj}=arccos(Σ_b sqrt(p_{θj}(b)q_j(b)))∈[0,π/2]`.

By Jensen's inequality and `-log t≥1-t`,
`KL(p||q)≥-2log BC(p,q)≥2(1-BC(p,q))`, with infinite KL handled by approximation/extended reals. Elementary `φ≤π sin(φ/2)` gives
`φ²≤(π²/2)(1-BC)≤(π²/4)KL(p||q)`.
Further `TV(p,q)≤sqrt(1-BC²)=sin φ≤φ`.

Fix any `0<η≤1`, and set deterministic `L_θ={j:φ_{θj}>η}`.
With the exact star seed, put `B=h̄(U)`, `Y=h(θ,U)`, and `Z_j=Y_j` if `j∈L_θ`, `Z_j=B_j` otherwise.

Large part: `|f(B)-f(Z)|≤Σ_{j∈L_θ}a_j^B`. Conditional on `U`, the reference B and row a^B are **θ-independent**. Therefore
`E_{θ,U}|f(B)-f(Z)|≤K max_j Pr_π[j∈L_θ]≤K π² I_*/(4η²)`.

Small part: conditional on each θ, the pairs `(Z_j,Y_j)` are independent over j, and their mismatch probabilities vanish on L_θ and otherwise equal `TV(p_{θj},q_j)≤φ_{θj}≤η`. The row-only switching bound gives
`E_U|f(Z)-f(Y)|≤2Kη`.

Hence the improved, fully finite **M-free reference-star lemma**:

`E_{θ,U}|f(h(θ,U))-f(h̄(U))| ≤ K[(π²/4)(I_*/η²)+2η]`.

If `0<I_*≤1` choose `η=I_*^{1/3}` to obtain
`≤C_K I_*^{1/3}`, with `C_K=K(π²/4+2)`.
If `I_*=0`, every positive-weight component marginal equals its reference and star coupling makes `Y=B` a.s., so the difference is exactly zero. If `I_*>1`, use the trivial `|f(y)-f(b)|≤K`, which is at most `C_K I_*^{1/3}`. Thus the cube-root bound holds for ALL `I_*≥0` and no minimum atom mass. This theorem needs no low-degree assumption beyond the existence of the full rows; the degree is used to obtain the row in the mixture-AA application.

### What this does, and does NOT, prove

- The key lemma is now a mathematical derivation with explicit finite seed and no correlated-sampling external hypothesis.
- The product-space AA theorem for the lifted `G(θ,U)=f(h(θ,U))` is *separate*: from an algebraic interaction expansion of f supported on `|S|≤d`, each lifted term depends only on `θ` and `U_S`, so algebraic degree is at most `d+1`. The proof must connect this **exact finite seed distribution** to the precise finite/infinitePi Efron–Stein degree interface in Lean.
- For `f∈[0,1]`, `Inf_c(G)≤(1/2)E|G-G^{(c)}|`. Product AA with variance ≥τ and degree D=d+1 gives `Inf_c(G)≥γ(τ,D)=sqrt(3 τ^5/12500)/(π²D²)^3`. For a seed coordinate this forces `E_π L_j^{μ_θ}(f)≥2γ`. For the label, a triangle through the reference gives `E|G(θ,U)-G(θ',U)|≤2C_KI_*^{1/3}`, hence `I_*≥(γ/C_K)^3`.
- The within-component potential `Φ=E_π Σ_j L_j^{μ_θ}(f)` obeys `0≤Φ≤K` **directly from the full rows**: resampling coordinate j at a fixed x has absolute increment ≤a_j^x, and sum rows ≤K. After querying coordinate j, exact tower/Fubini with zero-probability branches deleted gives `E[Φ_child]=Φ_parent-E_π L_j`, because the queried coordinate becomes deterministic within every surviving component and all other terms average back.
- Posterior entropy `H(π)=-Σ_θ π_θ log π_θ` has `0≤H≤log M`, with `0log0:=0`. Its exact expected query decrease is `I(Θ;X_j)`. For zero-probability observations, simply omit the zero-weight child; for a posterior weight π'_θ=0 define the component section arbitrarily (its weighted contribution is identically zero).
- At a live node define `γ=γ(τ,d+1)`, `κ=(γ/C_K)^3`, and the nonnegative combined potential `Z=Φ/(2γ)+H/κ`. A seed-increment or information query decreases `Z` by ≥1 in conditional expectation. Thus the expected number of queries until `Var_ν(f)≤τ` is at most `K/(2γ)+(C_K/γ)^3 log M`. Cap at depth `ceil(2 Ebound/δ)` and choose `τ=ε²δ/2`. Conditional Chebyshev and Markov on the stopping time yield total failure ≤δ, including at zero-posterior branches.
- This yields `O((d^8 τ^{-5/2}+d^{24} τ^{-15/2} log M)/δ)` for d≥1, as claimed up to safe constants. **The final deterministic decision-tree theorem is still only paper-level** until a named end-to-end Lean terminal and independent referee review are obtained.

## Adversarial attack checklist and results

1. **Correlated sampling / zero atoms:** no simultaneous pairwise component coupling required; reference-star exact maximal kernels work even with zero atoms and posterior-zero labels. Exact Fraction checker: 240 fixtures, 1,165 component-reference pairs, 132 zero-weight component values.
2. **Potential at zero branches:** exact original-law mean-increment query decrement independently replayed for 458 coordinate queries; 65 zero-predictive-mass observations excluded without renormalizing them into phantom branches.
3. **Row dependence on mismatch:** the large-angle set is deterministic in θ and does not depend on U, so the reference row a^B is independent of θ conditional on U; small-angle switching uses only mismatch probabilities, not correlated row weights.
4. **Degree/Lean interface:** **OPEN integration gate.** The published `Nightfall.InfinitePiAAProductTerminal.infinitePi_aa_product` statement is an `Lp` theorem for `ESDegreeLE`, not a lemma directly for the finite combinatorial `HasProdDegreeLE` of the lifted label/seed function. Need explicit finite distributions as measures, the mixed heterogeneous label/seed types, and the source-Lp degree equivalence. No compiler receipt is provided here.
5. **Published strong theorem / prior art:** the external 2026 GMNR paper `arXiv:2609.35327` treats fixed-biased products/slices, and BDST `arXiv:2608.19158` treats bounded-round quantum algorithms; neither abstract claims a full polylog-M simulation theorem. A limited 2026-11-19 search found no exact predecessor, but **this is not a dated comprehensive novelty clearance**. Existing mixture-learning and mixture-TV literature has different objectives. The key lemma's star-coupling is a standard maximal-coupling construction, not itself a claim of novelty.
6. **Independent reviewer:** this is an assistant-side attack plus independent code. NO unaffiliated human referee, external Lean formalization, or human novelty sign-off. Do not label an external review completed.

## Reproduction

`python3 -I research/nightfall/mixture_aa/check_route1_star_coupling_exact.py`

The checked script is independent of the proposed proof implementation: it uses exact `fractions.Fraction` probabilities, direct residual maximal-coupling tables, original-law independent resampling and an independent posterior reconstruction for all positive-predictive-probability children. No numerical optimizer, floating tolerance, or entropy logarithm is used to certify its exact algebraic claims. Recorded tested seed: `20261119`, source SHA256 when initially run locally: `3313881ead40f997a8302d83193193062e789a2bc75bce72a87ec9be984dcca9` (recheck after repository transcription). Output is a finite regression, never a universal proof.

## Outstanding decision

Mathematically the **key lemma and full Route 1 paper argument look sound under the stated abstract product AA and row theorems**, with the repaired finite star coupling. Do not promote Route 1 to *Lean-certified*, *peer-reviewed*, *novel contribution*, or *breakthrough* until (i) full named kernel theorem/assumption interface is inspected, (ii) an independent human/agent adversarial proof review agrees, (iii) latest same-day literature audit and attribution are completed, and (iv) consequences are separately checked. No publication/submission authorization is inferred.
