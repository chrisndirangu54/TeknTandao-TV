# ISP + TV bundle — staging design
A customer may purchase ISP, TV, or `ISP_TV_BUNDLE`. The single bundle subscription represents **both** ISP and TV entitlements for the same verified `customerId`. Workspace is optional and does not become a paid entitlement merely because someone purchased the bundle.

## Checkout / billing design
- The plan catalog will expose `ISP`, `TV`, and `ISP_TV_BUNDLE` as selectable products, each with configurable prices, currency KES, billing period, service zone, and any discounts. No prices are imposed in code until commercial terms are approved.
- A verified payment may activate a bundle only through the existing authoritative billing service.
- Issue one invoice/payment reference for the bundle, with accounting allocation and line items for TV and ISP.
- Publish a single idempotent subscription event; TV consumes the TV entitlement, and the ISP system consumes the ISP entitlement.
- Cancellation, expiry, refund, or suspension revokes or changes both components under the published grace-period and refund policy.
- Existing individual subscriptions must not be silently cancelled, double-billed, or merged. Require a customer-approved switch and prorate amounts on the backend.

## Limitations
This changes domain logic and tests, **not** the checkout form, M-Pesa callback, live TV streaming, or router provisioning. An admin must configure supported service areas, rights-cleared content, bundle plans, device support, and production identities before selling it.
