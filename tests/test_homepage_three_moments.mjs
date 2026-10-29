// Homepage editorial restraint guard. No external libraries or browser APIs.
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';

const html=readFileSync('docs/index.html','utf8');
const styles=readFileSync('docs/home-rhythm.css','utf8');
const find=(x)=>html.indexOf(x);
const count=(s,pattern)=>(s.match(pattern)||[]).length;

test('A single coherent front-door narrative retains the original scientific page',()=>{
  const stages=[
    '<section class="hero wrap"',
    '<section class="section wrap flagships"',
    '<section class="instrument-bridge wrap"',
    '<section class="section wrap sf-case"',
    '<section class="nf-observatory wrap"'
  ].map(find);
  assert.ok(stages.every((v,i)=>v>=0&&(i===0||v>stages[i-1])),String(stages));
  assert.equal(count(html,/<article class="flagship-card/g),4);
  assert.equal(count(html,/<a class="feature (?:dark|lime)?"/g),5);
  assert.equal(count(html,/class="review-card"/g),3);
  for(const id of ['main','flagships','instruments','live-case','observatory','section-index','research-systems','featured-title','evidence','work','review','method']){
    assert.ok(html.includes('id="'+id+'"'),id);
  }
});

test('Secondary material is accessible but initially folded; source and evidence preserved',()=>{
  const sections=['nf-frontiers-disclosure','nf-findings-disclosure','nf-provenance-disclosure','nf-audits-disclosure'];
  for(const cls of sections){
    const start=html.indexOf('<details class="nf-deep-disclosure '+cls+'"');
    assert.ok(start>=0,cls);
    const summary=html.indexOf('<summary>',start);
    const close=html.indexOf('</details>',start);
    assert.ok(summary>start&&close>summary,cls+' summary');
    assert.ok(!html.slice(start,summary).includes(' open'),cls+' should initially be collapsed');
  }
  for(const path of [
    'erdos-paper.html','research.html','living-paper.html','join.html#results',
    'constellation.html','passport.html?claim=sidon30','review.html#erdos',
    'review.html#sidon','review.html#pas','findings-20261029.html#singer975',
    'findings-20261029.html#graph-3port'
  ]) assert.ok(html.includes('href="'+path+'"'),path);
  for(const claim of ['131,072-cell','30-point Sidon','4–25','40-edge packing',
                      'external review','2⁻⁹⁶','8/20 versus 11/20']) {
    assert.ok(html.toLowerCase().includes(claim.toLowerCase()),claim);
  }
});

test('Internal homepage fragment destinations remain navigable',()=>{
  const ids=new Set([...html.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]));
  for(const m of html.matchAll(/href="#([a-z0-9_-]+)"/gi))
    assert.ok(ids.has(m[1]),'#'+m[1]);
  assert.ok(count(html,/href="/g)>=95,'Research archive URLs were lost');
  assert.equal(count(html,/<section\b/g),17,'A source section was deleted');
});

test('Readability and responsive treatments exist in both appearance modes',()=>{
  assert.ok(html.includes('href="home-rhythm.css"'));
  for(const s of [
    '.nf-focus-result-grid','.nf-secondary-frontiers-grid',
    '.nf-deep-disclosure > summary:focus-visible',
    'html[data-nf-theme="dusk"] .nf-deep-disclosure',
    '@media (max-width:820px)','@media (max-width:620px)',
    '@media (prefers-reduced-motion:reduce)'
  ]) assert.ok(styles.includes(s),s);
});
