# Synthetic-only security boundary

`oidc-bridge.mjs` validates OIDC ID Tokens against a *preapproved, out-of-band configured* issuer and public JWKS, requires nonce replay consumption and never accepts role/eligibility attributes as political authorization. Tests use locally generated cryptographic fixtures; no actual identity provider is contacted. This is not a complete OIDC authorization-code/PKCE login stack or passkey lifecycle.

`ballot-boundary.mjs` deliberately **refuses** real official or confidential ballots; a fictional roll-call is permitted, with no secrecy claim. Public releases use an aggregate-only allowlist, not unrestricted object serialization.

These interfaces are deliberate stop gates until a legitimate institutional authority and an independently reviewed election protocol exist. Do not use real voters, government identities, ballots, credentials, or privileged law-enforcement information.
