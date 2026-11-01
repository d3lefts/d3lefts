# Hole-progression bridge: 61-bit four-dimensional squared-phase code (R1)

**Draft 2026-10-31. Internally proved and exact arithmetic checked. No non-author human review, external priority certification, publication or production merge.**
Dependent proof: PR #284 odd-exponent central-symmetry upper bound; PR #279 diamond set construction (wrapped rectangle corrected in #284).

## The general bridge lemma
Let G be a finite abelian group of odd order. Suppose T⊂G is a proper b-bit affine binary cube, symmetric about s (T=s−T), and its *ordinary pair sumset* S=T+T omits m,m+h,m+2h. Then u=m−s∉T−T (since T−T=S−s). In G×G define
    C=(T×T) ∪ ((T×T)+(u,−h)).
The two halves are disjoint, so C is a proper (2b+1)-bit binary cube. Its pair sumset is the union of S×S translated by 0,(u,−h),2(u,−h). The element (m,m) is missing from all three: their second coordinates require m,m+h,m+2h in S, respectively. Therefore C−(m,m)/2 is zero-free and sign-separated, hence squaring is injective on the 2^(2b+1) points in any odd-characteristic field whose underlying additive group is G×G.

**Mechanism:** a triple of sumset holes enables one cross-factor bridge generator beyond ordinary Cartesian-product bit capacity.

## Uniform diamond progression
Let D=2^d≥4 and prime 3D≤p<4D. Let B=[0,D−1]^2⊂Fp², v=(D,D/2), w=(D,−D/2), and T=B+{0,v,w,v+w}. The four D×D layers are pairwise disjoint, giving a proper 2d+2-bit cube.

The sumset S=T+T is the union of 9 rectangles [0,2D−2]²+av+bw, a,b∈{0,1,2}. Set
    m=(4D−p−1,5D/2−1), h=(1,0).
At y=5D/2−1, the only possible contributing rectangles have a−b=2, or (when 3D≤p≤7D/2−1) a−b=−2 after wrap. Both have a+b=2, so their x-offset is 2D. For j=0,1,2, (m+jh)_x=4D−p−1+j lies between 0 and D+1<2D. Subtracting 2D modulo p gives 2D−1+j, which exceeds the rectangle's upper support 2D−2. Thus m,m+h,m+2h are all genuine ordinary sumset holes. This explicitly handles the previously omitted (a,b)=(0,2) wrapped rectangle.

The symmetry center is s=(3D−1,D−1); hence u=m−s=(D,3D/2) modulo p. The bridge in four coordinates is exactly
    (D,3D/2,−1,0).
The construction gives 4d+5 pairwise distinguishable anchored signs in **one squared observation over GF(p^4)** for every eligible prime.

## Seven finite-window exact capacities
All odd primes p≤200000 were checked with an exact sieve and integer bit_length, separately for dimensions 2,3,4. There are precisely seven instances where the sharp central-symmetry bit ceiling is one below the information-only ceiling:

| field | info bits | exact bits | matching independent representation |
|---|---:|---:|---|
| GF(3^4) | 5 | 4 | 4 standard coordinates, binary 0/1, zero as unique self-negative point |
| GF(5^4) | 8 | 7 | axis bit blocks (2,2,2,1); fourth coordinate anchor 1 |
| GF(13^3) | 10 | 9 | 6-bit D=4 diamond plus 3-bit spectator; 512 squares explicitly checked in GF(13^3) |
| GF(23^2) | 8 | 7 | PR #284 128-square explicit witness |
| GF(3251^3) | 34 | 33 | D=1024 diamond 22-bit seed plus 11-bit spectator; 9 rectangle-hole checks |
| GF(4871^4) | 48 | 47 | axis blocks (12,11,12,12); second coordinate anchor 1, hence zero-free |
| GF(55109^4) | 62 | 61 | two D=16384 30-bit diamonds coupled by bridge (16384,24576,−1,0) |

At p55109, 2^61=2305843009213693952 words. The sharp centrally symmetric ceiling 4611606529530439067 is below 2^62=4611686018427387904; the field square alphabet has 4611690212598769081 outputs. Hence **61 is optimal** within the specified affine binary-cube sensing model.

## Certificates and limits
- Full **8,192-word** enumeration at GF(13^4) verifies the bridge including distinct binary words and no opposite pairs.
- For GF(55109^4), verify the nine rectangles at each m+jh (j=0,1,2); no enormous enumeration is claimed.
- Direct GF(13^3)=F13[u]/(u³−2) multiplication independently verifies 512 distinct squares for the 9-bit spectator lift. 2 is not a cube in F13, so this cubic is irreducible.
- The p3251 33-bit witness has an independent compressed 9-rectangle certificate.
- Source-priority search: standard sumset and Freiman-type techniques (Bedert 2024; older restricted sumset literature) are relevant, but this session has **not** established an exact prior-art match or global novelty. There is **no human proof sign-off**.
- The scan is finite p≤200000, d=2..4, not an infinite classification. The upper-bound argument applies to cubes, while sharpness of the bound is proven only for arbitrary centrally symmetric sets. Always distinguish validity, novelty, and competitive scope.
