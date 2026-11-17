# Go pitfalls

- Errors ignored (`_ =` or unchecked returns), or wrapped without context; `%w` vs `%v` when callers need `errors.Is/As`.
- `defer` inside loops (resources held until function returns); `defer rows.Close()` missing; `defer` before checking the error from the open call.
- Goroutine leaks: goroutines blocked on channels nobody reads; missing `context` cancellation; no way to stop background workers.
- Data races: maps/slices shared across goroutines without a mutex; loop variable capture (pre-Go 1.22 semantics — check `go.mod` version).
- `context.Context` not passed through, or stored in structs; `context.Background()` inside request handlers.
- nil maps written to; nil pointer dereference on optional struct fields; typed nil interfaces (`error` holding a nil pointer is non-nil).
- Slices aliasing the same backing array after `append`.
- HTTP: response bodies not closed; clients without timeouts (`http.DefaultClient` has none); unbounded request body reads.
- SQL built with `fmt.Sprintf` instead of placeholders.
- Exported identifiers without doc comments in libraries; package names that stutter.

## Tooling hints
- `go vet ./...`, `gofmt -l .` (lists, doesn't write), `golangci-lint run` if configured, `go test ./...` (add `-race` if the project uses it in CI).
