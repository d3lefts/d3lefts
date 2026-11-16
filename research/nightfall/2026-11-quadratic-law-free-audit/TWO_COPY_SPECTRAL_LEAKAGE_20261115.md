# C96 first-chaos — exact two-copy Fourier leakage obstruction

**Research date:** 2026-11-15 UTC.
**Status:** Analytic spectral identity plus exact finite counterexample, independently replayed in rational arithmetic. No pinned Lean source compilation, independent human referee or global novelty certificate. This does **not** refute the desired unrestricted first-chaos budget or establish an end-to-end C96 theorem.

## Universal finite-product spectral identity

Let \(F\) be any scalar, square-integrable function of independent finite-law coordinates with orthogonal Hoeffding decomposition \(F=\sum_{S\subseteq[n]}F_S\), and let \(W_S=\mathbb E[F_S^2]\). Independently draw pairs \(A_i,B_i\sim\mu_i\), and fair orientation signs \(\epsilon_i\). Define \(Z_i(\epsilon_i)=A_i\) if \(\epsilon_i=+1\), else \(B_i\), and

\[
t_i(A,B)=\mathbb E_{\epsilon}[\epsilon_i F(Z(\epsilon))].
\]

Then the **exact spectral identity** is

\[
\boxed{2\mathbb E_{A,B}\sum_i t_i(A,B)^2
=\sum_{\varnothing\ne S\subseteq[n]} |S|\,2^{1-|S|}W_S.}\tag{1}
\]

**Derivation.** For a pure degenerate component \(F_S\) with \(i\in S\), the \(i\)-th signed coefficient is a pairwise difference \(D_i\) (square norm factor \(1/2\)) followed by pairwise averages \(M_j\) (each contributing another square norm factor \(1/2\)) for all \(j\in S\setminus\{i\}\). Thus each \(i\in S\) contributes \(2^{-|S|}W_S\). Different \(S\) remain orthogonal, and constants contribute no signed coefficient. Summing over \(i\in S\) and multiplying by two proves (1).

For product noise stability \(N(\rho)=\sum_S\rho^{|S|}W_S\), equation (1) equals \(N'(1/2)\); the genuine first-level projection budget is \(W_1=N'(0)\). The two-copy operator evaluates the **wrong spectral derivative** and assigns every second-order component the same coefficient as a first-order component.

## Exact four-sign counterexample to the *stronger* operator bound

Let \(\epsilon_1,\dots,\epsilon_4\) be independent fair signs, set \(h=0\), \(c=1\), and

\[
F=\left|\sum_{i=1}^4\epsilon_i\right|
=\frac32+\frac12\sum_{i<j}\epsilon_i\epsilon_j-\frac12\prod_{i=1}^4\epsilon_i.
\]

Consequently,

\[
u=\mathbb EF=\frac32,\qquad W_1=0,\qquad W_2=\frac32,\qquad W_4=\frac14.
\]

Equation (1) gives

\[
2\mathbb E_{A,B}\sum_i t_i^2=W_2+\tfrac12 W_4
=\frac{13}{8}>\frac32=c\,u,
\]

with **exact gap \(1/8\)**. Hence the *stronger* proposed comparison \(2\mathbb E\sum_i t_i^2\le\|h\|^2+c\,u\) is **false**. By contrast, the actual desired \(W_1\le\|h\|^2+c\,u\) holds here with \(W_1=0\). This does not disprove the original first-chaos conjecture.

The stand-alone \`check_two_copy_four_sign_no_go.py\` enumerates \(256\) paired assignments and \(16\) orientations per assignment using Python \`fractions.Fraction\`, checking the identity and gap without floating point, discretization or tolerance.

## Reusable research lesson and remaining gap

An unrestricted first-chaos proof must isolate the exact zero-correlation projection, rather than bounding the uncorrected two-copy positive-correlation energy. Pair symmetrization requires explicit subtraction or cancellation of degree-two and higher Fourier/Hoeffding leakage. Raising replica count alone does not certify the missing universal norm inequality without a spectral-tail argument.

**Audit boundary:** independent exact code replay verifies the counterexample and coefficient arithmetic; the universal identity has an analytic operator proof, not an independently human-reviewed or Lean-certified source formalization. The cited calculation concerns finite independent scalar laws, not deployment correctness or unrestricted Hilbert-space first-chaos bounds.

**Attribution and dependencies:** NIGHTFALL research directed by Devin J. Wright; related merged symmetric first-chaos PR #574, orthogonal-source PR #572, and one-increment Lean PR #571. The checker is source-controlled with this note. The previous text version accidentally contained 7 ASCII control characters in formula markup; this revision restores readable equations without changing the scientific claim.
