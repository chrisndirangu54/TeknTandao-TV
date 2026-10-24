# TeknTandao TV watch parties — implementation

## Supported flow
Authenticated users create **public or private** rooms bound to a catalogue media ID (TV, movie or podcast). Private rooms require a long invite token, stored only as a SHA-256 digest. Membership, status, synchronized play/pause/seek, and chat are managed by Firestore-backed HTTPS endpoints with verified Firebase ID tokens. Rooms cap at 25 members pending load testing. One account remains the identifier for TV, ISP and Workspace.

Endpoints in the Firebase TV Functions codebase:
- `POST createWatchParty`: `{kind,title,mediaId,visibility}` returns ID; private rooms return a **one-time invite token**.
- `POST joinWatchParty`: `{roomId,inviteToken?}`
- `POST partyAction`: `{roomId,action:'play'|'pause'|'seek',positionMs}`; host-only controls
- `POST partyComment`: `{roomId,text}`; text <=500 characters

Client TV room screen currently provides a **preview** of creation and synchronization concepts; no deployed party session can be assumed. Firestore security rules disallow direct client mutation; real-time subscriptions require a separately authorized listener service or callable polling endpoint, not an unrestricted Firestore listener.

## Voice notes and video calls
WebRTC video rooms need TURN/STUN configuration, consented microphone/camera capture, provider-issued short-lived room tokens, signalling backend, device platform permission flows and moderation. A production group call should use a vetted SFU (e.g., LiveKit) with an authenticated token-minting server, not route live camera streams through Firestore. Voice notes need secure object-storage uploads, retention limits, size limits and explicit recording consent. The current UX describes these functions but **does not** establish real audio/video transport.

## Content rights / security
Every participant needs their own valid TV/movie/podcast entitlement and territorial rights. Watch parties synchronize playback **commands**, not retransmitted copyrighted video/audio. Publishing a room is not publishing or relaying the underlying media. Room hosts can mute/kick/report participants only after a role-checked moderation API exists. Add rate limiting, privacy retention, child safety and abuse review before public rooms.
