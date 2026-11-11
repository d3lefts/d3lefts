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
    checks = [
        ("index.html", "archive", "flagships", "new-moon.html"),
        ("new-moon.html", "moon", "archived-records", "index.html"),
        ("active-proof-passport.html", None, "q2-influence", "index.html"),
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
            if path == "active-proof-passport.html" and ("cubic-obstruction" not in parsed.ids or "active-proof-passport.json" not in parsed.links):
                raise ValueError("Active Proof Passport or machine-readable companion missing")
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
    states = {item["status"] for item in report["results"]}
    report["status"] = "FAIL" if "FAIL" in states else "BLOCKED" if "BLOCKED" in states else "PASS"
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
