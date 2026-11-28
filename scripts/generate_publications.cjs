// Generate static, no-JavaScript scholarly pages from the canonical approved registry.
// Usage: node scripts/generate_publications.cjs [--check]
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname,"..");
const read = p => fs.readFileSync(path.join(root,p),"utf8");
function build(reg,home,moon,sitemap){
 const e=x=>String(x).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;");
 const origin="https://d3lefts.github.io/d3lefts/";
 const records=[...reg.records].sort((a,b)=>a.number-b.number);
 const fail=m=>{throw Error(m)};
 const unique=(k)=>new Set(records.map(r=>r[k])).size===records.length;
 for(const k of ["id","slug","number"])if(!unique(k))fail("Duplicate publication "+k);
 const dois=records.map(r=>r.doi).filter(Boolean);if(new Set(dois).size!==dois.length)fail("Duplicate publication doi");
 for(const r of records){if(!/^[a-z0-9-]+$/.test(r.slug)||(r.doi ? !/^10\.\d{4,9}\/[a-zA-Z0-9._/-]+$/.test(r.doi)||r.url!=="https://zenodo.org/records/"+r.doi.split(".").pop() : r.url!==reg.community.url)||!Number.isInteger(r.number)||r.number<1||!r.title||!r.author||!r.summary||!r.scope||!r.review_status||!r.publication_status||!/^\d{4}-\d{2}-\d{2}$/.test(r.date))fail("Invalid publication metadata "+r.id);for(const link of r.evidence_links||[])if(!/^(https:\/\/github\.com\/d3lefts\/d3lefts\/|[a-z0-9-]+\.html(?:#[a-z0-9-]+)?$)/.test(link.href))fail("Invalid evidence URL");}
 const file=r=>"publication-"+r.slug+".html";
 const doi=r=>r.doi?"https://doi.org/"+r.doi:reg.community.url;
 const n=r=>String(r.number).padStart(2,"0");
 const meta=r=>[r.date,"Preprint",r.manuscript_version?"Manuscript v"+r.manuscript_version:null,r.pages?r.pages+" pages":null].filter(Boolean).map(e).join(" · ");
 const entry=r=>`<article class="nf-pub-entry"><span class="nf-pub-number">${n(r)}</span><div><p class="nf-pub-kicker">${e(r.field)} · ${e(r.date)}</p><h3><a href="${file(r)}">${e(r.title)}</a></h3><p class="nf-pub-meta">${e(r.author)} · ${meta(r)}</p><p>${e(r.summary)}</p><div class="nf-pub-links"><a href="${file(r)}">Paper &amp; evidence →</a><a href="${doi(r)}">${r.doi?"Read preprint ↗":"Find in Zenodo community ↗"}</a></div></div></article>`;
 const section=(title,rs)=>`<section class="nf-pub-section wrap" id="selected-publications" aria-labelledby="selected-publications-title"><p class="nf-pub-kicker">NIGHTFALL / SCHOLARLY ARCHIVE</p><h2 id="selected-publications-title">${title}</h2><p class="nf-pub-intro">Original research, permanently archived and open to scrutiny.</p>${rs.map(entry).join("\n")}<div class="nf-pub-links"><a href="publications.html">Explore all publications →</a></div></section>`;
 const shell=(name,description,body,metadata="")=>`<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${e(name)} · NIGHTFALL</title><meta name="description" content="${e(description)}"><link rel="canonical" href="${origin}${body.file}"><meta property="og:title" content="${e(name)}"><meta property="og:description" content="${e(description)}"><meta property="og:url" content="${origin}${body.file}"><link rel="icon" href="favicon.svg" type="image/svg+xml"><link rel="stylesheet" href="site.css"><link rel="stylesheet" href="ethereal-theme.css"><link rel="stylesheet" href="publications.css"><script src="site.js" defer></script><script src="ethereal-theme.js" defer></script>${metadata}</head>
<body><a class="skip" href="#main">Skip to content</a><div class="topline"></div><header class="header"><div class="wrap header-inner"><a href="index.html" class="brand"><span class="mark" aria-hidden="true">N∕F</span><span class="brand-copy">NIGHTFALL <span>SCHOLARLY ARCHIVE</span></span></a><button type="button" class="menu-toggle" id="menu-button" aria-label="Toggle navigation" aria-expanded="false" aria-controls="site-nav">MENU +</button><nav class="nav" id="site-nav" aria-label="Primary navigation"><a href="index.html">Current research</a><a href="publications.html"${body.file==="publications.html"?' aria-current="page"':""}>Publications</a><a href="constellation.html">Methods &amp; connections</a><a class="nav-call" href="review.html">Review the evidence ↗</a></nav></div></header><main id="main">${body.html}</main><footer class="wrap nf-pub-footer"><a href="index.html">NULL FIELD / Active research</a><a href="new-moon.html">NEW MOON / Archived research</a><a href="theory.html">Theory Atlas</a><a href="evidence.html">Evidence</a></footer></body></html>\n`;
 const out={};
 out["docs/publications.html"]=shell("The NIGHTFALL Papers","Original research in mathematics, information and intelligence. Permanently archived and open to scrutiny.",{file:"publications.html",html:`<section class="nf-pub-hero wrap"><p class="nf-pub-kicker">NIGHTFALL / THE PAPERS / 2026 — PRESENT</p><h1>Discovery,<br><em>on the record.</em></h1><p class="nf-pub-intro">Original research in mathematics, information and intelligence. Permanently archived. Open to scrutiny.</p><div class="nf-pub-links"><a href="${e(reg.community.url)}">Zenodo community ↗</a><a href="https://github.com/d3lefts/d3lefts/blob/main/papers/publications.json">Publication registry ↗</a></div></section><section class="wrap nf-pub-section"><p class="nf-pub-kicker">PUBLICATION INDEX / ${records.length} REGISTERED PREPRINT${records.length===1?"":"S"}</p><h2>The papers.</h2>${records.map(entry).join("\n")}<p class="nf-pub-note">Publication in a public repository is distinct from journal peer review. Each paper links to its scope and evidence; no publication label independently certifies a theorem.</p></section>`});
 for(const r of records){
 const citation=`${r.author} (${r.date.slice(0,4)}). ${r.title}. Zenodo.${r.doi?" "+doi(r):""}`;
 const tags=[["citation_title",r.title],["citation_author",r.author],["citation_publication_date",r.date.replace(/-/g,"/")],["citation_doi",r.doi]].filter(([,v])=>v).map(([k,v])=>`<meta name="${k}" content="${e(v)}">`).join("");
 const json=JSON.stringify({"@context":"https://schema.org","@type":"ScholarlyArticle",name:r.title,author:{"@type":"Person",name:r.author},datePublished:r.date,...(r.doi?{identifier:r.doi,sameAs:doi(r)}:{}),url:origin+file(r),description:r.summary}).replace(/</g,"\\u003c");
 out["docs/"+file(r)]=shell(r.title,r.summary,{file:file(r),html:`<section class="wrap nf-pub-hero nf-pub-detail"><p class="nf-pub-kicker"><a href="publications.html">THE PAPERS</a> / ${n(r)} / ${e(r.field)}</p><h1>${e(r.title)}</h1><p class="nf-pub-meta">${e(r.author)} · ${meta(r)}</p><p class="nf-pub-intro">${e(r.summary)}</p><div class="nf-pub-links"><a class="button" href="${doi(r)}">${r.doi?"Read publication ↗":"Find in Zenodo community ↗"}</a>${r.doi?`<a href="${e(r.url)}">Zenodo record ↗</a>`:""}</div></section><section class="wrap nf-pub-section nf-pub-detail"><h2>Claim &amp; evidence.</h2><p>${e(r.scope)}</p><ul class="nf-pub-evidence">${(r.evidence_links||[]).map(l=>`<li><a href="${e(l.href)}">${e(l.label)} ↗</a></li>`).join("")}${(r.source_refs||[]).map(s=>`<li><a href="https://github.com/d3lefts/d3lefts/commit/${e(s.commit)}">${e(s.scope)} · source pin ↗</a></li>`).join("")}</ul><p class="nf-pub-note">${e(r.review_status.replace(/[.\s]+$/,""))}. ${e(r.publication_status.replace(/[.\s]+$/,""))}. Repository evidence can evolve independently of the archived manuscript.</p></section><section class="wrap nf-pub-section nf-pub-detail"><h2>Cite this paper.</h2><p class="nf-pub-citation">${e(citation)}</p>${r.doi?`<p class="nf-pub-meta">DOI: <a href="${doi(r)}">${e(r.doi)}</a></p>`:`<p class="nf-pub-meta">Individual record DOI pending reconciliation.</p>`}<p>For archived versions and file access, consult ${r.doi?"the Zenodo record":"the Zenodo community"}. For related research, visit the <a href="theory.html">Theory Atlas</a> or <a href="active-proof-passport.html">Proof Passports</a>.</p></section>`},tags+`<script type="application/ld+json">${json}</script>`);
 }
 const block=(src,marker,content,anchor)=>{const a=`<!-- ${marker}:start -->`,b=`<!-- ${marker}:end -->`,str=a+"\n"+content+"\n"+b;if(src.includes(a)){const i=src.indexOf(a),j=src.indexOf(b,i);if(j<0)fail("Unclosed "+marker);return src.slice(0,i)+str+src.slice(j+b.length);}const i=src.indexOf(anchor);if(i<0)fail("Missing "+anchor);return src.slice(0,i)+str+"\n"+src.slice(i);};
 const featured=records.filter(r=>r.featured).slice(0,3);
 out["docs/index.html"]=block(home,"nightfall-publications",section("Selected publications.",featured),'<section class="nf-observatory wrap"');
 out["docs/new-moon.html"]=block(moon,"nightfall-publications",section("On the scholarly record.",featured),'<section class="moon-dispatch wrap"');
 const csslink='<link rel="stylesheet" href="publications.css">';
 for(const f of ["docs/index.html","docs/new-moon.html"]){if(!out[f].includes(csslink))out[f]=out[f].replace("</head>",csslink+"\n</head>");}
 // Keep the owner-approved three primary active-home destinations plus the publication entry.
 for(const f of ["docs/index.html","docs/new-moon.html"]){if(!out[f].includes('<a href="publications.html">Publications</a>'))out[f]=out[f].replace('<a href="constellation.html">','<a href="publications.html">Publications</a>\n      <a href="constellation.html">');}
 out["docs/index.html"]=out["docs/index.html"].replace("Our first preprint is published.","Our research preprints are published.");
 const dates=[...records.map(r=>r.date)].sort();
 const sitemapContent=["publications.html",...records.map(file)].map((f,i)=>`  <url><loc>${origin}${f}</loc><lastmod>${i===0?dates[dates.length-1]:records[i-1].date}</lastmod></url>`).join("\n");
 out["docs/sitemap.xml"]=block(sitemap,"nightfall-publications",sitemapContent,"</urlset>");
 return out;
}
const output = build(JSON.parse(read("papers/publications.json")),read("docs/index.html"),read("docs/new-moon.html"),read("docs/sitemap.xml"));
for (const [p,content] of Object.entries(output)) {
  if (process.argv.includes("--check")) {
    if (!fs.existsSync(path.join(root,p)) || read(p)!==content) { console.error("Stale generated publication file: "+p);process.exitCode=1; }
  } else fs.writeFileSync(path.join(root,p),content);
}
