# archive-and-favorites Specification

## Purpose

Lets users browse the word archive and manage favorites, including named collections, from the main tab bar.

## Requirements

### Requirement: Three-tab shell
The main shell SHALL provide tabs Today, All words, and Favorites with labels localized to the selected language.

#### Scenario: Switch tabs
- **WHEN** the user selects All words, then Favorites, then Today
- **THEN** each tab shows its own page content and the tab bar labels match the UI language

### Requirement: All words archive
All words SHALL list catalog entries with day number, Armenian lemma, transliteration in brackets, glosses ordered for the UI language, today badge for the current word, and save toggles.

#### Scenario: Open archive
- **WHEN** the user opens the All words tab
- **THEN** the catalog list is shown with a localized title and a today badge on the current word

#### Scenario: Row shows transliteration
- **WHEN** an archive row is visible
- **THEN** under the Armenian lemma the row shows `[transliteration]` then the gloss

### Requirement: Favorites collections
Favorites SHALL let the user create named collections (folders). Collections SHALL appear as compact square cards. Creating a collection SHALL ask for a name.

#### Scenario: Create collection
- **WHEN** the user taps New collection, enters a name, and confirms
- **THEN** a new collection appears in Favorites

#### Scenario: Open collection
- **WHEN** the user taps a collection card
- **THEN** the app shows that collection’s words with a back action to Favorites

### Requirement: Save chooses General or a collection
When the user saves an unsaved word and at least one collection exists, the app SHALL present a destination picker with General plus each collection. If no collections exist, the word SHALL save to General immediately. Saving again on an already-saved word SHALL remove it from all favorites destinations.

#### Scenario: Save with collections
- **WHEN** the user taps Save on an unsaved word and collections exist
- **THEN** a Save to sheet lists General and each collection

#### Scenario: Save without collections
- **WHEN** the user taps Save on an unsaved word and no collections exist
- **THEN** the word is saved to General without a picker

### Requirement: Favorites list and empty state
Favorites SHALL show collections (when any) and a General section of words not in a custom collection. When the user has no saved words and no collections, Favorites SHALL show the localized empty state.

#### Scenario: Empty favorites
- **WHEN** the user has no saved words and no collections
- **THEN** Favorites shows the empty-state title and guidance in the selected language

#### Scenario: Remove from General
- **WHEN** the user removes a word from the General section
- **THEN** the word is no longer in General and is unsaved unless it remains in another collection

### Requirement: Favorite cards show transliteration and gloss
Favorite word cards SHALL show transliteration in brackets in a smaller italic style on the same line as the gloss.

#### Scenario: Preview line
- **WHEN** a saved word card is visible
- **THEN** the line under the Armenian lemma shows `[transliteration]` then the gloss for the UI language

### Requirement: Detail from archive or favorites
Opening a word from All words or Favorites SHALL show a detail view of that word with a back action to the list. Returning from All words detail SHALL restore the archive scroll position so the opened word remains in view.

#### Scenario: Open detail and go back
- **WHEN** the user opens a word from All words and taps back
- **THEN** the archive list is shown again at the same scroll position as before opening
