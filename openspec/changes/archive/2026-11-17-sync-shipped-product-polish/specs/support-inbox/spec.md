## Purpose

Lets users contact MiBar support through an inbox of conversations, creating a conversation only when the first message is sent.

## ADDED Requirements

### Requirement: Support inbox entry from Settings
Settings SHALL provide a Support row that opens a full-screen Support inbox with a Write action and a list of existing conversations that already contain user or support messages.

#### Scenario: Open empty inbox
- **WHEN** the user opens Support with no sent conversations
- **THEN** the inbox shows Write and an empty-state message

### Requirement: Write opens compose without creating a conversation
Tapping Write SHALL open a compose chat. A conversation SHALL be created only when the user sends the first message.

#### Scenario: Leave compose without sending
- **WHEN** the user opens Write and goes back without sending
- **THEN** no new conversation appears in the inbox

#### Scenario: First send creates conversation
- **WHEN** the user selects a topic, types a message, and sends
- **THEN** a conversation is created, the message appears, and one auto-reply is produced for that request

### Requirement: Topic chips and one auto-reply per conversation
Compose SHALL show topic choices (problem, feedback, other). The first send SHALL trigger a single prototype auto-reply for the selected topic. Further messages in the same conversation SHALL not trigger another auto-reply.

#### Scenario: Second message stays unanswered
- **WHEN** the user sends a second message in the same conversation after the auto-reply
- **THEN** the message is stored and no second auto-reply is added
