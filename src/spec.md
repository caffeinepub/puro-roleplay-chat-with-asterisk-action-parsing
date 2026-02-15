# Specification

## Summary
**Goal:** Shift the chat experience from Puro-focused roleplay to neutral, helpful assistant-style conversation while preserving action-message handling.

**Planned changes:**
- Update backend response generation to avoid Puro in-character roleplay mannerisms and immersion framing, while still recognizing and neutrally acknowledging action messages (messages ending with "*").
- Update chat UI copy to remove roleplay-first phrasing (e.g., references to talking “to Puro”) and present the bot as a general chat assistant, while keeping the existing hint about using "*" for actions.

**User-visible outcome:** Users can chat with the assistant in a neutral style (not roleplay as Puro), and action messages ending in "*" are still treated as actions and acknowledged plainly.
