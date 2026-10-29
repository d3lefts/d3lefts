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
const light=readFileSync(join(root,"golden-hour-light.css"),"utf8");
const dusk=readFileSync(join(root,"ethereal-theme.css"),"utf8");
for(const token of ["--lf-paper:#f4e7df","--lf-primary:#d97a4a","--lf-oxblood:#4a1f24"]){
 assert.ok(light.includes(token),"Missing sunset token: "+token);
}
for(const token of ["--nf-champagne:#d8c38a","--nf-lightray-gold:#d8c38a"]){
 assert.ok(dusk.includes(token),"Missing midnight gold token: "+token);
}
assert.ok(contrast("#2a1f1d","#d97a4a")>=4.5,"Dark ink on sunset CTA must meet WCAG AA");
assert.ok(contrast("#fcf3ea","#4a1f24")>=4.5,"Cream on oxblood must meet WCAG AA");
assert.ok(contrast("#d8c38a","#101727")>=4.5,"Lightray gold on midnight must meet WCAG AA");
console.log("Palette contract OK: "+files.length+" public assets; no neon lime; text contrast checks pass");
