# Contributing

Thanks for your interest in improving these skills! Contributions of all sizes are welcome.

## Ways to contribute

- **Report a problem**: open an issue describing the skill, the prompt or codebase you used it on, what you expected, and what you got.
- **Suggest an improvement**: open an issue or discussion with your idea before starting a large change.
- **Submit a fix or a new skill**: open a pull request.

## Pull request guidelines

1. Fork the repo and create a branch (`fix/solid-audit-report-format`, `feat/new-skill-name`).
2. Keep one skill per folder, with a `SKILL.md` at its root.
3. Use kebab-case for folder names. Use the `-first` suffix for skills that guide code generation and `-audit` for skills that produce a report.
4. Make sure the `description` in the `SKILL.md` frontmatter clearly says **when** the skill should be used, since it decides when the skill is triggered.
5. If you change a skill's output, include a short before/after example in the PR description.
6. Keep changes focused. Unrelated edits belong in a separate PR.

## Style

- Write instructions in clear, direct language.
- Prefer concrete examples over abstract rules.
- Avoid overlapping responsibilities between skills; if two skills touch the same principle, say which one to use and when.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
