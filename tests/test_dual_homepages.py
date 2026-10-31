"""Regression checks for the two independently authored NIGHTFALL homepages."""
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
    def test_independent_pages_and_scientific_boundaries(self):
        archive = (DOCS / "index.html").read_text()
        moon = (DOCS / "new-moon.html").read_text()
        self.assertIn('data-nf-experience="archive"', archive)
        self.assertIn('data-nf-experience="moon"', moon)
        self.assertIn('id="flagships"', archive)
        self.assertNotIn('id="open-ledger"', archive)
        self.assertIn('id="open-ledger"', moon)
        self.assertNotIn('id="flagships"', moon)
        self.assertIn("131,072", archive)
        self.assertIn("131,072", moon)
        self.assertIn("external", moon.lower())
        self.assertIn("global optimality", moon.lower())
        self.assertNotIn("nf-experience-underbelly", archive)
        for page in [archive, moon]:
            self.assertIn('href="index.html"', page)
            self.assertIn('href="new-moon.html"', page)
            self.assertIn('data-nf-route="archive"', page)
            self.assertIn('data-nf-route="moon"', page)
            parser = Inspector()
            parser.feed(page)
            self.assertEqual(len(parser.ids), len(set(parser.ids)), "Duplicate HTML IDs")
            self.assertIn("review.html", " ".join(parser.links))
    def test_toggle_navigates_and_state_is_persisted(self):
        toggle = (DOCS / "ethereal-theme.js").read_text()
        self.assertIn('window.location.assign(next===DUSK?"new-moon.html":"index.html")', toggle)
        self.assertIn('if(experience)persist(current)', toggle)
        self.assertIn('data-nf-route', toggle)
        site = (DOCS / "site.js").read_text()
        self.assertIn('"new-moon.html"', site)
    def test_canonical_pages_and_sitemap(self):
        moon = (DOCS / "new-moon.html").read_text()
        self.assertIn('rel="canonical" href="https://d3lefts.github.io/d3lefts/new-moon.html"', moon)
        self.assertIn("new-moon.html", (DOCS / "sitemap.xml").read_text())

if __name__ == "__main__":
    unittest.main()
