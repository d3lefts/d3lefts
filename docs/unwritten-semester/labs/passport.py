#!/usr/bin/env python3
"""Byte-identity manifest and declared dependency impact checker.

A matching hash is NOT evidence of authorship, reviewer independence, scientific
validity, or authority to deploy. No network, executable deserialization, or shell.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path


def safe_relpath(root, relative):
    if not relative or not isinstance(relative,str):
        raise ValueError('empty/non-string dependency path')
    relative_path=Path(relative)
    if relative_path.is_absolute() or '..' in relative_path.parts:
        raise ValueError('unsafe path '+repr(relative))
    full=(root/relative_path).resolve()
    if not full.is_relative_to(root.resolve()):
        raise ValueError('path escapes root '+repr(relative))
    return full


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def create(root, paths, claim):
    root=Path(root).resolve()
    if not claim.strip() or not paths: raise ValueError('claim and files are required')
    if len(set(paths))!=len(paths): raise ValueError('duplicate paths')
    files={}
    for item in paths:
        path=safe_relpath(root,item)
        if not path.is_file():raise ValueError('file not found: '+item)
        files[item]=digest(path)
    return {'schema':'unwritten-passport/v1','claim':claim,
            'status':'unreviewed-byte-identity-manifest',
            'files':dict(sorted(files.items())),
            'limitations':['Untracked inputs and environment may matter.',
                           'SHA-256 equality does not authenticate creator or content.',
                           'Neither a theorem proof nor a deployment safety certificate.']}


def inspect(root, manifest):
    root=Path(root).resolve()
    if manifest.get('schema')!='unwritten-passport/v1' or not isinstance(manifest.get('files'),dict):
        raise ValueError('unsupported manifest')
    checks={}
    for name,expected in manifest['files'].items():
        if not isinstance(expected,str) or len(expected)!=64 or any(c not in '0123456789abcdef' for c in expected):
            raise ValueError('invalid digest for '+str(name))
        path=safe_relpath(root,name)
        checks[name]=('missing' if not path.is_file() else
                      'matching' if digest(path)==expected else 'changed')
    return {'status':('byte-identical' if all(x=='matching' for x in checks.values()) else
                      'recheck-required'), 'files':checks,
            'limitation':'Byte-identity comparison only; dependency completeness not established.'}


def impact(graph, inspections):
    claims=graph.get('claims')
    if not isinstance(claims,dict):raise ValueError('graph requires claims mapping')
    known_files={'file:'+name for name in inspections['files']}
    for name,deps in claims.items():
        if not isinstance(name,str) or not name or not isinstance(deps,list) or not deps:
            raise ValueError('each named claim needs nonempty dependency list')
        for dep in deps:
            if dep not in known_files and not (isinstance(dep,str) and dep.startswith('claim:') and dep[6:] in claims):
                raise ValueError('unrecognized dependency '+str(dep))
    # A cycle makes this toy dependency model invalid even though a fixed point exists.
    visiting,visited=set(),set()
    def visit(name):
        if name in visiting:raise ValueError('cycle in claim dependencies')
        if name in visited:return
        visiting.add(name)
        for dep in claims[name]:
            if dep.startswith('claim:'): visit(dep[6:])
        visiting.remove(name);visited.add(name)
    for key in claims:visit(key)
    touched={'file:'+key for key,v in inspections['files'].items() if v!='matching'}
    invalidated=set()
    for name in visited:
        if any(dep in touched for dep in claims[name]):invalidated.add(name)
    changed=True
    while changed:
        before=len(invalidated)
        for name,deps in claims.items():
            if any(dep.startswith('claim:') and dep[6:] in invalidated for dep in deps):
                invalidated.add(name)
        changed=len(invalidated)>before
    return {'scope':'transitive closure of explicitly declared graph only',
            'directly_changed_files':sorted(touched),
            'claims_needing_recheck':sorted(invalidated),
            'unaffected_in_declared_graph':sorted(set(claims)-invalidated),
            'limitation':'Unmodeled dependencies or semantic changes can invalidate this impact analysis.'}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    sub=p.add_subparsers(dest='cmd',required=True)
    c=sub.add_parser('create')
    c.add_argument('--root',default='.')
    c.add_argument('--claim',required=True)
    c.add_argument('--out',required=True)
    c.add_argument('files',nargs='+')
    v=sub.add_parser('verify')
    v.add_argument('--root',default='.')
    v.add_argument('--manifest',required=True)
    v.add_argument('--graph')
    args=p.parse_args()
    try:
        if args.cmd=='create':
            out=create(args.root,args.files,args.claim)
            path=Path(args.out);path.parent.mkdir(parents=True,exist_ok=True)
            path.write_text(json.dumps(out,indent=2,sort_keys=True)+'\n',encoding='utf-8')
        else:
            out=inspect(args.root,json.loads(Path(args.manifest).read_text(encoding='utf-8')))
            if args.graph:
                out['impact']=impact(json.loads(Path(args.graph).read_text(encoding='utf-8')),out)
    except (ValueError,OSError,json.JSONDecodeError) as exc:p.error(str(exc))
    print(json.dumps(out,indent=2,sort_keys=True))
    if args.cmd=='verify' and out['status']!='byte-identical':raise SystemExit(1)

if __name__=='__main__':main()
