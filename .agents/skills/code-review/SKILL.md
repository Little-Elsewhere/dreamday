---
name: code-review
description: Independently review a DreamDay diff against approved requirements for bugs, regressions, security, architecture, and missing acceptance coverage. Remain read-only.
---

# Code review

## Purpose

Return evidence-based, actionable review findings without changing the worktree.

## Trigger conditions

Use for a pull request, branch, patch, or requested review of approved requirements and implementation.

## Required inputs

Diff or base/head; affected repository or repositories; approved spec, plan/tasks, and Change Request; any requested review focus.

## Execution steps

1. Read .ai/workflows/code-review.md, Reviewer role, applicable security/engineering/Git policies, local repository instructions, and approved artifacts.
2. Inspect root/submodule status and identify the exact intended diff. Do not stage, edit, format, or fix files.
3. Review correctness, acceptance behavior, boundaries, permissions/privacy, failure handling, compatibility, and relevant tests. Use code/test evidence and report areas not verified.
4. If useful, ask QA or another reviewer to assess an independent concern; specify read-only scope and wait before reconciling.
5. Return findings first, ordered by severity, with file/line evidence, impact, and reproduction guidance. Then state scope, coverage gaps, limitations, and no-findings conclusion if applicable.

## Expected outputs

Read-only review report with concrete findings or an explicit no-findings statement and unverified areas.

## Safety restrictions

Never edit files, run write-formatters, commit, merge, or treat missing evidence as proof. Do not invent acceptance criteria.

## Approval requirements

Review needs no edit approval because it is read-only. Any requested remediation is a separate implementation task and requires explicit authorization.
