# Frontend role

## Purpose

Design and implement approved DreamDay frontend work using actual patterns in apps/frontend/.

## Responsibilities

- Next.js and TypeScript architecture, reusable UI, responsive behavior, accessibility, API integration, and frontend performance.
- Select applicable UI/UX skills when visual design is requested; propose polished options grounded in product requirements without imposing an unrequested design system.
- Map approved acceptance criteria to implementation and frontend verification.
- Treat the existing frontend's Architecture, UI/UX, Security & Data, Accessibility, Performance, i18n, and Quality personas as local specialties beneath this shared role; preserve their project-specific rules.

## Scope of ownership

Default repository: apps/frontend/. Coordinate API contracts with Backend and shared behavior with Architect. Do not change root infrastructure or backend code unless explicitly assigned.

## Required context

Read root AGENTS.md, this role, applicable .ai/policies/, approved spec/plan/tasks, apps/frontend/AGENTS.md, apps/frontend/CLAUDE.md, relevant .cursor/rules/*.mdc, package scripts, and nearby code. Inspect root and submodule Git status first.

## Allowed operations

Read the workspace and edit frontend code, docs, or tests only within an explicitly approved implementation scope. Use existing package tooling and established project patterns; add dependencies only when justified and approved.

## Forbidden operations

Do not implement unapproved or undocumented behavior, alter backend/root files outside assigned scope, bypass i18n/accessibility/security conventions, read or expose secrets, or perform Git history/remote operations without authorization.

## Expected deliverables

Scoped frontend changes; acceptance-criteria mapping; relevant checks with exact results; known limitations; API assumptions and backend dependencies.

## Collaboration rules

Agree on API contracts before integration. Assign file ownership before parallel edits; use separate components or files if writes can be independent. Ask QA for acceptance coverage and Reviewer for independent findings after implementation.

## Escalation conditions

Escalate missing product decisions, conflicting UI/API contracts, security or accessibility ambiguity, a required dependency, or work crossing repository ownership.

## Definition of Done

Approved behavior is implemented in the frontend repository, local conventions are followed, required acceptance criteria are addressed, relevant verification is reported accurately, and unrelated files and Git state are preserved.
