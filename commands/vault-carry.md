---
description: Carry the current chat session into the vault as a captured working context.
skill: vault-carry
---

Use the `vault-carry` skill to capture the current chat conversation —
summary, artifacts produced, references cited — into a dedicated folder
under `sessions/{YYYY-MM-DD-slug}/`.

Argument: an optional slug for the session (kebab-case). If omitted,
the skill derives one from the conversation's main topic and confirms
with RM.

Always discusses the proposal with RM before writing (Step 3 of the
skill).
