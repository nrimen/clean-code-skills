# Python pitfalls

## Language
- Mutable default arguments (`def f(items=[])`).
- Bare `except:` or `except Exception:` swallowing errors; `except ... : pass`.
- Late-binding closures in loops (lambdas capturing the loop variable).
- `is` used for value comparison (`x is 1`, `s is "a"`); `is None` is correct.
- Integer vs float division; float equality; `round()` banker's rounding.
- Naive `datetime.now()` vs timezone-aware datetimes mixed; `utcnow()` returning naive objects.
- Iterating over a dict/list while modifying it.
- Shadowing builtins (`list`, `id`, `type`, `input`).
- Resources opened without `with` (files, locks, connections).

## Typing
- Missing type hints on public functions in a typed codebase; `Any` and `# type: ignore` without reason.
- `Optional` values used without a None check.

## Security
- `subprocess` with `shell=True` and interpolated input; `os.system`.
- f-strings or `%` formatting in SQL instead of parameters.
- `pickle`/`yaml.load` (non-safe loader)/`eval`/`exec` on untrusted data.
- `requests` with `verify=False`, or without `timeout`.
- `random` used for tokens instead of `secrets`.

## Frameworks
- Django: queries in loops (use `select_related`/`prefetch_related`), raw SQL, missing `@login_required`/permission checks, migrations that lock big tables.
- FastAPI/Flask: request data not validated, sync blocking calls inside `async def` endpoints, debug mode enabled.
- Async: blocking I/O in coroutines; forgotten `await`; tasks created without keeping a reference.

## Tooling hints
- Look in `pyproject.toml`, `setup.cfg`, `tox.ini`, `Makefile`, `noxfile.py`. Use `ruff check` (no `--fix`), `black --check`, `mypy`/`pyright`, `pytest` (scope with `-k` or paths if slow).
