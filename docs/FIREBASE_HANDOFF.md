# Firebase setup (owner-managed, not configured yet)

1. Choose whether TV and Workspace use the **same Firebase Authentication project**. If not, implement a secure identity broker/account-linking flow; do not assume tokens from one project are accepted by another.
2. Create Firebase project configuration locally using FlutterFire CLI. Never commit service-account secrets.
3. Review Workspace's existing customer ID contract and migrate accounts using verified authentication and an audited mapping.
4. Configure custom claims/role checks and server-side tenant authorization for broadcaster/admin functions.
5. Deploy the functions and restrictive Firestore rules after staging tests. `functions/index.js` currently exposes only verified-user profile and subscription reads.
6. Replace `AppServices.demo()` in `lib/main.dart` with real implementations of the typed gateway interfaces.
7. For paid channels, require backend-verified entitlements and expiring playback URLs. The bundled test video is public, not protected content.
8. Add authorized broadcaster feeds, signed payment webhooks, replay rights and retention policies before commercial launch.

**Current scope:** no live M-Pesa, router provisioning, shared production auth or recording service is configured.
