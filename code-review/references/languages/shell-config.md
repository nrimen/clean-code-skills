# Shell, Docker, config & infrastructure

## Shell scripts
- Missing `set -euo pipefail` (or equivalent handling) in scripts where failures should stop execution.
- Unquoted variables (`rm -rf $DIR/*` with an empty `DIR`); word splitting on filenames with spaces.
- `cd` without checking success; relative paths that depend on the caller's working directory.
- Parsing `ls` output; `eval` on input; `curl | sh`.
- Temp files in predictable paths instead of `mktemp`; no cleanup `trap`.
- Tooling: `shellcheck` if available.

## Dockerfile
- Base images unpinned (`latest`); running as root; secrets in `ENV`/`ARG` or copied into layers.
- `COPY . .` before dependency install (cache busting) and without a `.dockerignore`.
- `apt-get install` without `--no-install-recommends` and cleanup; missing `HEALTHCHECK` where orchestration relies on it.

## YAML / JSON / TOML / app config
- Secrets or credentials in plain config; real values in example files.
- Environment-specific values (hosts, ports, debug flags) hard-coded in shared config.
- YAML gotchas: `on`/`yes`/`no` parsed as booleans, leading-zero numbers, unquoted version strings (`3.10` → `3.1`), indentation errors changing structure.

## CI pipelines (GitHub Actions, GitLab CI…)
- Third-party actions not pinned to a commit SHA; `pull_request_target` with checkout of PR code; secrets exposed to forks; untrusted input (`${{ github.event.* }}`) interpolated into `run:` scripts.
- Overly broad `permissions`.

## Reverse proxies / load balancers (HAProxy, nginx…)
- Timeouts missing or inconsistent (client/server/connect); no limits on body size or connection counts.
- Health checks absent or checking the wrong endpoint.
- TLS: old protocols/ciphers enabled; missing HSTS where expected; certificate paths/permissions.
- Headers: `X-Forwarded-*` trusted from clients instead of set by the proxy; missing security headers if the proxy owns them.
- ACL ordering mistakes so a broader rule matches first; admin/stats endpoints or management APIs exposed publicly or without auth.
- Validate syntax when the tool allows it without side effects (`haproxy -c -f <file>`, `nginx -t` with a test config).

## Infrastructure as code (Terraform, Helm, k8s manifests)
- Public buckets/security groups open to `0.0.0.0/0`; missing encryption; wildcard IAM permissions.
- Containers without resource requests/limits, running privileged, or with `hostPath`.
- State or `.tfvars` with secrets committed. Tooling: `terraform validate`, `terraform fmt -check`, `helm lint`.
