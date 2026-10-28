# Correlated spectator construction for multiple Werner copies

**Date:** October 27, 2026. **Status:** exact rational *conditional* certificates. **Research lead:** Devin Wright, NIGHTFALL PHASESHIFT. Published lower-copy source: Tejasvi Singh Tomar (2026).

For any complex rank-at-most-two operator C on k physical qutrits, let

[
Q_k(t,C)=sum_{Jsubseteq[k]}(-t)^{|J|}|operatorname{Tr}_J C|_F^2.
]

The following rational thresholds arise from independently checked moment-polynomial dual identities, **assuming** the lower-copy quantitative source contract:

| k | this correlated-family bound | comparison |
|---|---:|---|
| 6 | 359/800 = **0.448750** | The separately certified direct-margin construction improves this to **0.448760** |
| 7 | 10807/25000 = **0.432280** | strict positive rational margin |
| 8 | 4199/10000 = **0.419900** | strict positive rational margin |
| 9 | 256/625 = **0.409600** | strict positive rational margin |

**Imported inequalities:** (Q_4(4979/10000,C)ge(229/10000000)|C|_F^2) and (Q_5(47/100,C)ge(401/100000)|C|_F^2). These quantify the source assumptions, whose original large SDP witnesses were **not independently replayed** in the release.

A correlated two-party separable spectator is constructed by twirling A:B product states of internal GHZ vectors across each site. Its normalized polynomial is

[
S_s^arepsilon(z)=
rac{2^s(1+z)^s+2(3-z)^s+(3arepsilon-1)(3z-1)^s}
{2^s+2cdot3^s+(3arepsilon-1)(-1)^s}.
]

For s=2 and aligned GHZ states this yields (1-rac23 z+z^2). Twirling a product across A:B preserves separability, so tensoring a valid rank-two block-positive source inequality with this spectator preserves nonnegativity. The independently checked identities have the shape ((1-tz)^k=M+sum_rlambda_r R_r(z)), with nonnegative exact rational multipliers and strictly positive M.

**Status boundary:** The downstream polynomial identities and separable-spectator algebra were checked with an independent standard-library verifier; the full original four-/five-copy SDP source witness remains an external dependency. Exact arithmetic does not independently establish the source theorems. The exact k=6..9 certificate JSON and verifier remain in the separate master reproducibility release awaiting binary mirror.

**Attribution:** Devin Wright, GPT-6-assisted reconstruction, original source input from Tomar and cited quantum partial-trace literature. External specialist originality assessment pending.
