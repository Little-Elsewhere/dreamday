---
name: bug-fix
description: Investigate and fix a DreamDay defect while checking approved requirements, repository ownership, authorization, reproduction evidence, and verification.
---

# Bug fix

## Purpose

Move from a reproducible defect to an appropriately scoped, verified correction.

## Trigger conditions

Use for an observed bug, regression, or incorrect behavior. Use change-request if the correction would change approved product behavior.

## Required inputs

Observed and expected behavior; reproduction or affected context; target repository; approved spec; whether the user requested investigation or an authorized fix.

## Execution steps

1. Read .ai/workflows/bug-fix.md, relevant policies, applicable role, local repository instructions, and approved spec.
2. Inspect root/submodule Git status and trace the actual code path. Do not expose secrets or private travel data.
3. Reproduce or gather available evidence. Label facts, hypotheses, and unknowns separately. Delegate read-only analysis if useful and assign disjoint ownership.
4. Determine whether the correction restores approved behavior. If it changes an approved requirement, create a Change Request and stop at its approval gate.
5. If the task only requested investigation, report cause, evidence, impact, proposal, and verification plan, then stop. If the user explicitly authorized the fix, edit only the owning repository and scope.
6. Add or adjust tests only within authorized scope. Run relevant non-destructive checks; record exact commands/results and skipped criteria.
7. Ask Reviewer for independent read-only findings when useful, reconcile them, and report changed files, evidence, limitations, and remaining work.

## Expected outputs

Evidence-based diagnosis and next step, or an authorized scoped fix with verification results.

## Safety restrictions

No broad speculative refactor, unapproved requirement change, destructive checks, secret exposure, or branch/remote actions without authorization.

## Approval requirements

Investigation is read-only. Code/test changes require explicit user authorization for the fix scope; product behavior changes also require an approved Change Request.
