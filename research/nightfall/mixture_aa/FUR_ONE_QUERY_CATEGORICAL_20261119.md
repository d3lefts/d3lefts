# NIGHTFALL: arbitrary-alphabet M-independent crux for ONE quantum query
Version 0.1 — 2026-11-19. **Author-side proof reduction using cited classical results. Not Lean-certified or independently reviewed.**

## Executive status

A bounded degree-2 polynomial on a categorical product need NOT have universal fixed pointwise coordinate weights: the degree-two categorical selector in `FUR_Q2_GROTHENDIECK_BINARY_20261119.md` proves a no-go. However an **actual one-query coherent quantum algorithm DOES have such fixed weights**, regardless of alphabet size. Its query-index distribution is independent of the oracle input because no earlier oracle query has been made.

Combining this ordinary one-query quantum hybrid fact, **universal correlated sampling for categorical laws**, and NIGHTFALL's certified product mean-increment theorem yields an M-free latent-mixture crux for actual T=1 algorithms, arbitrary finite alphabets, zero atoms included.

This is a stronger scope in alphabets and a narrower scope in function realizability than the Boolean generic-degree-two theorem of the companion note. Do NOT conflate the two.

## External inputs and credit

1. Standard quantum hybrid / Born probability bound (Bennett–Bernstein–Brassard–Vazirani; existing NIGHTFALL `QuantumHybridTelescope` #914 and coherent-oracle work #912, with the physical norm instantiation still a Lean obligation).
2. Classical Kleinberg–Tardos/Holenstein **correlated sampling**, disagreement at most `2TV(P,Q)/(1+TV(P,Q)) ≤2TV(P,Q)`, via one common sampler applied to arbitrary finite alphabet distributions. See Bavarian, Ghazi, Haramaty, Kamath, Rivest, Sudan, *Optimality of Correlated Sampling Strategies*, Theory of Computing 16(12), 2020, https://www.theoryofcomputing.org/articles/v016a012/ . This result is known; do not claim novelty.
3. NIGHTFALL's existing source-product degree/mean-increment theorem (ports the Turturean argument); finite Shannon entropy chain rule and Pinsker (standard).

## Theorem Q1 (paper derivation): fixed pointwise influence weights for actual 1-query algorithms

Let `A` be a normalized quantum circuit with exactly one standard coherent symbol-value query on `x∈∏_i Σ_i`, and arbitrary input-independent unitaries and final two-outcome measurement. Let `f(x)` be its acceptance probability. Before the sole query, the query-index register has a fixed distribution `w_i≥0`, `Σw_i=1` (include an optional dummy coordinate if necessary).

The oracle difference acts **only on index blocks where `x_i≠y_i`** and has operator norm at most 2 on each. The pre-query states are IDENTICAL for x,y. Therefore

    ||ψ_x - ψ_y||₂ ≤ 2 sqrt(Σ_i w_i 1[x_i≠y_i]).

The final measurement is 2-Lipschitz on normalized states, so

    |f(x)-f(y)| ≤ 4 sqrt(Σ_i w_i 1[x_i≠y_i]),
    |f(x)-f(y)|² ≤16 Σ_i w_i 1[x_i≠y_i].               (Q1)

This holds for **every pair of input strings and any finite alphabets**, including zero source atoms. It is not a theorem about all degree-two categorical polynomials; the selector counterexample cannot generally be computed with one quantum query.

## Lemma C (paper derivation): one universal finite categorical coupling

For any finite family of categorical probability laws `p_theta` on the same alphabet, classical correlated sampling provides a **single shared random seed** `U` and mappings `h(theta,U)` such that, for ALL theta simultaneously:

    h(theta,U) ~ p_theta,
    Pr[h(theta,U) != h(theta',U)]
       <= 2 TV(p_theta,p_theta')/(1+TV(p_theta,p_theta'))
       <= 2 TV(p_theta,p_theta').

A direct common-seed construction uses Poisson processes of marked events `(time, a, u)` with intensity `dt,du`, and `h(p,U)` equals the alphabet letter of the first event whose mark u satisfies `u≤p(a)`. Accepted events at letter a have rate p(a); hence the first accepted letter has law p. For p,q, common accepted event rate is `Σ_a min(p(a),q(a))=1-TV`, while union accepted event rate is `1+TV`. If the FIRST UNION event is common, both procedures output the same letter, so agreement probability is at least `(1-TV)/(1+TV)`. The shared Poisson process does not depend on the pair.

For finitely many theta the **joint output tuple** `(h(theta,U))_theta` takes values in a finite alphabet power. Replace U by this finite tuple endowed with the induced joint law: the same pairwise mismatch rates remain exact, so the lifted space is a **finite product** even when the Poisson construction is used to justify existence. Choose U_i independently for distinct observable coordinates i.

## Theorem Q2 (paper derivation): the degree-two quantum mixture crux with no M/atom/alphabet loss

Let theta have an arbitrary finite prior pi; given theta, X_i are independent finite categorical laws p_{theta,i}. Define `G(theta,U)=f((h_i(theta,U_i))_i)`, where h_i is the above universal shared sampler. Then

- G has the same law as f under the mixture and is in [0,1].
- G has **global indicator-interaction degree ≤3** on theta plus the independent seed coordinates U_i: f has degree≤2 from the genuine one-query circuit, and the categorical theta indicator contributes at most one more coordinate.
- Each observable seed increment satisfies `pincr_{U_i}(G)=E_theta pincr_i^{p_theta}(f)` under the true original component sources.

Let `J_theta=E_{theta,theta',U}|G(theta,U)-G(theta',U)|`, `I_i=I(theta;X_i)` in nats, and `Imax=max I_i`. Jensen, (Q1), the shared categorical sampler, triangle inequality, and Pinsker imply

    J_theta² <= 16 Σ_i w_i E_{theta,theta'} Pr_U[h_i(theta,U_i)!=h_i(theta',U_i)]
             <= 32 Σ_i w_i E_{theta,theta'} TV(p_{theta,i},p_{theta',i})
             <= 32 sqrt(2 Imax),

because `E_{theta,theta'}TV(p_theta,p_theta')≤sqrt(2I_i)` with barycenter `bar p_i=E_theta p_theta`. Hence

    J_theta^4 <= 2048 Imax.                              (Q2)

Apply certified source-product mean-increment to G with degree 3 and row cost `K_3=9π²/2`. If `Var_nu f≥τ>0`, then some seed or theta coordinate has increment at least

    eta = τ^(3/2)/(12 K_3²) = τ^(3/2)/(243π^4).

Therefore some **original observable coordinate** i obeys either

    E_theta pincr_i^{p_theta}(f) >= g(τ)
    OR I(theta;X_i) >= g(τ),
    g(τ) = eta^4 / 2048 = τ^6 / [2048(243π^4)^4].         (Q3)

For τ≤1/4, g≤eta. This establishes a paper-level **M-independent one-query categorical** instance of the FUR/latent mixture crux, using two identified classical external results and existing NIGHTFALL product-AA inputs.

## Corollary (paper-level, still needing terminal verification): polylog-M classical simulation for one-query algorithms

At every posterior transcript, the restricted f remains an acceptance function of **at most one original symbol-oracle query** (fixing known input symbols in oracle gates, without increasing the quantum query count), so (Q3) applies to the current posterior mixture. Let

    Φ = E_posterior sum_j pincr_j^{p_theta}(f_section) <= K_2 = 2π²,
    H = Shannon entropy(posterior) <= ln M.

For a selected original input coordinate i, conditioning on its value lowers `E[Φ]` by the posterior mean increment, and lowers `E[H]` by `I(theta;X_i | transcript)`. Thus `Φ+H` is a nonnegative drift potential dropping by at least g(τ) at any transcript with conditional variance >τ. For a tree truncated at n queries,

    Pr[unfinished] <= (K_2+ln M)/(g(τ)*n).

On completed leaves, return the mixture conditional mean; Chebyshev costs ≤τ/ε² failure. Setting `τ=ε²δ/2` and

    n >= 2(K_2+ln M)/(δ*g(ε²δ/2))

gives `Pr_nu(|f-T|>ε)≤δ`. Hence worst-case classical **symbol-query depth**

    O((1+ln M) ε^{-12} δ^{-7})

with a universal constant, no alphabet-size or minimum-atom penalty. This is **only for T=1 actual quantum algorithms**, not arbitrary T or all categorical degree-two polynomials. Entropy-chain-rule, quantum restriction and exact tree-potential composition are paper arguments requiring non-author review and one named Lean terminal.

## Independent checks / objections and stop rule

- Implement an independent **exact Fraction** finite categorical correlated-sampler using an absorbing Markov chain of marked Poisson event types; verify its marginals for every component and its all-pair TV error `≤2TV/(1+TV)` including zero atoms. Check the weighted Q1 bound for phase-oracle one-query circuits `f(x)=(mean_i χ_i(x_i))²` with query weights `w_i=1/n`.
- Insist on **original source** conditional laws at every posterior transcript. The universal sampler must be the same for all theta for each observable coordinate; pairwise maximal couplings chosen independently for different theta-pairs do NOT suffice.
- Use information in nats; if bits, insert ln2 factors.
- Explicitly preserve the distinction: generic Boolean Q2 uses Grothendieck, arbitrary categorical T=1 uses query weights; categorical degree-two selectors disprove the naïve universal pointwise row.
- Check 2016 Aaronson–Ambainis–Iraids–Kokainis–Smotrovs quadratic Grothendieck result and correlated-sampling literature for priority; results may be known as corollaries. Any claim to a novel strong mixture theorem needs independent referee and same-day search.
- **Do not merge or publish** on an analytic draft plus a finite checker alone. Strict gate: exact replay, independent proof attack, source-specific Lean terminal, prior-art clearance, human signoff.

Provenance: NIGHTFALL original mixture-AA crux and existing product-space AA theorem; BBBV one-query hybrid; Kleinberg–Tardos/Holenstein categorical correlated sampling; finite entropy/Pinsker.
