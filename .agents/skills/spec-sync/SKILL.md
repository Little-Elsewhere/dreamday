---
name: spec-sync
description: Reconcile DreamDay implementation and approved Spec Kit artifacts through the correct approval and Change Request lifecycle without silently rewriting requirements.
---

# Specification sync

## Purpose

Maintain traceability between living specifications, approved plans/tasks, implementation, verification, and Change Requests.

## Trigger conditions

Use after approved implementation, when a spec appears stale, during a Change Request, or when an implementation/spec mismatch is found.

## Required inputs

Feature directory and artifacts; affected repositories/diff; approval and CR status; verification evidence; requested sync scope.

## Execution steps

1. Read .ai/policies/change-requests.md, .ai/workflows/documentation-first.md, relevant Spec Kit instructions, and the approved spec/plan/tasks.
2. Inspect actual code and status in affected repositories. Build a traceability table from acceptance criteria to implementation and evidence.
3. Classify gaps as approved documentation omission, incomplete implementation, unapproved behavior drift, or unverified behavior.
4. For behavior drift, open a Change Request; do not rewrite approved requirements to match code. For an approved document update, edit only authorized feature artifacts on a reviewable branch and preserve history.
5. Update CR implementation/verification fields only from evidence. Append a changelog reference only at verified merge/release, or state why a docs-only entry does not apply.
6. Report changed artifact paths, criterion mapping, unresolved mismatch, checks, and approval still needed.

## Expected outputs

A traceability report and, only when authorized, a reviewed spec/history/CR update that preserves existing approval state.

## Safety restrictions

Never modify Spec Kit managed templates/integrations, change a spec before the CR requirements gate, falsify acceptance checkboxes, or claim implementation completion from documentation alone.

## Approval requirements

Inspection and reporting are read-only. Editing approved feature artifacts requires relevant requirements/implementation approval and a reviewable branch. Do not create or merge a release entry before verified work ships.
