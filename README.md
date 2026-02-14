# Vouch — Privacy-First Referral App

> Trusted recommendations from people you actually know.

Vouch digitizes word-of-mouth referrals for local service providers. Instead of anonymous reviews, you get recommendations filtered through your real social graph — with detail and trust level varying by how close the connection is.

---

## What It Is

Senior households and family "connectors" manage a mental black book of trusted plumbers, electricians, cleaners, and other service pros. Vouch makes that book shareable and portable while keeping privacy at the center of every design decision.

**How trust tiers work:**

| Relationship | What you see |
|---|---|
| 1st-degree friend | Full details: name, note, price paid, safety rating |
| 2nd-degree (friend of friend) | Blurred price, voucher shown as "a friend of [Name]" |
| Neighborhood | Anonymous aggregate: "Recommended by 12 neighbors" |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.29.1 (iOS + Android + Web) |
| State | Riverpod |
| Navigation | GoRouter |
| Backend | Supabase (PostgreSQL + Auth + Edge Functions) |
| AI | Google Gemini 2.0 Flash (AI Scout) |
| Payments | Stripe |
| Deep Linking | app_links |
| Crypto | SHA-256 (contacts) + AES-256 (price data) |

---

## Privacy Architecture

Vouch is zero-knowledge by design. **No raw phone numbers ever leave the device.**

```
Device                          Server
──────                          ──────
phone number
    │
    ▼
SHA-256(phone + salt)  ──────►  phone_hash column (only this is stored)
    │
    ▼
SecurityException thrown
if raw phone detected in
any outbound payload
```

Key privacy guarantees:

- **Contact matching** — hashes are sent to the `match-hashes` edge function; the server compares hashes and returns user IDs only. Names never leave the device.
- **Price data** — AES-256-CBC encrypted on-device before storage; decrypted client-side only for 1st-degree connections.
- **Row Level Security** — Supabase RLS policies ensure vouches are only readable by members of the voucher's active circle.

---

## Project Structure

```
lib/
├── core/
│   ├── config/          # Environment config (compile-time defines)
│   ├── constants/       # AppColors, AppConstants
│   ├── models/          # UserModel, ProModel, VouchModel, CircleModel, AlertModel, ProLeadModel
│   ├── router/          # GoRouter setup (AppRoutes)
│   ├── services/        # PrivacyService, EncryptionService, SupabaseService,
│   │                    # AIScoutService, ContactService, DeepLinkService
│   ├── theme/           # VouchTheme (WCAG AAA, Inter font, 60dp touch targets)
│   └── widgets/         # TrustCard, VouchButton, EmptyState, LoadingOverlay, NavigationShell
│
├── features/
│   ├── auth/            # Phone login, OTP verification
│   ├── onboarding/      # Splash, carousel, contact handshake
│   ├── home/            # Trust feed, search, alert ticker
│   ├── circle/          # Friends list, friend's vouch book
│   ├── vouch/           # Add vouch form, Pro profile (trust-tiered)
│   ├── scout/           # AI chat with Gemini
│   ├── safety/          # Alert center, scam reporting, trust bundle export
│   ├── pro/             # Pro dashboard, lead tracker, paywall
│   └── profile/         # User profile, settings
│
└── main.dart            # App entry point with ProviderScope + portrait lock

supabase/
├── migrations/
│   ├── 001_initial_schema.sql   # All tables, indexes, triggers
│   └── 002_row_level_security.sql  # RLS policies for every table
└── functions/
    └── match-hashes/    # Edge Function: privacy-preserving contact matching
```

---

## Getting Started

### Prerequisites

- Flutter 3.29.1+
- Dart 3.7.0+
- A [Supabase](https://supabase.com) project
- A [Google AI Studio](https://aistudio.google.com) API key (Gemini)
- A [Stripe](https://stripe.com) account (for Pro paywall)

### 1. Clone and install dependencies

```bash
git clone <repo-url>
cd Vouch-App
flutter pub get
```

### 2. Configure environment

Copy the example env file and fill in your credentials:

```bash
cp .env.example .env
```

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
PHONE_HASH_SALT=your-secret-salt
GEMINI_API_KEY=your-gemini-key
STRIPE_PUBLISHABLE_KEY=pk_test_...
GOOGLE_MAPS_API_KEY=your-maps-key
```

Run with compile-time defines (never commit `.env`):

```bash
flutter run --dart-define-from-file=.env
```

### 3. Set up the database

Run the migrations in your Supabase project in order:

```bash
# In the Supabase SQL editor or via the CLI:
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_row_level_security.sql
```

Deploy the edge function:

```bash
supabase functions deploy match-hashes
```

### 4. Run the app

```bash
flutter run --dart-define-from-file=.env
```

---

## Running Tests

```bash
# All tests
flutter test

# Specific suites
flutter test test/core/privacy_service_test.dart   # 15 tests
flutter test test/core/models_test.dart             # 9 tests
flutter test test/widget_test.dart                  # 14 tests
```

**38 tests, zero analyzer issues.**

Key test coverage:

- `PrivacyService` — hash consistency, phone normalization, `SecurityException` on raw PII
- All models — JSON serialization/deserialization, `copyWith`, defaults
- Widgets — `TrustCard` trust tiers, `VouchButton` states, `EmptyState` variants
- Accessibility — all key widgets render correctly at 200% text scale

---

## Database Schema

```
users          id, phone_hash (SHA-256), display_name, trust_score, zip_code
pros           id, business_name, category, avg_vouch_score, is_claimed
vouches        id, user_id, pro_id, price_paid_encrypted (AES-256), safety_rating, visibility_level
circles        id, user_a_id, user_b_id, status (pending/active/blocked)
alerts         id, reported_by, pro_id, alert_type (scam/warning), location (PostGIS)
pro_leads      id, pro_id, seeker_id, status (new/contacted/completed)
invite_links   id, inviter_id, code, expires_at
trust_bundles  id, creator_id, code, vouch_ids, expires_at
```

---

## Pro Business Model

Service providers get a freemium lead-generation model:

- First **5 leads are free** — zero friction for adoption
- Lead 6+ requires a **$99/month subscription** (Stripe)
- The value summary shown before the paywall: "You've earned $X through Vouch"
- Pros can verify their business by uploading a license photo

---

## Accessibility Design (Target: 65+ Users)

All screens are designed for senior-friendly use:

- Minimum **60dp touch targets** on all interactive elements
- **200% text scaling** — tested and verified to render without overflow
- **WCAG AAA** color contrast across all color combinations
- **Single-column scrollable layouts** only — no horizontal scrolling at any zoom level
- **Haptic feedback** on every button interaction
- **Screen reader** semantic labels on key widgets

Design tokens:
- Primary: Trust Blue `#1A5276`
- Secondary: Safety Amber `#F39C12`
- Font: Inter (400/500/600/700 weights)
- Body text: 16-18sp minimum

---

## Feature Roadmap

- [ ] Lottie animations (success checkmarks, logo splash)
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] SSL certificate pinning for all API calls
- [ ] Branch.io deferred deep links for viral invite attribution
- [ ] PDF trust bundle export
- [ ] Google Maps integration in Safety Center
- [ ] Voice-to-text in Scout chat
- [ ] Gemini Context Caching for neighborhood data (~90% token cost reduction)

---

## Security Notes

Before production deployment, complete the following:

1. **Rotate the `PHONE_HASH_SALT`** to a cryptographically random 32+ byte value and treat it as a secret.
2. **Verify RLS policies** by testing with two separate Supabase auth tokens that the circle trust gate is enforced.
3. **Enable SSL pinning** for all Supabase and API calls.
4. **Audit invite link expiry** (72-hour server-side enforcement).
5. **Test `SecurityException`** fires when raw phone data is included in any payload using a network proxy.

---

## License

Private — all rights reserved.
