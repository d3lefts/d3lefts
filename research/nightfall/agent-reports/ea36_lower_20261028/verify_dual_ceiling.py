#!/usr/bin/env python3
"""Exact rational audit of frozen 2026-10-27 EA36 lower rows (no network).

Usage: python3 verify_dual_ceiling.py ERDOS36_NEW_LOWER_ENVELOPE_20261027.zip
This independently checks source hashes, all eight exact interval endpoints,
full intermediate-mean coverage and a rational fixed-library ceiling.
Wetch's universal analytic and Arb interval prerequisites are inherited.
"""
import hashlib,io,json,sys,zipfile
from fractions import Fraction as F
from pathlib import Path

SHA="fe2a2027910a89ffdfa6c28cfd5f70228ffe5a26fa0e6c5d5dd12a5656d91f91"
ROOT="ERDOS36_NEW_LOWER_ENVELOPE_20261027/"
TARGET=F("0.38062747462668")
M0=F("0.00015476385606657769751043995839161416772")
CEILING=F("0.380627474626686")
LEFT,RIGHT=F(1,25000),F(9,2560)

def verify(path):
    data=Path(path).read_bytes()
    assert hashlib.sha256(data).hexdigest()==SHA,"ZIP identity changed"
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        assert z.testzip() is None,"ZIP CRC mismatch"
        def read(s):return z.read(ROOT+s)
        cert=json.loads(read("certificate.json"))
        old=json.loads(read("data/certificate.json"))
        rows=read("data/new_rows.tsv")
        assert hashlib.sha256(rows).hexdigest()==cert["original_rows_sha256"]
        assert hashlib.sha256(read("data/certificate.json")).hexdigest()==cert["original_certificate_sha256"]
        assert hashlib.sha256(read("data/RETARGET_V5_PLUS.json")).hexdigest()==cert["parent_retarget_sha256"]
    assert F(cert["target"])==TARGET
    assert F(cert["central_end"])==LEFT
    assert F(cert["outer_begin"])==RIGHT
    c=F(cert["new_common_quadratic"])
    assert c<0 and cert["new_common_quadratic"]==old["new_common_quadratic"]
    R={}
    for line in rows.decode().splitlines():
        i,a,b,d=line.split()
        i=int(i)
        assert i not in R and F(d)>0
        R[i]=(F(a),F(b),F(d))
    assert set(R)==set(range(8))
    reach=LEFT
    witnessed=set()
    for w in sorted(cert["windows"],key=lambda w:F(w["low"])):
        i=w["row"];lo,hi=F(w["low"]),F(w["high"])
        assert i not in witnessed and LEFT<=lo<hi<=RIGHT and lo<=reach
        witnessed.add(i)
        a,b,d=R[i]
        for m in (lo,hi):
            assert a+b*m+c*m*m>TARGET*d,("invalid endpoint",i,m)
        reach=max(reach,hi)
    assert reach==RIGHT and witnessed==set(range(8))
    values={i:(a+b*M0+c*M0*M0)/d for i,(a,b,d) in R.items()}
    worst=max(values.values())
    assert TARGET<worst<CEILING
    assert max(values,key=values.get) in (2,3)
    print(json.dumps({
      "result":"PASS",
      "verified_lower_conditional":str(TARGET),
      "fixed_library_ceiling":str(CEILING),
      "fixed_library_gap_less_than":str(CEILING-TARGET),
      "rational_obstruction_mean":str(M0),
      "max_at_mean_exact":str(worst),
      "source_archive_sha256":SHA,
      "scope":"Exact dual-window arithmetic and fixed eight-row ceiling only; inherited Wetch universal and Arb prerequisites"
    },indent=2))
if __name__=="__main__":
    if len(sys.argv)!=2:raise SystemExit("Provide original archived ZIP path")
    verify(sys.argv[1])
