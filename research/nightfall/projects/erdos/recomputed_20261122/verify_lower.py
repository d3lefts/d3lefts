#!/usr/bin/env python3
"""Exact fixed-eight-row lower deduction; original Wetch/Arb premises remain inherited.

Unpacks the byte-verified historic rows and the new 2026-11-22 certificate for
inspection in lower_source/, checks rational endpoint coverage and a separate
rational ceiling countercheck. This DOES NOT prove the universal kernel premise.
"""
from pathlib import Path
from fractions import Fraction as Q
import base64, hashlib, io, json, zipfile

if not __debug__: raise SystemExit("Python -O disables certificate assertions")

ROOT = Path(__file__).resolve().parent
BUNDLE = '38ab33cb54bbe3a1d070c14e86280ed9bba09af83ce83230deeec77901d67718'
ROWS = '87f57049b951c0d576cb868778f11b1514ab83ef5821500dc3205fd5df609cd3'
ORIGINAL = 'cf63d0af70e3ecc0aeba09eace283c27635dd2bd7394f42a818ce9e3a0751f87'
TARGET = Q(3806274746266857709, 10**19)
MEMBERS = {
 'lower/new_fixed_dual_certificate.json',
 'lower/source/certificate.json',
 'lower/source/data/new_rows.tsv',
}

def main():
 encoded = ''.join((ROOT/'lower_tight_bundle.b85').read_text('ascii').split())
 raw = base64.b85decode(encoded)
 assert hashlib.sha256(raw).hexdigest()==BUNDLE, 'lower archive SHA mismatch'
 with zipfile.ZipFile(io.BytesIO(raw)) as z:
  assert z.testzip() is None and set(z.namelist())==MEMBERS
  raw_cert=z.read('lower/source/certificate.json')
  raw_rows=z.read('lower/source/data/new_rows.tsv')
  cfg=json.loads(z.read('lower/new_fixed_dual_certificate.json'))
  assert hashlib.sha256(raw_cert).hexdigest()==ORIGINAL
  assert hashlib.sha256(raw_rows).hexdigest()==ROWS
  assert cfg['source_certificate_sha256']==ORIGINAL and cfg['source_rows_sha256']==ROWS
  original=json.loads(raw_cert)
  # Materialize inspectable source records; never extract arbitrary archive paths.
  for name in sorted(MEMBERS):
   out=ROOT/'lower_source'/name
   out.parent.mkdir(parents=True,exist_ok=True)
   out.write_bytes(z.read(name))
 C=Q(original['new_common_quadratic'])
 assert C<0 and C==Q(cfg['quadratic_c'])
 left,right=Q(original['central_end']),Q(original['outer_begin'])
 assert (left,right)==(Q(cfg['central_left']),Q(cfg['outer_right']))
 rows={}
 for line in raw_rows.decode('ascii').splitlines():
  i,a,b,d=line.split();i=int(i)
  assert i not in rows and Q(d)>0
  rows[i]=(Q(a),Q(b),Q(d))
 assert set(rows)==set(range(8))
 def ret(i,m):
  a,b,d=rows[i];return (a+b*m+C*m*m)/d
 T=Q(cfg['target_exact']); assert T==TARGET and T>Q(original['target'])
 windows=[]
 for w in cfg['windows']:
  i=int(w['row']); lo,hi=Q(w['low']),Q(w['high'])
  assert left<=lo<hi<=right
  assert ret(i,lo)>T and ret(i,hi)>T, ('bad endpoint',i)
  windows.append((lo,hi,i))
 assert len(windows)==8 and {i for _,_,i in windows}==set(rows)
 cover=left
 for lo,hi,i in sorted(windows):
  assert lo<=cover,('gap',cover,lo)
  cover=max(hi,cover)
 assert cover==right
 m=Q(cfg['near_minimizing_mean']); assert left<m<right
 ceiling=max(ret(i,m) for i in rows)
 assert ceiling==Q(cfg['fixed_eight_row_ceiling_exact'])
 assert ceiling-T==Q(cfg['ceiling_gap_above_target_exact'])
 assert 0<ceiling-T<Q(1,10**19)
 print('PASS 8 exact-rational dual-window endpoints, entire intermediate mean cover')
 print('conditional lower target:',T)
 print('frozen eight-row pointwise ceiling:',ceiling)
 print('margin to frozen-family ceiling:',float(ceiling-T))
 print('WARNING: Wetch universal analytic step and source Arb central/outer integrals NOT rerun')

if __name__=='__main__':main()
