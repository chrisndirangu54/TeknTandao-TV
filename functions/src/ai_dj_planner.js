'use strict';
/** BeatSync-inspired mix planner. Uses analyzed metadata only; audio rendering
 * requires licensed audio sources and an actual DSP/encoder worker. */
function candidateScore(current,next,votes=0){
 if(!current||!next||!Number.isFinite(next.bpm)||next.bpm<=0)return -Infinity;
 const bpmDiff=Math.abs((current.bpm||next.bpm)-next.bpm);
 const harmonic=current.camelot&&next.camelot
   ? (current.camelot===next.camelot ? 20 : 0) : 0;
 const energyDiff=Math.abs((current.energy??next.energy??0)-(next.energy??0));
 return Math.max(0,40-bpmDiff*2)+harmonic+Math.max(0,20-20*energyDiff)+Math.min(20,Math.max(0,votes)*2);
}
function planTransition(current,next){
 if(!current||!next||!Number.isFinite(current.bpm)||!Number.isFinite(next.bpm)||
 current.bpm<=0||next.bpm<=0)throw Error('invalid_track_analysis');
 const durationMs=Math.round(Math.min(12000,Math.max(2500,4*60000/current.bpm)));
 const beatMatchRatio=current.bpm/next.bpm;
 return {durationMs,beatMatchRatio,downbeatAligned:true,
   transition:'equal_power_crossfade',rendered:false};
}
function normalizedBeatPayload(payload){
 const keys=['beat','onset','bass','mids','treble','rms','brightness','dropLikelihood'];
 if(!payload||keys.some(k=>!Number.isFinite(payload[k])||payload[k]<0||payload[k]>1))throw Error('invalid_beat_frame');
 return Object.fromEntries(keys.map(k=>[k,payload[k]]));
}
module.exports={candidateScore,planTransition,normalizedBeatPayload};
