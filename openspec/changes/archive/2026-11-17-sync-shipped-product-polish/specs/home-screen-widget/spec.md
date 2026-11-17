## ADDED Requirements

### Requirement: App Group sync of today’s word
The main app SHALL publish today’s word content and selected widget style to a shared App Group store so the WidgetKit extension can display the same word and style.

#### Scenario: Style change updates shared store
- **WHEN** the user selects a widget style in the in-app sheet
- **THEN** the shared store is updated with that style and today’s word fields

## MODIFIED Requirements

### Requirement: WidgetKit extension exists
The `MiBarWidget` extension SHALL read from the App Group store when available and render the configured style (Classic / Soft / Sun / Clear). Clear SHALL use a frosted-glass presentation when the platform supports it.

#### Scenario: Add widget from Home Screen
- **WHEN** the user adds a MiBar widget from the iOS Home Screen gallery
- **THEN** a styled word widget appears using the last published style and word data when present
