#!/usr/bin/env python3
"""Reproduce a narrow *historical* Braatz-lineage TEP data probe, NOT DTU/COSTEP.

With internet: python3 original_tep_probe.py --download --out result.json
Offline:       python3 original_tep_probe.py --data-dir ./raw --out result.json

Hashes are immutable Git blob integrity checks, NOT guarantees of external source
authenticity, fault timing, calibration, or physical safety. No third-party libs.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
from urllib.request import urlopen

REV = '9a6c8e5fcef4a2850778704e7793c87b0a187005'
ORIGIN = 'https://github.com/jkitchin/tennessee-eastman-profbraatz'
SOURCES = {
    'd00.dat': ('ffcb9a1b4f34412bc3ef9a91ff19862e720f3c42', (52,500)),
    'd00_te.dat': ('a64b904657520e922bc5480031b52824e020d7c5', (960,52)),
    'd01_te.dat': ('fc149090376bc4f1a33dd8c324b9a031a9972458', (960,52)),
}
MONITORED = {4:'A/C feed flow',5:'recycle flow',7:'reactor pressure',9:'reactor temperature',40:'G product concentration'}
ONSET = 160  # *assumed* from common TEP testing protocol; not source-validated here.


def git_blob_sha(raw):
    return hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()


def read_data(name, raw):
    expected_sha, shape = SOURCES[name]
    digest=git_blob_sha(raw)
    if digest != expected_sha:
        raise ValueError(f'{name} blob SHA mismatch, expected {expected_sha}, got {digest}')
    rows=[]
    for line in raw.decode('ascii').splitlines():
        if not line.strip(): continue
        vals=[float(part) for part in line.split()]
        if any(not math.isfinite(x) for x in vals):
            raise ValueError('NaN or infinity')
        rows.append(vals)
    if len(rows)!=shape[0] or any(len(row)!=shape[1] for row in rows):
        raise ValueError(f'{name}: unexpected dimensions: {len(rows)} by {[len(row) for row in rows[:2]]}')
    if name=='d00.dat':
        rows=[[rows[j][i] for j in range(52)] for i in range(500)]
    return rows


def mean(vals):
    return sum(vals)/len(vals)


def run(data):
    normal_train=data['d00.dat']; normal_test=data['d00_te.dat']; fault=data['d01_te.dat']
    if not (len(normal_train)==500 and len(normal_test)==len(fault)==960):
        raise ValueError('invalid run lengths')
    report={}
    for idx,description in MONITORED.items():
        j=idx-1
        train=[r[j] for r in normal_train]
        mu=mean(train)
        sd=math.sqrt(sum((v-mu)**2 for v in train)/(len(train)-1))
        if not sd>0: raise ValueError(f'zero training deviation for {idx}')
        n=[r[j] for r in normal_test]
        f=[r[j] for r in fault]
        npre,npost=n[:ONSET],n[ONSET:]
        fpre,fpost=f[:ONSET],f[ONSET:]
        nc=sum(abs(x-mu)>3*sd for x in npost)
        fc=sum(abs(x-mu)>3*sd for x in fpost)
        report[f'XMEAS({idx})']={
            'description': description,
            'mean_normal_training':mu,
            'sd_normal_training':sd,
            'pre_difference_training_sd':(mean(fpre)-mean(npre))/sd,
            'post_difference_training_sd':(mean(fpost)-mean(npost))/sd,
            'normal_post_exceedances':nc,
            'fault1_post_exceedances':fc,
            'post_samples_per_trace':len(npost),
            'normal_post_exceedance_fraction':nc/len(npost),
            'fault1_post_exceedance_fraction':fc/len(fpost)
        }
    return {
        'status':'source_based_descriptive_only_not_dtu_not_safety',
        'source_repository':ORIGIN,
        'source_commit':REV,
        'source_git_blob_sha1':{f:meta[0] for f,meta in SOURCES.items()},
        'input_shapes_after_normalization': {'d00.dat':[500,52],'d00_te.dat':[960,52],'d01_te.dat':[960,52]},
        'fault':'IDV(1) A/C feed ratio, B composition constant',
        'fault_onset_index_assumption':ONSET,
        'threshold':'abs(x-normal_train_mean)>3*normal_train_sample_sd',
        'warning':'Three time series, not independently replicated or shared-seed paired; no physical-safe threshold, mission certificate, confidence interval, or DTU evaluation.',
        'channels':report
    }


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data-dir', default='raw')
    parser.add_argument('--download',action='store_true')
    parser.add_argument('--out',default='results_original_tep_replay.json')
    args=parser.parse_args()
    folder=Path(args.data_dir)
    if args.download: folder.mkdir(parents=True,exist_ok=True)
    loaded={}
    for name in SOURCES:
        path=folder/name
        if args.download:
            url=f'https://raw.githubusercontent.com/jkitchin/tennessee-eastman-profbraatz/{REV}/data/{name}'
            with urlopen(url,timeout=45) as response:
                raw=response.read()
            if git_blob_sha(raw)!=SOURCES[name][0]:
                raise ValueError('upstream blob mismatch; refusing to save')
            path.write_bytes(raw)
        else:
            raw=path.read_bytes()
        loaded[name]=read_data(name,raw)
    report=run(loaded)
    Path(args.out).write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(f'Validated historical TEP data and wrote {args.out}; NOT DTU and NOT a safety certificate.')

if __name__=='__main__':main()
