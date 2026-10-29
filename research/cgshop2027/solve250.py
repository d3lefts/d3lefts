#!/usr/bin/env python3
"""CG:SHOP 2027 250-instance full-coverage baseline.

Conservative constructive guarantee: an axis-aligned rectangle contained in
the actual cutter footprint sweeps every region cell when translated along
the computed rectilinear lanes. Feasibility is independently verified using
the official CG:SHOP 2027 checker before an archive is emitted.
"""
import argparse
import json
import zipfile
from pathlib import Path

import numpy as np
from cgshop2027_pyutils.schemas import CGSHOP2027Instance, CGSHOP2027Solution
from cgshop2027_pyutils.verify import SolutionValidator
from cgshop2027_pyutils.zip import ZipWriter


def cores(cutter):
    mask = cutter.mask
    x0, y0 = cutter.origin
    height, width = mask.shape
    hist = [0] * width
    best = {}
    for r in range(height):
        for c in range(width):
            hist[c] = hist[c] + 1 if mask[r, c] else 0
        stack = []
        for c in range(width + 1):
            cur, start = (hist[c] if c < width else 0), c
            while stack and stack[-1][1] > cur:
                start, ht = stack.pop()
                if ht:
                    rect = (x0 + start, y0 + r - ht + 1, x0 + c, y0 + r + 1)
                    w = c - start
                    keys = {'area': (w * ht, ht, w),
                            'width': (w, ht, w * ht),
                            'height': (ht, w, w * ht)}
                    for kind, key in keys.items():
                        if kind not in best or key > best[kind][0]:
                            best[kind] = (key, rect)
            if not stack or stack[-1][1] < cur:
                stack.append((start, cur))
    yi, xi = np.argwhere(mask)[0]
    fallback = (int(x0 + xi), int(y0 + yi), int(x0 + xi + 1), int(y0 + yi + 1))
    return list(dict.fromkeys([record[1] for record in best.values()] + [fallback]))


def lanes_for(region, rect, transposed):
    grid = region.mask.T if transposed else region.mask
    ox, oy = (region.origin[1], region.origin[0]) if transposed else region.origin
    rx0, ry0, rx1, ry1 = rect
    if transposed:
        rx0, ry0, rx1, ry1 = ry0, rx0, ry1, rx1
    lanes = []
    for low in range(0, grid.shape[0], ry1 - ry0):
        col = np.flatnonzero(np.any(grid[low:low + (ry1 - ry0)], axis=0))
        if len(col):
            left = int(col[0]) + ox - rx0
            right = max(left, int(col[-1]) + ox - (rx1 - 1))
            lanes.append((oy + low - ry0, left, right))
    return lanes


def tour_length(tour):
    points = list(zip(tour['x'], tour['y']))
    return sum(abs(a[0] - b[0]) + abs(a[1] - b[1])
               for a, b in zip(points, points[1:] + points[:1])) if len(points) > 1 else 0


def tour_for(lanes, transposed):
    points = []

    def add(x, y):
        p = (int(y), int(x)) if transposed else (int(x), int(y))
        if not points or points[-1] != p:
            points.append(p)

    for idx, (y, left, right) in enumerate(lanes):
        start, end = (left, right) if idx % 2 == 0 else (right, left)
        if points:
            prev_x = points[-1][1] if transposed else points[-1][0]
            add(prev_x, y)
        add(start, y)
        add(end, y)
    first = (points[0][1], points[0][0]) if transposed else points[0]
    last = (points[-1][1], points[-1][0]) if transposed else points[-1]
    if last[0] != first[0] and last[1] != first[1]:
        add(first[0], last[1])
    if len(points) > 1 and points[-1] == points[0]:
        points.pop()
    return {'x': [x for x, _ in points], 'y': [y for _, y in points]}


def partition(lanes, k):
    k = min(k, len(lanes))
    weights = [max(1, b - a) + 2 for _, a, b in lanes]
    targets = [sum(weights) * j / k for j in range(1, k)]
    cut = [0]
    cumulative, j = 0, 0
    for i, weight in enumerate(weights):
        cumulative += weight
        if j < len(targets) and cumulative >= targets[j] and i + 1 > cut[-1] and len(lanes) - i - 1 >= k - j - 1:
            cut.append(i + 1)
            j += 1
    while len(cut) < k:
        cut.append(cut[-1] + 1)
    cut.append(len(lanes))
    if len(set(cut)) != len(cut) or cut != sorted(cut):
        raise ValueError('Cannot partition lanes')
    return cut


def candidate(instance, validator, rect, transposed):
    lanes = lanes_for(validator.region, rect, transposed)
    k = min(instance.number_of_cutters, len(lanes))
    cuts = partition(lanes, k)
    tours = [tour_for(lanes[cuts[i]:cuts[i + 1]], transposed) for i in range(k)]
    for _ in range(3):
        changed = False
        for i in range(1, k):
            old = max(tour_length(tours[i - 1]), tour_length(tours[i]))
            for delta in (-1, 1):
                b = cuts[i] + delta
                if cuts[i - 1] < b < cuts[i + 1]:
                    left = tour_for(lanes[cuts[i - 1]:b], transposed)
                    right = tour_for(lanes[b:cuts[i + 1]], transposed)
                    if max(tour_length(left), tour_length(right)) < old:
                        cuts[i] = b
                        tours[i - 1], tours[i] = left, right
                        changed = True
                        break
        if not changed:
            break
    while len(tours) < instance.number_of_cutters:
        tours.append({'x': [tours[0]['x'][0]], 'y': [tours[0]['y'][0]]})
    return CGSHOP2027Solution.model_validate({
        'instance_uid': instance.instance_uid,
        'tours': tours,
        'meta': {'algorithm': 'NIGHTFALL rectangle-core sweep v1',
                 'core': list(rect), 'orientation': 'vertical' if transposed else 'horizontal'},
    })


def solve(instance):
    validator = SolutionValidator(instance)
    best, stats, rejected = None, None, []
    for core in cores(validator.cutter):
        for transpose in (False, True):
            try:
                sol = candidate(instance, validator, core, transpose)
                errs = validator.check_for_errors(sol)
                if errs:
                    rejected.append((core, transpose, errs))
                    continue
                if best is None or sol.max_tour_length < best.max_tour_length:
                    best = sol
                    stats = {'objective': sol.max_tour_length,
                             'total_length': sol.total_tour_length,
                             'core': core, 'transposed': transpose}
            except Exception as exc:
                rejected.append((core, transpose, repr(exc)))
    if best is None:
        raise RuntimeError(f'{instance.instance_uid}: no feasible solutions: {rejected[:3]}')
    return best, stats


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--instances', required=True)
    parser.add_argument('--output', default='cgshop2027_250_solutions.zip')
    parser.add_argument('--manifest', default='cgshop2027_250_manifest.json')
    parser.add_argument('--expected', type=int, default=250)
    args = parser.parse_args()
    instances = []
    with zipfile.ZipFile(args.instances) as archive:
        for filename in sorted(archive.namelist()):
            if filename.endswith('.instance.json') and not filename.startswith('__MACOSX/'):
                instances.append((filename, CGSHOP2027Instance.model_validate_json(archive.read(filename))))
    if len(instances) != args.expected:
        raise RuntimeError(f'Expected exactly {args.expected} instances, found {len(instances)}; partial archive forbidden')
    if len({v.instance_uid for _, v in instances}) != len(instances):
        raise RuntimeError('Duplicate instance identifiers')
    manifest = {}
    out = Path(args.output)
    with ZipWriter(out) as writer:
        for i, (filename, instance) in enumerate(instances, 1):
            sol, stats = solve(instance)
            writer.add_solution(sol)
            manifest[instance.instance_uid] = {'input': filename, **stats, 'verified': True}
            print(f'[{i}/{len(instances)}] {instance.instance_uid}: {stats["objective"]}', flush=True)
    with zipfile.ZipFile(out) as archive:
        actual = sum(name.endswith('.json') for name in archive.namelist())
    if actual != len(instances):
        out.unlink(missing_ok=True)
        raise RuntimeError(f'Archive contains {actual} solutions, expected {len(instances)}')
    Path(args.manifest).write_text(json.dumps({'count': len(manifest), 'instances': manifest}, indent=2))
    print(f'COMPLETE: {len(manifest)} verified solutions', flush=True)


if __name__ == '__main__':
    main()
