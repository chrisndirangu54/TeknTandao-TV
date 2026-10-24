'use strict';
const test=require('node:test'),assert=require('node:assert/strict');
const {rankQueue,beatVisualState,tipRequest,tipId}=require('../src/music_party_core');
test('more votes raises a track',()=>assert.equal(rankQueue([{trackId:'a',createdAt:new Date().toISOString()},{trackId:'b',createdAt:new Date().toISOString()}],{a:0,b:3})[0].trackId,'b'));
test('BeatSync signal contract maps to visualizer',()=>assert.equal(beatVisualState({beat:.8,onset:.2,bass:.9,mids:.5,treble:.3,rms:.4,brightness:.6,dropLikelihood:1}).particles,.9));
test('invalid amount is rejected',()=>assert.throws(()=>tipRequest({recipientId:'d',recipientKind:'dj',amountMinor:0,idempotencyKey:'abcd1234',context:'music'})));
test('tips use idempotent payer-scoped keys',()=>assert.notEqual(tipId('alice','tip123'),tipId('bob','tip123')));
