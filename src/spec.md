# Specification

## Summary
**Goal:** Make Puro’s chat persona and avatar consistently match Puro from the game “Changed” by DragonSnow.

**Planned changes:**
- Update the backend Puro response generator to produce short, in-character dialogue from Puro’s perspective (no echoing user text; no generic/AI-disclaimer phrasing).
- Improve backend handling of user action messages (ending with “*”) so Puro replies in-character to the action without immersion-breaking language, while preserving existing action parsing/storage behavior.
- Update the Puro avatar asset to visually match Puro from “Changed” and switch the PuroAvatar component to use the updated image from `frontend/public/assets/generated`.

**User-visible outcome:** Users can chat with Puro who responds consistently in-character (including to action messages), and the UI shows an updated Puro avatar that matches the “Changed” design.
