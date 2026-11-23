#!/usr/bin/env python3
"""Cancel ONLY stale queued PR runs; never treat cancellation as certification.

GitHub Actions must grant actions:write. Exactly-matching current PR heads,
running jobs, non-PR events, and unidentifiable PR sources are not touched.
"""
import datetime as dt
import json
import os
import sys
import urllib.error
import urllib.request

REPO = os.environ.get("GITHUB_REPOSITORY", "")
TOKEN = os.environ.get("GH_TOKEN", "")
API = "https://api.github.com/"
MAX_CANCEL = 250

def eligible(run, live, now):
    if run.get("status") != "queued" or run.get("event") != "pull_request":
        return False
    branch = run.get("head_branch")
    sha = run.get("head_sha")
    source = (run.get("head_repository") or {}).get("full_name")
    if not branch or not sha or not source or branch == "main":
        return False
    key = (source, branch)
    if key in live:
        return sha != live[key][0]
    # Only discard truly orphaned/closed-PR work after a full day.
    when = run.get("created_at")
    try:
        age = now - dt.datetime.fromisoformat(when.replace("Z", "+00:00"))
    except (AttributeError, ValueError, TypeError):
        return False
    return age >= dt.timedelta(days=1)

def self_test():
    now = dt.datetime(2026, 11, 23, tzinfo=dt.timezone.utc)
    base = {
        "event": "pull_request", "status": "queued", "head_branch": "proof",
        "head_sha": "old", "head_repository": {"full_name": "owner/repo"},
        "created_at": "2026-11-21T00:00:00Z"}
    live = {("owner/repo", "proof"): ("new", 7)}
    assert eligible(base, live, now)
    for change in ({"head_sha":"new"},{"status":"in_progress"},{"event":"push"},
                   {"head_repository":None},{"head_branch":"main"}):
        assert not eligible({**base, **change}, live, now), change
    assert not eligible({**base, "created_at":"2026-11-23T00:00:00Z"}, {}, now)
    assert eligible(base, {}, now)
    print("PASS: 7 fail-closed classification controls")

def api(path, method="GET"):
    url = API + path
    req = urllib.request.Request(
        url, method=method,
        headers={"Authorization": "Bearer "+TOKEN,
                 "Accept": "application/vnd.github+json",
                 "X-GitHub-Api-Version": "2022-11-28",
                 "User-Agent": "nightfall-ci-reconcile"})
    with urllib.request.urlopen(req, timeout=25) as resp:
        raw = resp.read()
    return json.loads(raw) if raw else None

def paged(path, field=None):
    out = []
    for page in range(1, 51):
        part = api(f"{path}{'&' if '?' in path else '?'}per_page=100&page={page}")
        rows = part[field] if field else part
        out.extend(rows)
        if len(rows) < 100:
            return out
    raise RuntimeError("Pagination limit reached; fail closed")

def main():
    self_test()
    if "--execute" not in sys.argv:
        print("Dry run: no cancellation without --execute")
    if not REPO or not TOKEN or "/" not in REPO:
        raise SystemExit("Need GITHUB_REPOSITORY and GH_TOKEN")
    prs = paged(f"repos/{REPO}/pulls?state=open")
    live = {(p["head"]["repo"]["full_name"],p["head"]["ref"]):
            (p["head"]["sha"],p["number"])
            for p in prs if p.get("head",{}).get("repo")}
    queue = paged(f"repos/{REPO}/actions/runs?status=queued", "workflow_runs")
    now = dt.datetime.now(dt.timezone.utc)
    candidates = [r for r in queue if eligible(r,live,now)]
    print(f"Observed {len(queue)} queued runs, {len(candidates)} stale PR candidates")
    cancelled = 0
    for r in candidates[:MAX_CANCEL]:
        # Fresh run state and fresh PR SHA eliminate stale-snapshot races.
        fresh = api(f"repos/{REPO}/actions/runs/{r['id']}")
        if not eligible(fresh, live, now):
            continue
        source = fresh["head_repository"]["full_name"]
        key = (source, fresh["head_branch"])
        if key in live:
            number = live[key][1]
            pr = api(f"repos/{REPO}/pulls/{number}")
            if pr.get("state") != "open" or pr["head"]["sha"] == fresh["head_sha"]:
                continue
        else:
            # If PR was freshly opened, do not cancel an orphan by mistake.
            prs_new = paged(f"repos/{REPO}/pulls?state=open")
            if any(p.get("head",{}).get("repo") and
                   (p["head"]["repo"]["full_name"],p["head"]["ref"]) == key
                   for p in prs_new):
                continue
        print(f"STALE queued {r['id']} {fresh['head_branch']} {fresh['head_sha'][:12]}")
        if "--execute" not in sys.argv:
            continue
        try:
            api(f"repos/{REPO}/actions/runs/{r['id']}/cancel",method="POST")
            cancelled += 1
        except urllib.error.HTTPError as ex:
            if ex.code in (409, 422):  # It already transitioned; not a proof result.
                print(f"Skipped racing job {r['id']}: HTTP {ex.code}")
            else:
                raise
    print(f"Cancelled {cancelled} stale queued PR runs (limit {MAX_CANCEL}); current heads untouched")

if __name__ == "__main__":
    main()
