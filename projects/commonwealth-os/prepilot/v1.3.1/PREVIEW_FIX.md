# iPhone preview compatibility fix v1.3.1

**Root cause reproduced:** The original v1.3 HTML had an empty `<main id="view"></main>` and relied entirely on inline JavaScript to insert the first screen. With JS disabled, the resulting page showed only the static masthead and dark background—matching the reported in-app iPhone screenshot. Chromium with scripts enabled rendered the full app correctly, but the ChatGPT document viewer did not run scripts.

**Change:** Add a complete, CSS-styled, native-HTML walkthrough inside `<main>` so JavaScript-disabled viewers display all essential information. Native links, form radio controls and `<details>` disclosures require no scripts. When inline JavaScript is allowed, the existing `render()` replaces this fallback and full v1.3 interactions work unchanged.

**Privacy:** The script-free fallback does not store choices; the script-enabled app still uses in-memory state only. Both are nonbinding simulations and neither has a backend.

**Limitation:** The mobile in-app preview is read-only in practice; radio controls are local visual selections and do not save personal history. For fully functioning history/survey navigation, open a JS-enabled HTTPS-hosted version in Safari (file preview alone may suppress scripts). No live deployment is claimed.
