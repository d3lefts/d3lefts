#!/usr/bin/env python3
"""Audit exact named declarations, ordinary axioms, and fresh replay receipts."""
import sys,re
from pathlib import Path
lane,d=sys.argv[1],Path(sys.argv[2])
targets={
"PaperVIGeneralLatentTerminal":["paper_vi_general_mse_wyner","paper_vi_quadratic_mse_wyner"],
"PaperVIReferenceTransfer":["reference_general_mse","reference_quadratic_mse"],
"PaperVIPaidTransfer":["paid_tree_mse","paid_general_wyner_mse"]
}

allowed={"propext","Classical.choice","Quot.sound"}
for mod,names in targets.items():
    p=d/(mod+".log")
    assert p.is_file(),mod
    s=p.read_text()
    assert "sorryAx" not in s and not re.search(r"error:|error\(lean\.",s),mod
    ax=dict(re.findall(r"'([^']+)' depends on axioms:\s*\[([^\]]*)\]",s))
    ax.update({n:"" for n in re.findall(r"'([^']+)' does not depend on any axioms",s)})
    for name in names:
        match=[n for n in ax if n.endswith("."+name)]
        assert len(match)==1,(mod,name,match)
        assert {a.strip() for a in ax[match[0]].split(",") if a.strip()}<=allowed,(mod,name)
        print(mod,match[0],ax[match[0]])
    k=d/(mod+".kernel.log")
    assert k.is_file() and k.stat().st_size,mod
print("Named terminals accepted; no claim of manuscript-wide completeness.")
