'use strict';
const GIFTS=Object.freeze([
 {id:'applause',label:'Applause',amountMinor:10000},
 {id:'coffee',label:'Coffee',amountMinor:25000},
 {id:'spotlight',label:'Spotlight',amountMinor:50000},
 {id:'encore',label:'Encore',amountMinor:100000}
]);
function giftDetails(id){
 const gift=GIFTS.find(g=>g.id===id);
 if(!gift)throw Error('unsupported_gift');
 return gift;
}
function normalizeBeatSyncFrame(x){
 const required=['beat','onset','bass','mids','treble','rms','brightness','dropLikelihood'];
 if(!x||required.some(k=>typeof x[k]!=='number'||!Number.isFinite(x[k])||x[k]<0||x[k]>1))throw Error('invalid_frame');
 const section=typeof x.section==='string'&&x.section.length<=30?x.section:'unknown';
 return { ...Object.fromEntries(required.map(k=>[k,x[k]])),section};
}
module.exports={GIFTS,giftDetails,normalizeBeatSyncFrame};
