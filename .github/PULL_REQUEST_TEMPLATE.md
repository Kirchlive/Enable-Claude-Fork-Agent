## Summary

<!-- One or two sentences. What changes and why. -->

## Linked issue

<!-- Closes #123 / Refs #456. Leave blank if there is none and explain in Summary. -->

## Testing performed

<!--
Required. List what you did to verify the change:
  - `bash install.sh --dry-run` output snippet
  - `bash install.sh --check` before/after
  - CI run link (will appear automatically once Actions complete)
"It builds on my laptop" is not testing.
-->

## Skill TDD evidence

<!--
Required IF this PR adds or materially changes a skill under skills/.
Paste the RED-phase transcript: the pressure scenario you ran against a subagent
*without* the skill, the verbatim failures observed, and (briefly) why the new
skill content addresses them. See CONTRIBUTING.md.

If this PR does not touch skills/, write "N/A".
-->

## Anthropic docs reference

<!--
Required IF this PR touches anything that claims to describe Claude Code behavior.
Link the relevant code.claude.com or anthropics/claude-code page.
If this is a docs-only correction, link the source you are correcting *against*.
-->

## Checklist

- [ ] Installer scripts remain dependency-light (no new runtime requirements)
- [ ] Re-running `install.sh` / `install.ps1` without flags still converges to the same end state
- [ ] If a skill was added or edited, the RED-phase transcript is included above
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
- [ ] Self-review of the diff complete
