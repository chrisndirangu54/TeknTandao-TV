'use strict';
const STATES=Object.freeze(['pending_payment','paid_verified','awaiting_dj','approved','rejected','fulfilled','refunded']);
function transition(from,to,actor){
 const allowed={
  pending_payment:{paid_verified:['verified_billing']},
  paid_verified:{awaiting_dj:['system']},
  awaiting_dj:{approved:['host','dj'],rejected:['host','dj']},
  approved:{fulfilled:['host','dj']},
  rejected:{refunded:['verified_billing']},
  fulfilled:{},refunded:{}
 };
 return STATES.includes(from)&&STATES.includes(to)&&(allowed[from]?.[to]??[]).includes(actor);
}
function eligibleForQueue(order){
 return !!order&&order.paymentVerified===true&&
 ['awaiting_dj','approved','fulfilled'].includes(order.status);
}
function displayPriority(order){
 return eligibleForQueue(order)&&order.feature==='priority_request'&&order.status==='approved';
}
module.exports={transition,eligibleForQueue,displayPriority};
