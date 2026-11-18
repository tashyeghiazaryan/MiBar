# Proposal: iPhone 16 layout, Lock Screen widgets, and UX polish

## Why
Ship Lock Screen widgets and tighten layout/UX across the iPhone 16 family so smaller phones stay readable and interactive (OTP, Share, widget sheet, All words).

## What Changes
- Lock Screen widgets via a separate `StaticConfiguration` (`accessoryCircular` / `rectangular` / `inline`)
- `ScreenMetrics` / `PhoneLayout` tiers for compact / plus / max
- Compact Welcome copy placement, Create collection modal motion, widget sheet pinned Got it
- Share page and OTP keyboard avoidance on compact phones
- All words: transliteration under lemmas; preserve scroll when returning from word detail

## Capabilities
- `home-screen-widget` — Lock Screen families
- `archive-and-favorites` — transliteration rows + scroll restore
- `onboarding` — OTP keyboard keeps resend visible

## Out of Scope
- Android widgets, backend OTP, medium Home Screen widget size
