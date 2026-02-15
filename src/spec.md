# Specification

## Summary
**Goal:** Make escape attempts in the Puro roleplay usually blocked in-character, but occasionally successful, while keeping Puro’s characterization consistent.

**Planned changes:**
- Update the backend escape-attempt handling so repeated escape attempts can have different outcomes, with most attempts being blocked and some resulting in a successful escape.
- Revise escape-attempt response text to match Puro’s established traits (kind but firm black wolf with puffy fur and a hard mask) and remove contradictory descriptors.
- Keep current message handling behavior for #action (messages ending with `*` are treated as action and the trailing `*` is stripped) and ensure non-escape messages continue producing in-character responses without verbatim echoing.

**User-visible outcome:** When the user tries to run away, Puro will usually stop them, but occasionally the user will successfully escape, with responses staying fully in-universe and consistent with Puro’s characterization.
