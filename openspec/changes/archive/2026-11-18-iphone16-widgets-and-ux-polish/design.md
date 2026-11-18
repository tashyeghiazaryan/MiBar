# Design

## Approach
- Home Screen stays `AppIntentConfiguration` + `systemSmall`; Lock Screen is a second widget with `StaticConfiguration` so it appears in the Lock Screen gallery.
- Layout uses `PhoneLayout` (compact / plus / max) from window bounds instead of one binary compact flag.
- Archive list stays mounted under word detail (opacity + overlay) so scroll position is preserved without manual `scrollTo`.

## Decisions
- No `systemMedium` Home Screen size (user request).
- OTP mirrors Sign Up keyboard padding + scroll-to-resend.
- Share export stickers keep full-size defaults; only the in-app preview is compact.
