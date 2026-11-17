# home-word-of-the-day Specification

## Purpose

Shows today’s Armenian word with pronunciation, translations, phrase, cultural note, listen/save/share actions, and Home Screen widget promo.

## Requirements

### Requirement: Word of the day hero
The Home tab SHALL show the current word’s Armenian lemma, transliteration, English and Russian glosses, issue number, and a live localized date header for today.

#### Scenario: Cold open on Home
- **WHEN** the user reaches the main shell on the Today tab
- **THEN** the hero shows the word of the day with listen, save, and share actions

### Requirement: First thirty words catalog
The app SHALL ship a static catalog of the first 30 MiBar words with Armenian lemma, transliteration, English gloss, Russian gloss, example sentence (+ transliteration + EN/RU), part of speech, and Between the lines notes in English and Russian. Today’s word SHALL be catalog entry day 1 until calendar rotation ships.

#### Scenario: Today shows day one
- **WHEN** the user opens Home
- **THEN** the hero shows the day-1 Armenian word (Ժպիտ) with its phrase and notes

### Requirement: Listen plays Armenian audio
Tapping Listen SHALL play bundled Armenian audio for the word when available (`word-{id}` audio in the app bundle). The control SHALL show a playing state until finished or stopped.

#### Scenario: Play pronunciation
- **WHEN** the user taps Listen and audio exists for that word id
- **THEN** pronunciation starts and the control shows a playing state until finished or stopped

### Requirement: Save toggles favorites
Tapping Save SHALL follow the Favorites save rules (General vs collection picker). When the word is already saved, tapping Save SHALL remove it from all favorites destinations.

#### Scenario: Unsave from Home
- **WHEN** the user taps Save on a word that is already saved
- **THEN** the word is removed from General and every collection

### Requirement: Share opens in-app story page
Tapping Share SHALL open an in-app Share page with story card style choices (including Soft, Classic, Bright) and a way to share to Instagram Stories or the system share sheet. The app MUST NOT deep-link as the only share path without user choice of style.

#### Scenario: Open share page
- **WHEN** the user taps Share on a word
- **THEN** the Share page appears with style options for the story card

#### Scenario: Share destination choice
- **WHEN** the user completes sharing from the Share page via the system activity path
- **THEN** the system activity sheet appears so the user can choose a destination

### Requirement: Say it today and Between the lines
Below the hero, the app SHALL show the day’s phrase with transliteration and the phrase translation for the selected UI language, then an optional “Between the lines” cultural note in the selected UI language.

#### Scenario: Localized cultural note
- **WHEN** the UI language is Russian and the word has a Russian note
- **THEN** the Between the lines body shows the Russian note text

### Requirement: Scroll-for-more hint dismisses at bottom
A Scroll for more hint MAY appear near the top of Home, but it MUST hide after the user scrolls, when content fits the viewport, or when the user is near the bottom of the page.

#### Scenario: Near bottom of Home
- **WHEN** the user scrolls near the bottom of the Home page
- **THEN** the Scroll for more badge is not shown
