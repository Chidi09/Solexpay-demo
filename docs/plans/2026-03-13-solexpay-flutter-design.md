# SolexPay Flutter Design Demo

**Date:** 2026-03-13

## Goal

Build a polished Flutter design demo for SolexPay from a blank slate using mock data only. The app should feel like a real student-fintech product, reflect the product direction in the MVP blueprint, and be easy to demo to the team in a browser or on a device without depending on backend services.

## Product Framing

This demo is not the production mobile app yet. It is a product-design showcase built in Flutter so the team can review visual quality, user flow, and interaction quality before backend integration. The blueprint is the product reference for what SolexPay is and how the core journeys should feel, while the implementation remains mock-data only.

## Scope

### Included

- Splash and onboarding
- Phone and OTP entry
- KYC-inspired onboarding screens for BVN/NIN/selfie states
- Account created and PIN setup
- Home dashboard with seeded financial activity
- Notifications
- Receive money
- Send money: SolexPay and bank transfer variants
- Review, PIN confirmation, transfer animation, result, and receipt
- Transaction history and detail
- Fund account
- Savings overview with mock activity
- Loan overview and preview/status flow
- Airtime and data bundle purchase flows
- Promos/deals screen
- Profile screen
- Virtual card as a showcase extra

### Out of Scope

- Real backend calls
- Real authentication
- Real KYC integrations
- Real account lookup, NIP, or bill payment APIs
- Production persistence
- Admin portals

## Design Principles

### Trust-first fintech UI

Money actions should feel credible before they feel flashy. The user should always understand who they are paying, what amount is leaving the account, what fee applies, and what state the transaction is in.

### Premium but readable

The React concept uses gradients, glassmorphism, and expressive illustrations. The Flutter version should keep that identity, but simplify any over-busy moments so the app reads clearly on a phone-sized canvas.

### Demo-ready motion

Animations should make the app memorable in a team presentation. The main animation investment goes into screen transitions, balance/success reveals, and the transfer animation.

### Product-faithful storytelling

The app should visually communicate the real SolexPay story from the blueprint: student onboarding, real account creation, transfers, savings, loans, and bill payments. Extras can remain if they improve the demo, but they should not overshadow the student banking narrative.

## Visual Direction

### Brand expression

- Primary trust color: deep navy
- Accent/action color: strong green
- Supporting colors: gold, blue, warm alerts
- Typography direction: display face for headers, clean sans for body copy
- Card-heavy interface with selective glass surfaces and gradient hero sections

### Refinements from the React source

- Normalize spacing and card rhythm across screens
- Reduce decorative effects on critical money screens
- Keep one consistent component language for chips, tiles, CTA buttons, and list rows
- Preserve illustrations, but use them as focal accents rather than on every surface
- Keep virtual card and promo moments present, but secondary to the transfer and loan story

## Demo Runtime Strategy

### Primary target

The demo is designed as a mobile app first.

### Fallback demo mode

Because Android Studio is not available right now, the app should be runnable in Chrome with a centered phone-style shell so it still presents like a mobile product during reviews.

### Demo behavior

The app uses seeded state and delayed mock service responses so interactions feel realistic. User actions should immediately update the visible UI where appropriate: balances change, transactions appear, receipts are created, and status cards update.

## App Architecture

### Project shape

Use a feature-first Flutter structure:

- `lib/app/`
- `lib/core/router/`
- `lib/core/theme/`
- `lib/core/constants/`
- `lib/shared/widgets/`
- `lib/shared/models/`
- `lib/mock/`
- `lib/features/onboarding/`
- `lib/features/home/`
- `lib/features/transfers/`
- `lib/features/history/`
- `lib/features/savings/`
- `lib/features/loans/`
- `lib/features/bills/`
- `lib/features/promos/`
- `lib/features/card/`
- `lib/features/profile/`

### State approach

Use lightweight app state suitable for a demo. A central app model or small feature providers can hold:

- current user profile
- wallet balance
- savings balance
- transactions
- notifications
- loan state
- current transfer draft
- demo toggles for pending/failed/success scenarios

This keeps the app easy to build now and easy to replace with real repositories later.

### Mock services

Mock services should simulate network delay and return deterministic data:

- `MockAuthService`
- `MockTransferService`
- `MockHistoryService`
- `MockSavingsService`
- `MockLoanService`
- `MockBillsService`

## Navigation Plan

### Primary journey

`Splash` -> `Welcome` -> `Phone` -> `OTP` -> `BVN/NIN/KYC` -> `Account Created` -> `Set PIN` -> `Home`

### Home branches

From `Home`, the user can open:

- `Notifications`
- `Receive Money`
- `Fund Account`
- `Send Choice`
- `Transaction History`
- `Savings`
- `Loans`
- `Airtime`
- `Promos`
- `Virtual Card`
- `Profile`

### Transfer journey

`Send Choice` -> `P2P Transfer` or `Bank Transfer` -> `Review` -> `PIN Confirmation` -> `Transfer Animation` -> `Transfer Result` -> `Transaction Detail`

## Screen Inventory

### Onboarding and auth

- Splash
- Welcome carousel
- Phone entry
- OTP verification
- BVN entry
- Selfie/liveness state
- Account created
- PIN setup
- Login variant if needed for demo return path

### Core banking

- Home dashboard
- Notifications
- Receive money
- Fund account
- Send choice
- P2P transfer
- Bank transfer
- Transfer review
- PIN confirmation
- Transfer animation
- Transfer result
- Transaction history
- Transaction detail / receipt

### Product features

- Savings overview
- Loans overview
- Loan preview / tracker state
- Airtime purchase
- Data bundles
- Promos / deals
- Virtual card showcase
- Profile

## Transfer Animation Design

### Objective

Make transfers feel premium and memorable during demos while still reinforcing trust, completion, and motion of value.

### Motion sequence

1. User confirms transfer with PIN.
2. App transitions into a dedicated transfer animation screen.
3. Sender account/card compresses slightly to imply value leaving.
4. A glowing amount chip or money orb travels toward the recipient side.
5. Recipient state lights up with a success ring.
6. The amount resolves into a success/result surface.

### States

- `Success`: used for SolexPay internal transfer
- `Pending`: available for bank transfer demos
- `Failed`: optional demo scenario with clear reversal messaging

### Motion rules

- Duration target: about 1.2 to 2.0 seconds
- Skippable on tap for testing
- Use navy/green trust palette, not arcade-style effects
- Land directly into result/receipt so the flow feels continuous

## Data and Demo Scenarios

### Seed data

The app should launch with believable seeded content:

- Active user profile
- Wallet balance with non-round value
- Savings balance and accrued interest label
- Mixed transaction history
- Notifications with unread items
- Loan status in either eligible or active state
- Airtime/data quick purchase presets

### Simulated outcomes

- Successful P2P transfer
- Pending bank transfer state
- Failed or reversed bank transfer variant available through a demo toggle or mocked branch

## Package Direction

Recommended packages for this design demo:

- `go_router` for clean route management
- `provider` for lightweight demo state
- `google_fonts` for typography
- `flutter_animate` for fast motion composition

Optional if needed later:

- `intl` for formatting
- `flutter_svg` for icons/logos

## Quality Bar

The finished demo should:

- feel polished on both desktop-web demo mode and real mobile dimensions
- have no dead-end core screens
- keep the transfer flow as the highlight of the product demo
- look more consistent and production-minded than the original React source
- stay easy to refactor into a real Flutter codebase later

## Delivery Summary

This Flutter demo should function as a high-quality product walkthrough: student onboarding, money movement, savings, loans, and bill payments, all presented with strong visual identity and mock data realism. It is a design-led app prototype in Flutter, not a backend-integrated MVP.
