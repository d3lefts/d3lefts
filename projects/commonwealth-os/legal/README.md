# Commonwealth Legal Knowledge Kernel — v0.1 (FICTIONAL ONLY)

**2026-11-15. Status:** executable, two separately implemented proof replayers and
a neutral civic dossier assembler. **Not a legal opinion, an official US law
corpus, a certified court-precedent engine, or authorization to perform any
real action.** This is the first executable step toward the redefined
Commonwealth *Legal Proof Passport*: a mathematical-proof-like derivation whose
premises refer to exact, versioned governing sources.

## Reproduce without network, accounts or external dependencies

From repository root:

```sh
python3 -m unittest discover -s projects/commonwealth-os/legal/tests -p 'test_*.py' -v
python3 projects/commonwealth-os/legal/kernel.py projects/commonwealth-os/legal/fixtures/riverfront_passport.json
python3 projects/commonwealth-os/legal/independent_checker.py projects/commonwealth-os/legal/fixtures/riverfront_passport.json
python3 projects/commonwealth-os/legal/dossier.py
```

CI: `.github/workflows/commonwealth-legal-kernel.yml`.

### What is actually checked

The immutable-looking *example* inputs include four fictional documents with
SHA-256 of their exact UTF-8 text. Every base fact and rule cites an actual
substring of the supplied source, has a claimed reviewer, a legal valid-from
date and a separate observed-at date. All sources must be ACTIVE, explicitly
FICTIONAL, and valid for the requested legal date and known by the knowledge
cutoff. A linear proof object introduces explicitly supported true/false facts
and then applies a *reviewer-supplied* positive Horn rule only after all positive
premises and all **explicitly grounded false exception predicates** are
available. Missing exceptions yield INDETERMINATE: absence of a record is not
absence of an exemption.

Both checkers reject corrupted source hashes, unanchored quotes, contradictory
premises, bad proof order, unsupported goals, unauthorized mode, missing sources,
stale/withdrawn sources and other hostile input. The second checker shares no
Python imports with the first. The output says
`SUPPORTED_IN_FICTIONAL_MODEL`, `INDETERMINATE`, or `INVALID`; it never says
"legally authorized."

The decision dossier attaches neutral consideration statements, explicit
missing economic/environmental/developer data, and allowed response vocabulary.
It has **no identity, response capture, consent storage, ballot or effect path**.
A reader's political preference is not measured by mere dossier access.

### Explicit trust boundaries

1. **Source authenticity:** a source hash authenticates supplied bytes against
   a declared digest; it does not authenticate the source's issuer. All bundled
   material is invented. No actual law or GIS parcel data is present.
2. **Interpretation:** exact quote matching does NOT prove that the formalized
   rule/fact is a correct reading. The example's reviewer strings are assertions,
   not authenticated attestations. An incorrect encoding can pass the deduction
   checker; independent legal review remains mandatory.
3. **Completeness:** this kernel cannot discover omitted statutes, binding
   precedent, emergency stays, contradictory facts, or unpublished decisions.
4. **Temporality:** `valid_from/valid_until` refer to the declared legal/factual
   applicability interval; `observed_at` refers to when the system claims to
   have seen the record. `as_of` and `known_at` are separately checked. Date
   equality is an approximation for dates, not an exact effect-time transaction.
5. **Recertification:** `source_change_status` compares *all recorded source
   dependencies*, including document hashes, status, effective intervals and
   observation date. A change requires rechecking. Identical recorded sources
   do not establish that all controlling legal sources have been discovered.
6. **No real-world authority:** OFFICIAL mode, live jurisdiction identifiers and
   non-fictional source authenticity labels are rejected. No voting,
   authorization, effect, or public-record ingestion endpoint is included.

### What a genuine American legal knowledge layer must add

- **Primary-source hierarchy:** U.S. Constitution, applicable federal statutes,
  regulations, binding federal holdings, Alabama constitution and statutes,
  state regulations and judicial holdings, municipal ordinance/enactment history,
  codification corrections, institution charters/bylaws and legally adopted
  procedural rules. These operate under jurisdiction-specific rules; one flat
  statute list is not a legal priority rule.
- **Precedential reasoning:** court hierarchy, jurisdiction, holding versus
  dicta, applicability and distinguishing facts, later treatment, overruling,
  stays, and unresolved conflicts. Legal experts must validate controlling
  interpretations; AI-generated claims alone have no authority.
- **Authenticity and legal-status custody:** official endpoints or legally
  validated custodians, source signatures where available, reliable catalog
  completeness claims, retrieval permissions, typed provenance and corrections.
  `published_at`, `effective_at`, `repealed_at`, `learned_at` and proof
  evaluation time cannot be conflated.
- **Independent evaluation:** two-source reconciliation, a separately authored
  formal semantics, court/legal practitioner challenge fixtures, adversarial
  incomplete-source tests, source issuance trust roots and continuous monitoring.
- **Typed conclusions:** legal procedure requires review; developer has applied;
  proposal adopted; financing authorized; project permitted; citizen preference
  recorded; ballot legally cast; and physical effect completed are distinct
  propositions, never promoted into one another automatically.

### Integration plan — one authoritative workflow, no parallel government

`legal/` is dependency-free and intentionally does not choose or change an
authoritative backend. Existing `app/` (FastAPI/reducer) and `apps/server/`
(Node/SQLite) are **two experimental implementations**, not two independent
sources of governing truth. The next integration must select one command
pipeline after a feature/guard comparison, preserve an independent checker,
and keep the other as a reference/test oracle. No duplicate vote writers.
The civic dossier is read-only; public views must be approved/redacted.
The Living Voter response and authorized ballot services remain separated,
consent-scoped and disabled until their distinct gates pass.

## Cheapest decisive follow-up

Add one authenticated, *permissioned* university-rulebook source with a legal
reviewer's signed interpretation, build a competing independently specified
precedence/exception semantics, and challenge five edge cases: changed bylaw,
rescinded exception, contested quorum, superseding motion, and a mid-transaction
authority revocation. Compare exact interpreter agreement against legal review.
Only then evaluate whether this kernel can participate in institutional votes.

The main repository currently lacks a root LICENSE. A license cannot be
inferred from a public GitHub repository; choose it explicitly, including
compatibility with any third-party code reused later.
