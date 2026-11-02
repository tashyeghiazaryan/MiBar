# archive-and-favorites Specification

## Purpose

Lets users browse the word archive and manage a favorites list from the main tab bar.

## Requirements

### Requirement: Three-tab shell
The main shell SHALL provide tabs Today, All words, and Favorites with labels localized to the selected language.

#### Scenario: Switch tabs
- **WHEN** the user selects All words, then Favorites, then Today
- **THEN** each tab shows its own page content and the tab bar labels match the UI language

### Requirement: All words archive
All words SHALL list catalog entries with day number, Armenian lemma, glosses ordered for the UI language, today badge for the current word, and save toggles.

#### Scenario: Open archive
- **WHEN** the user opens the All words tab
- **THEN** the catalog list is shown with a localized title and a today badge on the current word

### Requirement: Favorites list and empty state
Favorites SHALL list saved words as cards. When empty, it SHALL show the localized empty state encouraging bookmarking.

#### Scenario: Remove from favorites
- **WHEN** the user removes a word from Favorites
- **THEN** the word disappears from the list and is no longer marked saved elsewhere until saved again

#### Scenario: Empty favorites
- **WHEN** the user has no saved words
- **THEN** Favorites shows the empty-state title and guidance in the selected language

### Requirement: Detail from archive or favorites
Opening a word from All words or Favorites SHALL show a detail view of that word with a back action to the list.

#### Scenario: Open detail and go back
- **WHEN** the user opens a word from All words and taps back
- **THEN** the archive list is shown again
