# Design

## Context

Implementation already lives on `main` (commit after product polish). OpenSpec main specs still describe the earlier prototype (single email entry, TTS listen, flat favorites, no support/settings). This change is a documentation sync: delta specs describe shipped behavior so archive can update main specs.

## Goals / Non-Goals

**Goals:**
- Align OpenSpec capabilities with shipped UX: welcome auth, favorites collections, support inbox, settings, catalog, share, widget sync
- Keep deltas scenario-testable and free of framework trivia
- Archive cleanly after syncing main specs

**Non-Goals:**
- Re-implementing app features
- Real auth, persistence, remote catalog, or push scheduling
- Paid themes/levels (future)

## Decisions

1. **Retroactive change name `sync-shipped-product-polish`**
   - Alternative: many small changes per feature — rejected because the gap is one documentation catch-up.

2. **New capabilities `support-inbox` and `settings`**
   - Alternative: fold into onboarding/home — rejected; they are distinct user journeys.

3. **Modify existing onboarding / favorites / home / widget specs**
   - Prefer MODIFIED + ADDED over inventing parallel capability names for the same surfaces.

4. **Tasks marked complete**
   - Implementation already shipped; tasks document what landed for archive completeness, not future work.

## Risks / Trade-offs

- Specs may still lag small UI copy tweaks; accept and update via later deltas.
- Listen audio coverage is incomplete for all 30 ids; spec states “when available.”
- Legal URLs are placeholders (`mibar.app`) until real pages exist.
