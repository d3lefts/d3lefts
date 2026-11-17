#!/usr/bin/env python3
"""Dependency-free generated static-site local-link/anchor checker."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote,urlsplit

ROOT=Path(__file__).resolve().parents[1]
class Links(HTMLParser):
    def __init__(self):
        super().__init__();self.links=[];self.ids=set();self.dupes=[]
    def handle_starttag(self,tag,attrs):
        att=dict(attrs)
        if 'id' in att:
            if att['id'] in self.ids:self.dupes.append(att['id'])
            self.ids.add(att['id'])
        for key in ('href' if tag in ('a','link') else 'src' if tag=='script' else 'irrelevant',):
            if key in att:self.links.append(att[key])

def run():
    pages={}
    for item in ROOT.rglob('*.html'):
        if any(x.startswith('.') for x in item.relative_to(ROOT).parts): continue
        parser=Links();parser.feed(item.read_text(encoding='utf-8'));pages[item.resolve()]=parser
    errors=[];checked=0
    for current,parser in pages.items():
        if parser.dupes:errors.append(f'{current}: duplicate ids {parser.dupes}')
        for ref in parser.links:
            uri=urlsplit(ref)
            if uri.scheme or uri.netloc or ref.startswith(('mailto:','tel:','data:')):continue
            target=(current.parent/unquote(uri.path)).resolve() if uri.path else current
            if target.is_dir():target=target/'index.html'
            if not target.is_relative_to(ROOT):errors.append(f'{current}: href escapes course {ref}');continue
            checked+=1
            if not target.is_file():errors.append(f'{current.relative_to(ROOT)}: nonexistent {ref}');continue
            if uri.fragment and target.suffix=='.html':
                if target not in pages or unquote(uri.fragment) not in pages[target].ids:
                    errors.append(f'{current.relative_to(ROOT)}: missing anchor {ref}')
    return errors,len(pages),checked

if __name__=='__main__':
    problems,n,k=run()
    if problems:
        print('\n'.join('FAIL '+x for x in problems));raise SystemExit(1)
    print(f'PASS: {n} HTML pages, {k} relative references and anchors verified')
