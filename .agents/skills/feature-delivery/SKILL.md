---
name: feature-delivery
description: Plan and deliver a new DreamDay feature through code discovery, Spec Kit documentation, human approval, implementation, and verification. Use when work spans requirements, design, tasks, or application repositories.
---

# Feature delivery

## Purpose

Run the shared documentation-first workflow for a new DreamDay capability while preserving its approval gate.

## Trigger conditions

Use for new user-facing capabilities and multi-repository feature work. Do not use for a narrow typo or an independent code review.

## Required inputs

Feature request; user/problem context; affected repositories if known; existing spec or Change Request; any explicit implementation approval.

## Execution steps

1. Read root AGENTS.md, .ai/workflows/feature-delivery.md, .ai/workflows/documentation-first.md, relevant policies, and the Architect plus applicable domain roles.
2. Inspect root and affected submodule status, local instructions, existing Spec Kit artifacts, and real code. Separate implemented, partial, planned, and unknown behavior.
3. Delegate independent read-only Frontend/Backend/DevOps/QA inventories only when they add measurable value. Define inputs, output, repository ownership, dependencies, and no-write boundaries; wait for results.
4. Use installed Spec Kit skills as appropriate: speckit-specify, speckit-clarify, speckit-plan, speckit-tasks, speckit-checklist, and speckit-analyze. Follow their current instructions and generated paths.
5. Produce or update only authorized documentation. Present spec paths, architecture, repositories, acceptance criteria, risks, plan, and tasks. Stop for human approval before application implementation unless the user explicitly approved this exact scope.
6. After implementation approval, follow approved tasks, assign disjoint file ownership, use speckit-implement, and verify criteria. Use speckit-converge when a remaining-work audit is requested or appropriate.

## Expected outputs

Either (a) a reviewable spec/design/plan/task package awaiting approval, or (b) an approved implementation with repository-scoped changes and acceptance evidence. State what remains unknown.

## Safety restrictions

Do not infer features from product context, skip requirements approval, change unapproved behavior, touch unassigned repositories, expose secrets, or perform Git history/remote actions without explicit authorization.

## Approval requirements

Documentation preparation is allowed by a feature-planning request. Application code changes only after explicit authorization for the named implementation scope. A Change Request has separate requirements and implementation approvals.
