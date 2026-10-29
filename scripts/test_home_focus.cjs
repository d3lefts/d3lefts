"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const html=fs.readFileSync("docs/index.html","utf8");
const css=fs.readFileSync("docs/home-focus.css","utf8");
const between=(a,b)=>{
 const i=html.indexOf(a),j=html.indexOf(b,i+a.length);
 assert.ok(i>=0&&j>i,"Expected unchanged homepage anchor "+a.slice(0,50));
 return html.slice(i,j);
};
const hero=between('<div class="hero-actions"','</div>');
const hrefs=[...hero.matchAll(/<a\b[^>]*href="([^"]+)"/g)].map(x=>x[1]);
assert.deepEqual(hrefs,["#flagships","join.html#claim-investigation"],"One result action and one claim-continuation action");
const nav=between('<nav class="nav" id="site-nav"','</nav>');
assert.equal((nav.match(/<a\b/g)||[]).length,5,"Homepage primary navigation has only five destinations");
assert.ok(nav.includes('href="constellation.html"'));
const jump=between('<details class="nf-section-index wrap"','</details>');
assert.equal((jump.match(/<a\b/g)||[]).length,7,"All seven original jump points remain");
assert.match(jump,/<summary>Browse the full field index/);
assert.ok(!/<details class="nf-section-index wrap"[^>]*\bopen\b/.test(jump),"Section index initially collapsed");
const instruments=between('<details class="nf-home-toolbox"','</details>');
assert.match(instruments,/<summary>/);
assert.equal((instruments.match(/class="sf-system-card/g)||[]).length,4);
for(const path of ["living-investigation.html","desk.html","frontier.html","referee.html","passport.html","exact-research.html","atlas.html","adversary.html"]){
 assert.ok(instruments.includes('href="'+path+'"'),"Instrument path lost "+path);
}
assert.ok(!/<details class="nf-home-toolbox"[^>]*\bopen\b/.test(instruments),"Tool directory initially collapsed");
assert.match(html,/class="nf-home-tool-entry"/);
assert.match(html,/href="join\.html#claim-investigation"/);
assert.ok(html.includes('href="living-paper.html">Explore this finite proof'));
assert.ok(html.includes('href="erdos-paper.html"'));
assert.ok(html.includes('href="passport.html?claim=sidon30"'));
assert.ok(html.includes('href="referee.html?domain=sidon"'));
for(const id of ["flagships","live-case","research-systems","featured-title","evidence","review","work","method"])assert.ok(html.includes('id="'+id+'"'),"Evidence/history anchor lost "+id);
for(const term of ["External review","public research archives","Original evidence, in depth","Source comparisons"])assert.ok(html.includes(term),"Research-status disclosure lost "+term);
assert.ok(css.includes("@media(max-width:760px)"));
assert.ok(css.includes(".nf-home-toolbox>summary:focus-visible"));
assert.ok(css.includes(".nf-section-index>summary:focus-visible"));
console.log("PASS homepage focus: 2 first decisions, 5 primary nav destinations, 7 original section links and 8 preserved research instruments behind optional directory.");
