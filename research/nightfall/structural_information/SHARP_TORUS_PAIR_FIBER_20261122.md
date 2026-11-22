# Sharp triangular-torus pair-fiber law and stronger one-query simulation coefficient

**2026-11-22 · NIGHTFALL · v1.0**. **Status:** all-size elementary combinatorial paper proof and independently coded exact finite regression; no Lean or external mathematical review. This improves the coarse bound in `GRAPH_EDGE_PARITY_FIBER_THEOREM_20261122.md` without making any additional claim about the unproved T2 complex operator bound.

## Theorem

For every integer L≥4, take the finite triangular torus G_L on (Z/LZ)^2 with edges in directions (1,0),(0,1),(1,1). Assign the original binary character label `a_uv=e_u+e_v` to each edge. Let `D={0}∪{a_e:e∈E}`. Then the **ordered pair XOR multiplicity at every nonzero frequency** satisfies

```
 M₂(G_L)=max_{z≠0} #{(a,b)∈D²:a⊕b=z} = 6.
```

### Proof without extrapolating finite grids

Let `S={(1,0),(-1,0),(0,1),(0,-1),(1,1),(-1,-1)}` be the six neighbor offsets. If `z` has binary support of size 2, say {u,v}, the only ordered lifts consist of (i) two ordered pairs (0,a_uv),(a_uv,0), available iff uv is an edge, and (ii) the two orderings of each length-two path u-w-v. Thus

```
  fiber({u,v}) = 2·1_{v−u∈S (mod L)} + 2·|N(u)∩N(v)|.
```

For any nonzero displacement d=v−u, the common-neighbor number is the number of **ordered offset differences** `(s,t)∈S²` with `s−t=d (mod L)`.

For ordinary integer differences `S−S`, the zero displacement has six pairs, and exactly the following 18 nonzero displacements occur. The 12 displacements with two ordered representations are

```
 (-2,-1),(-1,-2),(-1,-1),(-1,0),(-1,1),(0,-1),
 (0,1),(1,-1),(1,0),(1,1),(1,2),(2,1).
```

The six with one ordered representation are

```
 (-2,-2),(-2,0),(0,-2),(0,2),(2,0),(2,2).
```

A direct six-by-six subtraction verifies that this list exhausts all 36 ordered pairs: six zero, 12·2+6·1=30 nonzero. **For L≥5**, reduction modulo L is injective on the square [-2,2]^2, so distinct integer differences cannot merge. Therefore any two distinct torus vertices share at most two neighbors. **For L=4**, direct reduction of the same explicit 36 offsets gives *exactly two* representations of every one of the 15 nonzero displacements. This is a complete finite exceptional case, not inference from sampling. Hence in all L≥4, any weight-two frequency has at most 2+2·2=6 ordered lifts.

If z has support four, its ordered lifts come from choosing two vertex-disjoint edges that perfectly match the four vertices; there are at most three unordered perfect matchings, hence at most six ordered lifts. No other nonzero z is possible from two D-labels. Thus M₂≤6. Equality holds for the adjacent pair u=(0,0), v=(1,0), which has exactly two common neighbors, (1,1) and (0,−1), giving 2+2·2=6. QED.

## Quantified application, scope and credit

Claude's pre-existing one-query PSD/Parseval simulation theorem (author source #960/#961, finite exact audit merged #962) yields for any **one-query** finite-dimensional complex phase-oracle acceptance probability under the uniform hidden torus-vertex signs and 0<ε,δ<1 a deterministic, nonadaptive predictor querying **actual original torus edges** with

```
  Q_C ≤ min{3 L², ceil(12/(ε²δ))}.
```

Through `GRAPH_INTENSITY_PHASE_ORACLE_BRIDGE_20261122.md`, those original edge queries are the actual unit sensing-row squared intensities of restricted unit-sphere real sign signals; this use assumes the explicit **ideal coherent response-bit quantum oracle**, not a free conversion from destructive laboratory measurements. The full sign-class requires L²−1 measured edges to reconstruct exactly. The raw source has C_W=(L²−1)ln2, a specialization of parallel independent #1095's stronger graph-bridge Wyner identity.

Previously, the generic Δ=6 graph bound gave `ceil(28/(ε²δ))` with a minimum against |E|. The **new sharp graph-source M₂=6 reduces 28 to 12**, a factor 7/3 in the coefficient. This is a quantitative strengthening of the special source, not a new generic quantum simulation theorem, a quantum computational speedup, a noise-robust result, or the conjectured two-query theorem. It remains a paper proof pending Lean certification; the finite checker tests L=4,5,6,7,8,9,10,16,32,64 and the exact integer difference enumeration and exceptional L=4.

**Next certifier target:** formalize a finite six-offset `S−S` difference table and mod-L injectivity for L≥5, with exact L=4 finite exception. Only then lift the existing one-query source theorem and actual-intensity character arithmetic into a named Lean theorem. Preserve Claude's generic one-query proof credit and #1095's stronger Wyner identity. Do not optimize T1 further in place of attacking unrestricted complex T2 grouping.
