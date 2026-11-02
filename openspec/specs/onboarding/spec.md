# onboarding Specification

## Purpose

Lets a new user enter the app through email, OTP, language choice, and a short loading moment before the main shell.

## Requirements

### Requirement: Email entry with prototype access
The app SHALL present an email screen where the user can enter an email address or the prototype code `1111`. The field placeholder SHALL be `name@example.com` in black. Continue SHALL validate email format or accept `1111`.

#### Scenario: Valid email continues
- **WHEN** the user enters a valid email and taps Continue
- **THEN** the app moves to the OTP screen for that email

#### Scenario: Prototype code continues
- **WHEN** the user enters `1111` and taps Continue
- **THEN** the app moves to the OTP screen in prototype mode

#### Scenario: Keyboard keeps Continue reachable
- **WHEN** the email field is focused and the keyboard is open
- **THEN** the email field and Continue remain visible above the keyboard on iPhone 16 and larger phones

### Requirement: OTP verification
The OTP screen SHALL collect a four-digit code with a number pad. Prototype success code SHALL be `1111`.

#### Scenario: Correct prototype OTP
- **WHEN** the user enters `1111` on the OTP screen
- **THEN** the app proceeds to language selection

### Requirement: Language selection drives UI language
After OTP, the app SHALL present English, Russian, and Armenian options. The selected language SHALL apply to main-app chrome (Home, All words, Favorites, tabs, widget sheet, share labels).

#### Scenario: Choose Russian
- **WHEN** the user selects Русский and continues
- **THEN** subsequent main-app UI strings use Russian copy from `L10n`
