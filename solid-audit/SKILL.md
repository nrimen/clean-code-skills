---
name: solid-audit
description: "Audit code against the 5 SOLID design principles — Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion — and write a report saying, for each principle, whether the code respects it, with file:line evidence and fixes. Use this whenever the user asks to check, audit or report on code design, SOLID, coupling, extensibility or testability, mentions SRP, OCP, LSP, ISP, DIP, dependency injection or \"is my code well structured\", or wants a SOLID report on a branch, folder, file or whole repo. Works for any language or paradigm (object-oriented, functional, front-end, back-end, services)."
---

# SOLID Audit

Check code design against the 5 SOLID principles and say clearly, for each one, whether it is respected.

This skill pairs with `solid-first`, which applies the same principles while writing code. For DRY, KISS, YAGNI and Separation of Concerns, use `principles-audit`; Single Responsibility is checked by both.

## 1. Pick the scope

Use the first that applies:
1. The user named files, a folder or the whole repo → use that.
2. Git repo on a feature branch → files changed vs the base branch (`main`, else `master`, else `develop`; use `origin/<name>` if there is no local branch): `git diff --name-only --diff-filter=d <base>...HEAD` (deleted files excluded), plus uncommitted and untracked files (`git status --porcelain`).
3. On the base branch itself, or the branch diff is empty → uncommitted and untracked files only.
4. Not a git repo, or nothing found → ask the user what to audit.

Always skip: generated code, lockfiles, vendored/third-party code, build output, tool-generated migrations, and non-code files (docs, images, data, env examples).

SOLID is about how parts depend on each other, so read the code around the scope too (the interfaces, base classes and callers the changed files use), but only report on the scope.

**Large scope** (whole repo or 50+ code files): map the structure and main dependencies first, then audit the core in depth (domain/business logic, services, the boundaries to DB, APIs and frameworks). State in the report what was covered and what wasn't.

## 2. Adapt to the paradigm

SOLID was written for object-oriented code, but the ideas apply everywhere. Translate the terms:
- **class / module** → whatever groups behavior: class, module, file, component, service
- **interface / abstraction** → interface, protocol, trait, abstract class, type, function signature, props contract, API contract
- **subtype** → subclass, implementation of an interface, any value passed where a contract is expected

If a principle really doesn't apply (e.g. LSP in code with no inheritance or interchangeable implementations), mark it **N/A** with one line why. For declarative code (SQL, infrastructure-as-code, config, markup), usually only S applies; mark the rest N/A. Don't force findings.

## 3. Check the 5 principles

**S — Single Responsibility**
- A module should have one reason to change: it serves one actor or one concern (e.g. billing rules vs. report layout vs. persistence).
- Violation: a class/service mixing business rules with persistence, transport, formatting or framework code; "God" classes/services; one module changed by unrelated feature requests.
- Quick test: who would ask for a change here? More than one kind of stakeholder or concern = violation.

**O — Open/Closed**
- Adding a new variant should mean adding code, not editing existing working code.
- Violation: `if/else` or `switch` on a type, kind or status repeated in several places, so each new variant edits many files; behavior that can only be changed by modifying a core module.
- Not a violation: a single switch in one place (e.g. a factory) that maps input to an implementation. Only flag where real variants exist or clearly keep being added.

**L — Liskov Substitution**
- Any implementation must work wherever its parent/contract is expected, without surprising callers.
- Violation: overrides that throw "not supported/not implemented", ignore inputs, return a different shape, add stricter preconditions or weaker guarantees; callers checking the concrete type (`instanceof`, `type ==`) to work around a subtype.
- Classic smell: a subclass that disables inherited behavior.

**I — Interface Segregation**
- Clients shouldn't depend on things they don't use.
- Violation: large interfaces/contracts where implementers stub out many methods; components or functions that take a big object, config or props bag and thereby force callers or tests to build unrelated data; one "service" interface used by many clients that each need a different slice.

**D — Dependency Inversion**
- Business logic depends on abstractions; details (DB, HTTP clients, file system, framework, SDKs, time, randomness) plug in from outside.
- Violation: business logic that talks to volatile infrastructure directly (builds its own DB/HTTP/SDK client, reads the clock or environment inline) so it can't be tested or swapped without editing it; framework types leaking into business logic.
- Not a violation: importing a single project module that wraps the infrastructure (a client, repository or gateway module) — that module is the abstraction, and constructor injection is one way to do this, not the only one; depending directly on stable things (language standard library, pure utility functions, value objects).

## 4. Don't reward over-engineering

SOLID applied everywhere creates needless layers. Also flag the opposite problem, under the principle whose machinery was overdone, and tag it `[over-applied]`:
- an interface with exactly one implementation and no test double or boundary reason → D
- strategy/factory/plugin machinery for a variant that has only one case → O
- dependency injection for things that never change and don't need faking in tests → D
- contracts split so finely that every client needs several of them → I

Judge against the project's size and real change patterns. For a small standalone script, mark D N/A. Test doubles are never an over-applied finding. Over-applied findings count like any other, but they are rarely blocking.

## 5. Verdicts

- ✅ **Respected** — 0 findings
- ⚠️ **Partially** — findings, none blocking
- ❌ **Not respected** — at least one blocking finding
- ➖ **N/A** — the principle doesn't apply to this code (one line why)

A finding is **blocking** if it causes wrong behavior today, forces the next change in that area to be made in several places, or makes the code impossible to test without editing it. Mark those `[blocking]` in the report. One finding = one fix: several lines solved by the same change are one finding that lists all of them.

Every finding needs a `file:line` and a short reason. No evidence, no finding. Count each issue under the one principle it fits best. Tie-break: a module that contains two concerns → S; a module with one concern that reaches a concrete detail directly → D. Never both.

## 6. Report

Write the report to `solid-audits/<scope>-<YYYY-MM-DD>.md`, placed at the repo root unless the project already has a reports folder (put it there) or the user names a location. `<scope>` is the branch name, else the audited folder or file name, else `repo`; replace `/` with `-` and append `-2`, `-3`… if the file exists. Then give a short summary in chat. Don't edit `.gitignore`; mention once that the user can ignore the folder if they don't want reports committed.

```markdown
# SOLID Report
Scope: <branch / files / repo>   Date: <date>
Covered: <what was audited>   Not covered: <what was skipped, if anything>

## Summary
| Principle | Verdict | Issues |
|---|---|---|
| S — Single Responsibility | ✅/⚠️/❌/➖ | n |
| O — Open/Closed | ... | n |
| L — Liskov Substitution | ... | n |
| I — Interface Segregation | ... | n |
| D — Dependency Inversion | ... | n |

**Overall:** <one or two sentences on the design: coupling, extensibility, testability>

## S — Single Responsibility — <verdict>
- `path/to/file:42` — <`[blocking]` or `[over-applied]` if it is> <what's wrong>. **Fix:** <concrete, small suggestion>
(same section for each principle; write "No issues found." or the N/A reason when empty)

## Top 3 fixes
1. ...
```

Order findings by impact (what most hurts changing or testing the code first). Keep fixes concrete and incremental, not full rewrites. Do not change code unless the user asks.