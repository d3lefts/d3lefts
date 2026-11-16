import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const html=readFileSync(new URL('../index.html',import.meta.url),'utf8');
const ui=readFileSync(new URL('../workspace.mjs',import.meta.url),'utf8');
const original=readFileSync(new URL('../app.mjs',import.meta.url),'utf8');

test('comprehensive app loads local synthetic assets and retains checker',()=>{
 for(const file of ['workspace.css','workspace.mjs','historical-fixtures.js','app.mjs'])
   assert.ok(html.includes(file),'missing '+file);
 for(const id of ['cwui-chamber','cwui-issues','cwui-representation','cwui-public','cwui-steward','cwui-assurance','cwui-history-results','cwui-question-text'])
   assert.ok(html.includes('id="'+id+'"'),'missing '+id);
 assert.ok(original.includes('import {evaluate} from "./core.mjs"'));
});
test('workspace controls cannot submit official acts or persist political responses',()=>{
 assert.ok(ui.includes("window.COMMONWEALTH_SYNTHETIC"));
 assert.ok(!/localStorage|sessionStorage|indexedDB|fetch\s*\(/.test(ui));
 assert.ok(!/XMLHttpRequest|sendBeacon|POST\s*\/api/.test(ui));
 assert.ok(html.includes('NO COMPLETENESS CLAIM'));
});
test('navigation starts before Chamber and all anchors are unique',()=>{
 const nav=html.indexOf('class="cwui-nav"');
 const chamber=html.indexOf('id="cwui-chamber"');
 assert.ok(nav>=0&&chamber>nav);
 for(const id of ['cwui-issues','cwui-representation','cwui-public','cwui-steward'])
   assert.equal(html.split('id="'+id+'"').length,2);
});
