# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CI smoke test workflow (`install-test.yml`) covering `install.sh` on `ubuntu-latest` + `macos-latest` and `install.ps1` on `windows-latest`, with stubbed `claude` binary returning a known version.
- `CONTRIBUTING.md`, `SECURITY.md`, GitHub issue forms (`bug_report.yml`, `feature_request.yml`), and a pull request template under `.github/`.
- `install.sh` and `install.ps1` now accept `--dry-run` / `-n`, `--check`, `--uninstall` (with `--yes` / `-Yes` to skip confirmation), and `--help`. Re-running without flags preserves the original idempotent behavior.

### Changed
- (Pending from Phase 1 fork) README Caveats section, Background release-date, Validation table provenance, and concurrency-cap citation will be reconciled by the parent and noted here once merged.

### Fixed
- (Pending from Phase 1 fork) Duplicate content in `skills/fork-fan-out/SKILL.md` will be removed before v1.0.0.

## [1.0.0] — TBD

Initial tagged release. See `docs/RELEASE-v1.0.0.md` (produced by the Phase 1 fork) for the full launch notes once reconciliation completes.

[Unreleased]: https://github.com/Kirchlive/Enable-Claude-Fork-Agent/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Kirchlive/Enable-Claude-Fork-Agent/releases/tag/v1.0.0
