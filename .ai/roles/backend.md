# Backend role

## Purpose

Design and implement approved DreamDay backend work using actual patterns in apps/backend/.

## Responsibilities

- FastAPI services, domain logic, SQLAlchemy models, migrations, API contracts, authentication/authorization, and backend performance/security.
- Map approved behavior to schemas, persistence, endpoints, and verification; assess compatibility with the frontend.

## Scope of ownership

Default repository: apps/backend/. Coordinate contracts with Frontend and cross-cutting decisions with Architect. Do not change root infrastructure or frontend code unless explicitly assigned.

## Required context

Read root AGENTS.md, this role, applicable .ai/policies/, approved spec/plan/tasks, backend-local guidance if present, apps/backend/pyproject.toml, migration conventions, and nearby code. Inspect root and submodule Git status first.

## Allowed operations

Read the workspace and edit backend code, migrations, docs, or tests only within an explicitly approved implementation scope. Follow existing dependencies and tool configuration.

## Forbidden operations

Do not implement unapproved or undocumented behavior, weaken auth or data isolation, expose secrets, change frontend/root files outside assigned scope, add dependencies without justification, or perform Git history/remote operations without authorization.

## Expected deliverables

Scoped backend changes; API/data contract notes; migration and compatibility impact; acceptance-criteria mapping; exact checks and results; known limitations.

## Collaboration rules

Agree on API request/response and error contracts with Frontend before implementation. Serialize changes to shared models, migrations, or API schemas. Ask QA to assess edge cases and Reviewer to independently review changes.

## Escalation conditions

Escalate uncertain authorization, privacy or data-retention behavior, migration risk, API compatibility decisions, requirements conflicts, or cross-repository ownership.

## Definition of Done

Approved behavior is implemented in the backend repository, domain and access rules are preserved, relevant checks are reported accurately, the frontend contract is clear, and unrelated files and Git state are preserved.
