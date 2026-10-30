// Homepage editorial contract: the record is deep, the public entrance is selective.
import {readFileSync} from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';

const html=readFileSync('docs/index.html','utf8');
const styles=readFileSync('docs/home-rhythm.css','utf8');
const find=s=>html.indexOf(s);
const count=(s,re)=>(s.match(re)||[]).length;

test('The two themed opening skies and Erdős cinematic precede the three detailed research moments',()=>{
 const stages=[
  '<section class="hero wrap',
  '<section class="nf-cinema"',
  '<section class="section wrap flagships"',
  '<section class="section wrap sf-case"',
  '<section class="section wrap sf-library-invite" id="featured-title"',
  '<section class="nf-observatory wrap"',
  '<section class="section review-section"',
  '<section class="section wrap sf-library-invite" id="work"'
 ].map(find);
 assert.ok(stages.every((v,i)=>v>=0&&(i===0||v>stages[i-1])),String(stages));
 assert.equal(count(html,/<article class="flagship-card/g),4,"All four scoped frontier research programs remain");
 assert.ok(html.includes("0.380856370118")&&html.includes("17 / 30")&&html.includes("Proof After Scarcity v2")&&html.includes("unvalidated"));
 for(const id of ["main","flagships","live-case","featured-title","nf-scroll-cinema","observatory","review","work","research-systems"])assert.ok(html.includes('id="'+id+'"'),id);
});

test('Detailed evidence and tools move to dedicated public destinations',()=>{
 for(const path of [
  'erdos-paper.html','research.html','living-paper.html','constellation.html#map',
  'passport.html?claim=sidon30','referee.html?domain=sidon',
  'review.html#erdos','review.html#priority','review.html#pas',
  'evidence.html#public-downloads','exact-research.html#research-tools-directory'
 ])assert.ok(html.includes('href="'+path+'"'),path);
 for(const scope of ['131,072-cell','30-point Sidon','4–25','external review','2⁻⁹⁶','Proof After Scarcity v2'])assert.ok(html.toLowerCase().includes(scope.toLowerCase()),scope);
 const secondary=html.indexOf('<details class="nf-deep-disclosure nf-frontiers-disclosure">');
 assert.ok(secondary>=0,"Supplemental research still available");
 assert.ok(!html.slice(secondary,html.indexOf("<summary>",secondary)).includes(" open"));
 assert.ok(!html.includes("nf-home-toolbox")&&!html.includes("instrument-workflow"));
 assert.ok(!html.includes("nf-section-index")&&!html.includes('src="observatory-home.js"'));
});

test('One entrance with fewer distractions and valid fragment destinations',()=>{
 const ids=new Set([...html.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]));
 for(const m of html.matchAll(/href="#([a-z0-9_-]+)"/gi))assert.ok(ids.has(m[1]),'#'+m[1]);
 assert.ok(count(html,/<a\b/g)<=45,"Homepage link density exceeds editorial budget");
 assert.ok(count(html,/<section\b/g)<=13,"Homepage sections exceed editorial budget");
 assert.ok(count(html,/<details\b/g)<=2,"Excessive nested disclosures");
 assert.equal(count(html,/id="nf-scroll-cinema"/g),1);
 assert.equal(count(html,/class="nf-experience nf-experience-(?:archive|underbelly) nf-dual-colophon/g),2);
 assert.equal(count(html,/class="nf-dual-index/g),0,"No duplicated three-destination entrance");
 const dual=readFileSync('docs/home-dual-experience.css','utf8');
 assert.match(dual,/html:not\(\[data-nf-theme="dusk"\]\) \.nf-experience-underbelly/);
 assert.match(dual,/html\[data-nf-theme="dusk"\] \.nf-experience-archive/);
 assert.ok(html.includes('href="home-dual-experience.css"'));
});

test('Scientific qualifiers survive the tighter narrative',()=>{
 assert.ok(html.includes('id="hero-title-archive">A precise number.<br><em>An open record.</em>'));
 assert.ok(html.includes('id="hero-title">Every shift.<br><em>Every assumption.</em>'));
 for(const q of ['external review','unproved','failed experiment','internal exact replay'])assert.ok(html.toLowerCase().includes(q),q);
 assert.ok(html.includes("no edge certifies a transfer theorem"));
});

test('Editorial sizing and motion controls retain accessible treatments',()=>{
 assert.ok(html.includes('href="home-rhythm.css"'));
 for(const s of ['.nf-focus-result-grid','.nf-secondary-frontiers-grid',
  '.nf-deep-disclosure > summary:focus-visible',
  'html[data-nf-theme="dusk"] .nf-deep-disclosure',
  '@media (max-width:820px)','@media (max-width:620px)',
  '@media (prefers-reduced-motion:reduce)'])assert.ok(styles.includes(s),s);
});

test('Opening and scroll chapters disclose the exact finite record before other campaigns',()=>{
 const hero=html.indexOf('<section class="hero wrap nf-opening"');
 const movie=html.indexOf('<section class="nf-cinema"');
 const others=html.indexOf('<section class="section wrap flagships"');
 assert.ok(hero>=0&&movie>hero&&others>movie);
 const front=html.slice(hero,others);
 assert.match(front,/Erdős overlap finite witness record/);
 assert.match(front,/Source-bound Erdős finite overlap record/);
 assert.ok((front.match(/0\.380856370118/g)||[]).length===2);
 assert.ok((front.match(/131,072/g)||[]).length>=3);
 for(const disclaimer of ['separate, incompletely recovered artifact','external review open','global optimum'])
  assert.ok(front.toLowerCase().includes(disclaimer.toLowerCase()),disclaimer);
 assert.match(front,/href="erdos-paper\.html"/);
 assert.match(front,/href="review\.html#erdos"/);
});
