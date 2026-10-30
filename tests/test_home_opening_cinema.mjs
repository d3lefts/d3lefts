import {readFileSync} from 'node:fs';
import {test} from 'node:test';
import assert from 'node:assert/strict';

const html=readFileSync('docs/index.html','utf8');
const css=readFileSync('docs/home-opening-cinema.css','utf8');
const moon=readFileSync('docs/media/new-moon-nightscape.svg','utf8');
const space=readFileSync('docs/media/null-field-deep-space.svg','utf8');

test('both first-fold atmospheres are static, crisp and decorative',()=>{
 assert.match(html,/<section class="hero wrap nf-opening"/);
 assert.match(html,/class="nf-opening-art nf-opening-art--gold" aria-hidden="true"/);
 assert.match(html,/class="nf-opening-art nf-opening-art--night" aria-hidden="true"/);
 assert.match(html,/href="home-opening-cinema.css"/);
 assert.doesNotMatch(html,/src="(?:scroll-cinema|home-opening-cinema)\.js"/);
 assert.match(html,/id="hero-title-archive"/);
 assert.match(html,/id="hero-title"/);
 assert.match(css,/url\("media\/new-moon-nightscape\.svg"\)/);
 assert.match(css,/url\("media\/null-field-deep-space\.svg"\)/);
 assert.match(css,/prefers-reduced-motion:reduce/);
 assert.match(css,/\.nf-opening-art\{[\s\S]*?pointer-events:none/);
 assert.match(css,/html\[data-nf-theme="dusk"\] \.nf-opening-art--gold\{display:none\}/);
 assert.match(css,/html\[data-nf-theme="dusk"\] \.nf-opening-art--night\{display:block\}/);
 for(const art of [moon,space]){
  assert.match(art,/viewBox="0 0 2560 1440"/);
  assert.doesNotMatch(art,/<(?:text|script|foreignObject)\b/i);
 }
});

test('all scientific content remains separate from still art',()=>{
 assert.match(html,/class="nf-opening-overlap"/);
 assert.match(html,/class="nf-cinema-record"/);
 assert.match(html,/id="nf-scroll-cinema"/);
 assert.match(html,/data-motion="static"/);
 assert.match(html,/class="nf-cinema-proof-path"/);
 assert.match(html,/href="#flagships"/);
 assert.match(html,/href="review.html#priority"/);
 assert.ok(html.indexOf('id="nf-scroll-cinema"')<html.indexOf('id="flagships"'));
 assert.match(css,/\.nf-cinema--still \.nf-cinema-stage/);
 assert.match(css,/position:relative!important/);
 assert.match(css,/\.nf-cinema--still \.nf-cinema-record\{transform:none!important\}/);
 assert.match(css,/\.nf-opening-overlap a:focus-visible/);
 for(const phrase of ['0.380856370118','131,072','separate, incompletely recovered artifact','global optimality remains unproved'])
  assert.ok(html.includes(phrase),phrase);
});
