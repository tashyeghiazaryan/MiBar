# Proposal

## Why

Product behavior shipped in the app has drifted ahead of OpenSpec main specs (auth welcome flow, favorites collections, support inbox, settings, 30-word catalog, share/widget polish). Specs need to catch up so planning stays the source of truth.

## What Changes

- Document the Welcome → Sign Up / Log in entry flow and OTP Continue verification
- Document Favorites collections (folders), save-to-folder picker, and card previews with transliteration
- Document Support inbox (compose on send) and Settings minimum rows
- Document first-30 word catalog, example sentences, Between the lines notes, and bundled Listen audio
- Document Share story page styles and App Group widget data sync
- Mark this change as already implemented in code; OpenSpec work is sync + archive only

## Capabilities

### New Capabilities
- `support-inbox`: Support conversations list, compose-on-send chat, topic chips, auto-reply
- `settings`: Settings sheet with account, language, new-word reminder preference, legal links, version, logout

### Modified Capabilities
- `onboarding`: Welcome screen; Sign Up vs Log in; OTP verifies on Continue button; returning users skip language
- `archive-and-favorites`: Collections/folders; save destination picker; Favorites layout
- `home-word-of-the-day`: 30-word catalog; Listen via bundled audio; Share opens in-app story page
- `home-screen-widget`: App Group sync of today’s word + style from the main app

## Impact

- OpenSpec only: `openspec/specs/*` and this change under `openspec/changes/`
- No app code changes required for this sync (implementation already on `main`)
- Future work (real auth, persistence, push) remains out of scope here
