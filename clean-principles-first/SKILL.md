---
name: principles-first
description: "Apply 5 engineering principles — DRY, KISS, YAGNI, Single Responsibility, Separation of Concerns — before and during ANY coding work. Use this skill before writing, editing, refactoring or planning code of any kind, in any language (new features, bug fixes, components, functions, scripts, APIs, tests). Read it before the first code change, even for small edits."
---

# Principles First

Before writing or changing any code, follow these 5 principles. They apply to every task, big or small.

## Before you start

1. Read the code around the change. Look for existing functions, components, helpers and patterns you can reuse.
2. Decide where the change belongs (which layer, which file) before writing it.
3. Pick the simplest approach that fully solves the request.

## The 5 principles

**DRY** — Don't duplicate logic or knowledge. Reuse what exists. Knowledge (a rule, constant, format, URL) lives in one place from the first repeat. Similar-looking logic is extracted at the third occurrence, and only if the copies change for the same reason. Repeated setup and literal values in tests are fine.

**KISS** — Write the simplest code that works. Plain over clever, flat over nested. No extra layers or patterns unless the task needs them.

**YAGNI** — Build only what the request needs, including its error handling, edge cases and tests. No "just in case" options, params, config, interfaces or features. No dead or commented-out code.

**Single Responsibility** — Each function, class, component and module has one reason to change. If two unrelated kinds of request (e.g. a pricing rule and a display format) would both edit it, split it. A unit that only calls other steps in order is fine.

**Separation of Concerns** — Keep layers apart: UI, business logic, data access/API, config. Don't put business rules in views or network/storage calls inside UI components. In code without UI layers, the concerns are whatever the project separates: parsing vs. logic vs. output in a script, schema vs. queries vs. data in SQL, modules vs. environments in infrastructure code. Follow the project's existing structure.

## When principles conflict

- KISS and YAGNI win over DRY for small or one-off cases — a little repetition beats a confusing abstraction.
- Don't split a unit for Single Responsibility if the pieces would never change or be reused separately.
- Follow the project's existing conventions unless they clearly break a principle; if so, mention it rather than rewriting unrelated code.

## Pairs with solid-first

If the task also creates or restructures modules, classes, services, interfaces or variants of something, `solid-first` applies as well. Single Responsibility appears in both skills: apply it once, not twice. For plain edits inside existing code, this skill alone is enough.

## Existing code that breaks a principle

- **Code you must change:** improve it only as far as your task needs.
- **Code you don't need to touch:** leave it. Mention it in one line in your final message.

## Before you finish

Quick self-check on the code you wrote:
- Did I duplicate anything that already existed?
- Is there a simpler way?
- Did I add anything the request doesn't need?
- Does each unit have one reason to change?
- Is each piece in the right layer?

Fix what fails. In your final message, add one short line if a principle shaped a decision (e.g. "Reused `formatDate` instead of adding a new helper").
