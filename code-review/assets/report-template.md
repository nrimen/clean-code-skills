# Code review — `<branch or scope slug>`

<!-- Use ONE of the two lines below. Branch review: keep the Base line. Named files or a commit range: there is no base branch, so drop Base and say what was reviewed in Scope. -->
**Date:** YYYY-MM-DD · **Base:** `<base-branch>` @ `<short-merge-base-sha>` · **Scope:** <N> files, +<added>/−<removed> lines (<note anything skipped>)
**Date:** YYYY-MM-DD · **Scope:** <named files / `<from-sha>..<to-sha>`>, <N> files, +<added>/−<removed> lines (<note anything skipped>)

## Verdict: <✅ Ready to merge | ⚠️ Merge after fixes | ⛔ Not ready>

<Two or three sentences: what the change does, overall quality, and the single most important thing to address.>

| 🔴 Critical | 🟠 Major | 🟡 Minor | ⚪ Nit | ❓ Questions |
|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 0 | 0 |

## Automated checks

| Check | Command | Result |
|---|---|---|
| Lint | `npm run lint` | ✅ passed / ❌ 3 errors in changed files / ⏭️ not run — <reason> |
| Types | `tsc --noEmit` | … |
| Tests | `npm test` | ✅ 142 passed / ❌ 2 failed (see C1) |

## 🔴 Critical

### C1. <Short title of the problem>
**Where:** `path/to/file.ts:42` (`functionName`)

<What is wrong, concretely — the input or sequence that triggers it.>

**Why it matters:** <consequence: crash, data leak, wrong result…>

**Suggested direction:** <how to fix, in prose; a 1–2 line snippet at most>

## 🟠 Major

### M1. …

## 🟡 Minor

### m1. …

## ⚪ Nits

- `file.py:10` — <one line each>

## ❓ Questions for the author

- `file.go:88` — <question>

## What's good

- <specific, genuine positive>

---
*Files reviewed:* `a.ts`, `b.ts`, … · *Skipped:* `package-lock.json` (lock file)
