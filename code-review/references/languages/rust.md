# Rust pitfalls

- `unwrap()`/`expect()` on fallible paths (I/O, parsing, network, user input), where `?` or explicit handling belongs. Fine in tests and for true invariants with a clear `expect` message.
- Panics in library code (`unwrap`, indexing, `panic!`, `unreachable!` on reachable paths): libraries should return `Result` and let the caller decide.
- `unsafe` blocks without a `// SAFETY:` comment explaining why the invariants hold.
- Lossy `as` casts (`u64 as u32`, `i64 as usize`, float → int) that silently truncate or wrap; use `try_from`. Integer overflow that panics in debug and wraps in release — use `checked_*`/`saturating_*` where inputs are untrusted.
- Blocking calls inside async tasks (`std::thread::sleep`, `std::fs`, blocking HTTP/DB clients); use the async equivalent or `spawn_blocking`.
- Holding a `Mutex`/`RwLock` guard across `.await` — deadlocks with `std::sync::Mutex` and makes the future non-`Send`. Drop the guard first, or use `tokio::sync::Mutex` deliberately.
- Unbounded channels and unbounded `tokio::spawn` loops with no backpressure or limit; spawned tasks whose `JoinHandle` and errors are never observed.
- `let _ = fallible_call();` silently ignoring a `Result`; at least log or comment why it's safe.
- `.clone()` used to silence the borrow checker on hot paths (large `Vec`/`String`/structs in loops); consider borrowing, `Arc`, or restructuring.
- `Rc<RefCell<…>>` cycles (parent ↔ child) that leak; use `Weak` for back-references. `RefCell` borrow panics at runtime.
- SQL built with `format!` instead of bound parameters (`sqlx::query!`, `$1`/`?` placeholders).
- Untrusted input deserialised with serde without limits (request body size, collection length, nesting depth); `#[serde(deny_unknown_fields)]` where strictness matters.
- `Cargo.toml`: wildcard versions (`*`), git dependencies without `rev`/`tag`, and `Cargo.lock` not committed for binaries.

## Tooling hints
- `cargo clippy --all-targets` and `cargo fmt --check` (check modes only — never `cargo fmt` or `clippy --fix`), `cargo test`, `cargo audit` if installed.
