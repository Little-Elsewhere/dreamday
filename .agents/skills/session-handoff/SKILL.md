---
name: session-handoff
description: Record a concise, conflict-aware DreamDay handoff in .ai/HANDOFF.md so work can continue between Codex and Claude Code.
---

# Session handoff

## Purpose

Transfer durable task state between tools without implying shared live context.

## Trigger conditions

Use when ending a session, switching between Codex and Claude Code, or resuming a task whose previous state is recorded in .ai/HANDOFF.md.

## Required inputs

Current objective; tool/session owner; feature/CR; approved decisions and scope; relevant paths; completed and outstanding work; verification; blockers; next action.

## Execution steps

1. Read .ai/HANDOFF.md and this skill. At session start, compare any active record with the current objective.
2. If another objective is Active, compare its owner/tool, objective, and timestamp. Do not overwrite or combine conflicting work; report the conflict and request a human decision.
3. Before writing, re-read the file and confirm it has not changed since inspection. If it has, reconcile rather than replace.
4. Update the single handoff slot concisely. Link to durable specs, CRs, and code paths; separate decisions from suggestions and actual verification from planned checks.
5. Omit secrets, credentials, unnecessary personal data, and full chat transcripts. Set Status to Active during a cross-tool continuation and Closed when finished.
6. Tell the user the objective, next action, evidence state, and any blocker recorded.

## Expected outputs

A conflict-free current handoff or a reported conflict that requires reconciliation. Do not create a second session log unless requested.

## Safety restrictions

Do not overwrite another active session, invent approval, include sensitive values, imply tools share live context, or record an unrun test as verified.

## Approval requirements

Updating the handoff file is allowed when the session owner and objective match and no conflict exists. Ask the user to reconcile competing active sessions before modifying the shared slot.
