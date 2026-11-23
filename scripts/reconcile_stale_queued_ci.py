#!/usr/bin/env python3
"""Reconcile stale queued Actions without deleting receipts or bypassing checks.

Only superseded PR heads and >7-day-old superseded main pushes qualify.
All candidates must remain queued and be revalidated before mutation.
A force-cancel is allowed ONLY after a normal cancellation returns HTTP 409.
""
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

def is_older(run, now, days):
    try:
        when = dt.datetime.fromisoformat(run["created_at"].replace("Z", "+00:00"))
        return now - when >= dt.timedelta(days=days)
    except (KeyError, AttributeError, ValueError, TypeError):
        return False

def eligible_stale_main(run, main_sha, repo, now):
    """Do not touch main's live SHA, any non-push event, or a recent run."""
    return (run.get("status") == "queued" and run.get("event") == "push"
            and run.get("head_branch") == "main"
            and (run.get("head_repository") or {}).get("full_name") == repo
            and bool(run.get("head_sha")) and run["head_sha"] != main_sha
            and is_older(run, now, 7))

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
    main_base = {**base, "event":"push", "head_branch":"main",
                 "head_repository":{"full_name":"owner/repo"},
                 "created_at":"2026-11-11T00:00:00Z"}
    assert eligible_stale_main(main_base, "new", "owner/repo", now)
    for change in ({"head_sha":"new"}, {"event":"pull_request"},
                   {"status":"in_progress"},
                   {"head_repository":{"full_name":"someone/else"}},
                   {"created_at":"2026-11-22T00:00:00Z"}):
        assert not eligible_stale_main({**main_base, **change}, "new", "owner/repo", now), change
    assert not eligible_stale_main({**main_base, "created_at":None}, "new", "owner/repo", now)
    print("PASS: stale-PR and stale-main fail-closed classification controls")

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
    current_main = api(f"repos/{REPO}/branches/main")["commit"]["sha"]
    candidates = [r for r in queue if eligible(r,live,now)
                  or eligible_stale_main(r,current_main,REPO,now)]
    print(f"Observed {len(queue)} queued runs, {len(candidates)} superseded candidates")
    cancelled = 0
    for r in candidates[:MAX_CANCEL]:
        # Fresh run state and fresh PR SHA eliminate stale-snapshot races.
        fresh = api(f"repos/{REPO}/actions/runs/{r['id']}")
        is_pr = eligible(fresh,live,now)
        is_main = eligible_stale_main(fresh,current_main,REPO,now)
        if not (is_pr or is_main):
            continue
        if is_pr:
            source = fresh["head_repository"]["full_name"]
            key = (source, fresh["head_branch"])
            if key in live:
                number = live[key][1]
                pr = api(f"repos/{REPO}/pulls/{number}")
                if pr.get("state") != "open" or pr["head"]["sha"] == fresh["head_sha"]:
                    continue
            else:
                prs_new = paged(f"repos/{REPO}/pulls?state=open")
                if any(p.get("head",{}).get("repo") and
                       (p["head"]["repo"]["full_name"],p["head"]["ref"]) == key
                       for p in prs_new):
                    continue
        if is_main:
            newest_main = api(f"repos/{REPO}/branches/main")["commit"]["sha"]
            if not eligible_stale_main(fresh,newest_main,REPO,now):
                continue
        print(f"STALE queued {r['id']} {fresh['head_branch']} {fresh['head_sha'][:12]}")
        if "--execute" not in sys.argv:
            continue
        try:
            api(f"repos/{REPO}/actions/runs/{r['id']}/cancel",method="POST")
            cancelled += 1
        except urllib.error.HTTPError as ex:
            if ex.code == 409 and is_older(fresh,now,7):
                # GitHub explicitly provides force-cancel for nonresponsive runs.
                # Reconfirm queue state and live branch head after ordinary 409.
                again = api(f"repos/{REPO}/actions/runs/{r['id']}")
                if is_pr:
                    if not eligible(again,live,now):
                        continue
                    source = again["head_repository"]["full_name"]
                    key = (source,again["head_branch"])
                    if key in live:
                        pr = api(f"repos/{REPO}/pulls/{live[key][1]}")
                        if pr.get("state") != "open" or pr["head"]["sha"] == again["head_sha"]:
                            continue
                    else:
                        prs_new = paged(f"repos/{REPO}/pulls?state=open")
                        if any(p.get("head",{}).get("repo") and
                               (p["head"]["repo"]["full_name"],p["head"]["ref"]) == key
                               for p in prs_new):
                            continue
                else:
                    newest_main = api(f"repos/{REPO}/branches/main")["commit"]["sha"]
                    if not eligible_stale_main(again,newest_main,REPO,now):
                        continue
                try:
                    api(f"repos/{REPO}/actions/runs/{r['id']}/force-cancel",method="POST")
                    cancelled += 1
                    print(f"Force-cancelled nonresponsive 7d+ run {r['id']}")
                except urllib.error.HTTPError as force_ex:
                    if force_ex.code in (409,422):
                        print(f"GitHub still rejects stale run {r['id']}: HTTP {force_ex.code}")
                    else:
                        raise
            elif ex.code in (409,422):
                print(f"Skipped racing job {r['id']}: HTTP {ex.code}")
            else:
                raise
    print(f"Accepted {cancelled} cancellation requests (limit {MAX_CANCEL}); current heads untouched")

if __name__ == "__main__":
    main()
