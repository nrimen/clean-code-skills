#!/usr/bin/env bash
# Read-only: prints review scope (branch, base, changed files) and the
# lint/type/test commands this repo appears to define. Modifies nothing.
# Usage: run from anywhere inside the repo. Optional: BASE=<branch> to override.

set -u

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository"; exit 1
fi

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT" || exit 1

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
DETACHED=""
if [ "$BRANCH" = "HEAD" ]; then
  BRANCH="detached-$(git rev-parse --short HEAD)"
  DETACHED=1
fi
echo "== Repo"
echo "root:    $ROOT"
echo "branch:  $BRANCH"
[ -n "$DETACHED" ] && echo "NOTE: HEAD is detached — no branch name; using '$BRANCH' for the report name."

# --- Base branch detection -------------------------------------------------
detect_base() {
  # 1. explicit override
  if [ -n "${BASE:-}" ]; then echo "$BASE"; return; fi
  # 2. upstream's default branch (origin/HEAD)
  local remote_head
  remote_head=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  if [ -n "$remote_head" ]; then echo "$remote_head"; return; fi
  # 3. common names, remote first then local
  for b in origin/main origin/master origin/develop main master develop; do
    if git rev-parse --verify --quiet "$b" >/dev/null; then echo "$b"; return; fi
  done
}

BASE_REF=$(detect_base)
echo
echo "== Base"
if [ -z "$BASE_REF" ]; then
  echo "base:    UNKNOWN — ask the user which branch this work started from"
  MERGE_BASE=""
else
  MERGE_BASE=$(git merge-base HEAD "$BASE_REF" 2>/dev/null)
  echo "base:    $BASE_REF"
  echo "merge-base: ${MERGE_BASE:-none}"
  BASE_SHORT=${BASE_REF#origin/}
  if [ "$BRANCH" = "$BASE_SHORT" ]; then
    echo "NOTE: current branch IS the base branch — only uncommitted changes can be diffed."
  fi
  if [ -n "$MERGE_BASE" ]; then
    echo
    echo "== Commits on this branch (since merge-base)"
    git log --oneline "$MERGE_BASE"..HEAD | head -50
    echo
    echo "== Changed files (A added, M modified, D deleted, R renamed)"
    git diff --name-status "$MERGE_BASE" | head -80
    git diff --shortstat "$MERGE_BASE"
  fi
fi

echo
echo "== Working tree status"
git status --porcelain | head -60
UNTRACKED=$(git ls-files --others --exclude-standard | head -60)
if [ -n "$UNTRACKED" ]; then
  echo
  echo "== Untracked files (new, not in diff — read in full)"
  echo "$UNTRACKED"
fi

# --- Tooling detection ------------------------------------------------------
echo
echo "== Candidate checks (verify before running; never use fix/write modes)"

if [ -f package.json ]; then
  PM="npm run"
  [ -f pnpm-lock.yaml ] && PM="pnpm"
  [ -f yarn.lock ] && PM="yarn"
  { [ -f bun.lockb ] || [ -f bun.lock ]; } && PM="bun run"
  echo "package.json scripts (runner: $PM):"
  if command -v node >/dev/null 2>&1; then
    node -e 'const s=require("./package.json").scripts||{};for(const[k,v]of Object.entries(s)){if(/lint|type|tsc|test|check|format|prettier|e2e/i.test(k))console.log("  "+k+": "+v)}'
  else
    grep -E '"(lint|test|typecheck|type-check|check|format)[^"]*"\s*:' package.json | sed 's/^/  /'
  fi
  [ -d node_modules ] || echo "  NOTE: node_modules missing — deps not installed; don't install, report as not run."
  ls tsconfig*.json >/dev/null 2>&1 && echo "  tsconfig present → type check: npx tsc --noEmit (if no script)"
fi

MONO=""
[ -f package.json ] && grep -q '"workspaces"' package.json && MONO="$MONO package.json:workspaces"
for f in pnpm-workspace.yaml turbo.json nx.json; do
  [ -f "$f" ] && MONO="$MONO $f"
done
[ -n "$MONO" ] && echo "monorepo:$MONO — scope checks to the changed packages where possible"

for f in pyproject.toml setup.cfg tox.ini ruff.toml .flake8 mypy.ini pytest.ini noxfile.py; do
  [ -f "$f" ] && echo "python config: $f"
done
if [ -f pyproject.toml ]; then
  grep -oE '^\[tool\.(ruff|black|mypy|pytest[^]]*|pyright|isort)' pyproject.toml | sed 's/^/  configured: /'
fi

[ -f go.mod ] && echo "go module: go vet ./... ; gofmt -l . ; go test ./...  ($(grep -m1 '^go ' go.mod))"
ls .golangci.y*ml >/dev/null 2>&1 && echo "  golangci-lint configured"

[ -f pom.xml ] && echo "maven: mvn -q verify (or mvn test)"
ls build.gradle* >/dev/null 2>&1 && echo "gradle: ./gradlew check"
[ -f Cargo.toml ] && echo "rust: cargo clippy ; cargo fmt --check ; cargo test"

if [ -f composer.json ]; then
  echo "php: composer validate"
  [ -x vendor/bin/phpunit ] && echo "  vendor/bin/phpunit"
fi
[ -f Gemfile ] && echo "ruby: bundle exec rubocop ; bundle exec rspec"
for f in ./*.sln ./*.csproj; do
  [ -e "$f" ] && { echo ".NET: dotnet build ; dotnet test"; break; }
done

if [ -f Makefile ]; then
  echo "Makefile targets (relevant):"
  grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1 | grep -Ei 'lint|test|check|vet|type' | sed 's/^/  make /'
fi

[ -f .pre-commit-config.yaml ] && echo "pre-commit configured (may modify files — prefer the underlying tools in check mode)"
ls .github/workflows/*.y*ml >/dev/null 2>&1 && echo "CI workflows in .github/workflows — see what CI runs: $(ls .github/workflows | tr '\n' ' ')"
[ -f .gitlab-ci.yml ] && echo "CI: .gitlab-ci.yml"
for f in CLAUDE.md CONTRIBUTING.md .editorconfig; do [ -f "$f" ] && echo "project guidance: $f"; done

exit 0
