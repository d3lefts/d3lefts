# Living Voter · Historical Intelligence Integration v0.2

**Status:** functional, locally testable synthetic-only preview. Not deployed; not an official election interface. This is the next version of the Living Voter journey, visually consistent with the archived mobile prepilot but powered by the new `historical` API instead of its fixed real congressional examples. The original v1.3.1 snapshot remains unchanged.

## Run

From `projects/commonwealth-os`:

```sh
python -m pip install -r app/requirements.txt
python -m uvicorn historical.api:app --host 127.0.0.1 --port 8001
# Then open http://127.0.0.1:8001/living-voter
```

The browser fetches only same-origin `GET /api/v1/historical/{health,issues,sources,dashboard}`. It fails closed unless the API identifies itself as synthetic-only with real imports and official ballots disabled. No client requests or sends private issue choices, practice ballots, identifiers, device location or account details. The only query inputs are *explicitly selected fictional* district/ward, date and issue/chamber filters. Nothing is saved in localStorage, cookies or the server. Refresh clears user choices.

## User flow

1. Choose a fictional issue, chamber, district/ward and historical date range. No location or real voter-residence inference.
2. Optionally enter an *issue* response (`Support`, `Don't support`, `No preference`, `Need more information`). It does not generate votes.
3. Explore source-provenanced fictional decision records, exact motion language, vote date, procedure, typed issue correspondence, reviewer rationale, source digests, and historic seat tenure. Results are paginated before chamber selection to avoid dropping valid matches.
4. Review recorded named positions. `Present`, `Not Voting`, `No recorded position`, `Voice vote — no named position` and `No matching tenure` remain distinct. Tenure matching is evaluated by the **historical vote date**.
5. An optional *hypothetical retrospective choice* appears only for an exact fixture proposition, direct passage/motion and named recorded rollcall. The choice is keyed to that exact question and exists only in volatile memory. No aggregate endorsement or official ballot is inferred.
6. Clear any or all session responses at will. All names, sources, questions, members and outcomes are invented.

## Assurances and limitations

- All API and HTML responses say `SYNTHETIC_ONLY`; strict same-origin CSP disallows external scripts and API connections.
- DOM data is inserted through `textContent` rather than HTML interpolation.
- The browser never makes requests to a live government system; there are no HTTP ingestion endpoints, social sharing controls or identity/KYC flows.
- SHA-256 hashes identify the shipped fictional fixture and derived records, **not** government authenticity, legal correctness, or a signed Proof Passport.
- The corpus is curated and incomplete. No match is **not** proof that no vote happened; a reviewed topical relationship is **not** an exact vote comparison; a historical representative's vote is **not** a citizen preference or electorate sample.
- Matching assumes the demo's fixed synthetic district and tenure scheme. It does not establish real district boundaries, redistricting, eligibility, representation or actual governmental legitimacy.

## Verification

```sh
python -m pytest -q historical/tests
node --test historical/web/tests/*.test.mjs
node --check historical/web/app.mjs
```

These tests establish finite fixture/API and client-side decision rules. They are not an independent accessibility, privacy, cryptographic or production-security audit. The historical API is read-only, but integration into a real citizen profile store would require new design, consent, identity and release gates.
