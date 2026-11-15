---
name: principles-audit
description: "Audit code against 5 engineering principles — DRY, KISS, YAGNI, Single Responsibility, Separation of Concerns — and write a report saying, for each principle, whether the code respects it, with file:line evidence and fixes. Use this whenever the user asks to check, audit or report on code quality against principles, asks \"is my code clean / DRY / too complex / over-engineered\", mentions any of DRY, KISS, YAGNI, SRP, single responsibility or separation of concerns, or wants a principles report on a branch, folder or file — in any language."
---

# Principles Audit

Check code against 5 principles and say clearly, for each one, whether it is respected.

This skill pairs with `principles-first`, which applies the same 5 principles while writing code. For SOLID (OCP, LSP, ISP, DIP), use `solid-audit`; Single Responsibility is checked by both.

## Scope

Use the first that applies:
1. The user named files, a folder or the whole repo → use that.
2. Git repo on a feature branch → files changed vs the base branch (`main`, else `master`, else `develop`; use `origin/<name>` if there is no local branch): `git diff --name-only --diff-filter=d <base>...HEAD` (deleted files excluded), plus uncommitted and untracked files (`git status --porcelain`).
3. On the base branch itself, or the branch diff is empty → uncommitted and untracked files only.
4. Not a git repo, or nothing found → ask the user what to audit.

Always skip: generated code, lockfiles, vendored/third-party code, build output, and non-code files (docs, images, data, env examples).

**Large scope** (whole repo or 50+ code files): map the structure first, then audit the core in depth. State in the report what was covered and what wasn't.

For DRY, search the rest of the repo for existing equivalents of each new function, constant or validation in the scope. Report only on the scope.

## The 5 principles — what to look for

**1. DRY (Don't Repeat Yourself)**
- Violation: knowledge (a rule, constant, format, URL, query) defined in 2+ places; the same logic repeated in 3+ places that change for the same reason.
- Not a violation: code that looks alike but changes for different reasons; repeated setup and literal values in test code.

**2. KISS (Keep It Simple)**
- Violation: deep nesting, clever one-liners that hurt reading, needless indirection (factory for one class, wrapper that only forwards), long functions doing tricky things a simpler approach would solve.
- Rule: only report a KISS finding if you can state the simpler alternative in one sentence.

**3. YAGNI (You Aren't Gonna Need It)**
- Violation: unused params/options/flags, config for things nobody configures, abstractions or interfaces with a single implementation "for later", dead code, commented-out code, speculative generic layers.
- Not a violation: a single-implementation interface at a real boundary (DB, external API, framework) or one a test double uses; error handling, edge cases and tests for behavior that exists.

**4. Single Responsibility (SRP)**
- Violation: a function, class, component or module with more than one reason to change (e.g. fetches data, formats it and renders it; a "utils" file mixing unrelated things). Size alone is not a violation.
- Quick test: name two unrelated kinds of change request that would both edit this unit. If you can, it's a finding.
- Not a violation: a unit that only calls other steps in order.

**5. Separation of Concerns (SoC)**
- Violation: layers mixed together — UI talking straight to the DB/API with business rules inline, business logic inside controllers/routes/views, storage or network code spread across UI files, config/secrets hard-coded in logic.
- In code without UI layers, the concerns are whatever the project separates: parsing vs. logic vs. output in a script, schema vs. queries vs. data in SQL, modules vs. environments in infrastructure code.
- SRP is about one unit; SoC is about how the system is split into layers. A unit in the wrong layer is an SoC finding, not also an SRP finding.

## Verdict per principle

- ✅ **Respected** — 0 findings
- ⚠️ **Partially** — findings, none blocking
- ❌ **Not respected** — at least one blocking finding
- ➖ **N/A** — the principle doesn't apply to this code (one line why)

A finding is **blocking** if it causes wrong behavior today, forces the next change in that area to be made in several places, or makes the code impossible to test without editing it. Mark those `[blocking]` in the report. One finding = one fix: several lines solved by the same change are one finding that lists all of them.

Every finding needs a `file:line` and a short reason. No evidence, no finding. Count each issue under the one principle it fits best. Don't invent problems to fill a section.

## Report

Write the report to `principles-audits/<scope>-<YYYY-MM-DD>.md`, placed at the repo root unless the project already has a reports folder (put it there) or the user names a location. `<scope>` is the branch name, else the audited folder or file name, else `repo`; replace `/` with `-` and append `-2`, `-3`… if the file exists. Then give a short summary in chat. Don't edit `.gitignore`; mention once that the user can ignore the folder if they don't want reports committed.

```markdown
# Principles Report
Scope: <branch / files / repo>   Date: <date>
Covered: <what was audited>   Not covered: <what was skipped, if anything>

## Summary
| Principle | Verdict | Issues |
|---|---|---|
| DRY | ✅/⚠️/❌/➖ | n |
| KISS | ... | n |
| YAGNI | ... | n |
| Single Responsibility | ... | n |
| Separation of Concerns | ... | n |

**Overall:** <one or two sentences>

## DRY — <verdict>
- `path/to/file:42` — <`[blocking]` if it is> <what's wrong>. **Fix:** <concrete, small suggestion>
(same section for each principle; write "No issues found." or the N/A reason when empty)

## Top 3 fixes
1. ...
```

Order findings by impact (most important first). Keep fixes concrete and incremental, not full rewrites. Do not change code unless the user asks.
