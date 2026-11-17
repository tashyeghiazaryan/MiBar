## ADDED Requirements

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

### Requirement: Favorite cards show transliteration and gloss
Favorite word cards SHALL show transliteration in brackets in a smaller italic style on the same line as the gloss.

#### Scenario: Preview line
- **WHEN** a saved word card is visible
- **THEN** the line under the Armenian lemma shows `[transliteration]` then the gloss for the UI language

## MODIFIED Requirements

### Requirement: Favorites list and empty state
Favorites SHALL show collections (when any) and a General section of words not in a custom collection. When the user has no saved words and no collections, Favorites SHALL show the localized empty state.

#### Scenario: Empty favorites
- **WHEN** the user has no saved words and no collections
- **THEN** Favorites shows the empty-state title and guidance in the selected language

#### Scenario: Remove from General
- **WHEN** the user removes a word from the General section
- **THEN** the word is no longer in General and is unsaved unless it remains in another collection
