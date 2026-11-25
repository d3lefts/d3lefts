'use strict';
document.addEventListener('DOMContentLoaded',async()=>{
 const $=id=>document.getElementById(id),el=(tag,text,klass)=>{const e=document.createElement(tag);if(text!==undefined)e.textContent=text;if(klass)e.className=klass;return e;};
 const link=(text,href)=>{const e=el('a',text);e.href=href;return e;};
 const repo='https://github.com/d3lefts/d3lefts';
 const sourceURL=(p,ref='main')=>repo+'/blob/'+encodeURIComponent(ref)+'/'+p.split('/').map(encodeURIComponent).join('/');
 try{
 const res=await fetch('proof-passport-v3.json',{cache:'no-cache'});if(!res.ok)throw Error('HTTP '+res.status);
 const data=await res.json();if(data.schema!=='nightfall.generated-proof-passports.v3')throw Error('Unexpected inventory schema');
 $('status').textContent='Generated snapshot · historical receipts and scoped metadata only';
 const metrics=[['Lean source paths',data.summary.custody_sources],['Exact blob + receipt references',data.summary.source_paths_with_exact_blob_and_receipt_reference],['Claim/evidence references',data.summary.known_record_refs],['Referenced runs',data.summary.distinct_referenced_runs],['Pending receipt leads',data.summary.pending_source_paths_with_receipt_leads]];
 for(const [label,n] of metrics){const box=el('div',undefined,'stat');box.append(el('strong',String(n)),el('span',label));$('stats').append(box);}
 let limit=30;
 function render(){
 const mode=$('mode').value,q=$('search').value.trim().toLowerCase();
 const rows=mode==='sources'||mode==='leads'?data.sources.filter(x=>mode!=='leads'||x.receipt_leads.length):data.records.filter(x=>mode!=='observed'||x.kind==='observed-job-named-audit');
 const matches=rows.filter(x=>!q||JSON.stringify(x).toLowerCase().includes(q));
 $('results').replaceChildren();$('result-count').textContent=matches.length+' matching records; showing '+Math.min(matches.length,limit)+'.';
 for(const r of matches.slice(0,limit)){
 const card=el('article');card.append(el('h3',r.title||r.original_id||r.path));
 card.append(el('p',r.state||r.custody,'small'));
 if(r.scope)card.append(el('p',r.scope));
 if(r.declarations?.length)card.append(el('p',r.declarations.join(' · '),'small'));
 if(r.blob)card.append(el('p','Blob '+r.blob+(r.source_match?' · '+r.source_match:''),'small'));
 if(r.receipt_leads?.length)card.append(el('p','Unreviewed receipt leads: '+r.receipt_leads.join(', '),'small'));
 if(r.evidence?.length)card.append(el('p','Evidence references: '+r.evidence.join(' · '),'small'));
 const links=el('div',undefined,'links');
 if(r.path)links.append(link('Source',sourceURL(r.path,r.head||'main')));
 if(r.run)links.append(link('Run '+r.run,repo+'/actions/runs/'+r.run));
 if(r.job&&r.run)links.append(link('Job '+r.job,repo+'/actions/runs/'+r.run+'/job/'+r.job));
 if(r.origin)links.append(link('Original ledger',sourceURL(r.origin)));
 card.append(links);$('results').append(card);
 }
 $('more').hidden=matches.length<=limit;
 }
 for(const id of ['search','mode'])$(id).addEventListener('input',()=>{limit=30;render();});
 $('more').addEventListener('click',()=>{limit+=30;render();});render();
 }catch(e){$('status').textContent='Could not load the generated inventory: '+e.message+'. Use the JSON download or repository source.';}
});
