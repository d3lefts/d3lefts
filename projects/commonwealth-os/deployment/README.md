# Commonwealth dedicated deployment

This folder constructs a standalone civic product. The default destination
is a *new* GitHub Pages project site at
`https://d3lefts.github.io/commonwealth/`. It never overwrites NIGHTFALL Pages.

## Build and verify

```bash
python3 projects/commonwealth-os/deployment/build_standalone.py \
  --output /tmp/commonwealth-repository \
  --zip-output /tmp/commonwealth-standalone-release.zip
python3 projects/commonwealth-os/deployment/test_standalone.py /tmp/commonwealth-repository
node scripts/test_commonwealth_standalone_browser.mjs /tmp/commonwealth-repository/site
```

The GitHub workflow `.github/workflows/commonwealth-standalone-release.yml`
runs these tests and publishes the vetted ZIP as an Actions artifact.
The target repository will contain only independent `site/` files and its
own `.github/workflows/pages.yml`. The Pages pipeline does not clone,
fetch or build NIGHTFALL, and rollback is isolated.

The source builder allowlists Commonwealth HTML, standalone shells, figures,
and functional demos. It rewrites canonical URLs, retains clearly attributed
scientific origins links, rejects missing links/imports, checks SHA-256 file
provenance, and omits research-only CSS/JavaScript. The app and source remain
synthetic and nonbinding.

## Publication gate

The linked GitHub connector does not offer new repository creation, Pages
administration, or custom-domain management. A repository owner must first
create `d3lefts/commonwealth`, push the validated ZIP contents, and enable
GitHub Actions in Settings → Pages. Then inspect its actual deployment and
point the NIGHTFALL portal to the confirmed URL. The old Commonwealth route
must continue to work until cutover.

This status is **BUILT_NOT_DEPLOYED** until the dedicated live host is observed;
an archived ZIP and passing tests alone do not imply publication.
