# home-screen-widget Specification

## Purpose

Helps users preview MiBar Home Screen widget styles in-app and add a WidgetKit extension widget on the device Home Screen.

## Requirements

### Requirement: In-app widget style sheet
From Home, the user SHALL be able to open a “Choose your widget” sheet with localized copy, style carousel (Classic / Soft / Sun / Clear), and add instructions for iPhone and Android.

#### Scenario: Open widget sheet
- **WHEN** the user taps Choose style on the Home Screen promo
- **THEN** the widget sheet appears above the main UI and the tab bar is hidden while it is open

#### Scenario: Sheet fills bottom edge
- **WHEN** the widget sheet is open
- **THEN** no gray paper/tab-bar strip shows under the sheet above the home indicator

### Requirement: Selected style preview is fully framed
Carousel cards SHALL show a complete border without clipping when a style is selected.

#### Scenario: Selected card border visible
- **WHEN** a widget style card is selected in the carousel
- **THEN** the full rounded border around that card is visible without top or bottom clipping

### Requirement: App Group sync of today’s word
The main app SHALL publish today’s word content and selected widget style to a shared App Group store so the WidgetKit extension can display the same word and style.

#### Scenario: Style change updates shared store
- **WHEN** the user selects a widget style in the in-app sheet
- **THEN** the shared store is updated with that style and today’s word fields

### Requirement: WidgetKit extension exists
The `MiBarWidget` extension SHALL read from the App Group store when available and render the configured style (Classic / Soft / Sun / Clear) for Home Screen `systemSmall`. Clear SHALL use a frosted-glass presentation when the platform supports it. Lock Screen support SHALL be a separate `StaticConfiguration` widget exposing `accessoryCircular`, `accessoryRectangular`, and `accessoryInline`.

#### Scenario: Add widget from Home Screen
- **WHEN** the user adds a MiBar widget from the iOS Home Screen gallery
- **THEN** a styled word widget appears using the last published style and word data when present

#### Scenario: Add Lock Screen widget
- **WHEN** the user customizes the Lock Screen and searches for MiBar
- **THEN** circular, rectangular, and inline MiBar widgets are available and show today’s word
