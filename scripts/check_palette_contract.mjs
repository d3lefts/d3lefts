/* NIGHTFALL color-only regression guard.
   Check literal presentation hues; source evidence and label meaning are separate. */
import assert from "node:assert/strict";
import {readdirSync,readFileSync} from "node:fs";
import {join,extname} from "node:path";
const root="docs";
const files=readdirSync(root).filter(f=>[".css",".html",".js",".svg"].includes(extname(f)));
function rgb(hex){
  let s=hex.slice(1);
  if(s.length===3)s=s.split("").map(x=>x+x).join("");
  return [0,2,4].map(i=>parseInt(s.slice(i,i+2),16)/255);
}
function hueSat(hex){
  const [r,g,b]=rgb(hex),max=Math.max(r,g,b),min=Math.min(r,g,b),d=max-min,l=(max+min)/2;
  let h=0;if(d){h=max===r?((g-b)/d)%6:max===g?(b-r)/d+2:(r-g)/d+4;h=(h*60+360)%360}
  return {h,s:d/(1-Math.abs(2*l-1)||1),l};
}
function luminance(hex){
 return rgb(hex).map(v=>v<=.04045?v/12.92:((v+.055)/1.055)**2.4)
   .reduce((x,v,i)=>x+v*[.2126,.7152,.0722][i],0);
}
function contrast(a,b){const x=luminance(a),y=luminance(b);return (Math.max(x,y)+.05)/(Math.min(x,y)+.05)}
const exceptions=[];
for(const f of files){
 const source=readFileSync(join(root,f),"utf8");
 for(const match of source.matchAll(/#(?:[0-9a-f]{8}|[0-9a-f]{6}|[0-9a-f]{3})\b/gi)){
  const hex=match[0],{h,s,l}=hueSat(hex);
  if(h>=55&&h<=175&&s>=.60&&l>=.30&&l<=.92)exceptions.push(f+": "+hex);
 }
}
assert.deepEqual(exceptions,[],"No neon lime/chartreuse presentation colors may survive");
for(const file of files.filter(x=>x.endsWith(".html")&&readFileSync(join(root,x),"utf8").includes("ethereal-theme.css"))){
 const html=readFileSync(join(root,file),"utf8");
 assert.ok(html.includes('href="two-skies.css"'),file+" missing shared palette stylesheet");
}
const light=readFileSync(join(root,"two-skies.css"),"utf8");
const dusk=readFileSync(join(root,"two-skies.css"),"utf8");
for(const token of ["--lf-paper:#020406","--lf-ink:#eaf0f5","--lf-primary:#e46a84","--lf-cherry-fill:#650d27","--lf-cherry-fill-hover:#841736","--lf-oxblood:#080d12"]){
 assert.ok(light.toLowerCase().includes(token),"Missing NULL FIELD token: "+token);
}
for(const token of ["--nf-champagne:#e2d28c","--nf-lightray-gold:#e2d28c"]){
 assert.ok(dusk.toLowerCase().includes(token),"Missing midnight gold token: "+token);
}
assert.ok(contrast("#020406","#e46a84")>=4.5,"Cherry display accent on space black must meet WCAG AA");
assert.ok(contrast("#eaf0f5","#080d12")>=4.5,"Porcelain on graphite must meet WCAG AA");
assert.ok(contrast("#e2d28c","#04060b")>=4.5,"Gilded moonlight on midnight must meet WCAG AA");
assert.ok(contrast("#e46a84","#1b292d")>=4.5,"Cherry text must remain readable on raised carbon");
assert.ok(contrast("#eaf0f5","#650d27")>=4.5,"Porcelain text on black-cherry CTA must meet WCAG AA");
assert.ok(contrast("#f2f5fa","#841736")>=4.5,"Porcelain text on hovered cherry CTA must meet WCAG AA");
assert.ok(contrast("#0b1425","#e2d28c")>=4.5,"Night action ink must remain readable on moonlight");
assert.equal((light.match(/--nf-24k-gold:#d4af37/g)||[]).length,1,"New Moon retains 24k");
assert.ok(light.includes("--nf-24k-gold:#c53b5f"),"Archive uses cherry diffraction, not gold");
// Signature surface rule: strong warm hues are reserved for small signals,
// never the full numeric plate or the repeated research cards.
for(const token of [
  "--nf-muted-signal:#c19aa8",
  "--nf-muted-carbon:#0f181d",
  "--nf-muted-plum:#211e28",
  "--nf-muted-signal:#dfd2a0"
])assert.ok(light.includes(token),"Quiet Signal palette token missing: "+token);
assert.ok(light.includes("html:not([data-nf-theme=\"dusk\"]) .sf-case-aside"),
  "NULL FIELD result plate must have a dark neutral treatment");
assert.ok(light.includes("html[data-nf-theme=\"dusk\"] .sf-case-aside"),
  "NEW MOON result plate must have a midnight treatment");
assert.ok(light.includes("background-image:linear-gradient(120deg,rgba(11,25,31,.28),rgba(10,20,29,.55))"),
  "Cherry CTA requires a desaturating translucent glaze");
assert.ok(contrast("#eaf0f5","#192229")>=7,
  "Muted Archive result plate needs comfortably legible body text");
assert.ok(contrast("#f1eedc","#172337")>=7,
  "Muted New Moon result plate needs comfortably legible body text");
assert.ok(contrast("#e2d28c","#172337")>=7,
  "Moonlight remains visible as the numerical accent on midnight slate");

console.log("Palette contract OK: "+files.length+" public assets; black-cherry and moonlight independently satisfy text contrast");
