import {readFileSync} from 'node:fs';
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {Script} from 'node:vm';

const html=readFileSync('docs/index.html','utf8');
const css=readFileSync('docs/home-opening-cinema.css','utf8');
const js=readFileSync('docs/home-opening-cinema.js','utf8');

test('opening scene is progressive, purely decorative, and both readings remain available',()=>{
 assert.match(html,/<section class="hero wrap nf-opening"/);
 assert.match(html,/class="nf-opening-art nf-opening-art--gold" aria-hidden="true"/);
 assert.match(html,/class="nf-opening-art nf-opening-art--night" aria-hidden="true"/);
 assert.match(html,/class="nf-opening-constellation"[\s\S]*?pathLength="1"/);
 assert.match(html,/href="home-opening-cinema.css"/);
 assert.match(html,/src="home-opening-cinema.js" defer/);
 assert.match(html,/id="hero-title-archive"/);
 assert.match(html,/class="nf-opening-overlap"/);
 assert.match(html,/class="nf-cinema-record"/);
 assert.ok(html.indexOf('id="nf-scroll-cinema"')<html.indexOf('id="flagships"'));
 assert.match(html,/id="hero-title"/);
 assert.match(html,/href="#flagships"/);
 assert.match(html,/href="review.html#priority"/);
 assert.match(html,/id="nf-scroll-cinema"/); // retain the second-act cinema
 assert.match(css,/prefers-reduced-motion:reduce/);
 assert.match(css,/\.nf-opening-art\{[\s\S]*?pointer-events:none/);
 assert.match(css,/\.nf-opening-overlap a:focus-visible/);
 assert.match(css,/html\[data-nf-theme="dusk"\] \.nf-opening-art--gold\{display:none\}/);
 assert.match(css,/html\[data-nf-theme="dusk"\] \.nf-opening-art--night\{display:block\}/);
 assert.match(js,/IntersectionObserver/);
 assert.match(js,/requestAnimationFrame/);
 assert.match(js,/passive:true/);
 assert.doesNotMatch(js,/preventDefault|scrollTo|scrollIntoView|innerHTML/);
});

test('scroll controller parses and preserves the static scene without browser APIs',()=>{
  assert.doesNotThrow(()=>new Script(js));
  assert.match(css,/--nf-open-trace:0/);
  assert.match(css,/#main>.hero\.nf-opening\{min-height:0/);
});
