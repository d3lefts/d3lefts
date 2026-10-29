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
for(const token of ["--lf-paper:#241a34","--lf-primary:#e7b768","--lf-oxblood:#191327"]){
 assert.ok(light.toLowerCase().includes(token),"Missing sunset token: "+token);
}
for(const token of ["--nf-champagne:#e2d28c","--nf-lightray-gold:#e2d28c"]){
 assert.ok(dusk.toLowerCase().includes(token),"Missing midnight gold token: "+token);
}
assert.ok(contrast("#241a34","#e7b768")>=4.5,"Dark ink on sunset CTA must meet WCAG AA");
assert.ok(contrast("#fff0e7","#191327")>=4.5,"Cream on oxblood must meet WCAG AA");
assert.ok(contrast("#e2d28c","#04060b")>=4.5,"Gilded moonlight on midnight must meet WCAG AA");
assert.ok(contrast("#e7b768","#503757")>=4.5,"Apricot gold must remain readable on raised plum");
assert.ok(contrast("#191327","#e7b768")>=4.5,"Dark action ink must remain readable on apricot gold");
assert.ok(contrast("#0b1425","#e2d28c")>=4.5,"Night action ink must remain readable on moonlight");
assert.equal((light.match(/--nf-24k-gold:#d4af37/g)||[]).length,2,"Each sky declares one shared 24k trace token");
console.log("Palette contract OK: "+files.length+" public assets; no neon lime; text contrast checks pass");
