# Specification

## Summary
**Goal:** Remove the Internet Identity login requirement so the chat works in guest mode by default, while keeping authenticated behavior intact.

**Planned changes:**
- Remove the Internet Identity authentication gate so opening the app goes directly into the chat experience (guest mode).
- Remove all login/logout UI and related user-facing text from the normal chat layout/header while keeping existing Puro branding/avatar.
- Add a per-browser persisted guest session id and use it for guest chat history and profile storage/retrieval.
- Update backend authorization to allow anonymous (guest) callers to use chat and profile APIs while preserving existing permission checks for authenticated principals.
- Update frontend data hooks/API usage so guest calls include the guest session id and continue to work end-to-end (load history, send messages, save profile).
- If backend state structures must change, add an upgrade-safe migration that preserves existing principal-based chat histories/profiles and stores guest data separately.

**User-visible outcome:** Users can open the app and immediately chat as a guest with their own per-browser chat history and profile saved, without seeing any login/logout flow; authenticated users continue to have their existing behavior and data.
