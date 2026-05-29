---
description: Enable fork mode — set CLAUDE_CODE_FORK_SUBAGENT=1 in user settings (the one thing the plugin can't do for itself) and verify the setup.
---

Fork mode needs `CLAUDE_CODE_FORK_SUBAGENT=1` in `~/.claude/settings.json`, read at Claude Code startup. A plugin cannot set this itself, so run the bundled installer for the user's platform.

Steps:

1. Detect the OS and run the env-only installer (skills come from the plugin, so don't copy them):
   - macOS / Linux / WSL / Git Bash → `bash "${CLAUDE_PLUGIN_ROOT}/install.sh" --env-only`
   - Windows (PowerShell 7+) → `pwsh -File "${CLAUDE_PLUGIN_ROOT}/install.ps1" -EnvOnly`

   The installer is idempotent: it backs up `settings.json` and merges `CLAUDE_CODE_FORK_SUBAGENT=1` into the `env` block. `--env-only`/`-EnvOnly` skips copying skills — the plugin already provides them, so copying again would double-register them.

2. Verify (pass the plugin root so the skill check finds plugin-provided skills):
   - macOS / Linux / WSL / Git Bash → `CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}" bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh"`
   - Windows → `$env:CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"; pwsh -File "${CLAUDE_PLUGIN_ROOT}/scripts/verify.ps1"`

3. Tell the user to **restart Claude Code** — the variable is read only at startup, so the running session won't pick it up. After restart, fork dispatch works.
