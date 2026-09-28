-- Captain Party core schema (PostgreSQL 15+). UNTESTED against a live DB in this session.
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ---------- Identity & RBAC ----------
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE, email text UNIQUE,
  password_hash text NOT NULL,              -- argon2id, never plaintext
  full_name text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended')),
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (phone IS NOT NULL OR email IS NOT NULL)
);
CREATE TABLE roles (id serial PRIMARY KEY, code text UNIQUE NOT NULL);  -- customer, provider, super_admin, admin, moderator, finance_admin, support
CREATE TABLE permissions (id serial PRIMARY KEY, code text UNIQUE NOT NULL); -- e.g. payments.verify, providers.approve
CREATE TABLE role_permissions (role_id int REFERENCES roles ON DELETE CASCADE, permission_id int REFERENCES permissions ON DELETE CASCADE, PRIMARY KEY (role_id, permission_id));
CREATE TABLE user_roles (user_id uuid REFERENCES users ON DELETE CASCADE, role_id int REFERENCES roles, PRIMARY KEY (user_id, role_id));

-- ---------- Content managed by admin ----------
CREATE TABLE currencies (code text PRIMARY KEY, exponent smallint NOT NULL CHECK (exponent BETWEEN 0 AND 4));
CREATE TABLE cities (id serial PRIMARY KEY, name_ar text NOT NULL, name_en text, is_active boolean NOT NULL DEFAULT true);
CREATE TABLE areas (id serial PRIMARY KEY, city_id int NOT NULL REFERENCES cities, name_ar text NOT NULL, name_en text);
CREATE TABLE categories (id serial PRIMARY KEY, slug text UNIQUE NOT NULL, name_ar text NOT NULL, name_en text, icon text, sort_order int NOT NULL DEFAULT 0, is_active boolean NOT NULL DEFAULT true);
CREATE TABLE amenities (id serial PRIMARY KEY, name_ar text NOT NULL, name_en text, category_id int REFERENCES categories);
CREATE TABLE platform_settings (key text PRIMARY KEY, value jsonb NOT NULL, updated_by uuid REFERENCES users, updated_at timestamptz NOT NULL DEFAULT now());
-- seeded keys: commission_bps, default_deposit_rule, default_cancellation_policy_id

-- ---------- Providers ----------
CREATE TABLE providers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id uuid NOT NULL REFERENCES users,
  category_id int NOT NULL REFERENCES categories,
  city_id int NOT NULL REFERENCES cities, area_id int REFERENCES areas,
  business_name text NOT NULL, description text, phone text,
  latitude numeric(9,6), longitude numeric(9,6),           -- future maps
  verification_status text NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending','verified','rejected','suspended')),
  commission_bps_override int CHECK (commission_bps_override BETWEEN 0 AND 10000),
  deposit_rule jsonb,                                      -- provider-level override
  cancellation_policy_id int,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX providers_search_idx ON providers (category_id, city_id, verification_status);
CREATE INDEX providers_name_trgm ON providers USING gin (business_name gin_trgm_ops);
CREATE TABLE provider_amenities (provider_id uuid REFERENCES providers ON DELETE CASCADE, amenity_id int REFERENCES amenities, PRIMARY KEY (provider_id, amenity_id));

-- Per-provider receiving details (Sham Cash number/link/QR, MTN, Sritel, bank). Admin approves each.
CREATE TABLE provider_payment_methods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id uuid NOT NULL REFERENCES providers ON DELETE CASCADE,
  method text NOT NULL CHECK (method IN ('mtn_cash','sritel_cash','sham_cash','bank','cash')),
  account_holder text, account_ref text,                   -- number / IBAN; never card data
  payment_link text, qr_image_key text, instructions text,
  approval_status text NOT NULL DEFAULT 'pending' CHECK (approval_status IN ('pending','approved','rejected')),
  UNIQUE (provider_id, method)
);

CREATE TABLE cancellation_policies (id serial PRIMARY KEY, name text NOT NULL, provider_id uuid REFERENCES providers);
CREATE TABLE cancellation_policy_tiers (policy_id int REFERENCES cancellation_policies ON DELETE CASCADE, min_days_before int NOT NULL CHECK (min_days_before >= 0), refund_bps int NOT NULL CHECK (refund_bps BETWEEN 0 AND 10000), PRIMARY KEY (policy_id, min_days_before));

-- ---------- Services ----------
CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id uuid NOT NULL REFERENCES providers ON DELETE CASCADE,
  name text NOT NULL, description text, is_active boolean NOT NULL DEFAULT true
);
CREATE TABLE service_packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid NOT NULL REFERENCES services ON DELETE CASCADE,
  name text NOT NULL, description text,
  price_minor bigint NOT NULL CHECK (price_minor >= 0),
  currency text NOT NULL REFERENCES currencies,
  max_guests int, duration_minutes int,
  deposit_rule jsonb                                        -- package-level override
);

-- ---------- Calendar: the single source of truth for occupied time ----------
CREATE TABLE calendar_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id uuid NOT NULL REFERENCES providers ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN ('confirmed_booking','manual_booking','blocked','holiday')),
  during tstzrange NOT NULL CHECK (NOT isempty(during)),
  booking_id uuid,                                          -- set for confirmed_booking
  customer_name text, customer_phone text, notes text,      -- for manual (external) bookings
  created_by uuid REFERENCES users, created_at timestamptz NOT NULL DEFAULT now(),
  -- THE double-booking guarantee: the database itself rejects overlaps per provider.
  CONSTRAINT no_overlap_per_provider EXCLUDE USING gist (provider_id WITH =, during WITH &&)
);
CREATE INDEX calendar_provider_time_idx ON calendar_entries USING gist (provider_id, during);

-- ---------- Bookings & payments ----------
CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES users,
  provider_id uuid NOT NULL REFERENCES providers,
  package_id uuid NOT NULL REFERENCES service_packages,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','pending','awaiting_payment','payment_submitted','payment_verification','confirmed','rejected','cancelled','completed','no_show')),
  during tstzrange NOT NULL CHECK (NOT isempty(during)),
  guests int, event_notes text,
  currency text NOT NULL REFERENCES currencies,
  total_minor bigint NOT NULL CHECK (total_minor >= 0),
  deposit_minor bigint NOT NULL CHECK (deposit_minor BETWEEN 0 AND total_minor),
  commission_bps int NOT NULL,                              -- snapshot at booking time
  commission_minor bigint NOT NULL,
  idempotency_key text, created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (customer_id, idempotency_key)                     -- prevents duplicate submits on bad connections
);
CREATE INDEX bookings_provider_status_idx ON bookings (provider_id, status);
CREATE INDEX bookings_customer_idx ON bookings (customer_id, status);
CREATE INDEX bookings_during_idx ON bookings USING gist (provider_id, during);
ALTER TABLE calendar_entries ADD FOREIGN KEY (booking_id) REFERENCES bookings;

CREATE TABLE booking_status_history (
  id bigserial PRIMARY KEY, booking_id uuid NOT NULL REFERENCES bookings,
  from_status text, to_status text NOT NULL, event text NOT NULL,
  actor_user_id uuid REFERENCES users, created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings,
  method text NOT NULL CHECK (method IN ('mtn_cash','sritel_cash','sham_cash','bank','cash')),
  amount_minor bigint NOT NULL CHECK (amount_minor > 0), currency text NOT NULL REFERENCES currencies,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','submitted','verified','rejected','refund_requested','refund_approved','refund_rejected','refunded')),
  reference_no text, sender_name text, paid_at timestamptz,
  verified_by uuid REFERENCES users, verified_at timestamptz,
  gateway_ref text,                                         -- for future official gateway adapters
  idempotency_key text, created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (booking_id, idempotency_key)
);
CREATE INDEX payments_booking_idx ON payments (booking_id, status);
CREATE TABLE payment_proofs (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), payment_id uuid NOT NULL REFERENCES payments ON DELETE CASCADE, object_key text NOT NULL, mime text NOT NULL, size_bytes int NOT NULL, created_at timestamptz NOT NULL DEFAULT now());

-- ---------- Audit ----------
CREATE TABLE audit_logs (
  id bigserial PRIMARY KEY, actor_user_id uuid REFERENCES users,
  action text NOT NULL, entity text NOT NULL, entity_id text NOT NULL,
  before jsonb, after jsonb, ip inet, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX audit_entity_idx ON audit_logs (entity, entity_id, created_at DESC);
-- Append-only: block edits and deletes
CREATE FUNCTION audit_immutable() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'audit_logs is append-only'; END $$;
CREATE TRIGGER audit_no_update BEFORE UPDATE OR DELETE ON audit_logs FOR EACH ROW EXECUTE FUNCTION audit_immutable();
