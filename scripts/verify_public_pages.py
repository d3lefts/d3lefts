#!/usr/bin/env python3
"""Read-only HTTP audit of NIGHTFALL public Pages routes.

Run against GitHub Pages after deployment. A failed/blocked fetch is an
UNVERIFIED live site, not evidence that the website is broken. The same
check can run against a local static server before a production attempt.
"""
import argparse
from html.parser import HTMLParser
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen
from urllib.parse import urljoin
import json
from datetime import date
from pathlib import Path


class Inspection(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = set()
        self.links = []
        self.html_props = {}
        self.meta = {}
    def handle_starttag(self, tag, attrs):
        attr = dict(attrs)
        if tag == "html":
            self.html_props = attr
        if "id" in attr:
            self.ids.add(attr["id"])
        if tag == "a" and "href" in attr:
            self.links.append(attr["href"])
        if tag == "meta" and "name" in attr:
            self.meta[attr["name"]] = attr.get("content", "")


def read_page(url, timeout):
    req = Request(url, headers={"User-Agent": "NIGHTFALL-public-pages-audit/1.0"})
    with urlopen(req, timeout=timeout) as r:
        if r.status != 200:
            raise ValueError("HTTP status " + str(r.status))
        body = r.read(2_000_001)
        if len(body) > 2_000_000:
            raise ValueError("HTML response unexpectedly large")
        if b"<html" not in body[:1000]:
            raise ValueError("Response does not look like HTML")
        parser = Inspection()
        parser.feed(body.decode("utf-8"))
        return parser, body.decode("utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="https://d3lefts.github.io/d3lefts/",
                    help="GitHub Pages base URL, or local static server base")
    ap.add_argument("--timeout", type=float, default=12)
    args = ap.parse_args()
    base = args.base if args.base.endswith("/") else args.base + "/"
    repository_root = Path(__file__).resolve().parents[1]
    registry = json.loads((repository_root / "docs/active-proof-passport.json").read_text("utf-8"))
    lean_registry = json.loads((repository_root / "docs/lean-certificate-provenance.json").read_text("utf-8"))
    expected_version = registry["version"]
    expected_claims = len(registry["claims"])
    expected_date = date.fromisoformat(registry["as_of"]).strftime("%d %B %Y").lstrip("0").upper()
    expected_lean_sources = len(lean_registry["modules"])
    checks = [
        ("index.html", "archive", "flagships", "new-moon.html"),
        ("new-moon.html", "moon", "archived-records", "index.html"),
        ("active-proof-passport.html", None, "q2-influence", "index.html"),
        ("discovery-system.html", None, "cycle", "constellation.html#map"),
        ("review.html", None, "start-here", "constellation.html"),
        ("portfolio.html", None, "career", "resume.html"),
    ]
    report = {"base": base, "results": [], "status": "UNVERIFIED"}
    for path, experience, anchor, destination in checks:
        url = urljoin(base, path)
        try:
            parsed, html = read_page(url, args.timeout)
            if experience is not None and parsed.html_props.get("data-nf-experience") != experience:
                raise ValueError("Wrong homepage identity: " + repr(parsed.html_props.get("data-nf-experience")))
            if anchor not in parsed.ids:
                raise ValueError("Missing required section #" + anchor)
            if destination not in parsed.links:
                raise ValueError("Missing direct destination link " + destination)
            if path == "index.html" and "class=\"nf-claim-passport\"" not in html:
                raise ValueError("Active proof-status summary missing in NULL FIELD")
            if path == "new-moon.html" and ("verify_sidon30_standalone.py" not in html or "0.380856370118" not in html):
                raise ValueError("Archived Erdős or Sidon evidence missing from deployed NEW MOON")
            if path == "discovery-system.html" and ("discovery-system.css" not in html or "Source-linked" not in html and "SOURCE-LINKED" not in html or "active-proof-passport.json" not in parsed.links):
                raise ValueError("Research-system identity, stylesheet or source ledger missing")
            if path == "active-proof-passport.html":
                if "cubic-obstruction" not in parsed.ids or "active-proof-passport.json" not in parsed.links:
                    raise ValueError("Active Proof Passport or machine-readable companion missing")
                if f"<strong>v{expected_version}</strong>" not in html or f"<strong>{expected_claims}</strong>Active claim records" not in html:
                    raise ValueError("Deployed active passport version/count does not match checked-in registry")
                if f"MANUAL SNAPSHOT · {expected_date}" not in html:
                    raise ValueError("Deployed passport date does not match checked-in registry")
                legacy = f">{expected_lean_sources}-source scoped Lean provenance" in html
                frozen = f">Frozen {expected_lean_sources}-source historical Lean provenance" in html
                if not (legacy or frozen):
                    raise ValueError("Deployed historical Lean source census is stale relative to repository manifest")
                if "current-lean-proof-receipts-20261114.json" not in parsed.links:
                    raise ValueError("Current Lean named-certificate index link missing from public passport")
            if path == "portfolio.html" and "noindex" not in parsed.meta.get("robots", ""):
                raise ValueError("Unlisted portfolio indexing instruction not present")
            report["results"].append({"url": url, "status": "PASS"})
        except HTTPError as exc:
            state = "BLOCKED" if exc.code in (403, 429) else "FAIL"
            report["results"].append({"url": url, "status": state, "error": str(exc)[:350]})
        except (URLError, TimeoutError, OSError) as exc:
            report["results"].append({"url": url, "status": "BLOCKED", "error": str(exc)[:350]})
        except (ValueError, UnicodeError) as exc:
            report["results"].append({"url": url, "status": "FAIL", "error": str(exc)[:350]})
    # Live public JSON must match this checkout's dated registry; passing an
    # anchor check alone can falsely green-light an older Pages deployment.
    registry_url = urljoin(base, "active-proof-passport.json")
    try:
        req = Request(registry_url, headers={"User-Agent": "NIGHTFALL-public-pages-audit/1.1"})
        with urlopen(req, timeout=args.timeout) as response:
            if response.status != 200:
                raise ValueError("HTTP status " + str(response.status))
            body = response.read(500_001)
            if len(body) > 500_000:
                raise ValueError("Registry JSON response unexpectedly large")
            published = json.loads(body.decode("utf-8"))
        if (published.get("version") != expected_version or
                published.get("as_of") != registry["as_of"] or
                len(published.get("claims", [])) != expected_claims or
                [c["id"] for c in published["claims"]] != [c["id"] for c in registry["claims"]]):
            raise ValueError("Deployed active passport JSON differs in version, date, count or claim IDs")
        report["results"].append({"url": registry_url, "status": "PASS"})
    except HTTPError as exc:
        state = "BLOCKED" if exc.code in (403, 429) else "FAIL"
        report["results"].append({"url": registry_url, "status": state, "error": str(exc)[:350]})
    except (URLError, TimeoutError, OSError) as exc:
        report["results"].append({"url": registry_url, "status": "BLOCKED", "error": str(exc)[:350]})
    except (ValueError, UnicodeError, KeyError, TypeError) as exc:
        report["results"].append({"url": registry_url, "status": "FAIL", "error": str(exc)[:350]})
    states = {item["status"] for item in report["results"]}
    report["status"] = "FAIL" if "FAIL" in states else "BLOCKED" if "BLOCKED" in states else "PASS"
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
