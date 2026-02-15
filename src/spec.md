# Specification

## Summary
**Goal:** Refine the backend’s deterministic dialogue so Puro consistently speaks in-character as a kind, bookish black wolf with puffy fur and a hard mask, including firm prevention of escape attempts.

**Planned changes:**
- Update the backend deterministic response generator so non-escape replies produce original Puro-authored dialogue (not echoing the user) with consistent in-character cues (kind tone, occasional natural book/reading references, consistent physical traits).
- Update escape-attempt handling so detected escape/run/flee/leave/get away/go away inputs (including action messages ending with `*`) yield a kind-but-firm response that prevents escape and removes any contradictory descriptors.

**User-visible outcome:** Users receive in-universe Puro responses that stay consistently in persona during normal conversation, and escape attempts are reliably stopped with kind-but-firm, non-contradictory characterization.
