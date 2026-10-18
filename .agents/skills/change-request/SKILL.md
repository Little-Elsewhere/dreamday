---
name: change-request
description: Create and carry a traceable DreamDay Change Request for a significant change to approved feature behavior, specifications, contracts, or cross-repository decisions.
---

# Change Request

## Purpose

Keep proposed changes to approved requirements reviewable and traceable through approval, implementation, verification, and release.

## Trigger conditions

Use when changing a significant approved behavior, acceptance criterion, API/data contract, or cross-repository decision. For implementation restoring existing approved behavior, use bug-fix instead.

## Required inputs

Requested change and rationale; current approved specification; affected repositories; acceptance criteria; available approver/decision status.

## Execution steps

1. Read .ai/workflows/change-request.md, .ai/policies/change-requests.md, relevant engineering/security/Git policies, and the current spec.
2. Inspect .ai/change-requests/ and allocate an unused CR-YYYYMMDD-NNN ID.
3. Assess specification, frontend, backend, API/data, infrastructure, risk, dependency, and verification impact. Use independent read-only specialist analysis only when useful.
4. Fill .ai/templates/CHANGE_REQUEST.md, set approval to Pending and implementation to Not started, and save one request file under .ai/change-requests/.
5. Present the completed proposal and stop. Do not edit the approved spec or code before the relevant approval.
6. After requirements approval, update the living spec on a reviewable branch, add its CR history entry, and update plan/tasks. Stop again for implementation approval. After that separate approval, implement, verify, and update the CR record.
7. Add a user-facing changelog reference only after verified merge/release; document the merged PR or N/A reason for docs-only work.

## Expected outputs

A complete CR record with ID, description/justification, affected specs/repositories, impact, risks, acceptance criteria, approvals, implementation status, verification, and changelog reference.

## Safety restrictions

Never silently rewrite approved requirements, edit main directly, combine requirements approval with implementation approval, delete rejected history, or publish an unverified release note. Preserve existing user changes and Git state.

## Approval requirements

This skill may prepare a proposal. Requirements approval is required before updating the approved living spec. Separate explicit implementation approval is required before application code or tests change.
