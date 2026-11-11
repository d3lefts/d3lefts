# Cubic shared-rare-core: unbounded failure of the independent fourth-moment step

**NIGHTFALL / 11 November 2026.** Status: exact analytic counterexample to a proposed *proof step*. It is **not** a counterexample to cubic Aaronson–Ambainis exponent two; no worldwide originality claim is made.

## Testable false hypothesis

The successful arbitrary-law quadratic matching method uses independent, centered Hilbert increments `Y_j` of norm at most `c`, with `s = E ||sum_j Y_j||^2`, to prove

    E ||sum_j Y_j||^4 <= c^2 s + 3 s^2.                         (F4)

It is tempting to reuse (F4) for cubic hyperedges after a greedy matching assignment, using only centeredness, pairwise L2-orthogonality and a per-hyperedge envelope. This is **false**, by an unbounded factor, even when the increments arise from a bounded pure cubic on an independent product law.

## Exact family

For every integer `m>=2` and `0<p<1`, let `X_0,Z_1,...,Z_m` be independent fair signs and `A~Bernoulli(p)` independent. Put `Y=A-p`, `S=sum_{j=1}^m Z_j`, and

    f_m(X_0,A,Z) = X_0 * (A-p) * S / m.

We have `|f_m| <= 1-p <= 1`. The Fourier/Hoeffding decomposition has exactly the degree-three hyperedges `{X_0,A,Z_j}`, with component `h_j=X_0(A-p)Z_j/m`. All lower-order terms vanish.

Assign all hyperedges to vertex `X_0`. In the Hilbert section space `H_0=L^2(X_0)`, the assigned increments are `T_j(x_0)=x_0(A-p) Z_j/m`. They are centered, pairwise orthogonal in `L^2(A,Z;H_0)`, and have `||T_j||_{H_0} <= c=(1-p)/m`. However, they share the rare coordinate `A`, hence are not independent.

Let `v=p(1-p)`, `t=(1-p)^3+p^3`. The exact second and fourth moments of the fair-sign sum are `E S^2=m`, `E S^4=3m^2-2m`; the centered Bernoulli moments satisfy `E Y^2=v`, `E Y^4=v t`. Therefore

    s = E ||sum T_j||^2 = v/m,
    L = E ||sum T_j||^4 = v*t*(3*m-2)/m^3,
    U = c^2*s + 3*s^2 = v*((1-p)^2 + 3*v*m)/m^3,
    R(m,p) = L/U = t*(3*m-2)/((1-p)^2+3*p*(1-p)*m).

At `m=16, p=1/64`, `R=179722/6993 = 25.700272... >1` exactly. Setting `p=m^{-2}` gives `R(m,m^{-2})/m -> 3`, so there is **no universal constant** `C` such that `L <= C(c^2*s+3*s^2)` under just centeredness, pairwise orthogonality and uniform increment bounds.

This witness remains a perfectly valid bounded cubic: its variance and maximum squared-resampling influence both equal `p(1-p)/m`, so it satisfies any weak variance-squared lower bound. It disproves only the unjustified reuse of the independent-increment fourth-moment lemma.

## Mechanism / next operator

The rare core `A` makes conditional increment variance random. Conditional on `A`, the `Z_j` increments *are* independent; integrating their fourth moments introduces `E_A[s(A)^2]`, not `(E_A s(A))^2`. Replacing the former with the latter is precisely the invalid transfer. The missing mechanism must control or charge this *variance-of-conditional-energy* term, possibly using the influence of the shared core (a top-degree cover, as in PR #335) or a link-energy inequality (open in PR #349). Neither repair is proved here.

## Checker and provenance

Run `python3 check_cubic_shared_core.py` (Python standard library only). It computes `E S^2` and `E S^4` independently by exact binomial enumeration, verifies the fixed rational witness and tests six members of `p=m^{-2}`. Passing the finite checker does not itself prove the asymptotic limit; the displayed closed formula does. The coefficient is not an empirically optimized constant.

Prior sources checked this session: Turturean arXiv:2611.09773; Escudero Gutiérrez arXiv:2304.06713; NIGHTFALL draft PRs #335, #347, #349, #350 and quadratic PR #375. This is a within-program *proof-attack* checkpoint only; it does not establish worldwide novelty.
