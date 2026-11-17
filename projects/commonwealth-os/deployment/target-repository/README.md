# Commonwealth — independent civic site

This repository is the dedicated **Commonwealth** public website, separate
from the NIGHTFALL research site. It contains only public Commonwealth static
assets in `site/` and its independent Pages workflow.

## Publish

1. Create a public repository named `d3lefts/commonwealth` and leave it empty.
2. Extract the vetted `commonwealth-standalone-release.zip` at the repository root.
3. Push the resulting `site/`, `.github/workflows/pages.yml`, and README to `main`.
4. In **Settings → Pages → Build and deployment**, select **GitHub Actions**.
5. Verify the actual live site at `https://d3lefts.github.io/commonwealth/`.
6. Only after a verified independent deployment, update NIGHTFALL's portal
   destination to the new site. Preserve the original route as an attribution
   or redirect, not a broken link.

No NIGHTFALL runtime stylesheet or JavaScript is included. No backend, keys,
real voter records, authoritative legal determination, official voting
functions, or municipal deployment are provided. All interactive scenarios
remain synthetic and nonbinding.

`site/build-manifest.json` records source and published SHA-256 file
digests and the pinned source commit. It does not certify scientific findings.

For a different GitHub Pages repository name or custom domain, rebuild with
`--base-url` pointing to the desired HTTPS root before publication, and
configure DNS/Pages separately.

## Rollback

Use this repository's own `main` history or redeploy a known-good ZIP.
Do not alter NIGHTFALL releases to restore Commonwealth.
