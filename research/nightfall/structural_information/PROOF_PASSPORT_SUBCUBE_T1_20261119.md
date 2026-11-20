# Proof Passport — Independent subcube one-query energy audit

**Date:** 2026-11-19 ET. **Status:** author-side mathematical theorem (Claude's Theorem I and Proposition J) + independently written, exact finite regression. Neither a Lean-kernel theorem nor a human nonauthor review, priority claim, or general-T result.

## Canonical theorem / provenance

Canonical source: [ONE_QUERY_ENERGY_20261119.md](ONE_QUERY_ENERGY_20261119.md) on the structural-information-theory workstream. Credit Claude for Theorem I (one-query pair-multiplicity simulation), Proposition J (the subcube multiplicity 2L+2), and Proposition K (linear-local representation obstruction). This passport does not rebrand those results as an independent first discovery. Separate prior parallel work #956/#957/#959 covers high-girth frame limitations.

For uniform s in F2^m and known bit oracle X_i=g_i dot s, let D={0} union {g_i} and define M=max(1,max_{u != 0}|{(r,t) in D^2:r+t=u}|) counting ORDERED pairs. Then any single-query quantum acceptance function has a deterministic nonuniform classical (epsilon,delta) simulation of depth at most min(n,ceil(2M/(epsilon^2 delta))). For L-fold subcube rows R_L={ (1,0),(0,1),(1,1) }^tensor L, M=2L+2, yielding depth min(3^L,ceil((4L+4)/(epsilon^2 delta))).

**Proof dependency outline:** normal bit-oracle eigenbasis gives an orthogonal prequery row-frequency decomposition; terminal measurement becomes a positive contraction 0<=A<=I with squared row/column norm bounded by 1; group the offdiagonal Fourier terms by their nonzero row-XOR fiber, discard all but heavy frequencies while preserving omitted diagonal constants, and bound mean-square error by 2M*tau with tau=epsilon^2 delta/(2M). The tensor row XOR multiplicity follows from rank-two flattening and pure-tensor decomposition classification.

## Independent exact checker

- Script: scripts/check_subcube_one_query.py
- Command: python3 -I scripts/check_subcube_one_query.py
- Entirely integer and fractions.Fraction; no floating tolerance, random sampling, or timeouts.
- Exhaustive ordered XOR fibers L=1,2,3,4,5, comparing maximum to 2L+2.
- Full F2^(2^L) hidden-secret enumeration L=1,2,3 for explicit normalized one-query rank-one measurement circuits; checks the exact heavy estimator, grouped Fourier expansion and Parseval mean-square error and matrix bound.
- Exact two-query falsifier: rotation U=[[3/5,-4/5],[4/5,3/5]] between phase queries to distinct rows a,b produces parallel 0/a Fourier-state components with inner product -6/25. A general T=2 argument CANNOT recycle one-query frequency orthogonality without proving a substitute.

GitHub Actions workflow .github/workflows/nightfall-subcube-onequery-fibers.yml hashes this passport, the canonical Claude theorem note, and checker; it also records the exact commit and preserves the complete script output. A green run certifies finite examples only; it does not kernel-check the all-L argument.

## Audit gates / limits

1. A separate reviewer should independently derive the bit-oracle no-query/zero-frequency sector, including repeated row indices and arbitrary intermediate workspaces.
2. Check A^2<=A, grouped ordered-pair multiplicities, and the exact 2*tau light contribution; positive contraction—not merely bounded polynomial degree—is essential.
3. Check whether the d>=3 pure-tensor secant decomposition uniqueness over F2 needs a separately stated rank hypothesis; test all small L via exact enumeration.
4. The general case T>=2 remains OPEN; the explicit two-query example attacks only the naive orthogonality extension, not the simulation conjecture.
5. This is a query-complexity statement, not polynomial-time construction of a simulator for arbitrary supplied quantum circuits.
6. Established prior art includes quantum query phase/Fourier methods, positive contraction bounds and tensor-rank/coding structure. No exact-match dated novelty clearance or specialist review obtained.

**Status policy:** author-side conditional-free T=1 proof + independent finite check (not Lean, human referee, or novelty certification); no publication without separate review.
