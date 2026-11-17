# General review checklist

Use this as a prompt for your attention, not a form to fill in. Most changes touch only a few of these areas; spend your time where the change is risky.

## Contents
1. Correctness
2. Security
3. Error handling & resilience
4. Data, state & concurrency
5. Performance
6. API & design
7. Readability & maintainability
8. Tests

## 1. Correctness
- Does the code do what the branch/commit messages and names say it does?
- Boundaries: empty collections, zero, negative numbers, very large inputs, off-by-one in loops and slices, first/last element.
- Null / undefined / None / missing keys on realistic paths (API responses, optional config, DB rows that may not exist).
- Conditionals: inverted logic, `&&` vs `||`, missing `else`, fallthrough, early returns that skip cleanup.
- Types & conversions: integer division, float comparison for equality, string ↔ number parsing, timezone-naive dates, locale-dependent formatting.
- Changed behaviour for existing callers: a modified signature, default value or return shape that other code relies on.
- Copy-paste errors: a duplicated block where one variable wasn't renamed.

## 2. Security
- Injection: user input reaching SQL, shell commands, HTML, templates, file paths, regexes, LDAP, or `eval`-like functions without parameterisation/escaping.
- Secrets: API keys, tokens, passwords, private keys in code, config, tests or fixtures. Treat any committed real-looking secret as Critical.
- AuthN/AuthZ: new endpoints or actions without permission checks; checks done client-side only; trusting IDs from the request without verifying ownership (IDOR).
- Sensitive data in logs, error messages, URLs or analytics.
- Unsafe deserialisation, disabled TLS verification, weak crypto (MD5/SHA1 for passwords, homemade crypto, static IVs), insecure randomness for tokens.
- Path traversal on file reads/writes; SSRF on server-side fetches of user-supplied URLs.
- New dependencies: are they well-known and maintained? Pinned?

## 3. Error handling & resilience
- Errors swallowed (empty catch, ignored return codes, `except: pass`).
- Errors caught too broadly, hiding unrelated bugs.
- I/O, network and parsing calls without failure handling; missing timeouts on network calls.
- Partial failure: if step 2 of 3 fails, is state left inconsistent? Are resources released (files, connections, locks)?
- Retries without backoff or limits; retrying non-idempotent operations.
- User-facing error messages that are useless or leak internals.

## 4. Data, state & concurrency
- Shared mutable state accessed from multiple threads/async tasks without protection.
- Check-then-act races (read, decide, write) on files, DB rows, caches.
- Missing transactions around multi-step DB writes.
- Schema migrations: reversible? Safe on a populated table (locks, default values, NOT NULL on existing rows)?
- Cache invalidation after writes.
- Mutating arguments or shared objects unexpectedly.

## 5. Performance
Only flag when the cost is plausible at the code's real scale.
- Queries or network calls inside loops (N+1).
- Loading whole datasets/files into memory when streaming or pagination is needed.
- Quadratic algorithms over collections that can be large.
- Missing indexes for new query patterns.
- Repeated expensive work that could be computed once.
- Unbounded growth: caches, queues, listeners, retries.

## 6. API & design
- Does new code fit the existing architecture, or does it bypass established layers (e.g. UI calling the DB directly)?
- Responsibilities: functions/classes doing several unrelated things.
- Public interfaces: clear names, minimal surface, backwards compatibility, versioning.
- Duplication of logic that already exists elsewhere in the repo (search before flagging).
- Configuration hard-coded where the project uses config/env.
- Dead code, leftover debug output, commented-out blocks, TODOs without context.

## 7. Readability & maintainability
- Names that describe intent; no misleading names.
- Functions short enough to understand at a glance; deep nesting that early returns would flatten.
- Magic numbers/strings that deserve a named constant.
- Comments that explain *why*, not *what*; comments that have become wrong after the change.
- Consistency with surrounding code style and patterns.

## 8. Tests
- Is new or changed behaviour covered? Risky logic without tests is at least Major.
- Do tests assert something meaningful (not just "doesn't throw")?
- Edge cases and failure paths tested, not only the happy path.
- Tests deterministic: no reliance on time, ordering, network, or random values without seeding.
- Tests modified to make them pass without a clear reason (weakened assertions, skipped tests) — always worth a Question or finding.
