## MODIFIED Requirements

### Requirement: All words archive
All words SHALL list catalog entries with day number, Armenian lemma, transliteration in brackets, glosses ordered for the UI language, today badge for the current word, and save toggles.

#### Scenario: Open archive
- **WHEN** the user opens the All words tab
- **THEN** the catalog list is shown with a localized title and a today badge on the current word

#### Scenario: Row shows transliteration
- **WHEN** an archive row is visible
- **THEN** under the Armenian lemma the row shows `[transliteration]` then the gloss

### Requirement: Detail from archive or favorites
Opening a word from All words or Favorites SHALL show a detail view of that word with a back action to the list. Returning from All words detail SHALL restore the archive scroll position so the opened word remains in view.

#### Scenario: Open detail and go back
- **WHEN** the user opens a word from All words and taps back
- **THEN** the archive list is shown again at the same scroll position as before opening
