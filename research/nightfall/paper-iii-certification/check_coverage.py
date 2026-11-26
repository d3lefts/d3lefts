from pathlib import Path
import json, re, sys
d=Path("receipts/paper-iii-manuscript")
manifest=json.loads(Path("research/nightfall/paper-iii-certification/claim-map.json").read_text())
log=(d/"named-axioms.log").read_text()
allowed={"Classical.choice","Quot.sound","propext"}
assert "sorryAx" not in log and "error:" not in log
for claim in manifest["claims"]:
    name=claim["declaration"]
    if name:
        m=re.search(r"'"+re.escape(name)+r"' depends on axioms:\s*\[([^\]]*)\]",log,re.S)
        assert m or f"'{name}' does not depend on any axioms" in log,name
        axioms={x.strip() for x in m.group(1).split(",") if x.strip()} if m else set()
        assert axioms<=allowed,(name,axioms)
    print(claim["status"].upper(),claim["label"],claim["scope"])
missing=[x for x in manifest["claims"] if x["status"]!="closed"]
summary={"claims":len(manifest["claims"]),"closed":len(manifest["claims"])-len(missing),"unclosed":missing}
(d/"coverage.json").write_text(json.dumps(summary,indent=2)+"\n")
print("MANUSCRIPT COVERAGE:",summary["closed"],"/",summary["claims"])
if missing:
    print("FAIL: full manuscript certification is incomplete; conditional and partial proofs cannot count as closed.")
    sys.exit(1)
