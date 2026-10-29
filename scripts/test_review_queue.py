#!/usr/bin/env python3
"""Static product gate for sourced, scoped review priorities.

This offline test verifies editorial integrity only. It does not verify
the state of live GitHub pull requests or mathematical validity.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PAGE = ROOT / "docs/review.html"
QUEUE = ROOT / "research/nightfall/REVIEW_TRIAGE_20261029.md"


def run():
    html = PAGE.read_text(encoding="utf8")
    queue = QUEUE.read_text(encoding="utf8")
    assert 'id="priority"' in html, "review-priority anchor missing"
    assert html.count('class="review-priority-card"') == 3, "expected three scoped review targets"
    for number in ("203", "204", "199"):
        link = f"https://github.com/d3lefts/d3lefts/pull/{number}"
        assert link in html, "missing primary PR source: " + link
        assert link in queue, "missing triage source: " + link
    for scope in ("THEOREM CANDIDATE", "FAMILY CANDIDATE", "RESEARCH GUARDRAIL"):
        assert scope in html, "missing scope: " + scope
    assert "machine replay" in html.lower(), "missing machine-replay scope"
    assert "human review" in html.lower(), "missing open human-review status"
    assert "NO EXTERNAL REPLAY CLAIMED" not in html, "retracted status recurred"
    assert "red checks" in queue, "release gate dependency missing"
    assert len(re.findall(r'<section[^>]+id="priority"', html)) == 1, "duplicate priority section"
    print("PASS review queue: 3 live-source PR links, scientific scopes, replay/referee separation")


if __name__ == "__main__":
    run()
