# Two-draw leaf scalarization: an unbounded expected-maximum obstruction

**NIGHTFALL proof attack, 11 November 2026 UTC.** Status: exact analytical counterexample to a *proposed proof operator*, not to the universal cubic variance-squared influence conjecture. Common occupancy asymptotics are classical; no standalone global novelty claimed.

## The tempting but false step

For a generalized quadratic selector f(X,Y)=sum_i g_i(X,Y_i), independently draw two full symbols Y_i^+,Y_i^- at each leaf and construct a bounded fair-sign selector with scalar control coefficients

    h_i(X)=[g_i(X,Y_i^+)-g_i(X,Y_i^-)]/2.

The old scalar/fair-sign theorem holds for each fixed pair draw. However, deriving a dimension-free theorem for original arbitrary leaves by averaging would need something like

    E_pairs[ max_j sum_i I_j^X(h_i) ] <= C * max_coordinate I_coordinate(f)

with absolute C. **This inequality is false**, even for bounded functions of total Hoeffding degree two and fair-sign controls.

## Exact counterexample

For every n>=2, let X_1,...,X_n be independent fair signs, and let Y_i=(J_i,e_i), i=1,...,n, be independent leaves, where J_i is uniform in [n] and e_i is an independent fair sign. Define

    f_n(X,Y) = (1/n) sum_{i=1}^n e_i X_{J_i}.

Its expansion sum_{i,j} n^(-1) e_i 1_{J_i=j} X_j shows deg(f_n)<=2. Also |f_n|<=1. Independence gives the exact identities

    Var(f_n)=1/n,
    I_{Y_i}(f_n)=1/n^2   for every i,
    I_{X_j}(f_n)=1/n^2   for every j.

Thus M=1/n^2=Var(f_n)^2: this is a sharp *positive* example for the desired exponent two.

Now sample each leaf twice independently: (J_i^+,e_i^+) and (J_i^-,e_i^-). Let

    h_i(X)=(e_i^+ X_{J_i^+}-e_i^- X_{J_i^-})/(2n).

For a fixed pair draw, define the control trace influence of the vector h=(h_1,...,h_n):

    A_j(pair)=sum_i I_{X_j}(h_i)
       = (1/(4n^2)) sum_i (e_i^+ 1_{J_i^+=j}-e_i^- 1_{J_i^-=j})^2.

Let N_j be the number of leaves i with J_i^+=j and J_i^- != j. Every such leaf contributes exactly 1/(4n^2), hence

    max_j A_j(pair) >= (max_j N_j)/(4n^2).

The categorical variables Z_i=j when J_i^+=j and J_i^- !=j, otherwise Z_i=0, are iid, with

    P(Z_i=j)=(n-1)/n^2 (each j),  P(Z_i=0)=1/n.

Therefore (N_1,...,N_n) are balls-in-bins occupancies with a vanishing dropout rate.

For every fixed k, P(max_j N_j>=k) ->1 as n->infinity:
P(N_1>=k) tends to the strictly positive Poisson(1) tail, so expected number of bins with >=k balls diverges linearly. These exceedance indicators have nonpositive pairwise covariance: conditioning on N_j=r leaves n-r trials for N_l, distributed Binomial(n-r,p/(1-p)), and its upper-tail probability decreases with r. Thus the exceedance count has variance <=its expectation; Chebyshev proves the claim.

Consequently E[max_j N_j] -> infinity and

    E_pairs[max_j A_j(pair)]/M >= (1/4) E[max_j N_j] -> infinity.

A standard balls-in-bins refinement yields growth Theta(log n / log log n), but divergence alone is sufficient.

## Interpretation

- This invalidates an expectation/max-interchange lemma sometimes tacitly used when trying to lift fair-sign selector bounds to arbitrary leaf alphabets.
- It does **not** disprove exponent two: the same example attains M=Var(f)^2.
- The failure occurs already at degree two. It is a stress test for a proof operator, not a new obstacle to the quadratic theorem.
- A successful unrestricted cubic proof must exploit leaf influence/occupancy structure *before* the worst-control maximization, or use an operator that never requires this expected-maximum comparison.
- The leaf alphabet here has 2n symbols and no rare atoms beyond uniform masses. The obstruction is distributed addressing, not solely a rare-event fourth-moment failure.

## Replay

`attack_two_draw_max.py` calculates the exact rational value of E[max N_j] for n=2,...,14 by counting all multinomial occupancy configurations via integer dynamic programming. Its output supports, but does not replace, the asymptotic proof. Finite replay and analytic statement are separate certification gates.
