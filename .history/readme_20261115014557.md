# clean-code-skills

Four agent skills that help engineers, and the AI assistants coding with them, write clean code and check it afterwards.

- **Write it right:** `principles-first` and `solid-first` guide the assistant *while* it writes or changes code.
- **Check it:** `principles-audit` and `solid-audit` read your code *afterwards* and write a report with `file:line` evidence and concrete fixes.

The audits are read-only for your source code: they never edit, commit or push. The only file they write is the report.

## What's inside

| Skill | Type | What it does |
|---|---|---|
| [`principles-first`](principles-first/SKILL.md) | Guide | Applies DRY, KISS, YAGNI, Single Responsibility and Separation of Concerns before and during any coding work |
| [`principles-audit`](principles-audit/SKILL.md) | Audit | Reports, for each of those 5 principles, whether the code respects it (✅ ⚠️ ❌ ➖) with evidence and fixes |
| [`solid-first`](solid-first/SKILL.md) | Guide | Applies the 5 SOLID principles when designing or changing structure: modules, interfaces, integrations, new variants |
| [`solid-audit`](solid-audit/SKILL.md) | Audit | Reports, for each SOLID principle, whether the design respects it, including "over-applied" abstractions |

## Which skill should I use?

| I want to… | Use |
|---|---|
| Have the assistant write simple, non-duplicated, well-layered code | `principles-first` |
| Have the assistant design a new module, service or integration cleanly | `solid-first` (plus `principles-first`) |
| Know if my code is DRY, simple, not over-engineered, well separated | `principles-audit` |
| Know if my design is extensible, testable and loosely coupled | `solid-audit` |

A typical flow: the `-first` skills shape the code as it is written, and the `-audit` skills check it afterwards.

## The principles

**Principles skills** (`principles-first`, `principles-audit`)

| Principle | In one line |
|---|---|
| DRY | Don't repeat knowledge or logic |
| KISS | Keep it simple |
| YAGNI | Build only what the request needs |
| SRP | One reason to change per unit |
| SoC | Keep UI, business logic, data and config in separate layers |

**SOLID skills** (`solid-first`, `solid-audit`)

| Principle | In one line |
|---|---|
| S: Single Responsibility | One reason to change per module |
| O: Open/Closed | New variants mean adding code, not editing many places |
| L: Liskov Substitution | Every implementation honors its contract |
| I: Interface Segregation | Clients depend only on what they use |
| D: Dependency Inversion | Business logic depends on abstractions; infrastructure plugs in from outside |

Both families stay pragmatic: they include rules against over-applying the principles (no interface for a single implementation, no strategy pattern for one case), and they adapt to the language and paradigm in use.

## Install and use (Claude Code)

Clone the repo once, then install each skill with one line from your project root. Each skill is self-contained, so install only the ones you need.

```bash
git clone <repo-url> clean-code-skills
```

| Skill | Install (one line) | How to use it |
|---|---|---|
| `principles-first` | `mkdir -p .claude/skills && cp -r clean-code-skills/principles-first .claude/skills/` | Loads on its own before the assistant writes code. Just ask for the change: *"Add a reset-password endpoint."* |
| `principles-audit` | `mkdir -p .claude/skills && cp -r clean-code-skills/principles-audit .claude/skills/` | Ask for it: *"Audit this branch against DRY, KISS and YAGNI."* |
| `solid-first` | `mkdir -p .claude/skills && cp -r clean-code-skills/solid-first .claude/skills/` | Loads on its own when the assistant designs or restructures code: *"Add Stripe as a new payment provider."* |
| `solid-audit` | `mkdir -p .claude/skills && cp -r clean-code-skills/solid-audit .claude/skills/` | Ask for it: *"Is my code SOLID? Check the services folder."* |

To make a skill available in all your projects instead, use `~/.claude/skills/` in place of `.claude/skills/`. You can also call a skill by name, for example `/solid-audit`, instead of describing the task.

The audits run on the scope you name. If you don't name one, they use the current branch compared with its base.

### Other tools

Any assistant that supports the `SKILL.md` format works the same way: copy the skill folders into its skills directory.

## Reports

| Skill | Report written to |
|---|---|
| `principles-audit` | `principles-audits/<scope>-<date>.md` |
| `solid-audit` | `solid-audits/<scope>-<date>.md` |

Reports go to the repo root unless your project already has a reports folder. If you don't want them committed, add those folders to `.gitignore`.

**How to read them**

- Each audit gives a verdict per principle: ✅ respected, ⚠️ partially, ❌ not respected, ➖ not applicable.
- A finding marked `[blocking]` causes wrong behavior today, forces the next change to be made in several places, or makes the code untestable without editing it.
- `solid-audit` also flags `[over-applied]` findings: abstractions that add complexity without a real need.
- Every finding points to a `file:line` and explains why it matters. No evidence, no finding.
- Each report ends with the top 3 fixes to make first.

## Good to know

- **Single Responsibility appears in both families.** If you run `principles-audit` and `solid-audit` on the same code, expect some overlap on SRP.
- **Some logic is duplicated between skills on purpose** (scope detection, verdict definitions). Each skill must work on its own when copied alone, so they don't share files.

## Repository layout

```text
clean-code-skills/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── principles-first/
│   └── SKILL.md
├── principles-audit/
│   └── SKILL.md
├── solid-first/
│   └── SKILL.md
└── solid-audit/
    └── SKILL.md
```

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)