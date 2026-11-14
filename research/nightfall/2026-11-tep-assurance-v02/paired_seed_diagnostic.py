#!/usr/bin/env python3
"""Descriptive paired-seed signal diagnostic for NORMALIZED TEP CSV exports.

Input schemas are intentionally not assumed for native DTU archives or MATLAB files.
CSV files must have an identical time_s column and common numeric sensor columns.
This is a signal comparison, NOT a physical safety certificate.
"""
import argparse
import csv
import json
import math


def read_csv(path):
    with open(path,newline='') as f:
        rows = list(csv.DictReader(f))
    if not rows or 'time_s' not in rows[0]:
        raise ValueError('normalized CSV must contain time_s and >=1 row')
    keys = list(rows[0])
    if len(keys) < 2:
        raise ValueError('must have at least one sensor column')
    numeric = []
    for row in rows:
        values = {key: float(row[key]) for key in keys}
        if any(not math.isfinite(v) for v in values.values()):
            raise ValueError('nonfinite values')
        numeric.append(values)
    if any(numeric[i]['time_s'] >= numeric[i+1]['time_s'] for i in range(len(numeric)-1)):
        raise ValueError('timestamps must be strictly increasing')
    return keys,numeric


def diagnostic(normal_path,fault_path,fault_time):
    normal_columns, normal = read_csv(normal_path)
    fault_columns, faulty = read_csv(fault_path)
    if normal_columns != fault_columns:
        raise ValueError('normal and faulty CSV columns differ')
    if len(normal) != len(faulty):
        raise ValueError('normal/faulty trace lengths differ')
    if any(a['time_s'] != b['time_s'] for a,b in zip(normal,faulty)):
        raise ValueError('pair must align exactly in timestamps')
    pre=[i for i,a in enumerate(normal) if a['time_s'] < fault_time]
    post=[i for i,a in enumerate(normal) if a['time_s'] >= fault_time]
    if len(pre)<2 or len(post)<2:
        raise ValueError('must have >=2 pre-fault and post-fault samples')
    answer = {}
    for col in normal_columns:
        if col == 'time_s': continue
        delta = [faulty[i][col]-normal[i][col] for i in range(len(normal))]
        rms_pre = (sum(delta[i]**2 for i in pre)/len(pre))**0.5
        rms_post = (sum(delta[i]**2 for i in post)/len(post))**0.5
        scale = sum(abs(normal[i][col]) for i in post)/len(post)
        answer[col] = {
            'pre_fault_pair_rms':rms_pre,
            'post_fault_pair_rms':rms_post,
            'post_fault_relative_rms_pct': 100*rms_post/scale if scale>0 else None,
            'normal_post_mean_abs_scale':scale
        }
    return {'status':'descriptive_only_no_safety_claim',
            'fault_time_s':fault_time,
            'normal_n':len(normal),'pre_n':len(pre),'post_n':len(post),
            'signals':answer}


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('normal_csv'); ap.add_argument('fault_csv')
    ap.add_argument('--fault-time-s',type=float,required=True)
    args=ap.parse_args()
    print(json.dumps(diagnostic(args.normal_csv,args.fault_csv,args.fault_time_s),indent=2))
