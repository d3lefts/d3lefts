#!/usr/bin/env python3
"""
Reproduce the OpenAI Math prospective verification ranking frozen on
2026-10-06 at commit adc7f1241b42e322a6451854ab7e4b4c146bf78a.

Requires: Python 3.10+ and requests.
"""
import csv, re, sys, requests
from pathlib import Path

COMMIT = "adc7f1241b42e322a6451854ab7e4b4c146bf78a"
URL = f"https://raw.githubusercontent.com/openai/math/{COMMIT}/CONTENTS.md"
EXPECTED_COUNT = 372
EXPECTED_FNV1A64 = "c429732aac46eae9"

def fnv1a64_ascii(s):
    h = 0xcbf29ce484222325
    p = 0x100000001b3
    for b in s.encode("ascii"):
        h ^= b
        h = (h * p) & 0xffffffffffffffff
    return f"{h:016x}"

text = requests.get(URL, timeout=60).text
text and None
pat = re.compile(r"\*\*(\d{3})\.\s*([^*]+?)\*\*([\s\S]*?)(?=\*\*\d{3}\.\s|$)")
rows = []
for m in pat.finditer(text):
    fid, title, block = m.group(1), m.group(2).strip(), m.group(3)
    first_cell = block.split("</td>")[0]
    lean = 1 if re.search(r"\(\[Lean\]\([^)]+\)\)", first_cell) else 0
    desc = re.sub(r"\(\[Lean\]\([^)]+\)\)", " ", first_cell)
    desc = re.sub(r"<[^>]+>", " ", desc)
    desc = re.sub(r"[`$*_]", " ", desc)
    desc = re.sub(r"\s+", " ", desc).strip()
    words = len(re.findall(r"\b[\w’'-]+\b", desc, flags=re.UNICODE))
    dirs = set(re.findall(r"\]\(preprints/([^/]+)/[^)]+\.pdf\)", block))
    rows.append(dict(
        id=fid, title=title, lean_formalized=lean,
        manuscript_count=len(dirs), description_words=words
    ))

rows.sort(key=lambda r: (
    r["lean_formalized"],
    -r["manuscript_count"],
    -r["description_words"],
    r["id"],
))
assert len(rows) == EXPECTED_COUNT, (len(rows), EXPECTED_COUNT)
seq = ",".join(r["id"] for r in rows)
fp = fnv1a64_ascii(seq)
assert fp == EXPECTED_FNV1A64, (fp, EXPECTED_FNV1A64)

out = Path(sys.argv[1] if len(sys.argv) > 1 else "openai_math_priority_ranking_2026-10-06.csv")
with out.open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=[
        "rank","id","lean_formalized","manuscript_count","description_words","title"
    ])
    w.writeheader()
    for i, r in enumerate(rows, 1):
        w.writerow(dict(rank=i, **r))
print(f"Wrote {len(rows)} rows to {out}")
print("fingerprint", fp)