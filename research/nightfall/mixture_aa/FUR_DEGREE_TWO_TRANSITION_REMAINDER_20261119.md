# Degree-two FUR: bounded transition remainder

NIGHTFALL research checkpoint, v1.0 (2026-11-19).
**Status: author-side mathematical derivation, NOT Lean-certified, independently peer-reviewed, or novelty-cleared.**

## Goal and starting reference

Target: fiber-uniform fractional certificate rows (FUR) for globally [0,1]-bounded functions of indicator interaction degree <=2 on arbitrary finite alphabets, including symbols with zero input probability.

Existing source checked this session: Nightfall.ProductSpace.RowBound.product_row_bound in research/nightfall/formalization/product_space/ProductRowBound.lean, giving at every anchor a nonnegative row with sum <= pi^2*d^2 for any degree-d function bounded in [-1,1] on an arbitrary finite alphabet. This depends on Turturean's row/packing proof and Lovett–Zhang's fractional-certificate ideas. The existing theorem does NOT itself assert fiber-uniformity.

## Candidate theorem (degree TWO only)

For finite nonempty alphabet A, finite coordinate set I, and f:A^I -> [0,1] of indicator degree <=2, there exist nonnegative weights a_i(x_-i), independent of x_i, satisfying

    |f(x)-f(y)| <= sum_{i:x_i != y_i} a_i(x_-i)
    sum_i a_i(x_-i) <= C2 = 8 + 16*pi^2 < 166

for ALL x,y. No product law is needed to define the rows.

### 1. Own-coordinate-independent oscillations

Define v_i(x_-i)=max_{a,b in A}|f(x[i:=a])-f(x[i:=b])|.

At any x set U_i=max_a(f(x[i:=a])-f(x)) and V_i=max_b(f(x)-f(x[i:=b])). Then U_i,V_i>=0 and v_i=U_i+V_i. Choose maximizing/minimizing replacement letters per coordinate. Independently switch all coordinates from x to the chosen replacements with probability s in [0,1]. The two interpolated expectations q_+(s),q_-(s) belong to [0,1] and have real polynomial degree <=2. Their derivatives at zero are sum U_i and -sum V_i. Endpoint Markov on [0,1] for a [0,1]-valued degree-2 polynomial gives |q'(0)|<=4, by the change p(t)=2q((t+1)/2)-1 and standard |p'(-1)|<=2^2. Thus

    sum_i v_i(x_-i) <= 8  uniformly in x.

### 2. The exact quadratic mixed-difference identity

Fix an arbitrary reference word r. For i!=j define

    D_ij(a,b;c,d) =
       f(r[i:=b,j:=d]) - f(r[i:=a,j:=d])
       - f(r[i:=b,j:=c]) + f(r[i:=a,j:=c]).

This D_ij is independent of r outside {i,j}, because applying two differences kills every degree<=2 indicator monomial except monomials supported on {i,j}. Consequently, for S={i:x_i!=y_i}, the monomial expansion gives EXACTLY

    f(y)-f(x)
      = sum_{i in S}(f(x[i:=y_i])-f(x))
        + sum_{i<j in S} D_ij(x_i,y_i;x_j,y_j).

The last term is the quadratic remainder. Its **independence of unchanged coordinates** is essential.

### 3. A bounded degree-2 function on a larger finite alphabet

Define transition alphabet T={bottom} disjoint-union {(a,b):a,b in A,a!=b}; and H:T^I -> R by

    H(t)=sum_{i<j, both active} D_ij(t_i.old,t_i.new;t_j.old,t_j.new).

Then H(bottom^I)=0 and H has indicator degree<=2 (each term uses only two transition coordinates).

**Key pointwise bound: |H(t)|<=4 for every t.** For a fixed t, form endpoint words u,v by using old/new symbols on active coordinates and r on inactive coordinates. Restrict f to the Boolean corner cube h(s), with each s_i in {-1,+1} choosing u_i or v_i. It is [0,1]-bounded and Fourier degree<=2:

    h(s)=c + sum_i L_i s_i + sum_{i<j} b_ij s_i s_j.

Each D_ij=4*b_ij (zero for inactive coordinates). Hence

    H(t)=4 sum_{i<j} b_ij
        =4 * ((h(+1)+h(-1))/2 - E_uniform h).

Both quantities in parentheses are in [0,1], so |H(t)|<=4. Equivalent exact identity: H(t)=2(f(u)+f(v))-4 E_corner f.

Apply the EXISTING source-pinned product-row theorem at the SINGLE anchor bottom^I to g=H/4, degree<=2 and bounded [-1,1]. It supplies nonnegative CONSTANT c_i (independent of any x), with

    sum_i c_i <= 4 * (pi^2*2^2) = 16*pi^2,
    |H(t)| <= sum_{i:t_i!=bottom} c_i.

### 4. FUR assembly

Set a_i(x_-i)=v_i(x_-i)+c_i. For x,y, choose t_i=(x_i,y_i) only at differing coordinates, bottom elsewhere. By the independence of D_ij from unchanged coordinate values, H(t) is EXACTLY the Taylor remainder in Step 2. Thus

    |f(y)-f(x)|
      <= sum_{i in S} v_i(x_-i) + |H(t)|
      <= sum_{i in S} a_i(x_-i).

The total row budget is <=8+16*pi^2. This is a paper-level proof with one already-certified ordinary-row theorem as input; the new cross-alphabet composition remains to be checked by Lean and independent mathematical review.

## Product-source transport: Lemma R at degree two

Given reference product P=otimes_i p_i define w_i=E_{X~P} a_i(X_-i), so sum_i w_i<=C2. For ANY other product Q=otimes_i q_i, independently maximally couple each coordinate pair (X_i,Y_i). Then P(X_i!=Y_i)=TV(p_i,q_i), and this mismatch event is INDEPENDENT of a_i(X_-i). Therefore

    |E_Q f - E_P f| <= sum_i w_i TV(p_i,q_i).

These weights depend only on f and reference P, not on target Q. Zero atoms are allowed, and no likelihood-ratio denominator is used.

For mixture nu=sum_theta pi_theta mu_theta, put pbar_i=sum_theta pi_theta mu_theta,i, Pbar=otimes_i pbar_i, m_theta=E_mu_theta f, and B=Var_pi(m_theta). By the same fixed w_i, Cauchy–Schwarz, and finite Pinsker (natural logs),

    B <= (C2^2 / 2) * max_i I(Theta;X_i).

This is ONLY the between-component half of the Mixture-AA crux. The M-independent within-component increment alternative and the resulting polylog-M simulator remain open.

## Independent adversarial regression and boundary

Companion script check_fur_degree_two_exact.py passed **73,633** exact rational assertions: random quadratic functions with (n,alphabet)=(3,3),(4,2),(5,2), 12 seeds per family; exact quadratic Taylor identity, own-fiber invariance, Fourier formula and |H|<=4, sum v_i<=8, original product-law TV transport with zero masses, and a deliberately invalid cubic generalization.

**Cubic counterexample:** f(x)=x_0*x_1*x_2, r=000, x=(0,0,1), y=(1,1,1). The actual remainder after changing coordinates 0 and 1 is 1, while D_01 at fixed r is 0. A naive all-degree version would require activating coordinates where x_i=y_i and would lose the fiber claim. Therefore DO NOT claim general FUR from this argument.

The checker uses c_i=4 as a **finite n<=5 regression convenience only**. This does not establish any n-independent row budget: the analytic bound depends on RowBound.product_row_bound. Finite exact testing also does not substitute for the higher-alphabet Lean theorem.

## Claude handoff: actual kernel obligations

1. mixed_difference_other_coords_independent: prove using indicator monomials HasProdDegreeLE f 2; test all symbol orientations.
2. quadratic_taylor_exact: use linearity of the monomial basis; no hidden cubic cancellation assumption.
3. transition_remainder_degree_two and transition_remainder_bound_four: auxiliary Option (alpha × alpha) alphabet; Fourier projection on binary corners.
4. fiber_oscillation_budget_eight: derive from exact source endpoint Markov bound with [0,1] normalization.
5. degree_two_fiber_uniform_row: instantiate RowBound.product_row_bound 2 (H/4) at all-bottom. Print complete axioms, exact Lean source SHA, and pinned CI.
6. degree_two_product_transport_tv: construct finite independent maximal coupling with zeros, rather than assuming mismatch independence.
7. degree_two_between_component_info: finite Pinsker and KL support edge cases; keep the full mixture crux explicitly open.
8. Independent adversarial proof review and dated prior-art search (especially Lovett–Zhang ITCS 2023, ITCS 2026 fractional-certificate strengthening, and Turturean).

**Stop rule:** if a step fails Lean or an exact counterexample appears, retract the claimed inequality and retain the failure witness. Next cheapest decisive test: a separately authored kernel proof or a counterexample to Step 3's uniform |H|<=4 and its monomial-degree statement. Novelty and breakthrough status are NOT established.

Discovery graph: mixture-M dilution -> source-independent transport -> own-fiber local oscillations + bounded quadratic transition remainder -> anchored ordinary certificate -> candidate FUR(2) -> exact regression -> Lean and human audit pending -> between-component mutual-information transfer.