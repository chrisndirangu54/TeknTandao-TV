# TeknTandao TV

Flutter proof-of-concept for **broadcaster-first, intelligent live television**.

**Architecture principle:** One account, one customer identity, multiple specialized apps, one central dashboard. TV, ISP and Workspace can be bought independently or bundled. Existing users can upgrade to Workspace without a new identity.

## Implemented (prototype)
- Responsive Flutter mobile / wide-screen channel-guide interface with stable channel numbers.
- Selectable channels, search, optional discovery section and HLS playback through `video_player`.
- One clearly labelled public Mux HLS **test video** (not a licensed TV channel).
- Channel placeholders for Techruptive, education and community partners.

## Not yet implemented
Firebase single sign-on, payments, subscription enforcement, licensed broadcaster streams, programme schedules, live rewind/DVR, AI search and recommendations, broadcaster portal, CDN/edge cache, ISP provisioning and end-to-end tests. The account icon deliberately shows an integration notice rather than pretending login works.

## Run
Install Flutter SDK, then:
```bash
flutter create . --platforms=android,web
flutter pub get
flutter run -d chrome
```
For Android, test HLS support and internet permissions on a device. The browser may block third-party test streams depending on CORS or codec support.

## Integration boundaries
- Shared account ID supplied by a **trusted identity service**, never by unverified client claims.
- Shared billing ledger and service entitlements; TV backend checks entitlements before issuing stream access.
- ISP and Workspace expose scoped APIs, not shared access to router secrets or raw customer data.
- Consent-based audience segments only. Third-party platform content must use approved players and cannot be cached or recorded without rights.
- Keep dedicated media servers/cloud object storage outside Firebase.

See [docs/INTEGRATION_API_V0_1.md](docs/INTEGRATION_API_V0_1.md).
