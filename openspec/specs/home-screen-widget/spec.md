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

### Requirement: WidgetKit extension exists
The `MiBarWidget` extension SHALL provide configurable styles for the Home Screen. Until sync ships, the extension MAY show placeholder word content independent of in-app catalog updates.

#### Scenario: Add widget from Home Screen
- **WHEN** the user adds a MiBar widget from the iOS Home Screen gallery
- **THEN** a styled word widget appears using one of the configured styles
