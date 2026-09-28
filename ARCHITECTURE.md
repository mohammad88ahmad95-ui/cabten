# Captain Party — architecture (decisions)

- **Double booking:** `calendar_entries` holds every occupied period (confirmed booking, external/manual booking, blocked date, holiday). A Postgres `EXCLUDE USING gist (provider_id =, during &&)` constraint makes overlaps impossible even under concurrent requests. Pending requests may overlap; confirmation inserts the calendar row in the same transaction as the status change and maps SQLSTATE 23P01 to an Arabic "date no longer available" error.
- **Money:** integer minor units (`bigint`), currency table with configurable exponent, basis points for all percentages (deposit, commission, refunds). No floats.
- **Deposit precedence:** package > provider > platform (`platform_settings`).
- **Commission:** snapshot per booking (`commission_bps`, `commission_minor`) so later changes don't rewrite history.
- **Lifecycle:** `packages/domain/src/booking-state.ts` is the single transition table (with allowed actors); every change writes `booking_status_history` and `audit_logs`.
- **Payments:** manual methods stay `submitted` until a provider/admin verifies; customers can never verify. Gateways plug in later via `payments.gateway_ref`.
- **Per-provider Sham Cash/MTN/Sritel/bank:** `provider_payment_methods`, admin-approved; customers see only approved methods of that provider.
- **Idempotency:** unique `(customer_id, idempotency_key)` on bookings and `(booking_id, idempotency_key)` on payments.

## Status
Verified (11 passing tests): money, deposit/commission/refund math, state machine, overlap logic.
Written but NOT yet executed: SQL migration and concurrency script (no PostgreSQL in this environment).
Not started: API layer, auth, Flutter app, provider/admin panels, notifications, reviews, uploads, seeding.
