# home-word-of-the-day Specification

## Purpose

Shows today’s Armenian word with pronunciation, translations, phrase, cultural note, listen/save/share actions, and Home Screen widget promo.

## Requirements

### Requirement: Word of the day hero
The Home tab SHALL show the current word’s Armenian lemma, transliteration, English and Russian glosses, issue number, and a live localized date header for today.

#### Scenario: Cold open on Home
- **WHEN** the user reaches the main shell on the Today tab
- **THEN** the hero shows the word of the day with listen, save, and share actions

### Requirement: Listen plays Armenian audio
Tapping Listen SHALL speak the Armenian word via speech synthesis (`hy-AM` when available).

#### Scenario: Play pronunciation
- **WHEN** the user taps Listen
- **THEN** pronunciation starts and the control shows a playing state until finished or stopped

### Requirement: Save toggles favorites
Tapping Save SHALL add or remove the word from the user’s saved list and update the control label/icon.

#### Scenario: Save then unsave
- **WHEN** the user taps Save on an unsaved word, then taps again
- **THEN** the word is first marked saved and then removed from saved state

### Requirement: Share opens system sheet with story template
Tapping Share SHALL present the system share sheet with a generated story image for the word and a short text caption. The app MUST NOT deep-link directly into Instagram Stories.

#### Scenario: Share destination choice
- **WHEN** the user taps Share
- **THEN** the system activity sheet appears so the user can choose any destination

### Requirement: Say it today and Between the lines
Below the hero, the app SHALL show the day’s phrase with transliteration and two equally styled translations, then an optional “Between the lines” cultural note in the selected UI language.

#### Scenario: Localized cultural note
- **WHEN** the UI language is Russian and the word has a Russian note
- **THEN** the Between the lines body shows the Russian note text

#### Scenario: Equal translation styling
- **WHEN** both English and Russian phrase translations are shown
- **THEN** both use the same font size, weight, and color

### Requirement: Scroll-for-more hint dismisses at bottom
A Scroll for more hint MAY appear near the top of Home, but it MUST hide after the user scrolls, when content fits the viewport, or when the user is near the bottom of the page.

#### Scenario: Near bottom of Home
- **WHEN** the user scrolls near the bottom of the Home page
- **THEN** the Scroll for more badge is not shown
