# IDEVERO 0.2.9 release consolidation — Git audit

Audit performed 2026-10-04 before creating the consolidated branch. Local tree was clean; origin refs were fetched and compared with live GitHub PR metadata.

| Ref / PR | Exact commit | State / target |
|---|---|---|
| main | 67b5347a9bf3cb02e65bdf0617ab42b8ed3b6ef6 | Frozen |
| release/0.2.8-rc / #6 | b4d577dd3e703e83c5236194184ca6f4ba8954af | OPEN / DRAFT / NOT MERGED → main |
| physical-v6-remediation / #7 | fc5b5b5fc1763adcc1d11ae0022dfde545e56051 | OPEN / DRAFT / NOT MERGED → release/0.2.8-rc |
| human-friendly-ux / #8 | 61eb2a8490b1bcfcbedbaadfda18b4746035326f | OPEN / DRAFT / NOT MERGED → physical-v6-remediation |

## Cumulative coverage

The actual graph is linear across these four refs. `git merge-base --is-ancestor` succeeds for main, #6 head and #7 head against the physically validated #8 head. `git rev-list <earlier-head> --not <build14>` returns zero commits for each earlier ref. There are therefore no earlier-branch-only commits to cherry-pick or merge. No files were deleted from #6 head to build 14. Later deliberate fixes supersede earlier content through preserved ancestry rather than rewriting or squashing history.

The cumulative diff from frozen main is 57 files, 5707 insertions and 428 deletions. Those are historical implementation/test/release changes already represented by physically validated build 14, not newly authorized consolidation changes. They cover structural/semantic/release gates, Physical V6 remediation, human-friendly presentation, localized metadata and release tooling. Snapshot branches are local recoverable duplicates of connector-created commits, not source branches requiring inclusion.

Build 13 physically tested fc4af6faba6b1dfa8997e4f6e36cbbd9ecd689a1 → build 14 changes exactly three production files: DiscoveryDisplayMetadata.json, DiscoveryPresentation.swift and ResultView.swift. Existing audits prove frozen engine/models/compiler/providers/persistence and unchanged semantic action callbacks; original 23 display metadata entries remain intact. The last build-14 CI is SUCCESS, with 159 unit PASS, one strictly physical skip, 11/11 UI on each device size, and unsigned ARM64/re-signability PASS. No accidental extra production change is demonstrated by this graph/diff/isolation review, and no required earlier commit is absent.

This is an evidence-backed consolidation audit, not a new claim that all possible product defects are absent. The reported floating-tab-bar overlap is recorded as non-blocking, and Foundation Models compilation is not physical runtime validation.

## Consolidated candidate policy

Create release/0.2.9-rc from exact build-14 commit 61eb2a8490b1bcfcbedbaadfda18b4746035326f, preserving its ancestry. Add only Markdown physical/release documentation and workflow release-evidence hygiene. No production, test, Xcode project, tool, version/build, architecture or runtime change is allowed. A new CI gate requires zero diff to build 14 for Idevero, IdeveroTests, IdeveroUITests, Idevero.xcodeproj and Tools.

Keep #6/#7/#8 and their branches untouched. Open one consolidated Draft PR to frozen main for audit/review only. Main must remain unchanged. Do not merge, publish, declare 1.0 or claim the newly packaged artifact was physically installed. A full GREEN run and exact manifest/artifact/hash verification are required before reporting RELEASE CONSOLIDATION: CI VALIDATED. Any gate failure means STOP, with no fixes hidden or automatic release-valid conclusion.
