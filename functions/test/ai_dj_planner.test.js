'use strict';
const test=require('node:test'),assert=require('node:assert/strict');
const {candidateScore,planTransition,normalizedBeatPayload}=require('../src/ai_dj_planner');
test('harmonically compatible and close BPM tracks score higher',()=>{
 assert.ok(candidateScore({bpm:120,energy:.8,camelot:'8A'},{bpm:121,energy:.8,camelot:'8A'})>
 candidateScore({bpm:120,energy:.8,camelot:'8A'},{bpm:150,energy:.2,camelot:'2B'}));
});
test('crossfade plan bounds duration and does not claim rendering',()=>{
 const plan=planTransition({bpm:120},{bpm:121});assert.ok(plan.durationMs>=2500&&plan.durationMs<=12000);
 assert.equal(plan.rendered,false);
});
test('invalid audio signals are rejected',()=>assert.throws(()=>normalizedBeatPayload({beat:2})));
