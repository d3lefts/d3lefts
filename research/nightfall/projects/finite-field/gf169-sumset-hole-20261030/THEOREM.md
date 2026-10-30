# Sumset-hole construction: six signed phases in one squared F169 observation

**NIGHTFALL | 30 October 2026 | Draft research candidate (R1)**  
**Human research lead:** Devin J. Wright. **AI-assisted construction and synthesis:** Vesper, building on Tessera's signed-digit approach (PR #267), the prior NIGHTFALL phase decoder (PR #256), and classical sumset/invariant separation. No human referee, global priority clearance, or site promotion is claimed.

## Exact oracle and field

Fix `K=F_13[t]/(t^2-2)=F_169`, since 2 is a quadratic nonresidue modulo 13. Every permitted query is the **square** of an arbitrary K-linear form, `(a·x)^2 in K`, chosen adaptively from prior squared readings. Recover **every** x∈K^k, including zero and unknown support, up to one global sign ±1. All coordinate and mixed queries are counted. This is **not** an F16 cube-oracle improvement.

## General lemma: sumset-hole → powered invariant separation

Let G be the additive group of an odd-characteristic field K. Choose `w_1,...,w_b∈K` and let `T={Σ ε_i w_i: ε_i∈{0,1}}`. Suppose (i) `|T|=2^b`, and (ii) `T+T≠G`. Choose `m∉T+T` and set `c=-m/2`. Define `a_i=w_i/2` and `a_0=c+Σ a_i`.

Then the **single legal powered linear observation**
```
eta=(eta_1,...,eta_b) in {+1,-1}^b
    -> (a_0+Σ_i a_i eta_i)^2
```
is injective on all 2^b assignments.

**Proof:** Set `ε_i=(eta_i+1)/2∈{0,1}`. The unpowered value equals `c+Σ ε_i w_i`, so the outputs are the squares of the translated cube `c+T`. Distinct eta give distinct unsquared values by (i). A collision of their squared values would imply distinct `u,v∈T` with `c+u=-(c+v)`, hence `u+v=-2c=m∈T+T`, contrary to (ii). In fact no translated point is zero, because `c+u=0` would imply `u+u=m`. QED.

**Scope note:** The hole condition is sufficient, **not claimed necessary**, since a translated cube containing zero can still have injective squares. The exact necessary/sufficient criterion for a fixed T is that the **off-diagonal** sumset `{u+v : u,v∈T,u≠v}` omit some element. This broader equivalent formulation is an immediate algebraic deduction, not a claim of new additive combinatorics.

## Explicit F169 six-phase certificate

Use the F13-basis (1,t), write `a+bt` for coefficient (a,b). Let six binary cube generators be
```
w = [1, t, 2, 2t, 7+5t, 12+5t].
```
The **exact 64-word subset-sum enumeration** gives `|T|=64`. The complete pairwise sumset has `|T+T|=167`, with precisely two missing field elements
```
F169 \ (T+T) = {6+9t, 12+4t}.
```
Choose `m=6+9t`, `c=-m/2=10+2t`. Then `a_i=w_i/2` and `a_0=c+Σa_i` yield the **explicit row**
```
(a_0;a_1,...,a_6)
  = (8+2t; 7, 7t, 1, t, 10+9t, 6+9t).
```
All `2^6=64` powered outputs are distinct by the lemma; the independent direct GF169 field-squaring enumeration agrees. The sumset-hole proof does **not** assume unknown unpowered values are observable.

The powered-query output alphabet has `M=(169+1)/2=85` elements, so `2^7=128>85` prevents any one-query encoding of seven independent anchored signs, including arbitrary adaptive choice within that single query. **Therefore exactly six is the optimal anchored relative-sign capacity for one squared reading in this K.**

## Universal all-signal transfer and sharp k=7

Query all `k` coordinate squares. These reveal support S and canonical representatives `u_i` of nonzero `x_i^2`; write `x_i=λ_i u_i`, `λ_i∈{±1}`. Choose a supported anchor t; each relative sign `eta_j=λ_j/λ_t`. Partition the remaining `s-1` supported indices into blocks of size at most six.

For a full six-sign block, take row coefficients `a_0/u_t` on the anchor and `a_j/u_{i_j}` on block coordinates. The squared output equals `(a_0+Σ a_j eta_j)^2`, because `λ_t^2=1`. Recover all six phases from the 64-word table. For a block of `b<6`, keep the first b coefficients and **absorb the remaining six coefficients into the anchor**: `a'_0=a_0+Σ_{j=b+1}^6 a_j`. This exactly restricts the same injective table to the extra phases eta=+1. Reconstruct all x up to one global λ_t, for every support.

Thus the legal protocol uses
```
m(k,s) ≤ k + ceil((s−1)/6), s≥1; zero signal uses k queries.
```
At `k=7`, every x is reconstructed using **at most 8 queries**. No protocol can guarantee <=7 queries because each query has <=85 outputs and the number of global-sign classes is `N_7=(169^7+1)/2>85^7`. Therefore **the exact adaptive minimax value is A_F169(7)=8** under this frozen oracle. This is a model-specific theorem candidate pending non-author mathematical review.

The elementary fixed complement obstruction from PR #256 gives `F_F169(k)≥2k−1` and therefore
```
F_F169(k)−A_F169(k) ≥ k−1−ceil((k−1)/6)
```
for every k≥2. This is a fixed-field unbounded adaptive advantage, **not** a claim that all of its individual ingredients are historically new.

## Independent reproducibility and evidence boundaries

`verify_f169.py` uses standard-library Python GF13[t]/(t²−2) arithmetic to audit:
- complete 64-word T and exact 167-word T+T, both missing values;
- 64 different actual squared GF169 outputs for the displayed coefficient row;
- all six partial-block tables, 2^b words for b=1,...,6;
- **every one of 169²=28,561 two-dimensional signal inputs**, including zero;
- all **1,093** seven-dimensional support/sign representatives (plus zero) and 20,000 additional deterministic random F169^7 signals;
- exact information and algebraic lower bounds as described in this note.

The **general proof is algebraic**, not implied by sampling all k7 signals (169^7 signals cannot reasonably be exhaustively enumerated). AI-internal exact checks are not human mathematical review. Need an *independent* implementation in a different GF169 basis and a non-author proof attack. Preserve exact source SHA, seed, and frozen transcript hash.

### Novelty and transfers

The *operator* is constructive: **dissociated binary cube → find hole in its pairwise sumset → translate to an antipodal-free cube → square-power invariant separates all signs**. It is potentially transferable to other odd-prime fields or related subgroup-orbit maps. This changes Tessera PR #267's GF169 `B=5` lower bound to **`B=6`**, saturating the one-query alphabet maximum. It does **not** alter earlier GF25, GF49, GF121 bounds; F16 cubic work remains distinct.

Compare priority with finite-field restricted separating invariants; compressed/disjoint subset sums; dissociated sets and sumset-avoiding translates; hidden shifted-power recovery; adaptive phaseless linear probing; scalar-orbit separating invariants. Do not present the general lemma alone as historically unprecedented. Dated same-oracle prior-art search, non-author mathematical audit, external human specialist review, and owner publication authorization are all outstanding.

### Cheapest next decisive experiment

Independently enumerate 64 codewords in an alternative irreducible F13[t]/(t²−δ) basis with an explicit isomorphism, mutation-test one coefficient, and seek a **symbolic pattern** generating nonproduct sumset-hole cubes for a family of primes rather than more isolated records. If no family is found, retain this exact finite theorem and its proof as a scoped result; stop random polishing.
