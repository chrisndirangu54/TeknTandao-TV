# TV + ISP bundle purchase order — staging
The `createTvOrder` Cloud Function accepts `POST` with JSON `{"planId":"approvedPlan","idempotencyKey":"customer-generated-unique-value"}` and `Authorization: Bearer <Firebase ID token>`. It verifies the token and looks up a **server-published** plan in `tvPlans/{planId}`. The customer cannot supply a price, status, or customer ID. Firestore transaction ensures retries with the same key produce a single pending order.

`tvPlans` schema: `product` = TV | ISP | ISP_TV_BUNDLE, `published`=true, `currency`=KES, `amountMinor`=integer in cents, `period`=monthly|quarterly|yearly, `title`=string, optional `availableUntil` ISO timestamp. The amount is in **minor units**: KSh 1,500 = `150000` cents.

The API returns `orderId`, status `pending_payment` and a plan snapshot. It **does not** initiate M-Pesa, capture card payment, issue a paid entitlement, connect TV streaming or provision ISP access. Verified billing must be implemented in Workspace as the single payment authority, including signed provider callbacks, expiry, cancellation, refunds, idempotent events and network provisioning approval.

Deploy only in a staging project after checking Firebase Auth issuer, API IAM, billing rules and Cloud Functions permissions. Server credentials stay in Secret Manager.

Customer view of prices and checkout button is pending integration with verified catalog; do not mistake preview screen for a live shop.
