# Commonwealth dedicated deployment

**Deployment status: DEPLOYED_AND_EXTERNALLY_CHECKED.** This is not a claim of
production voting, verified legal authority, or a formally certified civic system.

- Independent public website: https://d3lefts.github.io/commonwealth/
- Dedicated repository: https://github.com/d3lefts/commonwealth
- Canonical Pages publication: [GitHub Pages run #44005684585](https://github.com/d3lefts/commonwealth/actions/runs/44005684585) — successful.
- Independent external HTTP smoke test: [run #44006080861](https://github.com/d3lefts/commonwealth/actions/runs/44006080861) — successful for nine URLs/assets.
- Pinned source used in deployed release: `240f590a1d44f6a910754ea87c43507eebcb6ae8`.
- Release manifest: `d3lefts/commonwealth/site/build-manifest.json` contains original and published SHA-256 digests for 42 runtime assets and the canonical origin.
- NIGHTFALL research site: https://d3lefts.github.io/d3lefts/

## Source build and independent target

The source repository maintains the allowlist-only Commonwealth release
builder and validation tools. The dedicated repository has its own GitHub
Actions workflow at `.github/workflows/deploy.yml`. That workflow checks out
a **pinned public source revision** during build, performs the source and
deployment-closure audits, and runs mobile and desktop Chromium checks before
committing the generated static snapshot under `site/`. A separate job then
publishes that **locally committed, self-contained snapshot** through Pages.

The published site does not request NIGHTFALL CSS, JavaScript or backend
resources at runtime. Building a *future* release uses the pinned upstream
source, with the exact source hash carried into the manifest. This distinction
preserves independent hosting without disguising the build provenance.

To reproduce locally from the pinned source checkout:

```bash
python3 projects/commonwealth-os/deployment/build_standalone.py \
  --output /tmp/commonwealth-repository \
  --zip-output /tmp/commonwealth-standalone-release.zip \
  --base-url https://d3lefts.github.io/commonwealth/ \
  --source-ref 240f590a1d44f6a910754ea87c43507eebcb6ae8
python3 projects/commonwealth-os/deployment/test_standalone.py /tmp/commonwealth-repository
node scripts/test_commonwealth_standalone_browser.mjs /tmp/commonwealth-repository/site
```

The source workflow `.github/workflows/commonwealth-standalone-release.yml`
additionally produces an archived release ZIP on source changes.

## Scope and migration

The NIGHTFALL homepage's Commonwealth destination is switched to the
independent public URL once external verification is recorded. Historical
NIGHTFALL-hosted paths are retained as nonbreaking legacy deep links; they
are no longer the preferred product entrance.

The demos are synthetic and nonbinding. No real ballots, live voter data,
institutional endorsement, independent security audit, or government
authorization is implied. There is no automatic promotion of private
preference inferences to cast votes or governmental power.

## Recovery and change control

Use `d3lefts/commonwealth` history and saved release artifacts to roll back
the civic website without reverting NIGHTFALL scientific results. Verify the
public routes following each release. Advancing the source pin, adding
institutional data, changing voting semantics, or attaching real authority
requires independent review and applicable authorization.
