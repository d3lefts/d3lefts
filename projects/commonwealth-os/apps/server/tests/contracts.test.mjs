import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {join,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const dir=join(dirname(fileURLToPath(import.meta.url)),'..','contracts');
const schema=name=>JSON.parse(readFileSync(join(dir,name),'utf8'));
test('portable contracts retain synthetic-only constraints and named routes',()=>{
 const openapi=schema('openapi.json');assert.equal(openapi.openapi,'3.1.0');
 assert.ok(openapi.paths['/api/v1/commands'].post);
 assert.ok(openapi.paths['/api/v1/recertify'].post);
 assert.equal(schema('portable-evidence-v2.schema.json').properties.payload.properties.officialCertification.const,false);
 assert.equal(schema('synthetic-source.schema.json').properties.sourceUri.pattern,'^synthetic:');
 assert.equal(schema('procedural-policy.schema.json').properties.quorumFraction.properties.basis.const,'ELIGIBLE');
 assert.ok(schema('command.schema.json').properties.action.enum.includes('VOID'));
});
