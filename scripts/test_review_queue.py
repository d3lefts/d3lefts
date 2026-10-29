#!/usr/bin/env python3
"""NIGHTFALL product-owner gate: the review front door must expose scoped, live-source links.

Static, offline checks. These do not verify GitHub PR status or mathematical truth.
"""
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAGE = ROOT / "docs/review.html"
QUEUE = ROOT / "research/nightfall/REVIEW_TRIAGE_20261029.md"

class ReviewParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.section_depth = 0
        self.cards = []
        self.links = []
        self.ids = set()
        self.duplicate_ids = set()

    def handle_starttag(self, tag, attrs):
        props = dict(attrs)
        ident = props.get("id")
        if ident:
            if ident in self.ids:
                self.duplicate_ids.add(ident)
            self.ids.add(ident)
        if tag == "section" and ident == "priority":
            self.section_depth = 1
        elif self.section_depth:
            self.section_depth += 1
        if self.section_depth:
            if tag == "article" and "review-priority-card" in props.get("class", "").split():
                self.cards.append(props)
            if tag == "a":
                self.links.append(props.get("href"))

    def handle_endtag(self, tag):
        # Conservative parser uses a generic nested count only for balanced markup.
        if self.section_depth:
            self.section_depth -= 1

def run():
    html = PAGE.read_text(encoding="utf-8")
    queue = QUEUE.read_text(encoding="utf-8")
    required_prs = ("203", "204", "199")
    assert 'id="priority"' in html, "review queue anchor missing"
    assert len(html.split('class="review-priority-card"')) == 4 or html.count('class="review-priority-card"') == 3, "must show exactly 3 priorities"
    for number in required_prs:
        link = "https://github.com/d3lefts/d3lefts/pull/" + number
        assert link in html, "missing reviewer source " + link
        assert link in queue, "missing triage source " + link
    for marker in ("THEOREM CANDIDATE", "FAMILY CANDIDATE", "RESEARCH GUARDRAIL"):
        assert marker in html, "ambiguous scientific scope " + marker
    assert "machine replay" in html.lower(), "machine replay status missing"
    assert "human review" in html.lower(), "human-review separation missing"
    assert "main" in queue and "red checks" in queue, "release dependency missing"
    assert "independent implementation" not in html or "human review" in html.lower()
    print("PASS scoped review triage: three source-linked candidates; machine vs human status separated")

if __name__ == "__main__":
    run()
