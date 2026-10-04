# Human-friendly UX — isolated presentation phase

Base: fc5b5b5fc1763adcc1d11ae0022dfde545e56051, physically validated 0.2.8 (12).
Branch: human-friendly-ux. Draft PR #8 targets physical-v6-remediation, not main.

## Initial copy audit

P0: discovery actions “Bloquear/Lock” do not explain preservation; machine-like
unknown concepts require a safe fallback, without hiding explicit technical literals.
P1: “idempotencia”, “persistencia”, “arquitectura de información”, “Alto valor”;
provenance and perspective dominate the ordinary card. Action effects lack hints.
P1: generic application strategy titles expose specialist vocabulary. Provider
names and Settings “backend” are developer-facing rather than benefit-facing.
P1: Spanish app-shell tabs/settings for an English request; corrected with a
session-only presentation language following the explicit request (no new storage).
P0: English task titles could expose an underscore; corrected in the existing
display-only task formatter, without changing routing or compiler content.
P2 deferred: cosmetic email punctuation; History title truncation; broader authored
knowledge wording outside this bounded UX phase. No global UI rewrite.

## Architecture decision

A single immutable DiscoveryPresentation, used only by the shared ResultView row
(therefore Create and History), will project localized title, explanation, priority,
state, actions and optional provenance/perspective. It never feeds the compiler.
Resource-identity metadata covers known specialist concepts and application
strategy candidates; unknown natural-language recommendations retain their source
wording and reason. No runtime AI rewrite, guessing domain objects or mutable
semantic metadata. Explicit technical literals remain in source details.

Normal level: title, one-sentence meaning, priority/state, actions.
Details: reason, source, perspective and unchanged technical wording when different.
Button labels map directly to INCLUDED / LOCKED / EXCLUDED. Existing handlers,
authority and persistence remain untouched. Priority maps are display-only.

Onboarding: a short persistent section subtitle explains the purpose. No new
onboarding persistence or repeated dismissible modal is needed in this iteration.

## Validation policy

Tests were authored before production changes. UI RED must execute successfully;
a compiler or test-harness failure is not semantic RED. Baseline invariant tests
may already pass. Additional projection contracts follow implementation and are
not claimed as pre-production RED. Holdouts use different domains/technical
literals from the card design examples. Existing tests remain unchanged.

Physical V6 build 12 PASS is recorded separately in PHYSICAL-V6-BUILD12-PASS.md.
Any new UX IPA is AWAITING IPHONE UX RETEST, never physical UX PASS from CI.

## Pre-production CI evidence

Commit b0e7d6e03bbc27a8b84a1e77a279115eacc52c62, run 37189861405:
compiled and executed. Initial four invariant unit contracts PASS; 142 unit tests
with one physical-only skip and zero failures. New English and Spanish UI tests
failed at the missing Add / Añadir action respectively: 2 confirmed UX REDs.
Five existing UI tests PASS. Device artifact correctly not built after RED.
Additional projection and interaction tests are supplemental, not pre-fix REDs.

The English shell and task-title audit fixes are display-only. The audit also
compares History persistence handlers and the physical tab-bar clearance reader
byte-for-byte with the baseline. No semantic engine or authority changes.

Final review adds an authority-aware source-description contract: confirmed or
removed Apple-origin findings do not ask for confirmation again. Historical
accept/keep provenance is explained as historical when the current state excludes
the finding. The underlying provenance array, priority and transitions remain
unchanged. The provider badge can wrap at larger text sizes. The simulator job
timeout allows the full large + compact accessibility suites; no test is removed.
