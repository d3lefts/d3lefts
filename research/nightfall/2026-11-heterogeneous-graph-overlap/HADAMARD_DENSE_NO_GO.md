# Dense quadratic Hadamard benchmark: why edge coloring cannot close the general case

**Status:** exact classical matrix construction and elementary implication; not a new universal influence bound, an original Hadamard result, or a proof of the unrestricted quadratic conjecture. Connected to the analogous cubic dense-overlap benchmark already recorded in NIGHTFALL PR #349.

For each \(k\ge1\), set \(n=4^k\), index \(n\) input signs \(X_u\) and \(n\) input signs \(Y_v\) independently and uniformly by \(u,v\in\mathbb F_2^{2k}\). Let \(H_{uv}=(-1)^{u\cdot v}\) be the Sylvester/Walsh Hadamard matrix. Define
\[
f_n(X,Y)=\frac{1}{n^{3/2}}\sum_{u,v}H_{uv}X_uY_v.
\]
The support graph is the complete bipartite graph \(K_{n,n}\), and hence \(\chi'(G)=n\) and the new graph-overlap certificate \(\kappa(G)=n\).

However, \(H^TH=nI\) gives \(|X^THY|\le n^{3/2}\). Equality is attained: choose \(X_u=(-1)^{u_1u_2+u_3u_4+\cdots+u_{2k-1}u_{2k}}\). Its Walsh transform has every coefficient of magnitude \(2^k=\sqrt n\), and choose \(Y_v\) to match their signs. Therefore \(\|f_n\|_\infty=1\) **exactly**.

By orthogonality of the degree-two fair-sign monomials,
\[
\operatorname{Var}(f_n)=\frac{n^2}{n^3}=\frac1n,\qquad
I_{X_u}(f_n)=I_{Y_v}(f_n)=\frac{n}{n^3}=\frac1{n^2}.
\]
Thus \(M=V^2\), **exact sharp exponent two** despite arbitrarily large \(\kappa(G)=n\). This does not contradict the structural sufficient condition; it shows that *graph topology alone* is too crude for the dense-overlap regime. A universal proof must exploit **signed cancellation and coefficient/operator geometry**, not only matching support or unweighted graph coloring.

The result is a negative-control benchmark for the next operator family: design an energy-weighted certificate reflecting operator factorization and cancellation, then independently test it against this exact family, rare-symbol addresses, and PR #349's cubic Hadamard links. A purely support-graph upper bound cannot see the sharp behavior.

**Prior-art boundary:** Sylvester/Walsh matrices, bent Boolean functions, and operator-norm estimates are classical; this is an exact cross-program test fixture, not a novelty claim. Its relationship to existing cubic Hadamard checks is explicitly acknowledged.
