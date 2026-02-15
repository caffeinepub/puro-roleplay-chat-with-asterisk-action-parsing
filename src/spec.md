# Specification

## Summary
**Goal:** Build a Puro roleplay chat app with asterisk-marked action parsing, persistent session history, and deterministic local response generation.

**Planned changes:**
- Create a React chat UI with message list, input, send action, Enter-to-send (Shift+Enter for newline), loading/sending state, and error handling with retry.
- Visually differentiate action messages (user inputs ending with `*`) from normal dialogue in the transcript.
- Add a consistent friendly sci‑fi lab/creature-companion theme across the chat screen (not predominantly blue/purple).
- Include and display a static Puro avatar image in the UI (e.g., header and/or next to Puro messages) from `frontend/public/assets/generated`.
- Implement backend canister methods to send a message (returning Puro’s reply) and fetch the current session history.
- Persist per-user chat history (including author, order/timestamp, text, and type: dialogue vs action) across page reloads for the same principal or stable anonymous session.
- Implement a deterministic, local (non-third-party) Puro response generator that stays in-character and explicitly acknowledges action messages.

**User-visible outcome:** Users can chat with “Puro” in a styled chat interface; messages ending in `*` are treated and displayed as actions, and Puro responds in-character with deterministic replies while the conversation persists across reloads.
