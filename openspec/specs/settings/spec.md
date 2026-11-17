# settings Specification

## Purpose

Gives users a Settings sheet for account identity, UI language, new-word reminder preference, support entry, legal links, app version, and logout.

## Requirements

### Requirement: Settings sheet contents
From Home, Settings SHALL show Account (email), Language options, a New word reminder toggle (no fixed clock time in copy), Support, Legal links (Terms of Use, Privacy Policy), About version, and Log out.

#### Scenario: Change language in Settings
- **WHEN** the user selects a different language in Settings
- **THEN** main-app chrome copy updates to that language

#### Scenario: Toggle new word reminder
- **WHEN** the user toggles New word
- **THEN** the preference updates (push delivery may remain unimplemented until backend/notifications ship)

#### Scenario: Log out
- **WHEN** the user taps Log out
- **THEN** the app returns to Welcome and clears the in-session account email flag used for returning-user routing
