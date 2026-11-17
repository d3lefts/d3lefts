/* The Warrant: fictional public explainer, not an authentication or legal-decision service.
 * Pure sample projection and explicit manual UI controls; no storage, network or issuance.
 */
export const WARRANT_LAYERS=Object.freeze(["authority","evidence","assurance"]);
export const EVIDENCE_VOCABULARY=Object.freeze(["VERIFIED_EVIDENCE","UNVERIFIED","CONTESTED","ILLUSTRATIVE"]);
export const EXAMPLE_WARRANT=Object.freeze({
  recordId:"CW-W-001",synthetic:true,sourceStatus:"SYNTHETIC_UNVERIFIED",
  evidenceClass:"ILLUSTRATIVE",authenticated:false,officialIssuer:null,
  legalAuthority:"NOT_ASSESSED",legalEffect:false,
  independentProductReview:"NOT_PERFORMED",sourceVersion:"v1"
});
export function inspectExample(record=EXAMPLE_WARRANT){
  if(!record||record.synthetic!==true||record.evidenceClass!=="ILLUSTRATIVE")
    throw new TypeError("The public Warrant inspector accepts fictional examples only");
  return Object.freeze({
    evidenceClass:"ILLUSTRATIVE",authority:"NOT_ASSESSED",legalEffect:false,
    sourceAuthenticated:false,independentProductReview:"NOT_PERFORMED",
    scope:"FICTIONAL_LEARNING_EXAMPLE"
  });
}
export function sourceTransition(changed=false){
  if(typeof changed!=="boolean")throw new TypeError("Change simulation must be Boolean");
  return Object.freeze(changed?{
    source:"v2 / hypothetical revision",review:"RECHECK_REQUIRED",
    explanation:"The fictional source version changed. Earlier source-dependent conclusions are invalid for the new snapshot until reviewed; no actual source was updated."
  }:{
    source:"v1 / fictional baseline",review:"Not applicable to real law · illustrative only",
    explanation:"No real source change or live verification occurs."
  });
}
if(typeof document!=="undefined"){
  const root=document.getElementById("warrant-case");
  if(root){
    const buttons=[...root.querySelectorAll("[data-warrant-layer]")];
    const panels=[...root.querySelectorAll("[data-warrant-panel]")];
    const renderLayer=layer=>{
      if(!WARRANT_LAYERS.includes(layer))throw new RangeError("Unknown Warrant layer");
      for(const b of buttons)b.setAttribute("aria-pressed",String(b.dataset.warrantLayer===layer));
      for(const p of panels)p.hidden=p.dataset.warrantPanel!==layer;
    };
    for(const button of buttons)button.addEventListener("click",()=>renderLayer(button.dataset.warrantLayer));
    const changeButton=document.getElementById("warrant-change-source");
    const source=document.getElementById("warrant-source-version");
    const review=document.getElementById("warrant-recheck-state");
    const note=document.getElementById("warrant-change-note");
    let changed=false;
    changeButton.addEventListener("click",()=>{
      changed=!changed;
      const state=sourceTransition(changed);
      changeButton.setAttribute("aria-pressed",String(changed));
      changeButton.textContent=changed?"Restore fictional baseline":"Simulate a source revision";
      source.textContent=state.source;review.textContent=state.review;note.textContent=state.explanation;
    });
    const status=inspectExample();
    document.getElementById("warrant-case-status").textContent=status.evidenceClass;
    renderLayer("authority");
  }
}
