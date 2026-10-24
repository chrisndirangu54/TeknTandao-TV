# TeknTandao TV — AI DJ, Listening Parties, Gifts and Tips

BeatSync-Studio source: https://github.com/chrisndirangu54/BeatSync-Studio
Its README documents per-frame beat, onset, bass/mids/treble, RMS, spectral brightness, drops and sections. A provider adapter must deliver normalized *licensed* metadata to the Flutter player. This repository does not copy BeatSync's renderer or host Suno tracks.

## Music party model
Reuse public/private party access and chat, with kind='music'. Store music queues, one track selection per authenticated account and track votes. Queue order is deterministic using votes, age and stable submission ordering. Host can accept the top voted song; score/level and badges are cosmetic, no cash redemption. Each participant individually acquires a permitted stream; do not relay Spotify, Suno or other platform playback without commercial rights. A generated song is not automatically cleared for redistribution.

## AI DJ concept
A future BeatSync worker computes beat/onset/energy/section analysis and sends bounded normalized control signals and compatible BPM/key/energy metadata to the DJ decision engine. Beat-aligned crossfades, track suggestions, transitions and audio-reactive visualizers can be performed only if service APIs, stream rights and processing workers are configured. Music preference and voting data must respect consent.

## Monetization
`createTvTipIntent` creates **pending** KES tip intents. It does not accept payments or grant rewards. Payment settlement, gift catalog, KYC/payout eligibility, disputes, fees, tax records and currency conversions must be authorized by the server-side Workspace billing provider. Tips must be optional, clearly priced, non-refundable only where lawfully permitted, and never manipulate children's spending or turn votes into pay-to-win.
