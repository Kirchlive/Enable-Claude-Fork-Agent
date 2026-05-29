# Security policy

## What the installer touches

The installer's blast radius is intentionally narrow:

| Path | Access | Reason |
|---|---|---|
| `~/.claude/settings.json` | read + write | merge `CLAUDE_CODE_FORK_SUBAGENT=1` into `env` block, preserving every other key |
| `~/.claude/settings.json.pre-fork-backup-<timestamp>` | write | timestamped backup created before any modification |
| `~/.claude/skills/<skill-name>/SKILL.md` | write | install bundled skills |
| `$(which claude) --version` | execute | version gate (≥ 2.1.117) |

Nothing else in `$HOME` is read, written, executed, or transmitted. The installer makes no network calls. The installer never reads files outside `~/.claude/`.

## Backup and restore guarantee

Every invocation of `install.sh` / `install.ps1` that would mutate `settings.json` first copies the existing file to `settings.json.pre-fork-backup-YYYYMMDD-HHMMSS`. If anything goes wrong:

```bash
# bash / zsh
cp ~/.claude/settings.json.pre-fork-backup-<TIMESTAMP> ~/.claude/settings.json

# powershell
Copy-Item "$HOME/.claude/settings.json.pre-fork-backup-<TIMESTAMP>" "$HOME/.claude/settings.json"
```

The most recent backup path is printed at install time and surfaced again by `install.sh --check` / `./install.ps1 -Check`.

The `--uninstall` flag (added in v1.0.0) automates this: it restores the most-recent backup and removes installed skills after confirmation.

## Reporting a vulnerability

If you find a security issue in the installer or skills — for example, a way to escape the `~/.claude/` boundary, a duplicate-key bypass that loses settings, or a code-injection vector via skill content — please **do not** open a public GitHub issue.

Instead, email the repo owner at the address listed in the GitHub profile linked from the `Kirchlive` account. Expect an acknowledgement within seven days. Once a fix is available and shipped, the report will be credited in the relevant CHANGELOG entry unless you ask to remain anonymous.

For non-security bugs, use the public issue tracker.

## Supply chain

This repo ships:
- two installer scripts (`install.sh`, `install.ps1`) — pure shell / pwsh
- skills under `skills/*/SKILL.md` — plain Markdown
- documentation under `README.md` and `docs/`

No vendored binaries, no compiled artifacts, no package-manager manifests. Audit is a `git diff` away.
