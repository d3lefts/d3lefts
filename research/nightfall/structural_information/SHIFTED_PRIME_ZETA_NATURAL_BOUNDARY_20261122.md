# SHIFTED PRIME-ZETA NATURAL-BOUNDARY THEOREM — paper-level proof

**Date:** 2026-11-22. **Status:** unconditional mathematical deduction from classical prime-zeta natural-boundary and the September manuscript's proved shifted expansion. **Author-side proof; not externally refereed, Lean-kernel-certified or priority-cleared**. This is a nontrivial scope change: the ordinary analytic continuation of the original deformation does not reach the formal shifted-layer sources k>=2.

## Statement

Let

  A_plus(s)=Σ_{p prime}[(p−1)^(−s)−p^(−s)],   Re(s)>0.

Let P(w)=Σ_p p^(−w) be the classical prime zeta function, initially defined for Re(w)>1. Assume the established classical fact that the imaginary axis Re(w)=0 is a natural boundary of P(w) (Landau–Walfisz 1920; Fröberg 1968; see references below).

**Theorem (unconditional using that established fact).** The vertical line

  Re(s) = −1

is a natural boundary for the ordinary analytic continuation of A_plus from Re(s)>0: no branch of that continuation extends holomorphically through any point of this line. In particular, the original function cannot be analytically continued by overlapping holomorphic charts to formal sources rho/n−k with k>=2.

The latter statement concerns **ordinary analytic continuation** and does not preclude other generalized summation methods, resurgent objects or separately defined formal germs.

## Proof

### Step 1: first-layer localization

The September source manuscript proves the identity

  A_plus(s)=s P(s+1)+H(s),
  H(s)=Σ_{j>=2} (s)_j/j! P(s+j),

where H is holomorphic on Re(s)>−1. It holds originally for Re(s)>0 and supplies the locally multivalued analytic continuation of A_plus throughout Re(s)>−1 away from prime-zeta singular sources.

### Step 2: H extends through every nonreal point on the candidate boundary

Fix s*=−1+it with t!=0. Split

  H(s)=[s(s+1)/2] P(s+2)+H_3(s),
  H_3(s)=Σ_{j>=3}(s)_j/j! P(s+j).

The same compact-normal-convergence estimate used for first-layer localization shows H_3 is holomorphic for Re(s)>−2. This open half-plane contains s*.

At s=s*, s+2=1+it. The classical prime number theorem gives ζ(1+it)!=0 for t!=0, while the unique ζ pole is at 1. For m>=2 the arguments m(1+it) have Re>1 and therefore lie in the zero-free Euler-product half-plane. The Möbius representation for P(w), or its single-valued meromorphic derivative, consequently has no singular channel at w=1+it. Thus P(s+2) has a holomorphic local branch near s*, and H extends holomorphically across s*.

### Step 3: transfer the known natural boundary

Suppose some branch of A_plus extends through s* with t!=0. Then because s*!=0 and H is holomorphic there,

  P(s+1)=[A_plus(s)−H(s)]/s

would extend holomorphically through s*. Translating w=s+1 gives a continuation of P(w) through w=it on its classical natural boundary Re(w)=0. This contradicts the known prime-zeta natural-boundary theorem.

Hence no nonreal point s* on Re s=−1 is traversable.

Finally any open neighborhood of the remaining real point s=−1 contains nonreal points on the same vertical line. An extension through s=−1 would therefore imply an extension through such a nearby nonreal point, already impossible. Thus **the entire line Re s=−1 is a natural boundary**.

QED, conditional only on the established (classical) natural-boundary result for P and the proved shifted expansion.

## Consequences for the 2026 Affine Source Rigidity paper

1. **First shifted layer (k=1)**: source s0=rho/n−1 lies in −1<Re s0<0. It is accessible by local analytic continuation of A_plus. The separate derivative-residue theorem in FIRST_STRIP_PRIME_ZETA_RIGIDITY_CERTIFICATE_20261122.md gives the exact removability criterion M(lambda)=0.
2. **Deeper layers (k>=2)**: sources s0=rho/n−k satisfy Re s0<−1. They lie behind the newly identified natural boundary for the original A_plus. Without an explicitly new continuation/summation notion, formal sources there cannot be interpreted as ordinary reachable singular germs of the original analytic function.
3. The useful unconditional analytic frontier is the **first strip plus the natural-boundary line**, not a conjectured global all-layer cancellation framework. The affine source-rigidity theorem remains an exact algebraic classification of *formal candidate* source coordinates in every layer; this theorem changes their analytic interpretation, not the algebraic statement.
4. This does not imply the Riemann hypothesis. The use of the classical prime-zeta natural boundary does not require every zero to be on the central line.

## Audit notes and prior art

**Independent proof attack requested:** Check that the normal-convergence argument for H_3 is uniform near −1+it, that P is locally analytic at 1+it for t!=0 (using zeta's zero-free line Re=1), and whether the prime-zeta natural boundary as stated in classical references is indeed a boundary of *all local analytic branches* rather than merely a chosen principal branch. Confirm the original A_plus decomposition is a legitimate identity of locally continued germs across its initial domain. Search separately for the identical prime-shift difference Dirichlet series in the existing literature.

**Strongest sources checked:**
- E. W. Weisstein, *Prime Zeta Function*, MathWorld, https://mathworld.wolfram.com/PrimeZetaFunction.html (states the Re(w)=0 natural boundary, with Landau–Walfisz 1920 and Fröberg 1968 attribution).
- Carl-Erik Fröberg, *On the prime zeta function*, BIT 8 (1968), pp. 187–202, DOI 10.1007/BF01933420 (not fully accessed here; priority and original proof details still require examination).
- Brent, *Primes, the Riemann zeta-function, and sums over zeros*, https://maths-people.anu.edu.au/~brent/pd/Brent-CARMA21.pdf (standard local continuation).
- NIST Digital Library of Mathematical Functions, §25.10, https://dlmf.nist.gov/25.10 (ζ nonvanishing on Re(s)=1).
- September 2026 corrected NIGHTFALL manuscript (user Library): first-layer localization.

**Novelty:** The argument is a direct application of classical prime-zeta natural-boundary theory; while targeted searches did not locate the *exact* A_plus shifted-difference natural-boundary theorem, no worldwide priority or independent novelty certification is claimed. This is appropriately a paper-level research contribution with cited classical dependencies, not a new proof of the classical P natural boundary.
