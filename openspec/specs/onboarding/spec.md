# onboarding Specification

## Purpose

Lets users enter MiBar through Welcome (Sign Up / Log in), email + OTP, optional language choice for new users, and a short loading moment before the main shell.

## Requirements

### Requirement: Welcome entry with Sign Up and Log in
The app SHALL open on a Welcome screen with brand framing and two actions: Sign Up and Log in.

#### Scenario: Choose Sign Up
- **WHEN** the user taps Sign Up
- **THEN** the app opens the Sign Up email screen

#### Scenario: Choose Log in
- **WHEN** the user taps Log in
- **THEN** the app opens the Log in email screen

### Requirement: Sign Up collects email, terms, and account shortcut
The Sign Up screen SHALL collect email (or prototype `1111`), require agreement to Terms of Use and Privacy Policy before Continue, and offer “I already have an account” to open Log in. Back SHALL return to Welcome.

#### Scenario: Terms required
- **WHEN** the user taps Continue without agreeing to terms
- **THEN** the app shows that terms agreement is required and stays on Sign Up

#### Scenario: Already have an account
- **WHEN** the user taps “I already have an account”
- **THEN** the app opens the Log in screen

### Requirement: Email entry with prototype access
The Sign Up email field placeholder SHALL be `name@example.com` in black. Continue SHALL validate email format or accept `1111`.

#### Scenario: Valid email continues
- **WHEN** the user enters a valid email on Sign Up, agrees to terms, and taps Continue
- **THEN** the app moves to the OTP screen for that email

#### Scenario: Prototype code continues
- **WHEN** the user enters `1111` on Sign Up, agrees to terms, and taps Continue
- **THEN** the app moves to the OTP screen in prototype mode

#### Scenario: Keyboard keeps Continue reachable
- **WHEN** the email field is focused and the keyboard is open
- **THEN** the email field and Continue remain visible above the keyboard on iPhone 16 and larger phones

### Requirement: Log in collects email only
The Log in screen SHALL collect email (or prototype `1111`) without a terms checkbox. Continue SHALL move to OTP. Back SHALL return to Welcome. A Create an account action SHALL open Sign Up.

#### Scenario: Log in continues to OTP
- **WHEN** the user enters a valid email on Log in and taps Continue
- **THEN** the app moves to the OTP screen as a returning user

### Requirement: OTP verifies on Continue
The OTP screen SHALL collect a four-digit code and verify only when the user taps Continue (not automatically on the fourth digit). Prototype success code SHALL be `1111`.

#### Scenario: Wrong code
- **WHEN** the user enters a non-`1111` code and taps Continue
- **THEN** the app shows an error and keeps the user on OTP

#### Scenario: Sign Up success goes to language
- **WHEN** a new (Sign Up) user enters `1111` and taps Continue
- **THEN** the app proceeds to language selection

#### Scenario: Log in success skips language
- **WHEN** a returning (Log in) user enters `1111` and taps Continue
- **THEN** the app proceeds to the loading moment and then the main shell without language selection

#### Scenario: Keyboard keeps Send code again reachable
- **WHEN** the OTP field is focused and the keyboard is open
- **THEN** Continue and Send code again remain visible above the keyboard on iPhone 16 and larger phones

### Requirement: Language selection drives UI language
After OTP for a new user, the app SHALL present English, Russian, and Armenian options. The selected language SHALL apply to main-app chrome (Home, All words, Favorites, tabs, widget sheet, share labels, settings).

#### Scenario: Choose Russian
- **WHEN** the user selects Русский and continues
- **THEN** subsequent main-app UI strings use Russian copy from `L10n`
