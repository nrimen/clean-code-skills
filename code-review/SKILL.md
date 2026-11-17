---
name: code-review
description: "Review code for bugs, security issues, and code quality, and write a severity-ranked report to a markdown file in the repo. Use this skill whenever the user asks to review code, review a branch or PR, check code quality, audit changes, look for bugs or smells, or asks \"is this ready to merge?\" / \"what's wrong with my code?\" / \"check my work before I push\" — in any language, even if they don't say the word \"review\". By default it reviews the work on the current git branch. Not for principle-by-principle design audits (DRY, KISS, YAGNI, SRP, SOLID): those belong to principles-audit and solid-audit."
---

# Code Review

Produce an honest, useful review of the code the user is working on: find real problems, rank them by severity, and save the result as a markdown report in the repo. The review is **read-only** — never edit source files, never commit, never push. The only file this skill writes is the report.

A good review is one the user can act on in a few minutes: the most important problems first, each pinned to a `file:line`, each explaining *why* it matters. A review padded with nitpicks or speculative warnings is worse than a short one, because it buries the findings that count.

## Workflow

### 1. Work out what to review

Unless the user points at specific files, directories, a commit range or a PR, review **the work on the current branch**: everything it adds compared with the branch it was created from, plus uncommitted and staged changes.

Run `bash scripts/detect_context.sh` from the repo root. It prints the current branch, the likely base branch, the merge base, the changed files, and the lint/test commands it can find. Then:

- If the script reports that this is not a git repository, review the files the user names; if they named none, ask what to review.
- Use `git diff <merge-base>` (no second ref) to see committed + uncommitted changes together, and `git status --porcelain` for untracked new files (read those in full).
- If the current branch *is* the base branch (e.g. working directly on `main`), there's nothing to diff against — review uncommitted changes if there are any; otherwise ask the user what to review.
- Skip deleted files (`D`); for renamed files (`R`), read the new path.
- If the base branch can't be determined, ask rather than guess.
- For very large diffs (roughly 50+ files or 3,000+ changed lines), say so, prioritise source files over generated/lock/vendored files, and note in the report what was skimmed or skipped.

Skip generated and vendored content (lock files, `dist/`, `build/`, minified files, snapshots, `node_modules/`, `vendor/`) unless the change there looks hand-made and suspicious.

### 2. Gather context before judging

A diff alone is misleading. Before writing findings:

- Read the full current version of each changed file, not just the hunks — many bugs live in how new code interacts with unchanged code.
- Look at the project's own rules: README, CONTRIBUTING, lint/format configs (`.eslintrc*`, `ruff.toml`, `pyproject.toml`, `.editorconfig`, `golangci.yml`…), and any `CLAUDE.md`. The project's conventions win over generic best practice; don't flag something the project deliberately does.
- When a changed function is called elsewhere or changes a signature, check the callers (`git grep`).
- Check whether tests were added or changed alongside the code.

### 3. Run the project's own checks

Run the linters, type checkers and tests the project already has configured (the detect script lists candidates). Rules:

- If the branch comes from an untrusted source (e.g. an external contributor's PR), don't run project scripts: tests and linters execute that branch's code. Review statically and say so in the report.
- Only run commands the project defines (package.json scripts, Makefile targets, configured tools). Don't install dependencies, don't add new tools.
- Stop any command that runs longer than about 3 minutes and mark it "not run, too slow" in the report.
- Never run anything that modifies files: no `--fix`, no `--write`, no formatters in write mode, no snapshot updates, no migrations. Use check modes (`prettier --check`, `ruff check`, `black --check`, `gofmt -l`).
- If dependencies aren't installed or a command fails for environmental reasons (missing env vars, database not running), note it in the report and move on — don't try to repair the environment.
- Prefer scoping to changed files when the tool supports it; if a full test suite looks slow, run the tests related to the changed code and say so.
- Lint output belongs in the report only where it's relevant: summarise counts, and promote individual lint/test failures into findings only when they're in changed code or caused by it.
- After running checks, run `git status --porcelain`. Mention in the report any new files the checks created (coverage output, caches, build artifacts), and don't delete them.

### 4. Review

Go through the changes with the checklist in `references/review-checklist.md` (correctness, security, error handling, data & concurrency, performance, API & design, readability, tests). Then read the language reference(s) that match the files in the diff:

| Files | Reference |
|---|---|
| `.js .jsx .ts .tsx .mjs .vue .svelte` | `references/languages/javascript-typescript.md` |
| `.py` | `references/languages/python.md` |
| `.go` | `references/languages/go.md` |
| `.java .kt` | `references/languages/java-kotlin.md` |
| `.rs` | `references/languages/rust.md` |
| `.sh`, Dockerfile, YAML/JSON/TOML config, CI, IaC, `.cfg`/`.conf` | `references/languages/shell-config.md` |

For a language without a reference, apply the general checklist plus what you know of that language's idioms and pitfalls.

**Calibrate confidence.** Only report something as a problem when you can explain concretely how it fails (what input, what sequence, what consequence). If you suspect a problem but can't confirm it from the code you can see — e.g. it depends on how an external service behaves — report it as a **Question** rather than asserting a bug. Never invent line numbers; if you can't pin a location, say which function.

**Never put a secret in the report.** If you find a key, token or password, give its file, line and type (e.g. "AWS access key") and at most its first 4 characters.

**Stay on the change.** Report only issues the change introduces or makes worse. Pre-existing problems in untouched code get at most one line at the end.

**Don't relitigate taste.** If code is correct, clear and consistent with the project, leave it alone even if you'd have written it differently.

### 5. Assign severity

| Level | Meaning | Examples |
|---|---|---|
| 🔴 **Critical** | Will cause wrong behaviour, data loss, a security hole, or a crash in realistic use. Should block merging. | SQL/command injection, secret committed, unhandled null on a common path, broken migration, race corrupting data |
| 🟠 **Major** | Likely to cause bugs or real pain soon; should be fixed before merge in most teams. | Missing error handling on I/O, no tests for risky logic, N+1 queries on a hot path, breaking a public API without notice, resource leak |
| 🟡 **Minor** | Maintainability or robustness issue; fix when convenient. | Duplicated logic, confusing names, overly long function, magic numbers, weak typing (`any`), missing edge-case test |
| ⚪ **Nit** | Optional polish. Keep these few. | Wording of a comment, small style inconsistency the linter doesn't catch |
| ❓ **Question** | Possible issue you couldn't confirm, or intent you need from the author. | "Is it intended that expired tokens are still accepted here?" |

When unsure between two levels, pick the lower one and explain the risk — overstated severity erodes trust in the whole report. Group repeated instances of the same issue into one finding listing all locations, rather than one finding each.

### 6. Write the report

Save to `code-reviews/<branch>-<YYYY-MM-DD>.md` at the repo root, or inside the project's existing reports folder if it has one (replace `/` in branch names with `-`; append `-2`, `-3`… if the file exists). When reviewing named files or a commit range, replace `<branch>` with a short slug of that scope (e.g. `auth-refresh` or `a1b2c3d-e4f5g6h`). Create the `code-reviews/` folder if needed. Don't modify `.gitignore` — mention in your reply that they can ignore the folder if they don't want reports committed.

Use the template in `assets/report-template.md` exactly. Key points:

- The **verdict** at the top is one of: ✅ Ready to merge · ⚠️ Merge after fixes · ⛔ Not ready. Any Critical → ⛔. Any Major → ⚠️ at best.
- Order findings by severity, then by file.
- Each finding: title, location(s), what's wrong, why it matters, and a short hint toward the fix in prose (a one- or two-line snippet is fine when it's the clearest way to explain; don't write full patches — this is a report, not a fix).
- Include a short **What's good** section with genuine, specific positives (one to three bullets). This isn't flattery; it tells the author what to keep doing. Skip it if nothing stands out.
- If there are no findings at some level, omit that section rather than writing "None".

After saving, reply in the chat with: the report path, the verdict, the count per severity, and the top one to three issues in a sentence each. Keep the chat reply short — the detail lives in the file.
