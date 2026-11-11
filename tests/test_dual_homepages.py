"""Regression checks for active NULL FIELD and archival NEW MOON experiences."""
from html.parser import HTMLParser
from pathlib import Path
import unittest

DOCS = Path(__file__).resolve().parents[1] / "docs"


class Inspector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.links = []

    def handle_starttag(self, tag, attrs):
        props = dict(attrs)
        if "id" in props:
            self.ids.append(props["id"])
        if tag == "a":
            self.links.append(props.get("href", ""))


class DualHomepageTests(unittest.TestCase):
    def setUp(self):
        self.active = (DOCS / "index.html").read_text()
        self.archive = (DOCS / "new-moon.html").read_text()
        self.chrome = (DOCS / "site.js").read_text()

    def test_separate_pages_with_correct_lifecycle(self):
        self.assertIn('data-nf-experience="archive"', self.active)  # legacy palette token
        self.assertIn('data-nf-experience="moon"', self.archive)
        self.assertIn('id="flagships"', self.active)
        self.assertNotIn('id="live-case"', self.active)
        self.assertIn('id="archived-records"', self.archive)
        self.assertIn('id="live-case"', self.archive)
        self.assertIn('id="sidon-witness"', self.archive)
        self.assertIn('NEW MOON <small>Archived breakthroughs</small>', self.archive)
        self.assertIn('NULL FIELD <small>Active research</small>', self.active)
        self.assertIn("observability.html", self.active)
        self.assertIn("product-space-influence.html", self.active)
        self.assertIn("0.380856370118", self.archive)
        self.assertIn("131,072", self.archive)
        self.assertIn("global optimality", self.archive.lower())
        for page in (self.active, self.archive):
            self.assertIn('href="index.html"', page)
            self.assertIn('href="new-moon.html"', page)
            self.assertIn('data-nf-route="archive"', page)
            self.assertIn('data-nf-route="moon"', page)
            parser = Inspector()
            parser.feed(page)
            self.assertEqual(len(parser.ids), len(set(parser.ids)), "Duplicate HTML ID")
            self.assertTrue(any("review.html" in a for a in parser.links))

    def test_static_finite_witness_is_archived_and_replayable(self):
        self.assertNotIn('id="sidon-witness"', self.active)
        self.assertIn('id="sidon-witness"', self.archive)
        self.assertIn("verify_sidon30_standalone.py", self.archive)
        self.assertIn('"exact_sidon_number": 17', self.archive)
        self.assertIn("reimplement", self.archive)
        self.assertIn('src="referee-core.js"', self.archive)
        self.assertIn('src="home-system.js"', self.archive)

    def test_current_research_scope_is_not_promoted(self):
        self.assertEqual(self.active.count('class="nf-claim-passport"'), 4)
        for term in ("<dt>Claim</dt>", "<dt>Evidence</dt>", "<dt>Limit</dt>", "<dt>Reproduce</dt>"):
            self.assertEqual(self.active.count(term), 4)
        self.assertIn("not externally", self.active.lower())
        self.assertIn("CUBIC_OBSTRUCTION_NOTE.md", self.active)
        self.assertIn("INTERNAL REPLAY", self.archive)
        self.assertIn("IMPORTED THEOREM DEPENDENCIES", self.archive)

    def test_return_handoffs_and_palettes(self):
        self.assertIn("!location.hash", self.active)
        self.assertIn('name="theme-color" content="#020406"', self.active)
        self.assertIn('href="index.html" class="brand"', self.active)
        self.assertIn('href="new-moon.html" class="brand"', self.archive)
        self.assertIn("new-moon.html#archived-records", self.chrome)
        self.assertIn("index.html#flagships", self.chrome)
        self.assertIn("historicalPages", self.chrome)
        self.assertIn("activePages", self.chrome)
        self.assertIn("nightfall-theme-change", self.chrome)
        toggle = (DOCS / "ethereal-theme.js").read_text()
        self.assertIn('window.location.assign(next===DUSK?"new-moon.html":"index.html")', toggle)
        self.assertIn('if(experience)persist(current)', toggle)
        self.assertIn("Archived breakthroughs homepage", toggle)
        self.assertIn("Active research homepage", toggle)

    def test_cross_page_publication_paths(self):
        self.assertIn('rel="canonical" href="https://d3lefts.github.io/d3lefts/new-moon.html"', self.archive)
        self.assertIn("new-moon.html", (DOCS / "sitemap.xml").read_text())
        style = (DOCS / "site.css").read_text()
        self.assertIn("nf-global-route-nav", style)
        portfolio = (DOCS / "portfolio.html").read_text()
        self.assertIn('class="pf-career-signpost"', portfolio)
        self.assertIn('name="robots" content="noindex, nofollow, noarchive"', portfolio)


if __name__ == "__main__":
    unittest.main()
