# JavaScript / TypeScript pitfalls

## Language
- `==` vs `===`; truthiness traps (`0`, `""`, `NaN` are falsy — `if (count)` skips zero).
- `||` used for defaults where `??` is meant (`port || 3000` replaces a valid `0`).
- Floating promises: async calls without `await`/`.catch`, so errors vanish. `forEach` with an async callback doesn't wait.
- `await` inside loops where `Promise.all` was intended — or `Promise.all` where one failure should not cancel the rest (`allSettled`).
- Mutating arrays/objects that callers or React state still reference; `sort()` and `reverse()` mutate in place.
- `parseInt` without radix; `Number("")` is `0`; date parsing of non-ISO strings is engine-dependent; months are 0-based.
- `this` lost in callbacks; arrow vs function semantics.

## TypeScript
- `any`, `as` casts, and non-null assertions (`!`) that hide real nullability. `as unknown as X` is a red flag.
- `@ts-ignore` / `@ts-expect-error` without a comment.
- Types that lie about API responses — runtime data from fetch/JSON is unvalidated; check for a schema (zod, io-ts…) at trust boundaries.
- Overly wide types (`string` where a union of literals fits) and exhaustiveness on discriminated unions (`never` check in switch default).

## React (if present)
- Missing or wrong `useEffect` dependencies; effects that should be event handlers; effects without cleanup (subscriptions, timers, listeners, aborting fetches).
- State derived from props copied into `useState` and going stale.
- Keys: array index as `key` in lists that reorder/insert; missing keys.
- Direct state mutation (`state.items.push`) instead of new objects.
- Expensive work in render without memoisation where it matters; unnecessary `useMemo`/`useCallback` everywhere is a Nit at most.
- Conditional hook calls.
- Accessibility: clickable `div`s without role/keyboard support, images without `alt`, inputs without labels, colour-only signals.
- `dangerouslySetInnerHTML` with unsanitised content.

## Node / backend
- Unvalidated `req.body`/`req.query` reaching DB queries, `child_process`, `fs` paths.
- Sync file/crypto calls (`readFileSync`, `pbkdf2Sync`) on request paths.
- Missing error middleware / unhandled rejections crashing the process.
- Secrets read from code instead of env; `.env` committed.

## Browser / extensions
- `innerHTML` with dynamic content (XSS); `postMessage` handlers that don't check `origin`.
- Chrome MV3: overly broad `permissions`/`host_permissions`; service worker relying on in-memory state (it gets terminated); message handlers that trust any sender; remote code (forbidden in MV3).

## Tooling hints
- Check scripts in package.json: `lint`, `typecheck`/`tsc --noEmit`, `test`. Run `prettier --check`, never `--write`. Run `eslint` without `--fix`.
