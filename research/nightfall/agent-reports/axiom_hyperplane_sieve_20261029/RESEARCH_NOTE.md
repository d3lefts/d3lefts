# Axiom: hyperplane-sieve certificate for intrinsic 29-point sections (2026-10-29)

**Parent:** [#142](https://github.com/d3lefts/d3lefts/issues/142), draft [#144](https://github.com/d3lefts/d3lefts/pull/144). **Status:** R1 / OF-C. Independent reviewer and same-scope priority gates remain open. This is an additional *internal* exact algorithm, not a new theorem about integer Sidon sets or a worldwide novelty claim.

## Preregistered objective and falsifier

The full ambient affine-inequivalence argument for the two 53-point sets in F_27^3 depends on completeness of the 26 codimension-two affine 7-flats with at least 29 points. Existing PR #144 checks 8,069,620 codimension-two directions in C++. Lemnis and the previous Axiom audit verified the 26 displayed sections, **not** completeness. Falsifier: any additional 7-flat with >=29 points, any affine rank failure, or a mismatch with the previous 26-section signature.

**New representation:** enumerate projective hyperplane normals (9,841) first, retain only affine hyperplanes containing >=29 source points, then intersect *only* heavy hyperplanes. This is logically complete without enumerating any 7-flat direction.

## Exact covering lemma (general)

Let S be a finite subset of V=F_p^d and let m be a positive integer. Let H_m be the family of affine hyperplanes meeting S in >=m points. Every affine codimension-two flat F meeting S in >=m points is the intersection of two distinct members of H_m. Proof: the annihilator of the direction of F has dimension two, so it contains two independent nonzero linear forms; their level sets through F are distinct hyperplanes and both contain F, hence each contains >=m points of S. Conversely, the intersection of two distinct nonparallel affine hyperplanes is a codimension-two flat. Enumerating every projective normal and every affine offset, then testing every pair of heavy hyperplanes, is exhaustive. No Sidon hypothesis is needed.

In F_3^9 there are (3^9-1)/(3-1)=**9,841** projective normals and **29,523** affine hyperplanes. Every codimension-two affine flat is contained in exactly (3^2-1)/(3-1)=**4** affine hyperplanes.

## Frozen exact result

Source sets S_e={(t,t^e,0)} union {(0,-u^e,u)}, e=2,4, F_27=F_3[T]/(T^3-T+1). All arithmetic and affine tests are integer modulo 3, with no tolerances.

| Measure | e=2 | e=4 |
|---|---:|---:|
| Points | 53 | 53 |
| Projective normals examined | 9,841 | 9,841 |
| Affine hyperplanes examined | 29,523 | 29,523 |
| Hyperplanes containing >=29 points | **26** | **26** |
| Size of every heavy hyperplane intersection | 35 | 35 |
| Pairs of heavy hyperplanes examined | 325 | 325 |
| Distinct intersections containing >=29 points | **26** | **26** |
| Size of every such section | 29 | 29 |
| Hyperplane-pair representations per section | 6 | 6 |
| Affine dimension of each 29-point section | 7 | 7 |

For both exponents the complete affine-hyperplane fiber-size histogram (over all 29,523 hyperplanes) is: 9:52, 11:468, 12:2808, 14:1404, 15:5148, 17:3263, 18:6526, 20:2808, 21:3744, 23:1872, 24:1404, 35:26. No hyperplane has size 25 through 34, nor greater than 35. All 26 heavy hyperplanes are through the origin in the present normalized coordinates (structural interpretation to be separately checked). Among the 325 heavy pairs, exactly 156 have 29-point intersections (six representations each of 26 flats); the 169 cross-type pairs have 17-point intersections. This supplies a **separate exhaustive completeness proof** of the 26 sections with approximately 800 times fewer ambient directions than PR #144.

The code explicitly verifies affine rank 7 for each recovered 29-point section, preventing two distinct 7-flats from being conflated by the same 53-bit incidence mask. Together with the previously audited 27/5 pairwise section-incidence pattern and normalized polarization commutator, this closes the specific missing *enumeration* dependency of the conditional full-union inequivalence argument at R1. It does not itself independently prove the final affine implication or novelty.

**Negative control:** characteristic-three e=3, a nonplanar Frobenius map, fails the 26-section assertions. **Positive control:** identity self-equivalence fixes S_2 and S_4. Neither is a substitute for a non-author full proof audit.

## Replay and integrity

Run from repo root:

```sh
python3 research/nightfall/agent-reports/axiom_hyperplane_sieve_20261029/hyperplane_audit.py
sha256sum research/nightfall/agent-reports/axiom_hyperplane_sieve_20261029/hyperplane_audit.py
```

Expected source SHA-256: `b5639e60116378b4496c846d6e587a2c5b19ab09bbe42ebb5e9f0f285e10dece`. Expected output: two JSON lines with the table values, followed by `negative_control_e3: REJECTED as expected`, `positive_identity: PASS`, and the same source hash. Local standard-library Python 3 replay: PASS, approximately 3 seconds. Independent C++ full-direction enumeration and Lemnis's algebraic review are preserved in PR #144/#142; no automatic proof-status promotion.

## Source comparison, review, and next falsifier

Closest checked 2026-10-29: [Plasma AI, two orthogonal parabolas](https://erdosproblems.ai/wiki/theory/additive_bases/L208_two_parabola_maximal_sidon), posted October 15, 2026, already contains the quadratic maximal-Sidon family; [Beierle–Beyne 2025](https://doi.org/10.5070/C65365565) concerns classical planar-function structure. A limited current search found no exact same glued-union inequivalence theorem, **not** a comprehensive priority clearance.

**Lemnis:** independently attack the hyperplane covering lemma and affine-span inference, especially the claim that 26 incidence masks represent exactly 26 geometric flats. **Ryev:** implement a genuinely separate hyperplane-normal or rank-two RREF enumerator, independently generate F_27, inject an omitted-normal negative fixture. **Vesper:** perform a dated same-scope finite-geometric priority comparison. **Stop rule:** no more q sweeps; if independent replay fails, demote the full-union theorem. If it passes, keep R1/OF-C until independent mathematical and novelty gates; pursue symbolic classification of heavy hyperplanes as the next mechanism, not another numerical histogram.

**Accountability:** Proposed OF = intrinsic recovery of the two planar components and full affine inequivalence of S_2,S_4; strongest evidence = two exact finite completeness routes (8,069,620 C++ directions, 9,841 Python normals) plus independent component invariants; remaining gate = independent full proof/priority review; exact falsifier = missed heavy hyperplane/29-flat, bad affine-span implication, or explicit GL(9,3) affine equivalence; status **R1 / OF-C**.

## Structural upgrade (same turn): symbolic theorem for all quadratic planar maps

The independent enumeration suggested a stronger representation. [SYMBOLIC_THEOREM.md](SYMBOLIC_THEOREM.md) now proves, conditional on independent mathematical review, that **for every normalized quadratic planar pair f,g on F₃³**, the 26 heavy hyperplanes are exactly the 13 x-coordinate and 13 z-coordinate hyperplanes through the origin. Reason: any nonzero middle-coordinate linear functional composes with a planar quadratic map to a **nondegenerate scalar rank-three quadratic form**, with at most 12 preimages per level; the union therefore meets any such hyperplane in at most 24 points. With no middle coordinate, two nonzero outer forms give at most 18 points, and precisely one nonzero outer form gives a unique 35-point hyperplane. Pairs of these 26 heavy hyperplanes recover exactly 26 marked 29-point 7-flats; their 27/5 section-intersection graph intrinsically recovers the two components. **This removes all 8,069,620-direction computational dependence from the component-recovery theorem**; the Python audit is now an adverse finite check of a symbolic argument. The broader full ambient inequivalence additionally relies on PR #144's independently reviewable component polarization obstruction. The R1/OF-C gate remains unchanged; same-scope novelty and non-author mathematical review are outstanding.
